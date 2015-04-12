//
//  ErrorViewController.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *ErrorViewControllerStoryboardID;
@interface ErrorViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *errorMessage;

@end
