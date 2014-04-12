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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 88.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuizListCell" forIndexPath:indexPath];
    
  if (indexPath.row == 0) {
    cell.textLabel.text = @"ชุดคำถามล่าสุด 1 พ.ค. 2557";
  } else if (indexPath.row == 1) {
    cell.textLabel.text = @"ชุดคำถาม วันที่ 1 เม.ย. 2557";
  } else if (indexPath.row == 2) {
    cell.textLabel.text = @"ชุดคำถาม วันที่ 8 เม.ย. 2557";
  } else if (indexPath.row == 3) {
    cell.textLabel.text = @"ชุดคำถาม วันที่ 15 เม.ย. 2557";
  } else if (indexPath.row == 4) {
    cell.textLabel.text = @"ชุดคำถาม วันที่ 22 เม.ย. 2557";
  }
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  QuizDetailController *quizDetailController = [storyboard instantiateViewControllerWithIdentifier:@"QuizDetail"];
  [self.navigationController pushViewController:quizDetailController animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
