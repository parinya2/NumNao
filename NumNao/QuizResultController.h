//
//  QuizResultController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizManager.h"
#import "GADBannerView.h"

@interface QuizResultController : UIViewController <GADBannerViewDelegate> {
  GADBannerView *bannerView_;
}


@property (assign, nonatomic) NSInteger quizScore;
@property (assign, nonatomic) NSInteger quizMode;
@property (strong) IBOutlet UILabel *quizResultLabel;
@property (strong) IBOutlet UIButton *shareFacebookButton;
@property (strong) IBOutlet UIButton *backToMenuButton;
@property (strong) QuizManager *quizManager;
@property (nonatomic, strong) GADBannerView *bannerView;

- (GADRequest *)createRequest;
- (IBAction)goToMainMenu:(id)sender;
- (IBAction)shareOnFacebook:(id)sender;

@end
