//
//  ErrorViewController.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 12/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ErrorViewController.h"
#import "PlistManager.h"
NSString *ErrorViewControllerStoryboardID = @"ErrorViewController";
@interface ErrorViewController ()
- (IBAction)closeButtonPressed:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *checkForConnectivity;
- (IBAction)checkForConnectivityPressed:(id)sender;

@end

@implementation ErrorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)closeButtonPressed:(UIButton *)sender
{
  [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)checkForConnectivityPressed:(id)sender
{
  //start spinning
  [self.checkForConnectivity setEnabled:NO];
  [self runSpinAnimationOnView:self.checkForConnectivity duration:1.0f rotations:3 repeat:1];
  if ([PlistManager sharedManager].reachability.currentReachabilityStatus != NotReachable) {
    //close it
    [self closeButtonPressed:nil];
  }
}

- (void)runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
  CABasicAnimation* rotationAnimation;
  rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
  rotationAnimation.duration = duration;
  rotationAnimation.cumulative = YES;
  rotationAnimation.repeatCount = repeat;
  rotationAnimation.delegate = self;
  [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [self.checkForConnectivity setEnabled:YES];
}


@end
