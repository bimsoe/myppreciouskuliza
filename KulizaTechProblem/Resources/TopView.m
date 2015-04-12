//
//  TopView.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "TopView.h"

@implementation TopView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (TopView *)getTopView
{
  static NSString *nibName = @"TopView";
  NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
  for (id currentObject in nibContents) {
    if ([currentObject isKindOfClass:[TopView class]]) {
      return currentObject;
    }
  }
  return nil;
}

@end
