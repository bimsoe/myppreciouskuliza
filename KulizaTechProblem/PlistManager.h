//
//  PlistManager.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
@interface PlistManager : NSObject
+ (instancetype)sharedManager;

- (NSURL *)fetchAPIForProductCategory:(ProductCategory)category;

@end
