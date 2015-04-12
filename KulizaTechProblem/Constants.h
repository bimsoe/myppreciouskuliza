//
//  Constants.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#ifndef KulizaTechProblem_Constants_h
#define KulizaTechProblem_Constants_h
#import <UIKit/UIKit.h>

#pragma mark - Color Defines
#define BROWNISH_COLOR  [UIColor colorWithRed:0.749f green:0.4f blue:0.161f alpha:1.0f]
#define WHITISH_COLOR   [UIColor colorWithRed:0.937f green:0.937f blue:0.937f alpha:1.0f]
#define PINKISH_COLOR   [UIColor colorWithRed:0.969f green:0.925f blue:0.898f alpha:1.0f]
#define YELLOWISH_COLOR [UIColor colorWithRed:0.957f green:0.957f blue:0.91f alpha:1.0f]
#define GRAYISH_COLOR   [UIColor colorWithRed:0.733f green:0.733f blue:0.733f alpha:1.0f]
#define DARK_BLACK_COLOR        [UIColor blackColor]
#define LIGHT_BLACK_COLOR       [UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]
#define EXTRA_LIGHT_BLACK_COLOR  [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]

#pragma mark - Image Defines
#define BUY_NOW_IMG     @"buy-now"
#define CALL_US_IMG     @"call-us"
#define LEFT_ARROW_IMG  @"left_arrow"
#define RIGHT_ARROW_IMG @"right_arrow"
#define RELOAD_ICON     @"reload-icon"


#define GET_FONT(size) [UIFont systemFontOfSize:size]
#define MAX_CATEGORIES  5

typedef void(^CompletionBlockVoid)(void);

#define INT2STR(num)  [NSString stringWithFormat:@"%li", (long int)num]

typedef NS_ENUM(short, ProductCategory) {
  ProductCategoryInvalid = -1,
  ProductCategory1 = 1,
  ProductCategory2,
  ProductCategory3,
  ProductCategory4,
  ProductCategory5,
  ProductCategoryCount = 5
};

#pragma mark - Debug
#define DEBUG 0
#if DEBUG
  #define PS_LOG(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])
#else
  #define PS_LOG(...)
#endif

#endif
