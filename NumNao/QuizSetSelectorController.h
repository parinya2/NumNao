//
//  QuizSetSelectorController.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuizSetSelectorController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *onAirButton;
@property (strong, nonatomic) IBOutlet UIButton *retroCh3Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh5Button;
@property (strong, nonatomic) IBOutlet UIButton *retroCh7Button;

@property (strong, nonatomic) IBOutlet UIImageView *retroCh3LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh5LockImageView;
@property (strong, nonatomic) IBOutlet UIImageView *retroCh7LockImageView;

- (IBAction)goToQuiz:(id)sender;

@end
