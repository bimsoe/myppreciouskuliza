//
//  ViewController.h
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *productsCollectionView;
@property (copy, nonatomic) NSString *pageHeadingText; //e.g. DINING TABLES & SETS

@end

