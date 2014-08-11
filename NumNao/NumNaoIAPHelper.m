//
//  NumNaoIAPHelper.m
//  NumNao
//
//  Created by PRINYA on 8/7/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumNaoIAPHelper.h"

@implementation NumNaoIAPHelper

+ (NumNaoIAPHelper *)sharedInstance {
  static dispatch_once_t once;
  static NumNaoIAPHelper *sharedInstance;
  dispatch_once(&once, ^{
    NSSet *productIdentifiers = [NSSet setWithObjects:
                                 @"com.thechappters.NumNao.retroch3",
                                 @"com.thechappters.NumNao.retroch5",
                                 @"com.thechappters.NumNao.retroch7",
                                 nil];
    sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
  });
  return sharedInstance;
}

@end
