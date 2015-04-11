//
//  ViewController.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property NSMutableDictionary *productsDictionary; /**< Contains {category:[array of product]} pair} */
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _productsDictionary = [NSMutableDictionary dictionaryWithCapacity:MAX_CATEGORIES];
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
  NSUInteger numberOfProducts = [self productsInCategory:[self categoryForSection:section]].count;
  SM_LOG(@"Number of Products in category %i : %u", [self categoryForSection:section], (uint)numberOfProducts);
  return numberOfProducts;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
  
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;


#pragma mark UICollectionView Delegate


@end
