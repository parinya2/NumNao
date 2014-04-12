//
//  QuizManager.h
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuizManager : NSObject

@property (strong) NSArray *quizResult;

- (NSArray *)quizList;
- (NSString *)quizResultString:(NSInteger)quizScore;

@end
