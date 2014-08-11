//
//  QuizSetSelectorController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizSetSelectorController.h"
#import "QuizDetailController.h"
#import <StoreKit/StoreKit.h>
#import "NumNaoIAPHelper.h"
#import "NumNaoLoadingView.h"

@interface QuizSetSelectorController () {
  NSArray *_products;
}

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) NumNaoLoadingView *loadingView;

@end

@implementation QuizSetSelectorController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {

  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  [self decorateAllButtons];
  _products = nil;
  
  [self.retroCh3Button setHidden:YES];
  [self.retroCh5Button setHidden:YES];
  [self.retroCh7Button setHidden:YES];
  
  self.loadingView = [[NumNaoLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
  
  [[NumNaoIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
    if (success) {
      _products = products;
      
      [self.retroCh3Button setHidden:NO];
      [self.retroCh5Button setHidden:NO];
      [self.retroCh7Button setHidden:NO];
      
      [self renderLockIcon];
      [self.loadingView removeFromSuperview];
    }
  }];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (IBAction)goToQuiz:(id)sender {
  NSInteger tag = ((UIButton *)sender).tag;
  
  if (tag == 0) {
    
    // Mode: ON AIR
    [self goToQuizDetail:0];
    
  } else if (tag == 1){
    
    // Mode: Retro CH 3
    SKProduct *product = _products[0];
    NSLog(@"Button Buying %@", product.productIdentifier);
    BOOL isPurchased =[[NumNaoIAPHelper sharedInstance] productPurchased:product.productIdentifier];
    if (isPurchased) {
      [self goToQuizDetail:1];
    } else {
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
    
  } else if (tag == 2){
    
    // Mode: Retro CH 5
    
    SKProduct *product = _products[1];
    NSLog(@"Button Buying %@", product.productIdentifier);
    BOOL isPurchased =[[NumNaoIAPHelper sharedInstance] productPurchased:product.productIdentifier];
    if (isPurchased) {
      [self goToQuizDetail:2];
    } else {
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
  } else if (tag == 3){
    
    // Mode: Retro CH 7
    
    SKProduct *product = _products[2];
    NSLog(@"Button Buying %@", product.productIdentifier);
    BOOL isPurchased =[[NumNaoIAPHelper sharedInstance] productPurchased:product.productIdentifier];
    if (isPurchased) {
      [self goToQuizDetail:3];
    } else {
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
  }
}

- (void)goToQuizDetail:(NSInteger) mode {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
  [self.navigationController pushViewController:quizDetailController animated:YES];
}

- (void)renderLockIcon {
  NumNaoIAPHelper *IAPinstance = [NumNaoIAPHelper sharedInstance];
  BOOL isRetroCH3Purchased = [IAPinstance productPurchased:
                              ((SKProduct *)_products[0]).productIdentifier];
  BOOL isRetroCH5Purchased = [IAPinstance productPurchased:
                              ((SKProduct *)_products[1]).productIdentifier];
  BOOL isRetroCH7Purchased = [IAPinstance productPurchased:
                              ((SKProduct *)_products[2]).productIdentifier];
  
  if (isRetroCH3Purchased) {
    self.retroCh3LockImageView.image = nil;
  } else {
    self.retroCh3LockImageView.image = [UIImage imageNamed:@"lock_icon"];
  }
  
  if (isRetroCH5Purchased) {
    self.retroCh5LockImageView.image = nil;
  } else {
    self.retroCh5LockImageView.image = [UIImage imageNamed:@"lock_icon"];
  }
  
  if (isRetroCH7Purchased) {
    self.retroCh7LockImageView.image = nil;
  } else {
    self.retroCh7LockImageView.image = [UIImage imageNamed:@"lock_icon"];
  }
}

- (void)decorateAllButtons {
  NSArray *buttons = [NSArray arrayWithObjects: self.onAirButton, self.retroCh3Button, self.retroCh5Button, self.retroCh7Button,nil];
  
  for(UIButton *btn in buttons)
  {
    // Set the button Text Color
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:251.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
  }
}

@end
