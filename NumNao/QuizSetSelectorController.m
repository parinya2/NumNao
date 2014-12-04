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
@property (strong, nonatomic) id productDidPurchasedObserver;
@property (strong, nonatomic) id productDidRestoredObserver;
@property (strong, nonatomic) id productDidPurchasedFailedObserver;
@property (strong, nonatomic) id productDidRestoredFailedObserver;
@property (strong, nonatomic) NSTimer *theNewQuizLabelTimer;
@property (assign, nonatomic) NSInteger quizMode;
@property (assign, nonatomic) BOOL quizLabelAnimationGoForward;

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
 
  self.productDidRestoredObserver = [[NSNotificationCenter defaultCenter]
                                      addObserverForName:IAPHelperProductRestoredNotification
                                      object:nil
                                      queue:[NSOperationQueue mainQueue]
                                      usingBlock:^(NSNotification *note) {
                                        [weakSelf lockAllButtons:NO];
                                        [weakSelf renderLockIcon];
                                        [weakSelf.loadingView removeFromSuperview];
                                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                  message:@"Products restoration completed"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles: nil];
                                        [alert show];
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
  
  self.productDidRestoredFailedObserver = [[NSNotificationCenter defaultCenter]
                                            addObserverForName:IAPHelperProductRestoredFailedNotification
                                            object:nil
                                            queue:[NSOperationQueue mainQueue]
                                            usingBlock:^(NSNotification *note) {
                                              [weakSelf lockAllButtons:NO];
                                              [weakSelf renderLockIcon];
                                              [weakSelf.loadingView removeFromSuperview];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention"
                                                        message:@"Purchase restoration was cancelled"
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
                                              [alert show];
                                            }];
  
  __block float yPos = self.onAirButton.frame.origin.y +  self.onAirButton.frame.size.height + 10;
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, yPos, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];

  self.bannerView.adUnitID = MyAdUnitID_Banner;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  [self decorateAllButtons];
  [self renderLockIcon];

}

- (void)refreshNewQuizLabel {
  float currentSize = self.onAirNewQuizLabel.font.pointSize;
  float minSize = 7;
  float maxSize = 22;
  float newSize;
  NSInteger fontSizeGap = 1;
  if (self.quizLabelAnimationGoForward) {
    newSize = currentSize + fontSizeGap;
  } else {
    newSize = currentSize - fontSizeGap;
  }
  if (newSize >= maxSize) {
    self.quizLabelAnimationGoForward = NO;
  }
  if (newSize <= minSize) {
    self.quizLabelAnimationGoForward = YES;
  }
  [self.onAirNewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.retroCh3NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.retroCh5NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
  [self.retroCh7NewQuizLabel setFont:[UIFont systemFontOfSize:newSize]];
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
  [self renderNewQuizLabel];
  self.theNewQuizLabelTimer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                                               target:self
                                                             selector:@selector(refreshNewQuizLabel)
                                                             userInfo:nil
                                                              repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  
  [self.theNewQuizLabelTimer invalidate];
  self.theNewQuizLabelTimer = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidRestoredObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.productDidPurchasedFailedObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.productDidRestoredFailedObserver];
  self.bannerView = nil;
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.onAirButton.frame.origin.y + self.onAirButton.frame.size.height + 10;
  [UIView animateWithDuration:0 animations:^{
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
  NumNaoIAPHelper *IAPInstance = [NumNaoIAPHelper sharedInstance];
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
      
    case 201 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[0];
          [self lockAllButtons:YES];
          self.loadingView = [[NumNaoLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumNaoIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
    } break;
      
    case 202 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[1];
          [self lockAllButtons:YES];
          self.loadingView = [[NumNaoLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumNaoIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
    } break;
      
    case 203 : {
      if (buttonIndex == 1) {
        if (IAPInstance.products) {
          SKProduct *product = IAPInstance.products[2];
          [self lockAllButtons:YES];
          self.loadingView = [[NumNaoLoadingView alloc] init];
          [self.view addSubview:self.loadingView];
          [[NumNaoIAPHelper sharedInstance] buyProduct:product];
        } else {
          [self alertSKProductNotReady];
        }
      }
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
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดละครเก่าช่อง 3 ได้ง่ายๆ โดยการเล่นโหมดละครออนแอร์ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ล่ะฮะ"
                                            otherButtonTitles:@"ซื้อจ้ะ",nil];
      alert.tag = 201;
      [alert show];
    }
    
  } else if (tag == 2){
    
    // Mode: Retro CH 5
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
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดละครเก่าช่อง 5 ได้ง่ายๆ โดยการเล่นโหมดละครเก่าช่อง 3 ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ซื้อ"
                                            otherButtonTitles:@"ซื้อต่อ",nil];
      alert.tag = 202;
      [alert show];
    }
  } else if (tag == 3){
    
    // Mode: Retro CH 7
    if (IAPInstance.retroCh7Purchased) {
      [self goToQuizDetail:NumNaoQuizModeRetroCh7];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"โปรดทราบ"
                                                      message:@"ถ้าไม่อยากจ่ายเงินซื้อ เธอสามารถปลดล๊อคโหมดละครเก่าช่อง 7 ได้ง่ายๆ โดยการเล่นโหมดละครเก่าช่อง 5 ให้ได้ 30 คะแนนเท่านั้นนะจ๊ะ ต้องการซื้อต่อมั้ย"
                                                     delegate:self
                                            cancelButtonTitle:@"ไม่ซื้อ"
                                            otherButtonTitles:@"ซื้อต่อ",nil];
      alert.tag = 203;
      [alert show];
    }
  }
}

- (IBAction)restorePurchase:(id)sender {
  [self lockAllButtons:YES];
   self.loadingView = [[NumNaoLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
  [[NumNaoIAPHelper sharedInstance] restorePurchasedProducts];
}

- (void)alertSKProductNotReady {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ขออภัยนะจ๊ะ"
                                                  message:@"ตอนนี้ระบบกำลังดำเนินการเชื่อมต่อกับ iTune อยู่ รอสัก 2-3 นาทีแล้วลองอีกทีนะจ๊ะ!!"
                                                 delegate:self
                                        cancelButtonTitle:@"ตกลงจ้ะ"
                                        otherButtonTitles:nil];
  alert.tag = 110;
  [alert show];
}

- (void)goToQuizDetail:(NSInteger) mode {
  [self.audioPlayer stop];
  [[QuizManager sharedInstance] updateVersionNumberForQuizMode:mode];
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
  quizDetailController.quizMode = mode;
  [self.navigationController pushViewController:quizDetailController animated:YES];
}

- (void)renderNewQuizLabel {
  [self.onAirNewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewOnAirAvailable];
  [self.retroCh3NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewRetroCh3Available];
  [self.retroCh5NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewRetroCh5Available];
  [self.retroCh7NewQuizLabel setHidden:![QuizManager sharedInstance].isTheNewRetroCh7Available];
}

- (void)renderLockIcon {
  NumNaoIAPHelper *IAPinstance = [NumNaoIAPHelper sharedInstance];

  BOOL isRetroCH3Purchased = IAPinstance.retroCh3Purchased;
  BOOL isRetroCH5Purchased = IAPinstance.retroCh5Purchased;
  BOOL isRetroCH7Purchased = IAPinstance.retroCh7Purchased;
  
  if (isRetroCH3Purchased) {
    self.retroCh3LockImageView.image = nil;
  } else {
    self.retroCh3LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
  
  if (isRetroCH5Purchased) {
    self.retroCh5LockImageView.image = nil;
  } else {
    self.retroCh5LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
  
  if (isRetroCH7Purchased) {
    self.retroCh7LockImageView.image = nil;
  } else {
    self.retroCh7LockImageView.image = [UIImage imageNamed:@"blue_lock_icon"];
  }
}

- (void)lockAllButtons:(BOOL)flag {
  self.onAirButton.enabled = !flag;
  self.retroCh3Button.enabled = !flag;
  self.retroCh5Button.enabled = !flag;
  self.retroCh7Button.enabled = !flag;
}

- (void)decorateAllButtons {
  NSArray *gameModeButtons = [NSArray arrayWithObjects: self.onAirButton, self.retroCh3Button, self.retroCh5Button, self.retroCh7Button, self.restorePurchaseButton, nil];
  
  for(UIButton *btn in gameModeButtons)
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
    
    if ([btn isEqual:self.restorePurchaseButton]) {
      UIColor *grayColor = [UIColor colorWithWhite:150.0f / 255.0f alpha:1.0f];
      btnGradient.colors = [NSArray arrayWithObjects:
                            (id)[grayColor CGColor],
                            (id)[grayColor CGColor],
                            nil];
    }
    
    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [btn layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around Buy Button
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    
  }
  
  NSArray *allQuizLabels = [NSArray arrayWithObjects: self.onAirNewQuizLabel,
                            self.retroCh3NewQuizLabel, self.retroCh5NewQuizLabel,
                            self.retroCh7NewQuizLabel, nil];
  for (UILabel *label in allQuizLabels) {
    // Round label corners
    CALayer *labelLayer = [label layer];
    [labelLayer setMasksToBounds:YES];
    [labelLayer setCornerRadius:20.0f];
  }
}

@end
