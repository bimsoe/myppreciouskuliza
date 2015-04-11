//
//  ServerDataParser.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ServerDataParser.h"
NSString * const PD_ProductsKey                     = @"products"; //returns NSArray
  NSString * const PD_IdKey                           = @"id"; //returns NSNumber
  NSString * const PD_ProductNameKey                  = @"name"; //returns NSString
  NSString * const PD_ProductIDKey                    = @"product_id"; //returns NSNumber
  NSString * const PD_ProductPrice                    = @"price"; //returns NSNumber
  NSString * const PD_ProductDisplayPriceKey          = @"display_price"; //returns NSString
  NSString * const PD_ProductDicountPriceKey          = @"discount_price"; //returns NSNumber
  NSString * const PD_ProductDisplayDiscountPriceKey  = @"display_discount_price"; //returns NSString
  NSString * const PD_ProductInStockKey               = @"in_stock"; //returns BOOL
  NSString * const PD_ProductTemplateKey              = @"product_template"; //returns NSString
  NSString * const PD_ProductImageKey                 = @"images"; //returns NSDictionary
    NSString * const PD_ProductImageURL               = @"url"; //returns NSString
  NSString * const PD_ProductOptionValuesKey          = @"option_values"; //returns array of options
    NSString * const PD_ProductOptionPresentation     = @"presentation";// returns NSString
    NSString * const PD_ProductOptionTypePresentation = @"option_type_presentation";// returns NSString

@implementation ServerDataParser
+ (instancetype)sharedManager
{
  static ServerDataParser *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}


- (id)init
{
  if (self = [super init]) {
  }
  return self;
}


- (ProductData *)productDataFromProductJSON:(NSDictionary *)jsonDictionary
{
  ProductData *productData = [[ProductData alloc] init];
  productData.uId = [jsonDictionary[PD_IdKey] unsignedIntegerValue];
  productData.productName = jsonDictionary[PD_ProductNameKey];
  productData.productId = [jsonDictionary[PD_ProductIDKey] integerValue];
  productData.productPrice = [jsonDictionary[PD_ProductPrice] unsignedIntegerValue];
  productData.productDisplayPrice = jsonDictionary[PD_ProductDisplayPriceKey];
  productData.productDiscountedPrice = [jsonDictionary[PD_ProductDicountPriceKey] unsignedIntegerValue];
  productData.productDisplayDiscountedPrice = jsonDictionary[PD_ProductDisplayDiscountPriceKey];
  NSDictionary *imageDict = jsonDictionary[PD_ProductImageKey];
  productData.productImageURL = [NSURL URLWithString:imageDict[PD_ProductImageURL]];
  NSArray *optionValues = jsonDictionary[PD_ProductOptionValuesKey];
  if ((optionValues.count)) {
    NSMutableArray *productOptionArray = [NSMutableArray arrayWithCapacity:optionValues.count];
    for (NSDictionary *optionDict in optionValues) {
      NSString *presentationValue = optionDict[PD_ProductOptionPresentation];
      NSString *presentationType = optionDict[PD_ProductOptionTypePresentation];
      [productOptionArray addObject:[NSString stringWithFormat:@"%@ %@", presentationValue, presentationType]];
    }
    productData.optionValues = productOptionArray;
  }
  
  
  return productData;
}



- (NSArray *)productsDataFromServerJSON:(NSData *)jsonData
{
  NSDictionary *productsDictionary = [self parseJSON:jsonData];
  if (productsDictionary == nil) {
    return nil;
  }
  NSArray *products = productsDictionary[PD_ProductsKey];
  NSMutableArray *productDataArray = [NSMutableArray arrayWithCapacity:products.count];
  for (NSDictionary *productDictionary in products) {
    [productDataArray addObject:[self productDataFromProductJSON:productDictionary]];
  }
  PS_LOG(@"Parsing Done : %@", productDataArray);
  return productDataArray;
}



- (NSDictionary *)parseJSON:(NSData *)json_data
{
  if (json_data == nil || json_data.length == 0) {
    return nil;
  }
  
  NSError *parsingError = nil;
  id result = [NSJSONSerialization JSONObjectWithData:json_data
                                           options:0
                                             error:&parsingError];
  if (parsingError) {
    NSLog(@"JSON Pasring error : \n%@", parsingError.localizedDescription);
  }
  return (NSDictionary *)result;
}

@end
