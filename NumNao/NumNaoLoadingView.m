//
//  NumNaoLoadingView.m
//  NumNao
//
//  Created by PRINYA on 8/11/2557 BE.
//  Copyright (c) 2557 PRINYA. All rights reserved.
//

#import "NumNaoLoadingView.h"

@interface NumNaoLoadingView ()

@end

@implementation NumNaoLoadingView

- (id)init
{
  CGRect frame = CGRectMake(75, 200, 170, 90);
  self = [self initWithFrame:frame];
  return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
      self.clipsToBounds = YES;
      self.layer.cornerRadius = 10.0;
      
      UIActivityIndicatorView *spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
      spinnerView.frame = CGRectMake(65, 10, spinnerView.bounds.size.width, spinnerView.bounds.size.height);
      //spinnerView.center = self.center;
      spinnerView.hidesWhenStopped = YES;
      [self addSubview:spinnerView];
      [spinnerView startAnimating];
      
      UILabel *loadingCaption = [[UILabel alloc] initWithFrame:CGRectMake(20, 45, 130, 22)];
      loadingCaption.backgroundColor = [UIColor clearColor];
      loadingCaption.textColor = [UIColor whiteColor];
      loadingCaption.adjustsFontSizeToFitWidth = YES;
      loadingCaption.textAlignment = NSTextAlignmentCenter;
      loadingCaption.text = @"รอแป๊บนึงนะจ๊ะ...";
      
      [self addSubview:loadingCaption];
    }
    return self;
}


@end
