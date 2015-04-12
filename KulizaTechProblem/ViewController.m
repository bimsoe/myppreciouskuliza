//
//  ViewController.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ViewController.h"
#import "ProductView.h"
#import "TopView.h"
#import "ServerDataManager.h"
#import "PlistManager.h"
#import "ErrorViewController.h"

NSString *ProductCollectionHeaderIdentifier = @"product_collection_header_identifier";

#define GET_PRODUCTS_AT_SECTION(section) [self productsInCategory:[self categoryForSection:section]]
#define GET_PRODUCT_AT_INDEXPATH(indexPath) [self productAtIndexPath:indexPath]
#define KEY_FOR_CATEGORY(category)  INT2STR(category)
#define ZEROTH_INDEXPATH(indexPath) [NSIndexPath indexPathForItem:0 inSection:indexPath.section]
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ProductDatasource, ProductDelegate, UICollectionViewDelegateFlowLayout, UIContentContainer, ServerDataReceiver>
{
  TopView *headerTopView;
  UIRefreshControl *refreshControl;
  __weak ErrorViewController *errorVC;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *fetchLoadingIndicator;
@property (nonatomic, strong) NSMutableDictionary *productsDictionary; /**< Contains {category:[array of product]} pair} */
@property (nonatomic, strong) NSMutableDictionary *currentlyShownIndexPaths; /**< Contains {category:itemIndexPath pair; Each item refers to the index of Product in its products array */
@property (nonatomic, strong) NSMutableArray *categoryToSectionMapping;/**< Each index represents a section and object there represent the category */
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _productsDictionary = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
  _currentlyShownIndexPaths = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
  _categoryToSectionMapping = [NSMutableArray arrayWithCapacity:ProductCategoryCount];
  for (short i = ProductCategory1; i <= ProductCategoryCount; i++) {
    [_categoryToSectionMapping addObject:@(i)];
  }
  
  [self setUpCollectionView];
  [self addPullToRefresh];
  [self refreshView];
  //for network failure
  [[NSNotificationCenter defaultCenter] addObserverForName:kReachabilityChangedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
    PS_LOG(@"Reachability Changed : %ld", (long)[PlistManager sharedManager].reachability.currentReachabilityStatus);
    if ([PlistManager sharedManager].reachability.currentReachabilityStatus == NotReachable) {
      //show error message
      [self showErrorViewController];
    } else {
      [self refreshView];
    }
  }];
  
  _pageHeadingText = @"DINING TABLES & SETS";
  
}

- (void)setUpCollectionView
{
  //register classes/nib
  [self.productsCollectionView registerClass:[ProductViewCell class] forCellWithReuseIdentifier:ProductCellIdentifier];
  [self.productsCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:ProductCollectionHeaderIdentifier];
  [self.productsCollectionView setDataSource:self];
  [self.productsCollectionView setDelegate:self];
  //keep it bouncy
  [self.productsCollectionView setAlwaysBounceVertical:YES];
  
  [self.productsCollectionView setCollectionViewLayout:[self getFlowFayoutForEntityCollectionView]];

}

- (UICollectionViewFlowLayout *)getFlowFayoutForEntityCollectionView
{
  UICollectionViewFlowLayout *collectionFlowLayout;
  //set up some default flow layout
  collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
  [collectionFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
  CGSize screenSize = [ViewController screenSize];
  float width = MIN(screenSize.width, screenSize.height);
  CGSize itemSize = CGSizeMake(width, width);
  [collectionFlowLayout setItemSize:itemSize];
  [collectionFlowLayout setMinimumInteritemSpacing:5.0f];
  [collectionFlowLayout setMinimumLineSpacing:0.0f];
  [collectionFlowLayout setSectionInset:UIEdgeInsetsZero];// UIEdgeInsetsMake(0, 5.0f, 0, 50f)];
//  [collectionFlowLayout setHeaderReferenceSize:CGSizeMake(0, 30.0f)];
  return collectionFlowLayout;
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  if ([PlistManager sharedManager].reachability.currentReachabilityStatus == NotReachable && self.productsDictionary.allKeys.count == 0) {
    [self showErrorViewController];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (void)addPullToRefresh
{
  refreshControl= [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, -10, 200, 50)];
  refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
  [refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
  [self.productsCollectionView addSubview:refreshControl];
}

- (void)refreshView
{
  [[ServerDataManager sharedManager] fetchProductsForAllCategories:self completionBlock:^{
    //done fetching
    if (self.productsDictionary.allKeys.count == 0) {
      [self showErrorViewController];
    }
  }];
}


- (ProductData *)productDataWithID:(NSInteger)pId inCategory:(ProductCategory)category
{
  __block ProductData *pData = nil;
  if (category == ProductCategoryInvalid) {
    //go though all categories in productsDictionary
    [self.productsDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSArray *products, BOOL *stop) {
      pData = [self productDataWithID:pId inProducts:products];
      if (pData) {
        *stop = YES;
      }
    }];
  } else {
    pData = [self productDataWithID:pId inProducts:[self productsInCategory:category]];
  }
  
  return pData;
}


- (ProductData *)productDataWithID:(NSInteger)pId inProducts:(NSArray *)products
{
  NSUInteger index = [products indexOfObjectPassingTest:^BOOL(ProductData *productData, NSUInteger idx, BOOL *stop) {
    if (productData.productId == pId) {
      *stop = YES;
      return YES;
    }
    return NO;
  }];
  
  if(index == NSNotFound) {
    return nil;
  }
  
  return products[index];
}

- (ProductData *)productAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *products = [self productsInCategory:[self categoryForSection:indexPath.section]];
  if (products.count > indexPath.item) {
    return products[indexPath.item];
  }
  return nil;
}
                             
#pragma mark -
#pragma mark Orientation Changes
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  CGSize screenSize = [ViewController screenSize];
  CGRect frame = headerTopView.frame;
  frame.size.width = screenSize.width;
  [headerTopView setFrame:frame];
}
#pragma mark UIContentContainer Protocol
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
//  CGRect frame = headerLabel.frame;
//  frame.size.width = size.width;
//  [headerLabel setFrame:frame];
#if DEBUG
  [self.productsCollectionView.layer setBorderColor:[UIColor redColor].CGColor];
  [self.productsCollectionView.layer setBorderWidth:1.0f];
#endif
}


#pragma mark - Products Fetching
- (NSMutableArray *)productsInCategory:(ProductCategory)category
{
  return self.productsDictionary[KEY_FOR_CATEGORY(category)];
}

///helps in deciding the order in which they are to be displayed
- (ProductCategory)categoryForSection:(NSInteger)section
{
  return [self.categoryToSectionMapping[section] shortValue];
//  return (section + 1);// section has a +1 kinda relation with Product Category
}



- (void)adjustProductDictionaryForCategory:(ProductCategory)category removed:(BOOL)removed
{
  if (removed) {
    [self.categoryToSectionMapping removeObject:@(category)];
  } else {
    //added
    NSUInteger index = [self.categoryToSectionMapping indexOfObjectPassingTest:^BOOL(NSNumber *categoryNum, NSUInteger idx, BOOL *stop) {
      if (categoryNum.shortValue > category) {
        return YES;
        *stop = YES;
      }
      return NO;
    }];
    
    if (index != NSNotFound) {
      [self.categoryToSectionMapping insertObject:@(category) atIndex:index];
    }

    
  }
  
}

#pragma mark - 

#pragma mark UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  int keysCount = (int)self.productsDictionary.allKeys.count;
  PS_LOG(@"numberOfSectionsInCollectionView : %i", keysCount);
  if (keysCount) {
    [self.fetchLoadingIndicator stopAnimating];
  } else {
    [self.fetchLoadingIndicator startAnimating];
  }
  return self.productsDictionary.allKeys.count;
  //I'll be treating each category as one item (as oppose to each category as a separate section) because there is just one product
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 1;
  NSUInteger numberOfProducts = GET_PRODUCTS_AT_SECTION(section).count;
  PS_LOG(@"Number of Products in category %i : %u", [self categoryForSection:section], (uint)numberOfProducts);
  return numberOfProducts;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ProductViewCell *entityView = (ProductViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:ProductCellIdentifier forIndexPath:indexPath];
  [entityView.productView setDataSource:self];
  [entityView.productView setDelegate:self];
  //get index path from currentlyShownIndexPaths
  NSIndexPath *currentIndexPathForCategory = [self.currentlyShownIndexPaths objectForKey:KEY_FOR_CATEGORY([self categoryForSection:indexPath.section])];
  if (currentIndexPathForCategory == nil) {
    //use default
    currentIndexPathForCategory = indexPath;
    [self.currentlyShownIndexPaths setObject:indexPath forKey:KEY_FOR_CATEGORY([self categoryForSection:indexPath.section])];
  }

  [entityView.productView setProductIndexPath:currentIndexPathForCategory];
  [entityView.productView refresh:nil];
  
  return entityView;

}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
  UICollectionReusableView *headerView =
                                    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:ProductCollectionHeaderIdentifier
                                                                              forIndexPath:indexPath];
  static NSInteger HeaderLabelTag = 101;
  if (headerTopView == nil) {
    //add label
    headerTopView = [TopView getTopView];// [[UILabel alloc] initWithFrame: CGRectMake(0, 0, collectionView.frame.size.width, 30.0f)];
    [headerTopView setTag:HeaderLabelTag];//so that we dont add it over and over again
    [headerView addSubview:headerTopView];
    [headerTopView setCenter:headerView.center];
  }
  //text can be updated based on what group are we seeing
  [headerTopView.headerLabel setText:self.pageHeadingText];
  return headerView;
}

#pragma mark UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  PS_LOG(@"Product Selected at Index Path : %@", indexPath);
}

#pragma mark UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
  //only for 1st section
  if (section == 0) {
      return CGSizeMake(0, 30.0f);
  }
  
  //for others nil
  return CGSizeZero;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//  if(GET_PRODUCTS_AT_SECTION(indexPath.section).count == 0) {
//    //for others nil
//    return CGSizeZero;
//  }
//  
//  
//  return ((UICollectionViewFlowLayout *)self.productsCollectionView.collectionViewLayout).itemSize;
//}


#pragma mark - 
#pragma mark - ProductDatasource
- (ProductData *)dataForProductAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *products = GET_PRODUCTS_AT_SECTION(indexPath.section);
  if (products.count > indexPath.item) {
    ProductData *productData = products[indexPath.item];
    if (productData.productImage == nil) {
      productData.productImage = [[PlistManager sharedManager] imageForProduct:productData.productId];
    }
    return productData;
  }
  
  //some issue
  PS_LOG(@"products.count -1 > indexPath.item Failed");
  return nil;
}


- (BOOL)shouldDisplayPreviousProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;
{
  //you can add some additional conditions here;
  return indexPath.item != 0;
}


- (BOOL)shouldDisplayNextProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;
{
  NSUInteger productCount = GET_PRODUCTS_AT_SECTION(indexPath.section).count;
  return indexPath.item < (productCount - 1);
}


#pragma mark - ProductDelegate
- (void)buyButtonPressedForProductAtIndexPath:(NSIndexPath *)indexPath
{
  ProductData *product = GET_PRODUCT_AT_INDEXPATH(indexPath);
  NSString *title = nil;
  NSString *message = nil;
  if (product.inStock) {
    title = @"Added to Cart";
    message = [NSString stringWithFormat:@"%@ was added to cart!!", product.productName];
  } else {
    title = @"Out of Stock";
    message = [NSString stringWithFormat:@"%@ is out of stock. Check back soon", product.productName];
  }
  [self showAlertWithTitle:title message:message];
}

- (void)showAllProductsButtonPressed:(NSIndexPath *)indexPath
{
  //get the category
  //invalidate the collection view and remove all other sections and keep only one that is for category
}


- (void)previousProductButtonPressed:(NSIndexPath *)indexPath
{
  if (indexPath.item == 0) {
    //no can do
    return;
  }
  
  [self refreshProductCellAtIndexPath:indexPath withItem:indexPath.item - 1];
}


- (void)nextProductButtonPressed:(NSIndexPath *)indexPath
{
  NSInteger count = GET_PRODUCTS_AT_SECTION(indexPath.section).count;
  if (indexPath.item == count - 1) {
    //no can do
    return;
  }
  
  [self refreshProductCellAtIndexPath:indexPath withItem:indexPath.item + 1];
}


- (void)refreshProductCellAtIndexPath:(NSIndexPath *)oldIndexPath withItem:(NSInteger)item
{
  NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:item inSection:oldIndexPath.section];
  [self.currentlyShownIndexPaths setObject:newIndexPath forKey:KEY_FOR_CATEGORY([self categoryForSection:oldIndexPath.section])];
  
  //update the indexPath
  ProductViewCell *productCell = (ProductViewCell *)[self.productsCollectionView cellForItemAtIndexPath:ZEROTH_INDEXPATH(oldIndexPath)];
  [productCell.productView setProductIndexPath:newIndexPath];
  NSString *direction = (item > oldIndexPath.item) ? kCATransitionFromRight : kCATransitionFromLeft;
  [productCell.productView refresh:direction];

}


#pragma mark - ServerDataReceiver
- (void)doneFetchingProducts:(NSArray *)products forCategory:(ProductCategory)category
{
  if (products.count == 0) {
    [self.productsDictionary removeObjectForKey:KEY_FOR_CATEGORY(category)];
    [self adjustProductDictionaryForCategory:category removed:YES];
//    [self.productsDictionary setObject:@[] forKey:KEY_FOR_CATEGORY(category)];
    [self.productsCollectionView reloadData];
    return;
  }
  if (![self.categoryToSectionMapping containsObject:@(category)]) {
    [self adjustProductDictionaryForCategory:category removed:NO];
  }
  [self.productsDictionary setObject:products forKey:KEY_FOR_CATEGORY(category)];
  [self.productsCollectionView reloadData];
  for (ProductData *productData in products) {
    if (productData.productImage == nil) {
      [[ServerDataManager sharedManager] downloadImageForProduct:productData];
      //also meanwhile get local copies if available
      productData.productImage = [[PlistManager sharedManager] imageForProduct:productData.productId];
    }
  }
  [refreshControl endRefreshing];
}



- (void)errorOccured:(NSError *)error whileFetchingProductsForCategory:(ProductCategory)category
{
  //some issuefplist
  [self showAlertWithTitle:@"Some Error Occured"  message:error.localizedDescription];
  [refreshControl endRefreshing];
}


- (void)imageDownloadedAtLocation:(NSString *)image_path forProduct:(NSInteger)productId
{
  __block NSIndexPath *matchingIndexPath = nil;
  [self.currentlyShownIndexPaths enumerateKeysAndObjectsUsingBlock:^(NSString *categoryKey, NSIndexPath *indexPath, BOOL *stop) {
    ProductData *product = GET_PRODUCT_AT_INDEXPATH(indexPath);
    if (product.productId == productId) {
      *stop = YES;
      matchingIndexPath = indexPath;
    }
  }];
  if (matchingIndexPath) {
    [((ProductViewCell *)[self.productsCollectionView cellForItemAtIndexPath:matchingIndexPath]).productView refresh:nil];
  }
}



#pragma mark - 
#pragma mark - Utilitites Methods
+ (CGSize)screenSize
{
  CGSize screenSize = [UIScreen mainScreen].bounds.size; //iOS8 returns orientation specific size
  if ((NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1) && UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation])) {
    screenSize = CGSizeMake(screenSize.height, screenSize.width);
  } else {
    screenSize = [UIScreen mainScreen].bounds.size;
  }
  return screenSize;
}


- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message
{
  if ([UIAlertController class]) {
    //prefer this
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      //You can add some code here for more customization
    }]];
    [self presentViewController:alert animated:YES completion:nil];
  } else {
    //the good old UIAlertView
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
  }
}


- (void)showErrorViewController
{
  ErrorViewController *errorViewController = errorVC;
  NSString *errorMessage = nil;
  if([PlistManager sharedManager].reachability.currentReachabilityStatus == NotReachable) {
    errorMessage =@"You have lost Internet Connectivity!";
  } else {
    errorMessage = @"There is nothing to display!!";
  }

  if (errorViewController == nil) {
    errorViewController = [self.storyboard instantiateViewControllerWithIdentifier:ErrorViewControllerStoryboardID];
    [errorVC.errorMessage setText:errorMessage];
    [self presentViewController:errorViewController animated:YES completion:^{
      errorVC = errorViewController;
    }];
  } else {
    [errorVC.errorMessage setText:errorMessage];
  }

}

@end


