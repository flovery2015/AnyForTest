//
//  GACircleProgressView.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/13.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GACircleProgressView : UIView

//进度条背景色，默认是灰色
@property(nonatomic,strong)UIColor *progressBackgroundColor;

//进度条的宽度，默认是5
@property(nonatomic,assign)CGFloat progressWidth;

//进度百分比
@property(nonatomic,assign)CGFloat percent;

@property(nonatomic,assign)CGFloat oneCirleAnimationDuration;


- (void)startAnimation:(BOOL)animation;


@end
