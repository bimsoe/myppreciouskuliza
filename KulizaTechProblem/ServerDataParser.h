//
//  ServerDataParser.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProductData.h"

@interface ServerDataParser : NSObject
+ (instancetype)sharedManager;
- (ProductData *)productDataFromProductJSON:(NSDictionary *)jsonDictionary;
- (NSArray *)productsDataFromServerJSON:(NSData *)jsonData; /**< Returns array of @a ProductData objects */
@end
