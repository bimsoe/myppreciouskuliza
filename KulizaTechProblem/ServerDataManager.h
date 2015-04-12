//
//  ServerDataManager.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@protocol ServerDataReceiver
@required
///Sends Array of @a ProductData objects
- (void)doneFetchingProducts:(NSArray *)products forCategory:(ProductCategory)category;// moreAvialable:(BOOL);
- (void)errorOccured:(NSError *)error whileFetchingProductsForCategory:(ProductCategory)category;
- (void)imageDownloadedAtLocation:(NSString *)image_path forProduct:(NSInteger)productId;
@end



@class ProductData;
@interface ServerDataManager : NSObject
@property (nonatomic, weak) id<ServerDataReceiver> serverDataReceiver;/**< Right now kept just one; otherwise we can have a dictionary with @{category:array of receivers} pair */
+ (instancetype)sharedManager;
- (void)fetchProductsForAllCategories:(id<ServerDataReceiver>)receiver completionBlock:(CompletionBlockVoid)completion;
- (void)fetchProductsForCategory:(ProductCategory)category receiver:(id<ServerDataReceiver>)receiver;
- (BOOL)isFetchingProductsForCategory:(ProductCategory)category;
- (void)downloadImageForProduct:(ProductData *)product;
@end
