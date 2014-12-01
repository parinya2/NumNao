//
//  QuizRankController.m
//  NumNao
//
//  Created by PRINYA on 11/30/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizRankController.h"
#import "QuizRankTableViewCell.h"
#import "NumNaoLoadingView.h"
#import "QuizManager.h"
#import "QuizRankObject.h"

const NSInteger QuizRankDisplayCount = 10;

@interface QuizRankController ()

@property (strong, nonatomic) NumNaoLoadingView *loadingView;
@property (strong, nonatomic) NSArray *quizRankList;
@property (strong, nonatomic) id quizManagerDidLoadQuizRankSuccessObserver;
@property (strong, nonatomic) id quizManagerDidLoadQuizRankFailObserver;

@end

@implementation QuizRankController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.quizRankTable.delegate = self;
  self.quizRankTable.dataSource = self;
  
  [self decorateAllButtonsAndLabel];
  
  [self hideEverything:YES];
  self.loadingView = [[NumNaoLoadingView alloc] init];
  [self.view addSubview:self.loadingView];
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
  
  __typeof(self) __weak weakSelf = self;
  
  self.quizManagerDidLoadQuizRankSuccessObserver =
  [[NSNotificationCenter defaultCenter]
   addObserverForName:QuizManagerDidLoadQuizRankSuccess
   object:nil
   queue:[NSOperationQueue mainQueue]
   usingBlock:^(NSNotification *note) {
     QuizManager *quizManager = [QuizManager sharedInstance];
     weakSelf.quizRankList = quizManager.quizRankList;
     [weakSelf rearrangeQuizRankList];
     
     [weakSelf.loadingView removeFromSuperview];
     [weakSelf hideEverything:NO];
     
     [weakSelf.quizRankTable reloadData];
   }];
  
  self.quizManagerDidLoadQuizRankFailObserver =
  [[NSNotificationCenter defaultCenter]
   addObserverForName:QuizManagerDidLoadQuizRankFail
   object:nil
   queue:[NSOperationQueue mainQueue]
   usingBlock:^(NSNotification *note) {
     [weakSelf.loadingView removeFromSuperview];
     [weakSelf hideEverything:NO];
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"เกิดข้อผิดพลาด"
                                                     message:@"เธอต้องต่อ internet ก่อนนะถึงจะดูตารางคะแนนได้น่ะ แต่ถ้ายังเล่นไม่ได้อีก แสดงว่าเซิร์ฟเวอร์มีปัญหาน่ะ รอสักพักแล้วลองใหม่นะ"
                                                    delegate:self
                                           cancelButtonTitle:@"ตกลงจ้ะ"
                                           otherButtonTitles:nil];
     alert.tag = 100;
     [alert show];
   }];
  
  [[QuizManager sharedInstance] loadQuizRankFromServer:self.quizMode quizScore:self.playerScore];
  
//   [self.quizRankTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:10 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizRankSuccessObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizRankFailObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];

  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizRankSuccessObserver];
  [[NSNotificationCenter defaultCenter] removeObserver:self.quizManagerDidLoadQuizRankFailObserver];
}

- (void)setUpAudioPlayer {
  NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"bold_valor" ofType:@"mp3"]];
  self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
  self.audioPlayer.volume = 1.0;
  self.audioPlayer.numberOfLoops = -1;
  [self.audioPlayer play];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.quizRankList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  QuizRankTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuizRankCell"];
  NSInteger idx = indexPath.row;
  if (idx < self.quizRankList.count) {
    QuizRankObject *quizRankObject = self.quizRankList[idx];
    cell.rankNoLabel.text = [NSString stringWithFormat:@"อันดับ %zd", quizRankObject.rankNo];
    cell.playerNameLabel.text = quizRankObject.playerName;
    cell.scoreLabel.text = [NSString stringWithFormat:@"%zd คะแนน", quizRankObject.score];
    
    if (quizRankObject.isActivePlayer) {
      UIColor *yellowColor = [UIColor colorWithRed:227.0f / 255.0f green:214.0f / 255.0f blue:97.0f / 255.0f alpha:1.0f];
      cell.rankNoLabel.textColor = yellowColor;
      cell.playerNameLabel.textColor = yellowColor;
      cell.scoreLabel.textColor = yellowColor;
    }
  }

  
  return cell;
}

- (void)rearrangeQuizRankList {

  NSArray *scoreList = [self.quizRankList valueForKey:@"score"];
  
  for (QuizRankObject *quizRankObj in self.quizRankList) {
    if (quizRankObj.isActivePlayer) {
      quizRankObj.playerName = self.playerName;
    }

    NSPredicate *scorePredicate = [NSPredicate predicateWithFormat:@"score > %d", quizRankObj.score];
    NSArray *greaterScoreList = [self.quizRankList filteredArrayUsingPredicate:scorePredicate];
    if (!quizRankObj.isActivePlayer) {
      quizRankObj.rankNo = greaterScoreList.count + 1;
    }
  }
  
  NSArray *sortedQuizRankList = [self.quizRankList sortedArrayUsingComparator:^NSComparisonResult(QuizRankObject *obj1, QuizRankObject *obj2) {
    if (obj1.score > obj2.score) {
      return NSOrderedAscending;
    } else if (obj1.score < obj2.score) {
      return NSOrderedDescending;
    } else {
      return NSOrderedSame;
    }
  }];
  
  self.quizRankList = [sortedQuizRankList copy];
}

- (IBAction)goBack:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)decorateAllButtonsAndLabel {
  
  // Set the button Text Color
  [self.backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
  [self.backButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
  
  // Round button corners
  CALayer *backBtnLayer = [self.backButton layer];
  [backBtnLayer setMasksToBounds:YES];
  [backBtnLayer setCornerRadius:5.0f];
  
  // Apply a 1 pixel, black border around Buy Button
  [backBtnLayer setBorderWidth:1.0f];
  [backBtnLayer setBorderColor:[[UIColor blackColor] CGColor]];
}

- (void)hideEverything:(BOOL)flag {
  [self.quizRankTable setHidden:flag];
  [self.backButton setHidden:flag];
  [self.quizModeLabel setHidden:flag];
}

@end
