//
//  PillarLayer.h
//  GuanAiJiaJia
//
//  Created by wxf on 16/8/29.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface PillarLayer : CALayer

@property (nonatomic, copy) NSString *topTitle;

@property (nonatomic, strong) UIColor *pillarLayerColor;

@property (nonatomic, copy) NSString *bottomTitle;

@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, strong) CALayer *pillarLayer;

@property (nonatomic, strong) CATextLayer *textLayer;

@property (nonatomic,strong)CAGradientLayer *gradientLayer;

@property (nonatomic,assign)CGFloat lineWidth;

- (void)layerPillar;
@end
