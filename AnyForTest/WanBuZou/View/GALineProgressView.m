//
//  GAStepProgressView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/18.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GALineProgressView.h"
static CGFloat const perTime = 0.005;
@interface GALineProgressView ()
{
    CGFloat _tempProgressLabelWidth;
}

@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)CGFloat tempPercent;
@property(nonatomic,assign)CGFloat wholeDuration;
@property(nonatomic,strong)UILabel *progressLabel;

@end

@implementation GALineProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        [self initData];
        [self initSubViews];
    }
    return self;
}

//设置默认值
- (void)initData
{
    self.backgroundColor = [UIColor clearColor];
    self.lineWidth = 7;
    self.bgColor = GAJJ_RGBA(240, 240, 240, 1);
    self.percent = 1;
    self.startColor = [UIColor colorWithHex:0x00e915];
    self.endColor = [UIColor colorWithHex:0x00aaff];
    self.wholeDuration = 1;
    self.tempPercent = 0;
}

- (void)initSubViews
{
    UILabel *zeroLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 13, 10, 13)];
    zeroLabel.text = @"0";
    zeroLabel.font = [UIFont systemFontOfSize:10];
    zeroLabel.textColor = kCOLOR_999999;
    [self addSubview:zeroLabel];
}

//- (void)drawLineWithAnimation:(BOOL)animation
//{
//    CGFloat magin = 5;
//    //路径
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(magin, (self.frame.size.height - self.lineWidth)*0.5, (self.frame.size.width-magin*2)*self.percent, self.lineWidth) cornerRadius:self.lineWidth/2];
//    
//    //遮罩层
//    CAShapeLayer *shaplayer = [CAShapeLayer layer];
//    shaplayer.frame = CGRectMake(magin, (self.frame.size.height - self.lineWidth)*0.5, (self.frame.size.width-magin*2)*self.percent, self.lineWidth);
//    shaplayer.fillColor =  [[UIColor clearColor] CGColor];
//    shaplayer.strokeColor=[UIColor redColor].CGColor;
//    shaplayer.lineWidth = self.lineWidth;
//    shaplayer.lineCap = kCALineCapRound;
//    shaplayer.path = path.CGPath;
//
//    //渐变图层
//     CALayer * grain = [CALayer layer];
//    
//    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
//    gradientLayer.cornerRadius = self.lineWidth/2;
//    gradientLayer.frame = CGRectMake(magin, (self.frame.size.height - self.lineWidth)*0.5, (self.bounds.size.width-magin*2)*self.percent, self.lineWidth);
//    [gradientLayer setColors:@[(__bridge id)self.startColor.CGColor,(__bridge id)self.endColor.CGColor]];
//    [gradientLayer setLocations:@[@0,@1]];
//    [gradientLayer setStartPoint:CGPointMake(0, 0)];
//    [gradientLayer setEndPoint:CGPointMake(1, 1)];
//    [self.layer addSublayer:gradientLayer];
//    
//    [grain setMask:shaplayer];
//    [self.layer addSublayer:grain];

//这里动画不知道为什么不管用所以其用此方法，改在drawRect画图
    //CABasicAnimation *pathAnimation=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    //pathAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    //pathAnimation.fromValue=[NSNumber numberWithFloat:0.0f];
    //pathAnimation.toValue=[NSNumber numberWithFloat:1.0f];
    //pathAnimation.autoreverses=NO;
    //pathAnimation.repeatCount = 1;
    //pathAnimation.duration = self.oneCirleAnimationDuration*self.percent;
    //[progressLayer addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
//}

- (void)handleTimer
{
    if (self.tempPercent >= self.percent) {
        self.tempPercent = self.percent;
        [self.timer invalidate];
        self.timer = nil;
        
        if ([self.delegate respondsToSelector:@selector(didFinishAnimation:)]) {
            [self.delegate didFinishAnimation:self];
        }
        
    }else{
        self.tempPercent+=perTime;
    }
    
    [self setNeedsDisplay];
}

- (void)startAnimation:(BOOL)animation
{
    self.percent = self.percent>1?1:self.percent;
    
    if (self.percent == 1) {
        self.progressLabel.textColor = [UIColor colorWithHex:0x00aaff];
    }else{
        self.progressLabel.textColor = kCOLOR_999999;
    }
    
    self.tempPercent = 0.0;
    if (animation) {
        [self.timer setFireDate:[NSDate distantPast]];
    }else{
        self.tempPercent = self.percent;
        [self setNeedsDisplay];
    }
}

- (void)setLabelText:(NSString *)labelText
{
    _labelText = labelText;
    self.progressLabel.text = labelText;
    [_progressLabel sizeToFit];
    [_progressLabel setNeedsDisplay];
    _tempProgressLabelWidth = _progressLabel.frame.size.width;
    
}

- (void)drawRect:(CGRect)rect {
    
    CGFloat leftMagin = 0;
    CGFloat rightMagin = 5;
    
    //绘制背景
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, leftMagin, rect.size.height*0.5);
    CGContextAddLineToPoint(context, rect.size.width-rightMagin, rect.size.height*0.5);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    [self.bgColor setStroke];
    CGContextDrawPath(context, kCGPathFillStroke);

    //绘制路径
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(leftMagin, (self.frame.size.height - self.lineWidth)*0.5, (self.frame.size.width - leftMagin-rightMagin)*self.tempPercent, self.lineWidth) cornerRadius:self.lineWidth/2];
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id)self.startColor.CGColor,(__bridge id)self.endColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace,(__bridge CFArrayRef) colors , locations);
    
    //渐变开始结束点
    CGRect pathRect = CGPathGetBoundingBox(bezierPath.CGPath);
    CGPoint startPoint = CGPointMake(CGRectGetMinX(pathRect), CGRectGetMaxY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(pathRect), CGRectGetMaxY(pathRect));
    
    //添加路径
    CGContextSaveGState(context);
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGFloat progressLabelWidht = _tempProgressLabelWidth+ 15;
    CGFloat progressLabelHeight = 20;
    CGFloat progressLabelX = self.frame.size.width *self.tempPercent - progressLabelWidht;
    CGFloat progressLabelY = (rect.size.height - progressLabelHeight)*0.5;
    
    if (progressLabelX <= 0) {
        self.progressLabel.frame = CGRectMake(0, progressLabelY, 30, progressLabelHeight);
    }else{
        self.progressLabel.frame = CGRectMake(progressLabelX, progressLabelY, progressLabelWidht, progressLabelHeight);
    }

    self.progressLabel.layer.cornerRadius = progressLabelHeight*0.5;
}

- (UILabel *)progressLabel
{
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _progressLabel.backgroundColor = [UIColor whiteColor];
        _progressLabel.textColor = kCOLOR_999999;
        _progressLabel.font = [UIFont systemFontOfSize:10];
        _progressLabel.adjustsFontSizeToFitWidth = YES;
        _progressLabel.layer.masksToBounds = YES;
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        _progressLabel.layer.borderWidth = 1;
        _progressLabel.layer.borderColor = kCOLOR_Line.CGColor;
        [self addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UILabel *)totoalLabel
{
    if (!_totoalLabel) {
        _totoalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width - 100, self.frame.size.height-13, 100, 13)];
        _totoalLabel.font = [UIFont systemFontOfSize:10];
        _totoalLabel.textColor = kCOLOR_999999;
        _totoalLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_totoalLabel];
    }
    return  _totoalLabel;
}

- (NSTimer *)timer
{
    if (!_timer) {
        //这个地方时间计算不对以后有时间重写
        CGFloat time = self.wholeDuration * self.percent/2000;
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
        [_timer setFireDate:[NSDate distantFuture]];
    }
    return _timer;
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}


@end
