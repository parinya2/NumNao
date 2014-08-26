//
//  QuizManager.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const QuizManagerDidLoadQuizSuccess;
extern NSString * const QuizManagerDidLoadQuizFail;

typedef NS_ENUM(NSInteger, NumNaoQuizMode) {
  NumNaoQuizModeOnAir = 0,
  NumNaoQuizModeRetroCh3 = 1,
  NumNaoQuizModeRetroCh5 = 2,
  NumNaoQuizModeRetroCh7 = 3,
};

@interface QuizManager : NSObject

@property (strong) NSArray *quizListOnAir;
@property (strong) NSArray *quizListRetroCh3;
@property (strong) NSArray *quizListRetroCh5;
@property (strong) NSArray *quizListRetroCh7;

- (NSArray *)quizList:(NSInteger)quizMode;
- (NSArray *)mockQuizList;
- (NSString *)quizResultString:(NSInteger)quizScore;
- (void)loadQuizListFromServer:(NSInteger)quizMode;

+ (QuizManager *)sharedInstance;

@end
