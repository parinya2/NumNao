//
//  QuizManager.m
//  NumNao
//
//  Created by PRINYA on 4/12/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "QuizManager.h"
#import "QuizObject.h"

@implementation QuizManager

- (NSString *)quizResultString:(NSInteger)quizScore {
  
  NSString *resultString = [NSString stringWithFormat:@"คุณได้ %ld คะแนน ท่าทางคุณจะติดละครน้ำเน่างอมแงมเลยทีเดียว", quizScore];
  
  return resultString;
}

- (NSArray *)quizList {
  NSMutableArray *result = [[NSMutableArray alloc] init];

  QuizObject *quizObj1 = [[QuizObject alloc] initWithQuizText:@"ถ้าแกยังไม่หยุดปากดี ฉันจะเอาแกงส้มราดหัวแกเดี๋ยวนี้แหละ"
                                                   ansChoice1:@"สามีตีตรา"
                                                   ansChoice2:@"อีสารวีโชติช่วง"
                                                   ansChoice3:@"เจ้าสาวสลาตัน"
                                                   ansChoice4:@"ลูกทาส"
                                                  answerIndex:1];

  QuizObject *quizObj2 = [[QuizObject alloc] initWithQuizText:@"อีแดง แกไปยกสำรับมาให้ท่านเจ้าคุณซะทีสิ อย่ามัวพิรี้พิไร"
                                                   ansChoice1:@"อย่าลืมฉัน"
                                                   ansChoice2:@"ลูกทาส"
                                                   ansChoice3:@"ล่ารักสุดขอบฟ้า"
                                                   ansChoice4:@"คมพยาบาท"
                                                  answerIndex:1];

  QuizObject *quizObj3 = [[QuizObject alloc] initWithQuizText:@"ตอนนี้ผัวแกกำลังนอนอยู่บนเตียงของชั้น มาดูให้เต็มตาสิ"
                                                   ansChoice1:@"พายุเทวดา"
                                                   ansChoice2:@"อีสารวีโชติช่วง"
                                                   ansChoice3:@"เจ้าสาวสลาตัน"
                                                   ansChoice4:@"คิวบิก"
                                                  answerIndex:1];
  
  QuizObject *quizObj4 = [[QuizObject alloc] initWithQuizText:@"ถ้าแกยอมกราบเท้าของชั้นตอนนี้ล่ะก็ ชั้นสัญญาว่าจะไม่เอาเรื่องบัดสีที่แกทำไปบอกคุณย่า"
                                                   ansChoice1:@"สามีตีตรา"
                                                   ansChoice2:@"คุ้มนางครวญ"
                                                   ansChoice3:@"กุหลาบร้ายของนายตะวัน"
                                                   ansChoice4:@"ลูกทาส"
                                                  answerIndex:1];
  
  QuizObject *quizObj5 = [[QuizObject alloc] initWithQuizText:@"นังแพศยานี่มันกำแหงจริงๆ คุณหญิงตบสั่งสอนมันเลยค่ะ"
                                                   ansChoice1:@"เนตรนาคราช"
                                                   ansChoice2:@"อีสารวีโชติช่วง"
                                                   ansChoice3:@"เจ้าสาวสลาตัน"
                                                   ansChoice4:@"ลูกทาส"
                                                  answerIndex:1];
  
  [result addObject:quizObj1];
  [result addObject:quizObj2];
  [result addObject:quizObj3];
  [result addObject:quizObj4];
  [result addObject:quizObj5];
  
  return result;
}

@end
