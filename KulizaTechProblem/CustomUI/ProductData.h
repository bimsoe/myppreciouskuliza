//
//  ProductData.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#define STORE_PRICE 1

@interface ProductData : NSObject
@property (nonatomic) NSUInteger uId; //e.g. 2345
@property (nonatomic, copy) NSString *productName; //e.g. "Greenwich Sofa (Cobalt)",
@property (nonatomic, copy) NSString *productDisplayPrice; //e.g. "₹42,999"
@property (nonatomic, copy) NSString *productDisplayDiscountedPrice; // "₹42,999",
@property (nonatomic) NSInteger productId; //704
//not storing the price as its not needed (for the current problem at least)
#if STORE_PRICE
@property (nonatomic) NSUInteger productPrice;
@property (nonatomic) NSUInteger productDiscountedPrice;
#endif
@property (nonatomic) BOOL inStock;// true,
@property (nonatomic, strong) NSURL *productImageURL; //"https://d22osf57l9srmn.cloudfront.net/images/skus/product/FNSF51AGCO1.jpg?1421811780"
@property (nonatomic, strong) UIImage *productImage;
@property (nonatomic) CGSize productImageSize; //dont think its needed
@property (nonatomic) ProductCategory productCategory;
@end
