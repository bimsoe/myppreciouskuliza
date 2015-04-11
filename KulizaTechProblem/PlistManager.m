//
//  PlistManager.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "PlistManager.h"
@implementation PlistManager

+ (instancetype)sharedManager
{
  static PlistManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (instancetype)init
{
  if ((self = [super init])) {
    //Register defaults
    NSDictionary *defaultValues = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
                                                                              pathForResource:@"FetchAPIs"
                                                                              ofType:@"plist"]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
  }
  return self;
}


- (NSString *)urlEncodedString:(NSString *)str
{
  return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSURL *)fetchAPIForProductCategory:(ProductCategory)category
{
  NSArray *urls = @[@"https://stg1-hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83386&q[product_taxons_id_eq]=151",
                    @"https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=76",
                    @"https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=95",
                    @"https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=202",
                    @"https://stg1­hercules.urbanladder.com/api/variants?token=107fd0a0fc914faa981c90588cf7fe6dbd8cdd5578c83 386&q[product_taxons_id_eq]=69"];

  NSString *apiUrlStr = [[NSUserDefaults standardUserDefaults] objectForKey:INT2STR(category)];
  return [NSURL URLWithString:[self urlEncodedString:apiUrlStr]];

  
  
  //  NSString *apiUrlStr = [[NSUserDefaults standardUserDefaults] objectForKey:INT2STR(category)];
}



@end
