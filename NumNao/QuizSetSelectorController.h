//
//  QuizSetSelectorController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GADBannerView.h"

@interface QuizSetSelectorController : UIViewController <UIAlertViewDelegate, GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}


@property (strong, nonatomic) IBOutlet UIButton *onAirButton;
@property (strong, nonatomic) IBOutlet UIButton *retroCh3Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh5Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh7Button;
@property (strong, nonatomic) IBOutlet UIButton *restorePurchaseButton;

@property (strong, nonatomic) IBOutlet UIImageView *retroCh3LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh5LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh7LockImageView;

@property (strong, nonatomic) IBOutlet UILabel *onAirNewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *retroCh3NewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *retroCh5NewQuizLabel;
@property (strong, nonatomic) IBOutlet UILabel *retroCh7NewQuizLabel;

@property (nonatomic, strong) GADBannerView *bannerView;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

- (GADRequest *)createRequest;
- (IBAction)goToQuiz:(id)sender;
- (IBAction)restorePurchase:(id)sender;

@end
