//
//  TopView.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopView : UIView
@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
+ (TopView *)getTopView;
@end
