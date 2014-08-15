//
//  QuizSetSelectorController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

typedef NS_ENUM(NSInteger, NumNaoQuizMode) {
  NumNaoQuizModeOnAir = 0,
  NumNaoQuizModeRetroCh3 = 1,
  NumNaoQuizModeRetroCh5 = 2,
  NumNaoQuizModeRetroCh7 = 3,
};

@interface QuizSetSelectorController : UIViewController <UIAlertViewDelegate, GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}


@property (strong, nonatomic) IBOutlet UIButton *onAirButton;
@property (strong, nonatomic) IBOutlet UIButton *retroCh3Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh5Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh7Button;

@property (strong, nonatomic) IBOutlet UIImageView *retroCh3LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh5LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh7LockImageView;
@property (nonatomic, strong) GADBannerView *bannerView;

- (GADRequest *)createRequest;
- (IBAction)goToQuiz:(id)sender;

@end
