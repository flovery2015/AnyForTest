//
//  GATodayDataTopView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/24.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GATodayDataTopView.h"
#import "GAStepsView.h"
#import "GAWanBuZouDataDisplayBar.h"

@implementation GATodayDataTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bg.image = [UIImage imageNamed:@"wbz_img_background"];
        [self addSubview:bg];
        
        UIButton *changDataSourceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        changDataSourceBtn.frame = CGRectMake(self.frame.size.width-50-10    , 16, 50, 50);
        [changDataSourceBtn setImage:[UIImage imageNamed:@"wbz_img_shujuyuan"] forState:UIControlStateNormal];
        [changDataSourceBtn addTarget:self action:@selector(changDataSourceBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:changDataSourceBtn];
        
    }
    return self;
}

- (void)changDataSourceBtnAction
{
    if ([self.delegate respondsToSelector:@selector(changeDataResource)]) {
        [self.delegate changeDataResource];
    }
}

- (GAStepsView *)circleProgressView
{
    if (!_circleProgressView) {
        CGFloat width = GAFloat(160);
        CGFloat y = 10;
        if (GA_IPHONE6||GA_IPHONE6_PLUS) {
            y = GAFloat(40);
        }
        _circleProgressView = [[GAStepsView alloc] initWithFrame:CGRectMake((self.frame.size.width-width)*0.5, y, width, width)];
        _circleProgressView.progressWidth = 6;
        _circleProgressView.oneCirleAnimationDuration = 1;
        _circleProgressView.titleLabel.text = @"今日步数";
        _circleProgressView.logoImageView.image = [UIImage imageNamed:@"wanbuzou_img_bushu"];
        [self addSubview:_circleProgressView];
    }
    
    return _circleProgressView;
}

- (GAWanBuZouDataDisplayBar *)dataDisplayBar
{
    if (!_dataDisplayBar) {
        CGFloat dataDisplayBarHeight = 50;
        _dataDisplayBar = [[GAWanBuZouDataDisplayBar alloc] initWithFrame:CGRectMake(0, self.frame.size.height - dataDisplayBarHeight-10, kScreenWidth, dataDisplayBarHeight)];
        [self addSubview:_dataDisplayBar];
    }
    return _dataDisplayBar;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
