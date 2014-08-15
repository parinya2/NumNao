//
//  QuizManager.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizManager.h"
#import "QuizObject.h"
#import "TBXML.h"

@implementation QuizManager

- (NSString *)quizResultString:(NSInteger)quizScore {
  
  NSString *resultString = [NSString stringWithFormat:@"คุณได้ %ld คะแนน ท่าทางคุณจะติดละครน้ำเน่างอมแงมเลยทีเดียว", quizScore];
  
  return resultString;
}

- (NSArray *)quizList {
  NSMutableArray *result = [[NSMutableArray alloc] init];
  NSLog(@"startExtract");
  result = [self extractQuizFromXML];
  NSLog(@"finishExtract");
  return result;
}

- (NSArray *)mockQuizList {
  NSMutableArray *result = [[NSMutableArray alloc] init];

  for (int i = 0; i < 30; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 1 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:1];
    [result addObject:obj];
  }

  for (int i = 30; i < 60; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 2 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:2];
    [result addObject:obj];
  }
  
  for (int i = 60; i < 100; i++) {
    NSString *quizText = [NSString stringWithFormat:@"Level 3 Question %d", (i+1)];
    QuizObject *obj = [[QuizObject alloc] initWithQuizText:quizText
                                                ansChoice1:@"choice1"
                                                ansChoice2:@"choice2"
                                                ansChoice3:@"choice3"
                                                ansChoice4:@"choice4"
                                               answerIndex:1
                                                 quizLevel:3];
    [result addObject:obj];
  }
  
  return result;
}

- (NSMutableArray *)extractQuizFromXML {
  
  NSMutableArray *result = [[NSMutableArray alloc] init];
  
  NSString *urlString = @"http://quiz.thechappters.com/webservice.php?app_id=1&method=getQuiz&category_id=2";
  NSURL *url = [NSURL URLWithString:urlString];
  NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
  
  NSData *urlData;
  NSURLResponse *urlResponse;
  NSError *error;
  NSLog(@"Start Connecting");
  urlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&error];
  NSLog(@"End Connecting");
  NSString *xmlString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
  
  TBXML *tbxml = [TBXML newTBXMLWithXMLString:xmlString error:&error];

  TBXMLElement *rootXMLElement = tbxml.rootXMLElement;
  
  if (!rootXMLElement) {
    return nil;
  }
  
  TBXMLElement *childXMLElement = [TBXML childElementNamed:@"quiz" parentElement:rootXMLElement];
  while (childXMLElement) {
    
    QuizObject *quizObject = [[QuizObject alloc] init];
   
    quizObject.quizText = [TBXML valueOfAttributeNamed:@"quiz_text" forElement:childXMLElement];
    
    NSString *quizLevelStr = [TBXML valueOfAttributeNamed:@"quiz_level" forElement:childXMLElement];
    quizObject.quizLevel = [quizLevelStr integerValue];
    
    TBXMLElement *choicesListElement = [TBXML childElementNamed:@"choices" parentElement:childXMLElement];
    
    TBXMLElement *choiceElement = [TBXML childElementNamed:@"choice" parentElement:choicesListElement];

    while (choiceElement) {
      
      TBXMLAttribute *attribute = choiceElement->firstAttribute;
      NSString *choiceNo;
      NSString *choiceText;
      BOOL isCorrectChoice = NO;
      while (attribute) {
        NSString *attName = [TBXML attributeName:attribute];
        NSString *attValue = [TBXML attributeValue:attribute];
        
        if ([attName isEqualToString:@"choice_no"]) {
          choiceNo = attValue;
        } else if ([attName isEqualToString:@"choice_text"]) {
          choiceText = attValue;
        } else if ([attName isEqualToString:@"correct"]) {
          isCorrectChoice = [attValue isEqualToString:@"1"] ? YES : NO;
        }
      
        attribute = attribute->next;
      }
    
      if ([choiceNo isEqualToString:@"1"]) {
        quizObject.ansChoice1 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 1;
        }
      } else if ([choiceNo isEqualToString:@"2"]) {
        quizObject.ansChoice2 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 2;
        }
      } else if ([choiceNo isEqualToString:@"3"]) {
        quizObject.ansChoice3 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 3;
        }
      } else if ([choiceNo isEqualToString:@"4"]) {
        quizObject.ansChoice4 = choiceText;
        if (isCorrectChoice) {
          quizObject.answerIndex = 4;
        }
      }
      
      choiceElement = choiceElement->nextSibling;
    }
    
    [result addObject:quizObject];
    childXMLElement = childXMLElement->nextSibling;
  }

  
  return result;
}

@end
