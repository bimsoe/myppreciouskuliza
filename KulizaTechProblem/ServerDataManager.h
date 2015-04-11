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
@end




@interface ServerDataManager : NSObject
+ (instancetype)sharedManager;

- (void)fetchProductsForCategory:(ProductCategory)category receiver:(id<ServerDataReceiver>)receiver;
- (BOOL)isFetchingProductsForCategory:(ProductCategory)category;

@end
