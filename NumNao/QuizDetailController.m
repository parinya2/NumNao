//
//  QuizDetailController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizDetailController.h"
#import "QuizManager.h"
#import "QuizObject.h"
#import "QuizResultController.h"

@interface QuizDetailController ()

@property NSInteger quizCounter;
@property NSInteger quizScore;
@property NSInteger selectedAnswer;
@property BOOL isAnswerConfirmed;
@property (strong) NSArray *quizList;
@property (strong) UIColor *neutralButtonColor;
@property (strong) UIColor *selectedButtonColor;
@property (strong) QuizManager *quizManager;

- (IBAction)chooseAnswer:(id)sender;
- (IBAction)confirmAnswer:(id)sender;
- (IBAction)goToNextQuiz:(id)sender;


@end

@implementation QuizDetailController

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
  // Do any additional setup after loading the view.
  self.quizManager = [[QuizManager alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  self.quizCounter = 0;
  self.quizScore = 0;
  self.quizList = [self.quizManager quizList];
  
  self.neutralButtonColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
  self.selectedButtonColor = [UIColor colorWithRed:80.0/255.0 green:255.0/255.0 blue:80.0/255.0 alpha:1.0];
  
  QuizObject *firstQuiz = [self.quizList objectAtIndex:self.quizCounter];
  [self renderPageWithQuizObject:firstQuiz quizNo:self.quizCounter+1];
  
  [self enableNextButton:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)renderPageWithQuizObject:(QuizObject *) quizObject quizNo:(NSInteger) quizNo{
  self.quizCounterLabel.text = [NSString stringWithFormat:@"ข้อที่ %ld",quizNo];
  self.quizLabel.text = quizObject.quizText;

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
  
  if ([self.confirmButton isEnabled]) {
    self.selectedAnswer = ((UIButton *)sender).tag;
    
    self.ans1Button.backgroundColor = self.neutralButtonColor;
    self.ans2Button.backgroundColor = self.neutralButtonColor;
    self.ans3Button.backgroundColor = self.neutralButtonColor;
    self.ans4Button.backgroundColor = self.neutralButtonColor;
    
    switch (self.selectedAnswer) {
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
  }
}

- (IBAction)confirmAnswer:(id)sender {
  // Check whether users selected the correct answer
  if (self.selectedAnswer != 0) {
    if (self.selectedAnswer == 1) {
      self.correctionImageView.image = [UIImage imageNamed:@"right_icon"];
      self.quizScore++;
    } else {
      self.correctionImageView.image = [UIImage imageNamed:@"wrong_icon"];
    }
    
    [self enableNextButton:YES];
  }

}

- (IBAction)goToNextQuiz:(id)sender {
  
  // Users already confirm the answer, so we go to the next quiz
  self.quizCounter++;
  
  if (self.quizCounter < self.quizList.count) {
    QuizObject *nextQuiz = [self.quizList objectAtIndex:self.quizCounter];
    self.selectedAnswer = 0;
    [self renderPageWithQuizObject:nextQuiz quizNo:self.quizCounter+1];
    
  } else {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    QuizResultController *quizResultController = [storyboard instantiateViewControllerWithIdentifier:@"QuizResult"];
    quizResultController.quizScore = self.quizScore;
    quizResultController.quizManager = self.quizManager;
    [self.navigationController pushViewController:quizResultController animated:YES];
  }
  
  [self enableNextButton:NO];
}

- (void)enableNextButton:(BOOL)flag {
  [self.nextButton setEnabled:flag];
  [self.confirmButton setEnabled:!flag];
  
  [self.nextButton setHidden:!flag];
  [self.confirmButton setHidden:flag];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  QuizResultController *quizResultController = [segue destinationViewController];
  quizResultController.quizScore = self.quizScore;
  quizResultController.quizManager = self.quizManager;
}

@end
