//
//  ViewController.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ViewController.h"
#import "ProductView.h"

NSString *ProductCollectionHeaderIdentifier = @"product_collection_header_identifier";

#define GET_PRODUCTS_AT_SECTION(section) [self productsInCategory:[self categoryForSection:section]]
#define GET_PRODUCT_AT_INDEXPATH(indexPath) [self productsInCategory:[self categoryForSection:indexPath.section]][indexPath.item]

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ProductDatasource, ProductDelegate>
@property NSMutableDictionary *productsDictionary; /**< Contains {category:[array of product]} pair} */
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _productsDictionary = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
  [self setUpCollectionView];
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
  CGSize itemSize = CGSizeMake(screenSize.width, 250.0f);
  [collectionFlowLayout setItemSize:itemSize];
  [collectionFlowLayout setMinimumInteritemSpacing:10.0f];
  [collectionFlowLayout setMinimumLineSpacing:5.0f];
  [collectionFlowLayout setSectionInset:UIEdgeInsetsZero];// UIEdgeInsetsMake(0, 5.0f, 0, 50f)];
  [collectionFlowLayout setHeaderReferenceSize:CGSizeMake(0, 30.0f)];
  
  return collectionFlowLayout;
}


- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


#pragma mark - Products Fetching
- (NSMutableArray *)productsInCategory:(ProductCategory)category
{
  return self.productsDictionary[INT2STR(category)];
}

///helps in deciding the order in which they are to be displayed
- (ProductCategory)categoryForSection:(NSInteger)section
{
  return (section + 1);// section has a +1 kinda relation with Product Category
}

#pragma mark - 

#pragma mark UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return self.productsDictionary.allKeys.count;
  //I'll be treating each category as one item (as oppose to each category as a separate section) because there is just one product
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  NSUInteger numberOfProducts = GET_PRODUCTS_AT_SECTION(section).count;
  SM_LOG(@"Number of Products in category %i : %u", [self categoryForSection:section], (uint)numberOfProducts);
  return numberOfProducts;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  ProductViewCell *entityView = (ProductViewCell *) [collectionView dequeueReusableCellWithReuseIdentifier:ProductCellIdentifier forIndexPath:indexPath];
  [entityView.productView setDataSource:self];
  [entityView.productView setDelegate:self];
  [entityView.productView setProductIndexPath:indexPath];
  [entityView.productView refresh];
  
  return entityView;

}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
  UICollectionReusableView *headerView =
                                    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:ProductCollectionHeaderIdentifier
                                                                              forIndexPath:indexPath];
  
  
  return headerView;
}

#pragma mark UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  SM_LOG(@"Product Selected at Index Path : %@", indexPath);
}

#pragma mark - 
#pragma mark - ProductDatasource
- (ProductData *)dataForProductAtIndexPath:(NSIndexPath *)indexPath
{
  NSArray *products = GET_PRODUCTS_AT_SECTION(indexPath.section);
  if (products.count -1 > indexPath.item) {
    return products[indexPath.item];
  }
  
  //some issue
  SM_LOG(@"products.count -1 > indexPath.item Failed");
  return nil;
}


- (BOOL)shouldDisplayPreviousProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;
{
  //you can add some additional conditions here;
  return indexPath.item == 0;
}


- (BOOL)shouldDisplayNextProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;
{
  NSUInteger productCount = GET_PRODUCTS_AT_SECTION(indexPath.section).count;
  return indexPath.item == (productCount - 1);
}


#pragma mark - ProductDelegate
- (void)buyButtonPressedForProductAtIndexPath:(NSIndexPath *)indexPath
{
  ProductData *product = GET_PRODUCT_AT_INDEXPATH(indexPath);
  NSString *message = [NSString stringWithFormat:@"%@ was added to cart!!", product.productName];
  NSString *title = @"Added to Cart";
  if ([UIAlertController class]) {
    //prefer this
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
      //You can add some code here for more customization
    }]];
  } else {
    //the good old UIAlertView
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
  }
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
  
  //update the indexPath
  ProductViewCell *productCell = (ProductViewCell *)[self.productsCollectionView cellForItemAtIndexPath:indexPath];
  [productCell.productView setProductIndexPath:[NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section]];
  [productCell.productView refresh];      
}


- (void)nextProductButtonPressed:(NSIndexPath *)indexPath
{
  NSInteger count = GET_PRODUCTS_AT_SECTION(indexPath.section).count;
  if (indexPath.item == count - 1) {
    //no can do
    return;
  }
  
  //update the indexPath
  ProductViewCell *productCell = (ProductViewCell *)[self.productsCollectionView cellForItemAtIndexPath:indexPath];
  [productCell.productView setProductIndexPath:[NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section]];
  [productCell.productView refresh];
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



@end

