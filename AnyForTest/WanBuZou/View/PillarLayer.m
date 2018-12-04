//
//  PillarLayer.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/8/29.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "PillarLayer.h"

@implementation PillarLayer

- (void)layerPillar {
    if (self.scale == 0) {
        self.scale = 0.05;
    }
    //切半圆圆角
    self.pillarLayer.frame = CGRectMake((self.frame.size.width - self.lineWidth)*0.5, self.frame.size.height*(1-self.scale), self.lineWidth, self.frame.size.height*self.scale);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.pillarLayer.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(self.pillarLayer.frame.size.width/2, self.pillarLayer.frame.size.width/2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.pillarLayer.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.gradientLayer.frame = self.pillarLayer.bounds;
    [self.gradientLayer setMask:maskLayer];
    [self.pillarLayer addSublayer:self.gradientLayer];
    
    //柱形图上面的文字
    self.textLayer.string = self.topTitle;
    self.textLayer.alignmentMode = @"center";
    self.textLayer.fontSize = 12;
    self.textLayer.frame = CGRectMake(0, self.pillarLayer.frame.origin.y + self.pillarLayer.frame.size.height + 5, self.frame.size.width, 20);
}

- (CALayer *)pillarLayer {
    if (_pillarLayer == nil) {
        _pillarLayer = [CALayer layer];
        _pillarLayer.backgroundColor = _pillarLayerColor.CGColor;
        [self addSublayer:_pillarLayer];
    }
    return _pillarLayer;
}

- (CATextLayer *)textLayer {
    if (_textLayer == nil) {
        _textLayer = [CATextLayer layer];
        _textLayer.alignmentMode = @"center";
        _textLayer.foregroundColor = [UIColor grayColor].CGColor;
        _textLayer.fontSize = 9;
        _textLayer.contentsScale = [UIScreen mainScreen].scale;
        [self addSublayer:_textLayer];
    }
    return _textLayer;
}

- (CAGradientLayer *)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        [_gradientLayer setLocations:@[@0,@1]];
        [_gradientLayer setStartPoint:CGPointMake(0, 0)];
        [_gradientLayer setEndPoint:CGPointMake(0, 1)];
    }
    return _gradientLayer;
}


@end
