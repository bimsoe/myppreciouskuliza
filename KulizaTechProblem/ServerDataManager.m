//
//  ServerDataManager.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ServerDataManager.h"

@implementation ServerDataManager
+ (instancetype)sharedManager
{
  static ServerDataManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (id)init {
  if (self = [super init]) {
  }
  return self;
}

@end
