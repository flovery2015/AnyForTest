//
//  BaseChartView.h
//  HappyPsychology
//
//  Created by wxf on 2016/10/17.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseChartView : UIView

//坐标轴颜色
@property (nonatomic, strong) UIColor *coordinateLineColor;
//渐变色
@property (nonatomic,strong) CAGradientLayer *gradientLayer;
//虚线颜色
@property (nonatomic, strong) UIColor *dottedLineColor;

@property (nonatomic, strong) NSArray *dashColors;
//坐标轴宽度
@property (nonatomic, assign) CGFloat coordinateLineWidth;
//折线宽度
@property (nonatomic, assign) CGFloat chartLineWidth;
//折线颜色
@property (nonatomic, strong) UIColor *chartLineColor;
//可自定义
@property (nonatomic, strong, readonly) CAShapeLayer *shapeLayer;
//是不是曲线
@property (nonatomic, assign) BOOL isCurve;
//绘制时要不要动画
@property (nonatomic, assign) BOOL haveAnimation;
/**
 *  深度定制坐标系
 */
@property (nonatomic, strong, readonly) CALayer *coordinateLayer;
@property (nonatomic, copy) void(^layerCoordinate)(CALayer *coordinateLayer, NSArray *datas,BaseChartView *chartView);
//设置点信息
@property (nonatomic, copy) void(^pointConfig)(UIButton *point);
//点的数组
@property(nonatomic,strong)NSMutableArray *pointLayerArr;
//坐标行数 (即是y轴的数量,下同)
@property (nonatomic, assign) NSInteger rows;
//坐标列数
@property (nonatomic, assign) NSInteger columns;
/**
 *  y轴的值 （max - min）
 */
@property (nonatomic, assign) CGFloat yValue;
///**
// *  返回数据源   这里只接受字符串
// */
//@property (nonatomic, copy) NSArray<NSString *>*(^coordinates)(void);
/**
 *  返回横轴标题
 */
@property (nonatomic, strong) NSArray <NSString *>*coordinateXTitles;

@property (nonatomic, copy) void(^titleConfig)(CATextLayer *text, NSInteger index,BaseChartView *chartView);
/**
 *  返回纵轴标题
 */
@property (nonatomic, strong) NSArray <NSString *>*coordinateYTitles;

//上下左右偏移
@property (nonatomic, assign) UIEdgeInsets chartEdgeInset;


/**
 *  初始化表格 （执行前请设置好上述属性）
 */
- (void)layerChart;

- (void)configData:(NSArray<NSString*>*)data;

- (void)configPillarData:(NSArray<NSString*>*)data;

@end
