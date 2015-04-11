//
//  ProductView.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductData.h"

#pragma mark -
@protocol ProductDelegate <NSObject>
@required
- (void)buyButtonPressedForProductAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (void)showAllProductsButtonPressed:(NSIndexPath *)indexPath;
- (void)nextProductButtonPressed:(NSIndexPath *)indexPath;
- (void)previousProductButtonPressed:(NSIndexPath *)indexPath;
@end

#pragma mark -
@protocol ProductDatasource <NSObject>
@required
- (ProductData *)dataForProductAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldDisplayPreviousProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)shouldDisplayNextProductButtonForProductAtIndexPath:(NSIndexPath *)indexPath;;
@end

#pragma mark -
@class ProductView;
FOUNDATION_EXPORT NSString *ProductCellIdentifier;
@interface ProductViewCell : UICollectionViewCell
@property (nonatomic, strong) ProductView *productView;
@end

#pragma mark -
@interface ProductView : UIView
@property (weak, nonatomic) IBOutlet UILabel *productHeading;
@property (weak, nonatomic) IBOutlet UIButton *viewAllProducts;
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productSubtitle;
@property (weak, nonatomic) IBOutlet UILabel *productExtraInfo;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (copy, nonatomic) NSIndexPath *productIndexPath;
@property (weak, nonatomic) id<ProductDelegate> delegate;
@property (weak, nonatomic) id<ProductDatasource> dataSource;
/** 
 *  Call after setting @b delegate, @b datasource and @b productIndexPath
 *  @code [self updateWithProductData:[self.dataSource dataForProductAtIndexPath:self.productIndexPath]]; @endcode
 */
- (void)refresh;
- (void)updateWithProductData:(ProductData *)product_data;

+ (ProductView *)getProductView;

@end
