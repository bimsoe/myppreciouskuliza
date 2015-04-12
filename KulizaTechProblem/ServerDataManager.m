//
//  ServerDataManager.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ServerDataManager.h"
#import "ServerDataParser.h"
#import "PlistManager.h"

#define MAX_PARALLEL_REQUEST  5

@interface ServerDataManager () <NSURLSessionDataDelegate>
{
  CompletionBlockVoid fetchCompletionBlock;
}
@property (nonatomic, strong) NSURLSession *serverSession;
@property (nonatomic, strong) NSURLSession *imageDownloadSession;
@property (nonatomic, strong) NSOperationQueue *fetchQueue;
@property (nonatomic, strong) NSOperationQueue *imageQueue;
@property (nonatomic, strong) NSMutableArray *currentDataTasks; /**< Array of @a ProductCategory that are being requested right now */
@property (nonatomic, strong) NSMutableArray *currentImageDownloads ; /**< Array of @b ProductData.productId whose image is  being downloaded right now */
@end



@implementation ServerDataManager
+ (instancetype)sharedManager
{
  static ServerDataManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
    [self initBasicStuff];
  }
  return self;
}


- (void)initBasicStuff
{
  _fetchQueue = [[NSOperationQueue alloc] init];
  [_fetchQueue setMaxConcurrentOperationCount:MAX_PARALLEL_REQUEST];
  _currentDataTasks = [NSMutableArray arrayWithCapacity:5];//say
  _currentImageDownloads = [NSMutableArray arrayWithCapacity:5];//say
  _serverSession = [self createURLSessionWithDelegateQueue:self.fetchQueue];
  _imageDownloadSession = [self createURLSessionWithDelegateQueue:self.imageQueue];
  fetchCompletionBlock = nil;
  
//initialized in plist
//https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83
//  386&q[product_taxons_id_eq]=151
//https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=76
//https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=95
//https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=202
//https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=69
  
}


- (NSURLSession *)createURLSessionWithDelegateQueue:(NSOperationQueue *)queue
{
  
  NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
  [sessionConfiguration setHTTPMaximumConnectionsPerHost:MAX_PARALLEL_REQUEST];
  NSURLSession *sharedSession = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                              delegate:self
                                                         delegateQueue:queue];
  return sharedSession;
}


- (NSURLRequest *)fetchRequestForProductCategory:(ProductCategory)category
{
  NSURL *urlForCategory = [[PlistManager sharedManager] fetchAPIForProductCategory:category];
  if (urlForCategory == nil) {
    return nil;
  }
  
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:urlForCategory];
  PS_LOG(@"Url (%d) : %@", category, urlForCategory);
  return urlRequest;
}


- (void)fetchProductsForAllCategories:(id<ServerDataReceiver>)receiver completionBlock:(CompletionBlockVoid)completion
{
  self.serverDataReceiver = receiver;
  for (short i = ProductCategory1; i <= ProductCategoryCount; i++) {
    [self fetchProductsForCategory:i receiver:nil];
  }
  fetchCompletionBlock = completion;
}

- (void)fetchProductsForCategory:(ProductCategory)category receiver:(id<ServerDataReceiver>)receiver
{
  //check if already downloading
  if ([self isFetchingProductsForCategory:category]) {
    PS_LOG(@"Already Fetching");
    return;
  }
  
  NSURLRequest *urlRequest = [self fetchRequestForProductCategory:category];
  if (urlRequest == nil) {
    //no can do
    return;
  }
  
  if(self.serverDataReceiver == nil) {
    _serverDataReceiver = receiver;
  }
  
  NSURLSessionDataTask *fetchDataTask =
  [self.serverSession dataTaskWithRequest:urlRequest
                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          //parse 'em
                          NSArray *products = [[ServerDataParser sharedManager] productsDataFromServerJSON:data];
                          [self notifyReceiverWithDataArray:products imageLocation:nil error:error forId:category];
                        }];
  [fetchDataTask resume];
  [fetchDataTask setTaskDescription:INT2STR(category)];
  //add to current downloads
  [self.currentDataTasks addObject:@(category)];
}


- (BOOL)isFetchingProductsForCategory:(ProductCategory)category
{
  return ([self.currentDataTasks indexOfObject:@(category)] != NSNotFound);
}

- (BOOL)isDownloadingImageForProduct:(NSInteger)productId
{
  return ([self.currentDataTasks indexOfObject:@(productId)] != NSNotFound);
}


- (void)downloadImageForProduct:(ProductData *)product
{
  if (product.productImageURL == nil) {
    //no can do
    return;
  }
  

  
  NSURLSessionDownloadTask *imageDownloadTask =
  [self.imageDownloadSession downloadTaskWithURL:product.productImageURL
                               completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                 NSString *imagePath = nil;
                                 if (error) {
                                   PS_LOG(@"Some Error Occurred While Downloading image for product : %@; %@", product.                              productName, error);
                                 } else {
                                   //image downloaded
                                   //write to file
                                   imagePath = [[PlistManager sharedManager] writeImageData:[NSData dataWithContentsOfURL:location] forProduct:product.productId];

                                 }
                                 [self notifyReceiverWithDataArray:nil
                                                     imageLocation:imagePath
                                                             error:error
                                                             forId:product.productId];
                               }];
   
  [imageDownloadTask resume];
  [imageDownloadTask setTaskDescription:INT2STR(product.productId)];
  //add to current downloads
  [self.currentDataTasks addObject:@(product.productId)];

}


- (void)notifyReceiverWithDataArray:(NSArray *)dataArray imageLocation:(NSString *)location error:(NSError *)error forId:(NSInteger)d_id
{
  [[NSOperationQueue mainQueue] addOperationWithBlock:^{
      if (error) {
        //data task failed
        [self.serverDataReceiver errorOccured:error whileFetchingProductsForCategory:d_id];
        [self.currentDataTasks removeObject:@(d_id)];
      } else if (location == nil) {
        //must be a data task
        [self.serverDataReceiver doneFetchingProducts:dataArray forCategory:d_id];
        [self.currentDataTasks removeObject:@(d_id)];
      } else {
        //image downloaded
        [self.currentImageDownloads removeObject:@(d_id)];
        [self.serverDataReceiver imageDownloadedAtLocation:location forProduct:d_id];
      }
    
    if (self.currentDataTasks.count == 0 && fetchCompletionBlock) {
      fetchCompletionBlock();
      fetchCompletionBlock = nil;
    }
    PS_LOG(@"Receiver Notified : dataArray %i: location %@: error %@: d_id %i", (int)dataArray.count, location.absoluteString, error.localizedDescription, (int)d_id);
    }];
}

#pragma mark - NSURLSessionDataDelegate



@end
