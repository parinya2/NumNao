//
//  QuizSetSelectorController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizSetSelectorController.h"
#import "QuizDetailController.h"

@interface QuizSetSelectorController ()

@end

@implementation QuizSetSelectorController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (IBAction)goToQuiz:(id)sender {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
  [self.navigationController pushViewController:quizDetailController animated:YES];
}


@end
