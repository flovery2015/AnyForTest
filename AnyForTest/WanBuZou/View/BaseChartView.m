//
//  BaseChartView.m
//  HappyPsychology
//
//  Created by wxf on 2016/10/17.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "BaseChartView.h"

@interface BaseChartView ()
{
    CGFloat _width;
    CGFloat _height;
}

@end

@implementation BaseChartView
@synthesize shapeLayer = _shapeLayer;
@synthesize coordinateLayer = _coordinateLayer;

- (void)layerChart {
    
    _width = self.frame.size.width - self.chartEdgeInset.left - self.chartEdgeInset.right;
    _height = self.frame.size.height - self.chartEdgeInset.bottom - self.chartEdgeInset.top;
    //坐标系layer位置
    self.coordinateLayer.sublayers = nil;
    self.shapeLayer.sublayers = nil;
    self.coordinateLayer.frame = self.layer.bounds;
    //折线layer位置
    self.shapeLayer.frame = self.layer.bounds;
    
    //绘制坐标系
    if (self.layerCoordinate) {
        self.layerCoordinate(self.coordinateLayer,nil,self);
    } else {
        //不反回用默认方式绘制
        for (int index = 0; index < self.columns; index ++) {
            CALayer *yLayer = [CALayer layer];
            yLayer.backgroundColor = self.coordinateLineColor.CGColor;
            yLayer.frame = CGRectMake(self.chartEdgeInset.left + (_width/(self.columns - 1))*index , self.chartEdgeInset.top, self.coordinateLineWidth, _height);
            [self drawDashLine:yLayer lineLength:6 lineSpacing:4 lineColor:self.dottedLineColor];
            [self.coordinateLayer addSublayer:yLayer];
        }
    }
    for (NSInteger index = 0; index < self.columns; index ++) {
        if (self.coordinateXTitles.count == self.columns) {
            CATextLayer *textLayer = [CATextLayer layer];
            textLayer.string = self.coordinateXTitles[index];
            textLayer.frame = CGRectMake(self.chartEdgeInset.left + (_width/(self.columns - 1))*index - _width*0.5/(self.columns - 1), self.chartEdgeInset.top + _height, _width/(self.columns - 1), self.chartEdgeInset.bottom);
            textLayer.contentsScale = [UIScreen mainScreen].scale;
            textLayer.fontSize = 10;
            //                textLayer.foregroundColor = GA_COLOR_0x999999.CGColor;
            
            textLayer.alignmentMode = @"center";
            [self.shapeLayer addSublayer:textLayer];
            if (self.titleConfig) {
                self.titleConfig(textLayer,index,self);
            }
        }
        
        if (self.coordinateYTitles.count == self.rows) {
            
        }
    }
}

- (void)configPillarData:(NSArray<NSString *> *)data {
    //绘制坐标系
    if (self.layerCoordinate) {
        self.layerCoordinate(self.coordinateLayer,data,self);
    }
}

- (void)configData:(NSArray<NSString*>*)data {
    //    NSAssert(self.columns.count==data.count, @"折 线图数据源个数不正确");
    //    self.shapeLayer.sublayers = nil;
    
    if (!data || data.count ==0) {
        data = @[@"0",@"0",@"0",@"0",@"0",@"0",@"0"];
    }
    
    [self.pointLayerArr enumerateObjectsUsingBlock:^(UIButton  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.pointLayerArr removeAllObjects];
    
    CGPoint points[self.columns];
    
    for (int index = 0; index < self.columns; index ++) {
        //        ChartPoint *point = [[ChartPoint alloc]init];
        points[index].x = self.chartEdgeInset.left + (_width/(self.columns - 1))*index;
        points[index].y = self.chartEdgeInset.top + _height*(1-([data[index] floatValue]/self.yValue));
        UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
        pointButton.tag = 2016+index;
        pointButton.frame = CGRectMake(points[index].x - 2.5, points[index].y - 2.5, 5, 5);
        pointButton.backgroundColor = [UIColor clearColor];
//        pointButton.layer.cornerRadius = 2.5;
        if (self.pointConfig) {
            self.pointConfig(pointButton);
        }
        [self addSubview:pointButton];
        [self.pointLayerArr addObject:pointButton];
    }
    
    self.shapeLayer.strokeColor = self.chartLineColor.CGColor;
    self.shapeLayer.lineWidth = self.chartLineWidth;
    
    CGPathRef pathl = [self handleData:points];
    self.shapeLayer.path = pathl;
    if (_isCurve == NO) {
        CGPathRelease(pathl);//释放路径
    }
}

- (CGPathRef)handleData:(CGPoint *)points
{
    if (_isCurve == YES) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint lastPoint;
        for (int i = 0; i < self.columns; i++) {
            if (i == 0) {
                lastPoint = points[i];
                [path moveToPoint:lastPoint];
            } else {
                [path addCurveToPoint:points[i] controlPoint1:CGPointMake((points[i].x + lastPoint.x)/2, lastPoint.y) controlPoint2:CGPointMake((points[i].x + lastPoint.x)/2, points[i].y)];
                lastPoint = points[i];
            }
        }
        return path.CGPath;
    } else {
        CGMutablePathRef pathl = CGPathCreateMutable();
        CGPathAddLines(pathl, NULL, points, self.columns);
        return pathl;
    }
}

- (CAShapeLayer *)shapeLayer {
    if (_shapeLayer == nil) {
        _shapeLayer = [[CAShapeLayer alloc]init];
        _shapeLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer addSublayer:_shapeLayer];
    }
    return _shapeLayer;
}
- (CALayer *)coordinateLayer {
    if (_coordinateLayer == nil) {
        _coordinateLayer = [[CALayer alloc]init];
        [self.layer addSublayer:_coordinateLayer];
    }
    return _coordinateLayer;
}

- (NSMutableArray *)pointLayerArr
{
    if (!_pointLayerArr) {
        _pointLayerArr = [NSMutableArray array];
    }
    
    return _pointLayerArr;
}

//渐变层
- ( CAGradientLayer*)gradientLayer
{
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        [_gradientLayer setLocations:@[@0,@1]];
        [_gradientLayer setStartPoint:CGPointMake(0, 0)];
        [_gradientLayer setEndPoint:CGPointMake(1, 1)];
        [_gradientLayer setMask:self.shapeLayer];
        [self.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

- (void)drawDashLine:(CALayer *)lineLayer lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineLayer.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineLayer.frame) / 2, CGRectGetHeight(lineLayer.frame)/2)];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    UIBezierPath *path=[UIBezierPath bezierPath];
    //沿着哪个放向
    [path moveToPoint:CGPointMake(0, lineLayer.frame.size.width)];
    [path addLineToPoint:CGPointMake(lineLayer.frame.size.width, lineLayer.frame.size.height)];
    
    [shapeLayer setPath:path.CGPath];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = self.dashColors;
    gradientLayer.frame = lineLayer.bounds;
    [gradientLayer setLocations:@[@0,@1]];
    [gradientLayer setStartPoint:CGPointMake(0, 0)];
    [gradientLayer setEndPoint:CGPointMake(1, 1)];
    [gradientLayer setMask:shapeLayer];
    [lineLayer addSublayer:gradientLayer];
    
    //  把绘制好的虚线添加上来
//    [lineLayer addSublayer:shapeLayer];
}

@end
