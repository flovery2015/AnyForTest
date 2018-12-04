//
//  GAStepDisplayView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAStepDisplayView.h"

@implementation GAStepDisplayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = kCOLOR_333333;
    titleLabel.text = @"朝三暮四";
    [self addSubview:titleLabel];
    
    CGFloat ruleBtnWidth = 100;
    UIButton *ruleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    ruleBtn.frame = CGRectMake(self.frame.size.width - ruleBtnWidth-10, 10, ruleBtnWidth, 20);
    [ruleBtn setTitle:@"活动规则" forState:UIControlStateNormal];
    ruleBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    ruleBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [ruleBtn setTitleColor:kCOLOR_999999 forState:UIControlStateNormal];
    [ruleBtn addTarget:self action:@selector(ruleBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:ruleBtn];
}

- (void)ruleBtnAction
{
    if ([self.delegate respondsToSelector:@selector(enterActionRule)]) {
        [self.delegate enterActionRule];
    }
}

- (GAStepDisplayViewItem *)zhaosanProgressView
{
    if (!_zhaosanProgressView) {
        CGFloat height = 60;
        _zhaosanProgressView = [[GAStepDisplayViewItem alloc] initWithFrame:CGRectMake(0, 20+5, kScreenWidth, height)];
        _zhaosanProgressView.leftImageView.image = [UIImage imageNamed:@"wbz_img_zhaosan"];
        [self addSubview:_zhaosanProgressView];
    }
    return _zhaosanProgressView;
}

- (GAStepDisplayViewItem *)musiProgressView
{
    if (!_musiProgressView) {
        CGFloat height = 60;
        _musiProgressView = [[GAStepDisplayViewItem alloc] initWithFrame:CGRectMake(0, 20+5+height, kScreenWidth, height)];
        _musiProgressView.leftImageView.image = [UIImage imageNamed:@"wbz_img_musi"];
        [self addSubview:_musiProgressView];
    }
    return _musiProgressView;
}

@end

@implementation GAStepDisplayViewItem

- (UIImageView *)leftImageView
{
    if (!_leftImageView) {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (self.frame.size.height - 20)*0.5, 20, 20)];
        [self addSubview:_leftImageView];
        
    }
    return _leftImageView;
}

- (GALineProgressView *)progressView
{
    if (!_progressView) {
        CGFloat x = CGRectGetMaxX(self.leftImageView.frame)+15;
        CGFloat width = self.frame.size.width - x - 10;
        _progressView = [[GALineProgressView alloc] initWithFrame:CGRectMake(x, 0, width, self.frame.size.height)];
        [self addSubview:_progressView];
    }
    return _progressView;
}

- (void)startAnimation:(BOOL)animation currentData:(NSInteger)currentData totoalData:(NSInteger)totoalData
{
    self.progressView.percent = currentData/(CGFloat)totoalData;
    self.progressView.totoalLabel.text = [NSString stringWithFormat:@"%ld",totoalData];
    self.progressView.labelText = [NSString separatedDigitStringWithStr:[NSString stringWithFormat:@"%ld",currentData]];
    [self.progressView startAnimation:animation];
}



@end
