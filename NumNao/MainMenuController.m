//
//  MainMenuController.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "MainMenuController.h"
#import "TBXML.h"

@interface MainMenuController ()

- (IBAction)testHTTP:(id)sender;
- (IBAction)testCon:(id)sender;

@end

@implementation MainMenuController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)testHTTP:(id)sender {
  return;
  NSString *urlString = @"http://quiz.thechappters.com/webservice.php?category=namnao&method=getQuiz&quiz_no=0&quiz_of_the_week=true";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  
  NSData *urlData;
  NSURLResponse *urlResponse;
  NSError *error;
  
  urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
  
  NSString *result = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
  NSLog(@"xx=%@",result);

  TBXML *tbxml = [TBXML newTBXMLWithXMLString:result error:&error];
  
  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;
  TBXMLElement *childXMLElement = [TBXML childElementNamed:@"quiz" parentElement:rootXMLElement];
  while (childXMLElement) {

    NSString *x = [TBXML valueOfAttributeNamed:@"quiz_text" forElement:childXMLElement];
    NSLog(@"quizText=%@",x);
    
    TBXMLElement *choicesListElement = [TBXML childElementNamed:@"choices" parentElement:childXMLElement];
    
    TBXMLElement *choiceElement = [TBXML childElementNamed:@"choice" parentElement:choicesListElement];
    while (choiceElement) {
      
      TBXMLAttribute *attribute = choiceElement->firstAttribute;
      while (attribute) {
        NSLog(@"attName=%@ attVal=%@",[TBXML attributeName:attribute], [TBXML attributeValue:attribute]);
        
        attribute = attribute->next;
      }
      choiceElement = choiceElement->nextSibling;
    }
    
    childXMLElement = childXMLElement->nextSibling;
  }
}

- (IBAction)testCon:(id)sender {
  NSString *urlString = @"http://quiz.thechappters.com/webservice.php";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  
  NSData *urlData;
  NSURLResponse *urlResponse;
  NSError *error;
  
  urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
  
  NSString *result = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
  NSLog(@"xx=%@",result);
}

@end
