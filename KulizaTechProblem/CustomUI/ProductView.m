//
//  ProductView.m
//  KulizaTechProblem
//
//  Created by Pankaj Sharma on 11/04/15.
//  Copyright (c) 2015 Pankaj Sharma. All rights reserved.
//

#import "ProductView.h"

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

- (void)refresh
{
  //can add animation here
  [self updateWithProductData:[self.dataSource dataForProductAtIndexPath:self.productIndexPath]];
}

- (void)updateWithProductData:(ProductData *)product_data
{
  productData = product_data;
  [self.productHeading setText:productData.productName];
  [self.productImage setImage:productData.productImage];

  NSString *productPrice = productData.productDisplayDiscountedPrice;
  if (productPrice.length == 0) {
    //display the normal price
    productPrice =productData.productDisplayPrice;
  }
  
  [self.productPrice setText:productPrice];

  [self.previousProductButton setHidden:![self.dataSource shouldDisplayPreviousProductButtonForProductAtIndexPath:self.productIndexPath]];
  [self.nextProductButton setHidden:![self.dataSource shouldDisplayNextProductButtonForProductAtIndexPath:self.productIndexPath]];
  
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


@end
