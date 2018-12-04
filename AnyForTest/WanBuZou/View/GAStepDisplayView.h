//
//  GAStepDisplayView.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GALineProgressView.h"

@class GAStepDisplayViewItem;
@protocol GAStepDisplayViewDelegate;
@interface GAStepDisplayView : UIView

@property (nonatomic,strong)GAStepDisplayViewItem *zhaosanProgressView;
@property (nonatomic,strong)GAStepDisplayViewItem *musiProgressView;
@property (nonatomic,weak)id<GAStepDisplayViewDelegate>delegate;

@end

@protocol GAStepDisplayViewDelegate <NSObject>

- (void)enterActionRule;

@end



@interface GAStepDisplayViewItem : UIView

@property(nonatomic,strong)UIImageView *leftImageView;
@property (nonatomic,strong)GALineProgressView *progressView;

- (void)startAnimation:(BOOL)animation currentData:(NSInteger)currentData totoalData:(NSInteger)totoalData;

@end


