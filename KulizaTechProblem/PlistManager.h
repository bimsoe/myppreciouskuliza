//
//  PlistManager.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "Reachability.h"
@interface PlistManager : NSObject
{
  
}
+ (instancetype)sharedManager;
@property (nonatomic, strong, readonly) Reachability *reachability;
- (NSURL *)fetchAPIForProductCategory:(ProductCategory)category;
- (NSString *)cachesDirectoryPath;
- (UIImage *)imageForProduct:(NSInteger)pId;
- (NSString *)writeImageData:(NSData *)data forProduct:(NSInteger)pId;/**< @returns the path to written file */
- (UIImage *)getReloadImage;
@end
