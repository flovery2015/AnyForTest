//
//  GATodayDataTopView.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/24.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GAStepsView,GAWanBuZouDataDisplayBar;
@protocol GATodayDataTopViewDelegate;
@interface GATodayDataTopView : UIView

@property(nonatomic,strong)GAStepsView *circleProgressView;
@property(nonatomic,strong)GAWanBuZouDataDisplayBar *dataDisplayBar;

@property(nonatomic,weak)id<GATodayDataTopViewDelegate>delegate;

@end

@protocol GATodayDataTopViewDelegate <NSObject>

- (void)changeDataResource;

@end
