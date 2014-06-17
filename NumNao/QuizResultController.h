//
//  QuizResultController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuizManager.h"

@interface QuizResultController : UIViewController

@property NSInteger quizScore;
@property (strong) IBOutlet UILabel *quizResultLabel;
@property (strong) QuizManager *quizManager;

- (IBAction)goToMainMenu:(id)sender;
- (IBAction)shareOnFacebook:(id)sender;

@end
