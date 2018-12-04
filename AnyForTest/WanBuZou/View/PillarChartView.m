//
//  ChartView.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/8/21.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "PillarChartView.h"

@interface PillarChartView ()
{
    CGFloat _width;
    CGFloat _height;
}

@property(nonatomic,strong)NSMutableArray *pointLayerArr;

@end

@implementation PillarChartView
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
            [self.coordinateLayer addSublayer:yLayer];
        }
        //x轴
        CALayer *xLayer = [CALayer layer];
        xLayer.backgroundColor = self.coordinateLineColor.CGColor;
        xLayer.frame = CGRectMake(self.chartEdgeInset.left , self.chartEdgeInset.top + _height, _width + self.chartEdgeInset.right, self.coordinateLineWidth);
        [self.coordinateLayer addSublayer:xLayer];
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
//    NSAssert(self.columns.count==data.count, @"折线图数据源个数不正确");
    //    self.shapeLayer.sublayers = nil;
    
    [self.pointLayerArr enumerateObjectsUsingBlock:^(CALayer  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    [self.pointLayerArr removeAllObjects];
    
    CGPoint points[self.columns];
    
    for (int index = 0; index < self.columns; index ++) {
        //        ChartPoint *point = [[ChartPoint alloc]init];
        points[index].x = self.chartEdgeInset.left + (_width/(self.columns - 1))*index;
        points[index].y = self.chartEdgeInset.top + _height*(1-([data[index] floatValue]/self.yValue));
        CALayer *pointLayer = [CALayer layer];
        pointLayer.frame = CGRectMake(points[index].x - 2.5, points[index].y - 2.5, 5, 5);
        pointLayer.backgroundColor = [UIColor redColor].CGColor;
        pointLayer.cornerRadius = 2.5;
        if (self.pointConfig) {
            self.pointConfig(pointLayer);
        }
        [self.layer addSublayer:pointLayer];
        [self.pointLayerArr addObject:pointLayer];
    }
    
    self.shapeLayer.strokeColor = self.chartLineColor.CGColor;
    self.shapeLayer.lineWidth = self.chartLineWidth;
    CGMutablePathRef pathl = CGPathCreateMutable();
    
    CGPathAddLines(pathl, NULL, points, self.columns);
    
    self.shapeLayer.path = pathl;
    
    
    CGPathRelease(pathl);//释放路径
    //    [self.coordinateLayer setContentsRect:CGRectMake(320, 0, 600, 275)];
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



@end

