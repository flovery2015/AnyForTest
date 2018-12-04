//
//  GAStepsView.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GACircleProgressView.h"

@protocol GAStepsViewDelegate;
@interface GAStepsView : GACircleProgressView

@property(nonatomic,strong)UIImageView *logoImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *bottomLabel;
@property(nonatomic,weak)id <GAStepsViewDelegate>delegate;

- (void)startAnimationWithTargetStep:(NSInteger)targetStep accuracyStep:(NSInteger)accuracyStep animation:(BOOL)animation;
@end

@protocol GAStepsViewDelegate <NSObject>

- (void)didClickStepsView:(GAStepsView *)stepsView;

@end
