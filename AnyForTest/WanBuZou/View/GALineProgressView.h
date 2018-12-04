//
//  GAStepProgressView.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GALineProgressViewDelegate;
@interface GALineProgressView : UIView

@property(nonatomic,assign)CGFloat lineWidth;

@property(nonatomic,strong)UIColor *bgColor;

@property(nonatomic,assign)CGFloat percent;

@property(nonatomic,strong)UIColor *startColor;

@property(nonatomic,strong)UIColor *endColor;

@property(nonatomic,strong)NSString *labelText;

@property(nonatomic,strong)UILabel *totoalLabel;

@property(nonatomic,weak)id<GALineProgressViewDelegate>delegate;

- (void)startAnimation:(BOOL)animation;


@end

@protocol GALineProgressViewDelegate <NSObject>

- (void)didFinishAnimation:(GALineProgressView *)progressView;

@end
