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

#define KEY_FOR_CATEGORY(category)  INT2STR(category)
#define ZEROTH_INDEXPATH(indexPath) [NSIndexPath indexPathForItem:0 inSection:indexPath.section]
@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, ProductDatasource, ProductDelegate, UICollectionViewDelegateFlowLayout, UIContentContainer>
{
  UILabel *headerLabel;
}
@property NSMutableDictionary *productsDictionary; /**< Contains {category:[array of product]} pair} */
@property NSMutableDictionary *currentlyShownIndexPaths; /**< Contains {category:itemIndexPath pair; Each item refers to the index of Product in its products array */
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _productsDictionary = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
  _currentlyShownIndexPaths = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
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
  CGSize itemSize = CGSizeMake(screenSize.width, screenSize.width);
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
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Orientation Changes
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  CGSize screenSize = [ViewController screenSize];
  CGRect frame = headerLabel.frame;
  frame.size.width = screenSize.width;
  [headerLabel setFrame:frame];

}
#pragma mark UIContentContainer Protocol
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
  CGRect frame = headerLabel.frame;
  frame.size.width = size.width;
  [headerLabel setFrame:frame];
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
  return (section + 1);// section has a +1 kinda relation with Product Category
}

#pragma mark - 

#pragma mark UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
  return 7;
  return self.productsDictionary.allKeys.count;
  //I'll be treating each category as one item (as oppose to each category as a separate section) because there is just one product
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
  return 1;
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
  //get index path from currentlyShownIndexPaths
  NSIndexPath *currentIndexPathForCategory = [self.currentlyShownIndexPaths objectForKey:KEY_FOR_CATEGORY([self categoryForSection:indexPath.section])];
  if (currentIndexPathForCategory == nil) {
    //use default
    currentIndexPathForCategory = indexPath;
  }
  [entityView.productView setProductIndexPath:currentIndexPathForCategory];
  [entityView.productView refresh];
  
  return entityView;

}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
{
  UICollectionReusableView *headerView =
                                    [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                       withReuseIdentifier:ProductCollectionHeaderIdentifier
                                                                              forIndexPath:indexPath];
  static NSInteger HeaderLabelTag = 101;
  if (headerLabel == nil) {
    //add label
    headerLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, collectionView.frame.size.width, 30.0f)];
    [headerLabel setTextAlignment:NSTextAlignmentCenter];
    [headerLabel setTag:HeaderLabelTag];//so that we dont add it over and over again
    [headerView addSubview:headerLabel];
    [headerLabel setCenter:headerView.center];
  }
  //text can be updated based on what group are we seeing
  [headerLabel setText:@"DINING TABLES & SETS"];
  return headerView;
}

#pragma mark UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
  SM_LOG(@"Product Selected at Index Path : %@", indexPath);
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

