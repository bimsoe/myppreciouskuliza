//
//  ProductView.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ProductView.h"
#import "PlistManager.h"

#pragma mark - ProductViewCell
NSString *ProductCellIdentifier = @"product_cell_identifier";
@implementation ProductViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    _productView = [ProductView getProductView];
    [self.contentView addSubview:self.productView];
    [_productView setFrame:self.bounds];
  }
  return self;
}


#if DEBUG
- (void)prepareForReuse
{
  [super prepareForReuse];
  [self.productView.layer setBorderColor:self.productView.productIndexPath.item % 2 ? [UIColor redColor].CGColor : [UIColor greenColor].CGColor];
  [self.productView.layer setBorderWidth:2.0f];
}
#endif
@end


#pragma mark - 
#pragma mark - ProductView
@interface ProductView ()
{
  __weak ProductData *productData;
  UITapGestureRecognizer *tapGesture;
}
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *previousProductButton;
@property (weak, nonatomic) IBOutlet UIButton *nextProductButton;

@end

@implementation ProductView

+ (ProductView *)getProductView
{
  static NSString *productViewNibName = @"ProductView";
  NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:productViewNibName owner:self options:nil];
  for (id currentObject in nibContents) {
    if ([currentObject isKindOfClass:[ProductView class]]) {
      ProductView *productView = (ProductView *)currentObject;
      [productView addSwipeGesture];
      return currentObject;
    }
  }
  return nil;
}

- (void)awakeFromNib
{
  [super awakeFromNib];
  [self.productHeading setTextColor:DARK_BLACK_COLOR];
  [self.viewAllProducts setTitleColor:BROWNISH_COLOR forState:UIControlStateNormal];
  [self.productSubtitle setTextColor:EXTRA_LIGHT_BLACK_COLOR];
  [self.productExtraInfo setTextColor:EXTRA_LIGHT_BLACK_COLOR];
  [self.productPrice setTextColor:BROWNISH_COLOR];
}


- (void)addSwipeGesture
{
  UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(productViewSwiped:)];
  [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
  [self addGestureRecognizer:swipeGestureLeft];
  [swipeGestureLeft setCancelsTouchesInView:NO];
  
  UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(productViewSwiped:)];
  [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
  [self addGestureRecognizer:swipeGestureRight];
    [swipeGestureRight setCancelsTouchesInView:NO];
}

- (void)productViewSwiped:(UISwipeGestureRecognizer *)swipeGesture
{
    [swipeGesture setCancelsTouchesInView:NO];
  if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft) {
    //simulate next button press
    if (!self.nextProductButton.hidden) {
      [self buttonPressed:self.nextProductButton];
    }
  } else {
    //simulate previous button press
    if (!self.previousProductButton.hidden) {
      [self buttonPressed:self.previousProductButton];
    }
  }
}

- (void)refresh:(NSString *)direction
{
  //can add animation here
  [self updateWithProductData:[self.dataSource dataForProductAtIndexPath:self.productIndexPath]];
  if (direction) {
    [self animateIndirection:direction];
  }
  
}


- (CATransition *)animateIndirection:(NSString *)direction
{
  CATransition *transition = [CATransition animation];
  transition.duration = 0.2f;
  transition.delegate = self;
  //  transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  transition.type = kCATransitionPush;//kCATransitionFade;//
  transition.subtype = direction;
  [self.layer addAnimation:transition forKey:nil];
  return transition;
}

- (void)moveFromView:(UIView *)fromView toView:(UIView *)toView direction:(NSString *)direction
{
  CATransition *transition = [CATransition animation];
  [transition setDuration:0.3f];
  transition.type = kCATransitionPush;//kCATransitionPush;
  transition.subtype = direction;//kCATransitionFromRight
  [transition setFillMode:kCAFillModeBoth];
  [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  [fromView.layer addAnimation:transition forKey:kCATransition];
  
  transition.type = kCATransitionFade;//remove this line to change the aniim type
  [toView.layer addAnimation:transition forKey:kCATransition];
}


- (void)updateWithProductData:(ProductData *)product_data
{
  productData = product_data;
  [self.productHeading setText:productData.productName];
  [self setImageReloadIcon];

  NSString *productPrice = productData.productDisplayDiscountedPrice;
  if (productPrice.length == 0) {
    //display the normal price
    productPrice =productData.productDisplayPrice;
  }
  [self.productPrice setText:productPrice];

  if (productData.optionValues.count == 2) {
    [self.productSubtitle setText:productData.optionValues[0]];
    [self.productExtraInfo setText:productData.optionValues[1]];
    [self.productSubtitle setHidden:NO];
    [self.productExtraInfo setHidden:NO];
  } else if (productData.optionValues.count == 1) {
    [self.productExtraInfo setText:productData.optionValues[0]];
    [self.productSubtitle setHidden:YES];
    [self.productExtraInfo setHidden:NO];
  } else {
    [self.productSubtitle setHidden:YES];
    [self.productExtraInfo setHidden:YES];
  }
  
  
  [self.previousProductButton setHidden:![self.dataSource shouldDisplayPreviousProductButtonForProductAtIndexPath:self.productIndexPath]];
  [self.nextProductButton setHidden:![self.dataSource shouldDisplayNextProductButtonForProductAtIndexPath:self.productIndexPath]];
  
}


- (void)setImageReloadIcon
{
  UIImage *imageToSet = productData.productImage;
  if (imageToSet) {
    //hide indicator
    [self.loadingIndicator stopAnimating];
    [self.productImage removeGestureRecognizer:tapGesture];
  } else {
    //use default
    [self.productImage setImage:[[PlistManager sharedManager] getReloadImage]];
    if (tapGesture == nil) {
      tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(requestReload)];
    }
    [self.productImage addGestureRecognizer:tapGesture];    
  }
  [self.productImage setImage:imageToSet];
}

- (void)requestReload
{
  if ([self.delegate respondsToSelector:@selector(requestReloadForProductAtIndexPath:)]) {
    [self.delegate requestReloadForProductAtIndexPath:self.productIndexPath];
    if (productData.productImage == nil) {
      //do default image is present
      //start spinning
      [self.loadingIndicator startAnimating];
    }
  }
}

- (IBAction)buyNowButtonPressed:(UIButton *)sender
{
  if ([self.delegate respondsToSelector:@selector(buyButtonPressedForProductAtIndexPath:)]) {
    [self.delegate buyButtonPressedForProductAtIndexPath:self.productIndexPath];
  }
}


- (IBAction)buttonPressed:(UIButton *)sender
{
  if (sender == self.nextProductButton) {
    if ([self.delegate respondsToSelector:@selector(nextProductButtonPressed:)]) {
      [self.delegate nextProductButtonPressed:self.productIndexPath];
    }
  } else if (sender == self.previousProductButton) {
    if ([self.delegate respondsToSelector:@selector(previousProductButtonPressed:)]) {
      [self.delegate previousProductButtonPressed:self.productIndexPath];
    }
  } else if (sender == self.viewAllProducts) {
    if ([self.delegate respondsToSelector:@selector(showAllProductsButtonPressed:)]) {
      [self.delegate showAllProductsButtonPressed:self.productIndexPath];
    }
  }
}


#pragma mark - CATransitionDelegate
- (void)animationDidStart:(CAAnimation *)anim
{
  [[UIApplication sharedApplication] beginIgnoringInteractionEvents];  
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
  [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

@end
