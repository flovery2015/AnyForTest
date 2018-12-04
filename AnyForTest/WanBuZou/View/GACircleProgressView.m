//
//  GACircleProgressView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/13.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GACircleProgressView.h"

@interface GACircleProgressView()

@property(nonatomic,strong)UIBezierPath *bezierPath;
@property(nonatomic,strong) CAShapeLayer *shapLayer;
@property(nonatomic,strong)CALayer *tempLayer;

@end

@implementation GACircleProgressView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initData];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initData];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2;
    }
    
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

//初始化数据,默认数据
- (void)initData
{
    self.progressWidth = 6.0f;
    self.progressBackgroundColor =GAJJ_RGBA(240, 240, 240, 1);
    self.percent = 1;
    self.oneCirleAnimationDuration = 5.0;
}

- (void)startAnimation:(BOOL)animation
{
    CGFloat angle = 2 * self.percent * M_PI - M_PI_2+(M_PI_2/50);
    
    [self.bezierPath removeAllPoints];
    
    [self.bezierPath addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:(self.bounds.size.width-self.progressWidth)/2 startAngle:-M_PI_2+(M_PI_2/50) endAngle:angle clockwise:YES];
    
    //遮罩层
    self.shapLayer.path = self.bezierPath.CGPath;
    
    //用progressLayer来截取渐变层 遮罩
    [self.tempLayer setMask:self.shapLayer];
    [self.layer addSublayer:self.tempLayer];
    
    //增加动画
    if (animation) {
        CABasicAnimation *pathAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        pathAnimation.fromValue=[NSNumber numberWithFloat:0.0f];
        pathAnimation.toValue=[NSNumber numberWithFloat:1.0f];
        pathAnimation.autoreverses=NO;
        pathAnimation.repeatCount = 1;
        pathAnimation.removedOnCompletion = YES;
        pathAnimation.duration = self.oneCirleAnimationDuration*self.percent;
        [self.shapLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
    }
}

- (UIBezierPath *)bezierPath
{
    if (!_bezierPath) {
        _bezierPath = [UIBezierPath bezierPath];
    }
    return _bezierPath;
}

- (CAShapeLayer *)shapLayer
{
    if (!_shapLayer) {
        _shapLayer= [CAShapeLayer layer];
        _shapLayer.frame = self.bounds;
        _shapLayer.fillColor =  [[UIColor clearColor] CGColor];
        _shapLayer.strokeColor=[UIColor redColor].CGColor;
        _shapLayer.lineCap = kCALineCapRound;
        _shapLayer.lineWidth = self.progressWidth;
    }
    return _shapLayer;
}

- (CALayer *)tempLayer
{
    if (!_tempLayer) {
        _tempLayer = [CALayer layer];
        
       CAGradientLayer *leftGradientLayer =  [CAGradientLayer layer];
        leftGradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.height);
        [leftGradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithHex:0x01ca89] CGColor],(id)[[UIColor colorWithHex:0x00aaff] CGColor], nil]];
        [leftGradientLayer setLocations:@[@0,@1.0]];
        [leftGradientLayer setStartPoint:CGPointMake(1.0, 1.0)];
        [leftGradientLayer setEndPoint:CGPointMake(0, 1.0)];
        [_tempLayer addSublayer:leftGradientLayer];
        
        CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
        rightGradientLayer.frame = CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, self.bounds.size.height);
        [rightGradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithHex:0x00e915] CGColor],(id)[[UIColor colorWithHex:0x01ca89] CGColor], nil]];
        [rightGradientLayer setLocations:@[@0.0,@1.0]];
        [rightGradientLayer setStartPoint:CGPointMake(0.1, 0)];
        [rightGradientLayer setEndPoint:CGPointMake(0, 1.0)];
        [_tempLayer addSublayer:rightGradientLayer];
    }
    return _tempLayer;
}


- (void)drawRect:(CGRect)rect
{
    CGPoint center = CGPointMake( self.frame.size.width*0.5, self.frame.size.height*0.5);
    CGFloat radius = (self.frame.size.width-self.progressWidth)*0.5;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);//设置填充色
    CGContextSetShouldAntialias(context, YES);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI*2, 0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.progressWidth);
    [self.progressBackgroundColor setStroke];
    
//    CGContextStrokePath(context);设置线条的颜色
//    CGContextFillPath(context);只设置填充色
//
    CGContextDrawPath(context, kCGPathFillStroke);//设置填充色和线条的颜色    
}


@end
