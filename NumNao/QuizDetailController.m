//
//  QuizDetailController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizDetailController.h"
#import "QuizSetSelectorController.h"
#import "QuizManager.h"
#import "QuizObject.h"
#import "QuizResultController.h"
#import "NumNaoLoadingView.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "appID.h"
#import "AVFoundation/AVAudioPlayer.h"

const NSInteger QuizScoreToPassLevel1 = 8;
const NSInteger QuizScoreToPassLevel2 = 16;

@interface QuizDetailController ()

@property NSInteger quizCounter;
@property NSInteger quizScore;
@property NSInteger selectedAnswerIndex;
@property NSInteger correctAnswerIndex;
@property BOOL isAnswerConfirmed;
@property (strong) NSArray *quizList;
@property (strong) NSMutableArray *quizListLevel1;
@property (strong) NSMutableArray *quizListLevel2;
@property (strong) NSMutableArray *quizListLevel3;
@property (strong) UIColor *neutralButtonColor;
@property (strong) UIColor *selectedButtonColor;
@property (strong) QuizManager *quizManager;
@property (strong) NSTimer *timer;
@property NSInteger remainingTime;

@property (strong, nonatomic) UIActivityIndicatorView *spinnerView;
@property (strong, nonatomic) NumNaoLoadingView *loadingView;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (IBAction)chooseAnswer:(id)sender;
- (IBAction)confirmAnswer:(id)sender;
- (IBAction)goToNextQuiz:(id)sender;


@end

@implementation QuizDetailController
@synthesize bannerView = bannerView_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  [self setUpAudioPlayer];
  
  float yPos = self.ans2Button.frame.origin.y + self.ans2Button.frame.size.height - 5;
  self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(400.0, yPos, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
  self.bannerView.adUnitID = MyAdUnitID;
  self.bannerView.delegate = self;
  [self.bannerView setRootViewController:self];
  [self.view addSubview:self.bannerView];
  [self.bannerView loadRequest:[self createRequest]];
  
  self.quizManager = [[QuizManager alloc] init];
  [self.confirmButton setHidden:YES];

  self.loadingView = [[NumNaoLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  [self decorateAllButtonsAndLabel];
  
  self.remainingTime = 45;
  self.quizCounter = 0;
  self.quizScore = 0;
  self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
  self.remainingTimeLabel.text = [self stringForRemainingTimeLabel:self.remainingTime];
  
  self.quizList = [self.quizManager quizList:self.quizMode];

  [self.loadingView removeFromSuperview];
  
  if (!self.quizList) {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"เกิดข้อผิดพลาด"
                                                    message:@"เธอต้องต่อ internet ก่อนนะถึงจะเล่นได้น่ะ แต่ถ้ายังเล่นไม่ได้อีก แสดงว่าเซิร์ฟเวอร์มีปัญหาน่ะ รอสักพักแล้วลองใหม่นะ"
                                                   delegate:self
                                          cancelButtonTitle:@"ตกลงจ้ะ"
                                          otherButtonTitles:nil];
    alert.tag = 100;
    [alert show];
    return;
  }

  self.neutralButtonColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
  self.selectedButtonColor = [UIColor colorWithRed:80.0/255.0 green:255.0/255.0 blue:80.0/255.0 alpha:1.0];
  
  [self extractQuizByLevel];
  QuizObject *quizObject = [self randomQuiz];
  [self renderPageWithQuizObject:quizObject quizNo:self.quizCounter+1];
  
  [self enableNextButton:NO];
  
  if (!self.timer) {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(decreaseRemainingTime)
                                                userInfo:nil
                                                 repeats:YES];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [self.audioPlayer stop];
  [self.timer invalidate];
  self.timer = nil;
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"a_day_in_the_sun" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)extractQuizByLevel {
  NSIndexSet *quizLevel1Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 1;
  }];
  
  NSIndexSet *quizLevel2Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 2;
  }];
  
  NSIndexSet *quizLevel3Indexes = [self.quizList indexesOfObjectsPassingTest:^BOOL(QuizObject *quizObj, NSUInteger idx, BOOL *stop) {
    return quizObj.quizLevel == 3;
  }];
  self.quizListLevel1 = [[self.quizList objectsAtIndexes:quizLevel1Indexes] mutableCopy];
  self.quizListLevel2 = [[self.quizList objectsAtIndexes:quizLevel2Indexes] mutableCopy];
  self.quizListLevel3 = [[self.quizList objectsAtIndexes:quizLevel3Indexes] mutableCopy];
}

- (QuizObject *)randomQuiz {
  QuizObject *quizObject = nil;
  if (self.quizMode == NumNaoQuizModeOnAir) {
    
    if (self.quizScore < QuizScoreToPassLevel1) {
      if ([self.quizListLevel1 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex = arc4random() % [self.quizListLevel1 count];
      quizObject = [self.quizListLevel1 objectAtIndex:randomIndex];
      [self.quizListLevel1 removeObjectAtIndex:randomIndex];
      
    } else if (self.quizScore < QuizScoreToPassLevel2) {
      if ([self.quizListLevel2 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex = arc4random() % [self.quizListLevel2 count];
      quizObject = [self.quizListLevel2 objectAtIndex:randomIndex];
      [self.quizListLevel2 removeObjectAtIndex:randomIndex];
      
    } else {
      if ([self.quizListLevel3 count] == 0) {
        [self extractQuizByLevel];
      }
      NSUInteger randomIndex = arc4random() % [self.quizListLevel3 count];
      quizObject = [self.quizListLevel3 objectAtIndex:randomIndex];
      [self.quizListLevel3 removeObjectAtIndex:randomIndex];
    }
  } else {
    if ([self.quizListLevel1 count] == 0) {
      [self extractQuizByLevel];
    }
    NSUInteger randomIndex = arc4random() % [self.quizListLevel1 count];
    quizObject = [self.quizListLevel1 objectAtIndex:randomIndex];
    [self.quizListLevel1 removeObjectAtIndex:randomIndex];
  }
  return quizObject;
}

- (GADRequest *)createRequest {
  GADRequest *request = [GADRequest request];
  request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
  return request;
}

- (void)adViewDidReceiveAd:(GADBannerView *)adView {
  __block float yPos = self.ans2Button.frame.origin.y + self.ans2Button.frame.size.height + 5;
  [UIView animateWithDuration:1.0 animations:^{
    adView.frame = CGRectMake(0.0, yPos, adView.frame.size.width, adView.frame.size.height);
  }];
}

- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error {
  NSLog(@"Failed to receive ad due to: %@", [error localizedFailureReason]);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  switch (alertView.tag) {
    case 100: {
      [self performSegueWithIdentifier:@"QuizDetailMainMenuSegue" sender:self];
    } break;
    default: break;
  }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)decreaseRemainingTime {
  self.remainingTime--;
  self.remainingTimeLabel.text = [self stringForRemainingTimeLabel:self.remainingTime];
  if (self.remainingTime <= 0) {
    [self goToSummaryPage];
  }
}

- (NSString *)stringForRemainingTimeLabel:(NSInteger) remainingTime {
  NSInteger time = remainingTime < 0 ? 0 : remainingTime;
  return [NSString stringWithFormat:@"คุณเหลือ %ld วินาที",time];
}

- (NSString *)stringForScoreLabel:(NSInteger) score {
  return [NSString stringWithFormat:@"คุณได้ %ld คะแนน",score];
}

- (void)renderPageWithQuizObject:(QuizObject *) quizObject quizNo:(NSInteger) quizNo{
  self.quizCounterLabel.text = [NSString stringWithFormat:@"ข้อที่ %ld",quizNo];
  self.quizLabel.text = quizObject.quizText;
  self.correctAnswerIndex = quizObject.answerIndex;
  self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
  
  [self.ans1Button setTitle:quizObject.ansChoice1 forState:UIControlStateNormal];
  [self.ans2Button setTitle:quizObject.ansChoice2 forState:UIControlStateNormal];
  [self.ans3Button setTitle:quizObject.ansChoice3 forState:UIControlStateNormal];
  [self.ans4Button setTitle:quizObject.ansChoice4 forState:UIControlStateNormal];

  self.ans1Button.backgroundColor = self.neutralButtonColor;
  self.ans2Button.backgroundColor = self.neutralButtonColor;
  self.ans3Button.backgroundColor = self.neutralButtonColor;
  self.ans4Button.backgroundColor = self.neutralButtonColor;

  self.correctionImageView.image = nil;
}

- (IBAction)chooseAnswer:(id)sender {
  
  if (![self.nextButton isEnabled]) {
    self.selectedAnswerIndex = ((UIButton *)sender).tag;
    
    self.ans1Button.backgroundColor = self.neutralButtonColor;
    self.ans2Button.backgroundColor = self.neutralButtonColor;
    self.ans3Button.backgroundColor = self.neutralButtonColor;
    self.ans4Button.backgroundColor = self.neutralButtonColor;
    
    switch (self.selectedAnswerIndex) {
      case 1:
        self.ans1Button.backgroundColor = self.selectedButtonColor;
        break;
      case 2:
        self.ans2Button.backgroundColor = self.selectedButtonColor;
        break;
      case 3:
        self.ans3Button.backgroundColor = self.selectedButtonColor;
        break;
      case 4:
        self.ans4Button.backgroundColor = self.selectedButtonColor;
        break;
      default:
        break;
    }
    
    [self checkAnswer];
  }
}

- (void)checkAnswer {
  // Check whether users selected the correct answer
  if (self.selectedAnswerIndex != 0) {
    if (self.selectedAnswerIndex == self.correctAnswerIndex) {
      self.correctionImageView.image = [UIImage imageNamed:@"right_icon"];
      self.quizScore++;
      self.scoreLabel.text = [self stringForScoreLabel:self.quizScore];
      self.remainingTimeLabel.text = [self stringForRemainingTimeLabel:self.remainingTime];
    } else {
      self.correctionImageView.image = [UIImage imageNamed:@"wrong_icon"];
      self.remainingTime = (self.remainingTime - 3) < 0 ? 0 : (self.remainingTime - 3);
    }
    
    [self enableNextButton:YES];
  }
}

- (IBAction)confirmAnswer:(id)sender {
  // Check whether users selected the correct answer
  [self checkAnswer];
}

- (IBAction)goToNextQuiz:(id)sender {
  
  // Users already confirm the answer, so we go to the next quiz
  self.quizCounter++;
  
  QuizObject *nextQuiz = [self randomQuiz];
  self.selectedAnswerIndex = 0;
  [self renderPageWithQuizObject:nextQuiz quizNo:self.quizCounter+1];
  
  [self enableNextButton:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"QuizDetailToQuizResultSegue"]) {
    QuizResultController *quizResultController = [segue destinationViewController];
    quizResultController.quizScore = self.quizScore;
    quizResultController.quizMode = self.quizMode;
    quizResultController.quizManager = self.quizManager;
  }
}

- (void)goToSummaryPage {
  [self performSegueWithIdentifier:@"QuizDetailToQuizResultSegue" sender:self];
  
//  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//  QuizResultController *quizResultController = [storyboard instantiateViewControllerWithIdentifier:@"QuizResult"];
//  quizResultController.quizScore = self.quizScore;
//  quizResultController.quizMode = self.quizMode;
//  quizResultController.quizManager = self.quizManager;
//  [self.navigationController pushViewController:quizResultController animated:YES];
}

- (void)enableNextButton:(BOOL)flag {
  [self.nextButton setEnabled:flag];
  [self.confirmButton setEnabled:!flag];
  
  [self.nextButton setHidden:!flag];
  [self.confirmButton setHidden:YES];
}

- (void)decorateAllButtonsAndLabel {
  
  // Draw a custom gradient for quizLabel
  CAGradientLayer *quizLabelGradient = [CAGradientLayer layer];
  quizLabelGradient.frame = self.quizLabel.bounds;
  quizLabelGradient.colors = [NSArray arrayWithObjects:
                        (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:0.3f] CGColor],
                        (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:0.3f] CGColor],
                        nil];
  [self.quizLabel.layer insertSublayer:quizLabelGradient atIndex:0];
  [[self.quizLabel layer] setCornerRadius:5.0];
  
  NSArray *buttons = [NSArray arrayWithObjects: self.ans1Button, self.ans2Button, self.ans3Button, self.ans4Button, self.nextButton, nil];
  
  for(UIButton *btn in buttons) {
    
    // Draw a custom gradient for button
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = btn.bounds;
    
    if ([btn isEqual:self.nextButton]) {
      btnGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:240.0f / 255.0f green:200.0f / 255.0f blue:120.0f / 255.0f alpha:0.3f] CGColor],
                            (id)[[UIColor colorWithRed:200.0f / 255.0f green:150.0f / 255.0f blue:70.0f / 255.0f alpha:0.3f] CGColor],
                            nil];
    } else {
      btnGradient.colors = [NSArray arrayWithObjects:
                            (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:0.3f] CGColor],
                            (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:0.3f] CGColor],
                            nil];
    }

    [btn.layer insertSublayer:btnGradient atIndex:0];
    
    [[btn layer] setMasksToBounds:YES];
    [[btn layer] setCornerRadius:5.0];
  }
}
@end
