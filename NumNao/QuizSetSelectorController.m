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
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
#import "QuizManager.h"
#import "AVFoundation/AVAudioPlayer.h"

@interface QuizSetSelectorController ()

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) NumNaoLoadingView *loadingView;
@property (nonatomic, strong) id productDidPurchasedObserver;
@property (nonatomic, strong) id productDidPurchasedFailedObserver;
@property (assign, nonatomic) NSInteger quizMode;

@end

@implementation QuizSetSelectorController
@synthesize bannerView = bannerView_;

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
  __typeof(self) __weak weakSelf = self;
  
  self.productDidPurchasedObserver = [[NSNotificationCenter defaultCenter]
                                addObserverForName:IAPHelperProductPurchasedNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *note) {
                                  [weakSelf lockAllButtons:NO];
                                  [weakSelf renderLockIcon];
                                  [weakSelf.loadingView removeFromSuperview];
                                }];
 
  self.productDidPurchasedFailedObserver = [[NSNotificationCenter defaultCenter]
                                            addObserverForName:IAPHelperProductPurchasedFailedNotification
                                            object:nil
                                            queue:[NSOperationQueue mainQueue]
                                            usingBlock:^(NSNotification *note) {
                                              [weakSelf lockAllButtons:NO];
                                              [weakSelf renderLockIcon];
                                              [weakSelf.loadingView removeFromSuperview];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                  message:@"การซื้อขายถูกยกเลิกนะจ๊ะ"
                                                  delegate:nil
                                                  cancelButtonTitle:@"ตกลงจ้ะ"
                                                  otherButtonTitles: nil];
                                              [alert show];
                                            }];
  
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, 80.0, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];

  self.bannerView.adUnitID = MyAdUnitID;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  [self decorateAllButtons];
  [self renderLockIcon];
  
  NumNaoIAPHelper *IAPInstance = [NumNaoIAPHelper sharedInstance];
  
  if (![IAPInstance isRetroCh3Purchased] ||
      ![IAPInstance isRetroCh5Purchased] ||
      ![IAPInstance isRetroCh7Purchased]) {
    
    if (!IAPInstance.products) {
      self.loadingView = [[NumNaoLoadingView alloc] init];
      [self.view addSubview:self.loadingView];
      
      [IAPInstance requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (!success) {
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"เกิดข้อผิดพลาด"
                                                          message:@"เธอต้องต่อ internet ก่อนนะถึงจะเล่นได้น่ะ แต่ถ้ายังเล่นไม่ได้อีก แสดงว่าเซิร์ฟเวอร์ของ iTune มีปัญหาน่ะ รอสักพักแล้วลองใหม่นะ"
                                                         delegate:nil
                                                cancelButtonTitle:@"ตกลงจ้ะ"
                                                otherButtonTitles:nil];
          [alert show];
        }
        [self.loadingView removeFromSuperview];
      }];
    }
  }
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"ominous_sounds" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (!self.audioPlayer.isPlaying) {
    if (self.audioPlayer) {
      [self.audioPlayer play];
    } else {
      [self setUpAudioPlayer];
    }
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedFailedObserver];
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.onAirButton.frame.origin.y + self.onAirButton.frame.size.height + 10;
  [UIView animateWithDuration:1.0 animations:^{
    adView.frame = CGRectMake(0.0, yPos, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  
  switch (alertView.tag) {
    case 100: {
      [self goToQuizDetail:NumNaoQuizModeOnAir];
    } break;

    case 101: {
      [self goToQuizDetail:NumNaoQuizModeRetroCh3];
    } break;

    case 102: {
      [self goToQuizDetail:NumNaoQuizModeRetroCh5];
    } break;
      
    default:
      break;
  }
}

#pragma mark - Table view data source

- (IBAction)goToQuiz:(id)sender {
  NSInteger tag = ((UIButton *)sender).tag;
  NumNaoIAPHelper *IAPInstance = [NumNaoIAPHelper sharedInstance];
  if (tag == 0) {
    
    // Mode: ON AIR
    if (IAPInstance.retroCh3Purchased) {
      [self goToQuizDetail:NumNaoQuizModeOnAir];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"เธอสามารถปลดล๊อดโหมดละครเก่าช่อง 3 ได้อย่างง่ายๆ เพียงแค่เล่นโหมดละครออนแอร์ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                     delegate:self
                                            cancelButtonTitle:@"ตกลงจ้ะ"
                                            otherButtonTitles:nil];
      alert.tag = 100;
      [alert show];
    }

  } else if (tag == 1){
    
    // Mode: Retro CH 3
    SKProduct *product = IAPInstance.products[0];
    if (IAPInstance.retroCh3Purchased) {
      if (IAPInstance.retroCh5Purchased) {
        [self goToQuizDetail:NumNaoQuizModeRetroCh3];
      } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                        message:@"เธอสามารถปลดล๊อดโหมดละครเก่าช่อง 5 ได้อย่างง่ายๆ เพียงแค่เล่นโหมดละครเก่าช่อง 3 ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                       delegate:self
                                              cancelButtonTitle:@"ตกลงจ้ะ"
                                              otherButtonTitles:nil];
        alert.tag = 101;
        [alert show];
      }
    } else {
      [self lockAllButtons:YES];
      [self.view addSubview:self.loadingView];
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
    
  } else if (tag == 2){
    
    // Mode: Retro CH 5
    
    SKProduct *product = IAPInstance.products[1];
    if (IAPInstance.retroCh5Purchased) {
      if (IAPInstance.retroCh7Purchased) {
        [self goToQuizDetail:NumNaoQuizModeRetroCh5];
      } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                        message:@"เธอสามารถปลดล๊อดโหมดละครเก่าช่อง 7 ได้อย่างง่ายๆ เพียงแค่เล่นโหมดละครเก่าช่อง 5 ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ !!"
                                                       delegate:self
                                              cancelButtonTitle:@"ตกลงจ้ะ"
                                              otherButtonTitles:nil];
        alert.tag = 102;
        [alert show];
      }
    } else {
      [self lockAllButtons:YES];
      [self.view addSubview:self.loadingView];
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
  } else if (tag == 3){
    
    // Mode: Retro CH 7
    
    SKProduct *product = IAPInstance.products[2];;
    if (IAPInstance.retroCh7Purchased) {
      [self goToQuizDetail:NumNaoQuizModeRetroCh7];
    } else {
      [self lockAllButtons:YES];
      [self.view addSubview:self.loadingView];
      [[NumNaoIAPHelper sharedInstance] buyProduct:product];
    }
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"QuizSetToQuizDetailSegue"]) {
    QuizDetailController *quizDetailController = [segue destinationViewController];
    quizDetailController.quizMode = self.quizMode;
  }
}

- (void)goToQuizDetail:(NSInteger) mode {
  [self.audioPlayer stop];
  self.quizMode = mode;
  [self performSegueWithIdentifier:@"QuizSetToQuizDetailSegue" sender:self];
//  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
//  quizDetailController.quizMode = mode;
//  [self.navigationController pushViewController:quizDetailController animated:YES];
}

- (void)renderLockIcon {
  NumNaoIAPHelper *IAPinstance = [NumNaoIAPHelper sharedInstance];

  BOOL isRetroCH3Purchased = IAPinstance.retroCh3Purchased;
  BOOL isRetroCH5Purchased = IAPinstance.retroCh5Purchased;
  BOOL isRetroCH7Purchased = IAPinstance.retroCh7Purchased;
  
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

- (void)lockAllButtons:(BOOL)flag {
  self.onAirButton.enabled = !flag;
  self.retroCh3Button.enabled = !flag;
  self.retroCh5Button.enabled = !flag;
  self.retroCh7Button.enabled = !flag;
}

- (void)decorateAllButtons {
  NSArray *buttons = [NSArray arrayWithObjects: self.onAirButton, self.retroCh3Button, self.retroCh5Button, self.retroCh7Button,nil];
  
  for(UIButton *btn in buttons)
  {
    // Set the button Text Color
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f] CGColor],
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
