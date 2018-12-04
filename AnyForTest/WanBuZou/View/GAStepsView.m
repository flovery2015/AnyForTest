//
//  GAStepsView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAStepsView.h"


@interface GAStepsView ()
{
    NSInteger _accuracyStep;
    NSInteger _targetStep;
    NSInteger _tempNum;
}

@property(nonatomic,strong)NSTimer *timer;

@end

@implementation GAStepsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)tap{
    
    if ([self.delegate respondsToSelector:@selector(didClickStepsView:)]) {
        [self.delegate didClickStepsView:self];
    }
}

- (void)startAnimationWithTargetStep:(NSInteger)targetStep accuracyStep:(NSInteger)accuracyStep animation:(BOOL)animation
{
    self.bottomLabel.text = [NSString stringWithFormat:@"今日目标:%@",[NSString separatedDigitStringWithStr:[NSString stringWithFormat:@"%ld",targetStep]]];
    if (targetStep == 0) {
        [self contentLabelText:@"0"];
        return;
    }
    
    _accuracyStep = accuracyStep;
    _targetStep = targetStep;
    
    self.percent = _accuracyStep >= _targetStep?1.0:(CGFloat)accuracyStep/targetStep;
    
    [self startAnimation:animation];
    
    if (!animation || self.percent == 0) {
        [self contentLabelText:[NSString stringWithFormat:@"%ld",(long)_accuracyStep]];
    }else{
        _tempNum = 0;
        [self.timer setFireDate:[NSDate distantPast]];
    }
}

- (void)handleTimer
{
    _tempNum+=20;
    NSString *str;
    if (_tempNum >= _accuracyStep) {
        str = [NSString stringWithFormat:@"%ld",(long)_accuracyStep];
        [_timer invalidate];
        _timer = nil;
    }else{
        str = [NSString stringWithFormat:@"%ld",(long)_tempNum];
    }
    [self contentLabelText:str];
}


- (UIImageView *)logoImageView
{
    if (!_logoImageView) {
        CGFloat width = 20;
        _logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - width)*0.5, self.progressWidth + GAFloat(15), width, width)];
        [self addSubview:_logoImageView];
    }
    return _logoImageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        CGFloat height = 15;
        CGFloat width = 40;
        CGFloat x = (self.frame.size.width - width)*0.5;
        CGFloat y = CGRectGetMinY(self.contentLabel.frame)-height;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:10];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = kCOLOR_999999;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (NSTimer *)timer
{
    if (!_timer) {
        CGFloat time = self.oneCirleAnimationDuration * self.percent/_accuracyStep;
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [_timer setFireDate:[NSDate distantFuture]];

    }
    return _timer;
}

- (UILabel *)contentLabel
{
    if (!_contentLabel) {
        CGFloat height = GAFloat(35);
        CGFloat width = self.frame.size.width - self.progressWidth*2-10;
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.bounds = CGRectMake(0, 0, width, height);
        _contentLabel.center =CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UILabel *)bottomLabel
{
    if (!_bottomLabel) {
        CGFloat height = 15;
        CGFloat width = 80;
        CGFloat x = (self.frame.size.width - width)*0.5;
        CGFloat y = CGRectGetMaxY(self.contentLabel.frame)+GAFloat(10);
        _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.textColor = [UIColor colorWithHex:0x00aaff];
        _bottomLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:_bottomLabel];
    }
    return _bottomLabel;
}

- (void)contentLabelText:(NSString *)text
{
    NSString *tempStr = [NSString separatedDigitStringWithStr:text];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@步",tempStr] attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:GAFloat(30)]}];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:GAFloat(15)] range:NSMakeRange(attributedString.length-1, 1)];
    
    self.contentLabel.attributedText = attributedString;
}

- (void)dealloc
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }

}


@end
