//
//  GAWanbuzouStatisticsCenterVC.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/13.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWanbuzouStatisticsCenterVC.h"
#import "BaseChartView.h"
#import "GAWBZRankingBar.h"
#import "GACalloutView.h"
#import "PillarLayer.h"
#import "PillarChartView.h"
#import "GAHealthKitManager.h"
#import "GADBManager.h"
#import "VHSCommon.h"
#import "GAMessage+PedoStep.h"
#import "GACommonWebVC.h"
#import "GAHtmlAdress.h"

@interface GAWanbuzouStatisticsCenterVC ()
{
    BaseChartView *_stepRecordChart;
    BaseChartView *_caloriesRecordChart;
    NSTimer *_stepTimer;
    NSTimer *_caloriesTimer;
    UIButton *_tempBtn;
    PillarChartView *_chartView;
    NSArray *_stepsArray;
    NSArray *_caloriesArray;
}

@property(nonatomic,strong)GAWBZRankingBar *rankingBar;
@property(nonatomic,strong)GACalloutView *stepCalloutView;
@property(nonatomic,strong)GACalloutView *caloriesCalloutView;

@end

@implementation GAWanbuzouStatisticsCenterVC

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:GANotificationChangeHealthKitDataSource];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor =  GAJJ_RGBA(240, 240, 240, 1);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDataSourceAction) name:GANotificationChangeHealthKitDataSource object:nil];

    self.rankingBar.personalRanking.contentLabel.text = @"0";
    [self.rankingBar.personalRanking addTarget:self action:@selector(toPersonalRankingAction) forControlEvents:UIControlEventTouchUpInside];
    self.rankingBar.wanbulvRanking.contentLabel.text = @"0";
       [self.rankingBar.wanbulvRanking addTarget:self action:@selector(toPwanbulvRankingAction) forControlEvents:UIControlEventTouchUpInside];
    [self postPersonalWblRanking];
    [self getPersonRank];
    [self stepAndCalorieRecordChart];
    [self getData];
}

//获取个人排名
- (void)getPersonRank
{
    GAMessage *message = [GAMessage getRank];
    [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
        if ([resultObject[@"data"] class]==[NSNull class]) {
            return ;
        }
        if ([resultObject[@"data"][@"rankingCount"] class] == [NSNull class]) {
            return;
        }
        self.rankingBar.personalRanking.contentLabel.text = [NSString stringWithFormat:@"%@",resultObject[@"data"][@"rankingCount"]];
    } fail:^(NSError *error) {
        [MyToast showWithText:error.localizedDescription];
    }];
}

//获取个人万步率排名
- (void)postPersonalWblRanking
{
    GAMessage *message = [GAMessage getPersonalWBLRanking];
    [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
        if ([resultObject[@"data"] class] != [NSNull class]) {
            if ([resultObject[@"data"][@"ranking"] class]!=[NSNull class]) {
                self.rankingBar.wanbulvRanking.contentLabel.text = [NSString stringWithFormat:@"%@",resultObject[@"data"][@"ranking"]];
            }else{
                self.rankingBar.wanbulvRanking.contentLabel.text = @"0";
            }
            
        }else{
            self.rankingBar.wanbulvRanking.contentLabel.text = @"0";
        }
    } fail:^(NSError *error) {
        self.rankingBar.wanbulvRanking.contentLabel.text = @"0";
        [MyToast showWithText:error.localizedDescription];
    }];
}

- (void)changeDataSourceAction
{
    [self getData];
}

- (void)getData
{
    if ([GAHealthKitManager share].isHealthDataAvailable) {
        [[GAHealthKitManager share] authorizateHealthKit:^(BOOL isAuthorizateSuccess) {
            if (!isAuthorizateSuccess) {
                return ;
            }
            //获取一周的步数
            NSString *sourceName = [NSUD objectForKey:@"kDeviceName"];
            [[GAHealthKitManager share] fetchWeekSteps:^(GAQuantityModel *weekData, NSError *error) {
                NSDictionary *sourceDic = nil;
                if ([sourceName isEqualToString:@"iPhone"]) {
                    sourceDic = weekData.iPhoneSourcesDic;
                }else if ([sourceName isEqualToString:@"iWatch"]){
                    sourceDic = weekData.iWatchSourcesDic;
                }else if ([sourceName isEqualToString:@"xiaomi"]){
                    sourceDic = weekData.xiaoMiSourcesDic;
                }else if ([sourceName isEqualToString:@"华为穿戴"]){
                    sourceDic = weekData.huaWeiSourcesDic;
                }
                
                [self reloadStepChartDataWithStepDic:sourceDic];
            }];
        }];
    }else{
        [MyToast showWithText:@"当前设备不支持健康数据获取" duration:1.5f];
    }
}

//更新步数纪录
- (void)reloadStepChartDataWithStepDic:(NSDictionary *)stepDic
{
    if (_stepTimer) {
        _stepTimer = nil;
    }
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDate *startDate = [calendar dateFromComponents:components];//当天0点的时间
    NSDate *da = [NSDate dateWithTimeInterval:-24*6*3600 sinceDate:startDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM.dd";
    NSMutableArray *stepsArray = [NSMutableArray array];
    NSMutableArray *calorieArray = [NSMutableArray array];
    NSMutableArray *fatArr = [NSMutableArray array];
    for (int i =0; i<7; i++) {
        NSDate *date = [NSDate dateWithTimeInterval:24*3600*i sinceDate:da];
        NSString *dateStr = [formatter stringFromDate:date];
        GASourceModel *model = stepDic[dateStr];
        [stepsArray addObject:model.quantity];
        
        CGFloat distance = [VHSCommon getDistance:[model.quantity integerValue]];
        CGFloat calorie = [VHSCommon getActionCalorie:distance speed:distance * 3600 / 24*60*60];
        [calorieArray addObject:[NSString stringWithFormat:@"%.2f",calorie]];
        [fatArr addObject:[NSString stringWithFormat:@"%.2f",calorie*0.11]];
    }
    
    //更新步数纪录
    _stepsArray = stepsArray;
    CGFloat maxNum = [[stepsArray valueForKeyPath:@"@max.intValue"] floatValue];
    _stepRecordChart.yValue = maxNum <= 0?1:maxNum;
    [_stepRecordChart layerChart];
    [_stepRecordChart configData:_stepsArray];
    _stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(stepChatHandle) userInfo:nil repeats:YES];
    
    //更新卡路里表
    _caloriesArray = calorieArray;
    if (_caloriesTimer) {
        _caloriesTimer = nil;
    }
    CGFloat calorieMaxNum = [[calorieArray valueForKeyPath:@"@max.floatValue"] floatValue];
    _caloriesRecordChart.yValue = calorieMaxNum <= 0?1:calorieMaxNum;
    [_caloriesRecordChart layerChart];
    [_caloriesRecordChart configData:calorieArray];
    _caloriesTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(caloriesChatHandle) userInfo:nil repeats:YES];
    
    //更新脂肪消耗
     CGFloat fatMaxNum = [[fatArr valueForKeyPath:@"@max.floatValue"] floatValue];
    [_chartView layerChart];
    _chartView.yValue = fatMaxNum <= 0?1:fatMaxNum;
    [_chartView configPillarData:fatArr];
    
}

////更新卡路里
//- (void)reloadStepChartDataWithDistanceDic:(NSDictionary *)distanceDic
//{
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
//    NSDate *startDate = [calendar dateFromComponents:components];//当天0点的时间
//    NSDate *da = [NSDate dateWithTimeInterval:-24*6*3600 sinceDate:startDate];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"MM.dd";
//    NSMutableArray *caloriesArray = [NSMutableArray array];
//    for (int i =0; i<7; i++) {
//        NSDate *date = [NSDate dateWithTimeInterval:24*3600*i sinceDate:da];
//        NSString *dateStr = [formatter stringFromDate:date];
//        GASourceModel *model = distanceDic[dateStr];
//        CGFloat calorie = [VHSCommon getActionCalorie:[model.quantity floatValue] speed:[model.quantity floatValue] * 3600 / 24*60*60];
//        [caloriesArray addObject:[NSString stringWithFormat:@"%.2f",calorie]];
//    }
//    
//    _caloriesArray = caloriesArray;
//    if (_caloriesTimer) {
//        _caloriesTimer = nil;
//    }
//    CGFloat maxNum = [[caloriesArray valueForKeyPath:@"@max.intValue"] floatValue];
//    _caloriesRecordChart.yValue = maxNum <= 0?1:maxNum;
//    [_caloriesRecordChart layerChart];
//    [_caloriesRecordChart configData:caloriesArray];
//    _caloriesTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(caloriesChatHandle) userInfo:nil repeats:YES];
//}

//计算时间段
- (NSString *)calculateTimeBucket
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *todayDate = [calendar dateFromComponents:components];//开始时间
    NSDate *startDate = [NSDate dateWithTimeInterval:-24*6*3600 sinceDate:todayDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"MM.dd";
    
    NSString *startStr = [formatter stringFromDate:startDate];
    NSString *todayStr = [formatter stringFromDate:[NSDate date]];
    
    return [NSString stringWithFormat:@"%@~%@",startStr,todayStr];
}

- (void)stepAndCalorieRecordChart
{
    CGFloat height = (kScreenHeight - kNavBarHeight - CGRectGetHeight(self.rankingBar.frame)  - 5*2 - GAFloat(45))/3;
    NSString* timeStr = [self calculateTimeBucket];
    
    //步数纪录
    CGFloat y = CGRectGetHeight(self.rankingBar.frame) + 5;
    UIImageView *stepBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, kScreenWidth, height)];
    stepBg.image = [UIImage imageNamed:@"wbz-tjzx-bg"];
    stepBg.userInteractionEnabled = YES;
    [self.view addSubview:stepBg];
    
    UILabel *stepTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    stepTipLabel.textColor = [UIColor whiteColor];
    stepTipLabel.font = [UIFont systemFontOfSize:10];
    stepTipLabel.text = [NSString stringWithFormat:@"最近7天步数纪录(%@)",timeStr];
    [stepBg addSubview:stepTipLabel];
    
    UILabel *stepUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(stepBg.frame.size.width-100, 0, 90, 30)];
    stepUnitLabel.textAlignment = NSTextAlignmentRight;
    stepUnitLabel.textColor = [UIColor whiteColor];
    stepUnitLabel.font = [UIFont systemFontOfSize:10];
    stepUnitLabel.text = @"单位:步";
    [stepBg addSubview:stepUnitLabel];
    
    _stepRecordChart = [[BaseChartView alloc]initWithFrame:CGRectMake(0, 25, stepBg.frame.size.width, stepBg.frame.size.height-25)];
    _stepRecordChart.chartEdgeInset = UIEdgeInsetsMake(5, 20, 5, 20);
    _stepRecordChart.columns = 7;
    _stepRecordChart.rows = 7;
    _stepRecordChart.coordinateLineColor = [UIColor clearColor];
    _stepRecordChart.dottedLineColor = [UIColor whiteColor];
    _stepRecordChart.dashColors = @[(__bridge id)[UIColor whiteColor].CGColor,(__bridge id)[UIColor whiteColor].CGColor];
    _stepRecordChart.coordinateLineWidth = 1;
    _stepRecordChart.chartLineWidth = 2;
    _stepRecordChart.chartLineColor = [UIColor whiteColor];
    _stepRecordChart.yValue = 99999;
    _stepRecordChart.isCurve = YES;
    __weak typeof(self) weakSelf = self;
    _stepRecordChart.pointConfig = ^(UIButton *button){
        CGPoint centerPoint = button.center;
        button.bounds = CGRectMake(0, 0, 40, 40);
        button.center = centerPoint;
        [button addTarget:weakSelf action:@selector(stepBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    };
    _stepRecordChart.shapeLayer.strokeStart = 0;
    _stepRecordChart.shapeLayer.strokeEnd = 0;
//    [_stepRecordChart layerChart];
//    [_stepRecordChart configData:array];
    [stepBg addSubview:_stepRecordChart];
    _stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(stepChatHandle) userInfo:nil repeats:YES];
    
    //卡路里消耗记录
    UIView *caloriesBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(stepBg.frame), kScreenWidth, height)];
    caloriesBgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:caloriesBgView];
    
    UILabel *caloriesTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    caloriesTipLabel.textColor = kCOLOR_666666;
    caloriesTipLabel.font = [UIFont systemFontOfSize:10];
    caloriesTipLabel.text = [NSString stringWithFormat:@"卡路里消耗(%@)",timeStr];
    [caloriesBgView addSubview:caloriesTipLabel];
    
    UILabel *caloriesUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(caloriesBgView.frame.size.width-100, 0, 90, 30)];
    caloriesUnitLabel.textAlignment = NSTextAlignmentRight;
    caloriesUnitLabel.textColor = kCOLOR_666666;
    caloriesUnitLabel.font = [UIFont systemFontOfSize:10];
    caloriesUnitLabel.text = @"单位:大卡";
    [caloriesBgView addSubview:caloriesUnitLabel];
    
    _caloriesRecordChart = [[BaseChartView alloc]initWithFrame:CGRectMake(0, 25, stepBg.frame.size.width, stepBg.frame.size.height-25)];
    _caloriesRecordChart.chartEdgeInset = UIEdgeInsetsMake(5, 20, 5, 20);
    _caloriesRecordChart.columns = 7;
    _caloriesRecordChart.rows = 7;
    _caloriesRecordChart.coordinateLineColor = [UIColor clearColor];
    _caloriesRecordChart.dottedLineColor = [UIColor colorWithHex:0x00aaff];
    _caloriesRecordChart.dashColors = @[(__bridge id)[UIColor colorWithHex:0x00aaff].CGColor,(__bridge id)[UIColor colorWithHex:0x00e915].CGColor];
    _caloriesRecordChart.coordinateLineWidth = 1;
    _caloriesRecordChart.chartLineWidth = 2;
    _caloriesRecordChart.chartLineColor = [UIColor whiteColor];
    _caloriesRecordChart.yValue = 1000;
    _caloriesRecordChart.isCurve = YES;
    [_caloriesRecordChart.gradientLayer setColors:@[(__bridge id)[UIColor colorWithHex:0x00e915].CGColor,(__bridge id)[UIColor colorWithHex:0x00aaff].CGColor]];
    _caloriesRecordChart.pointConfig = ^(UIButton *button){
        CGPoint centerPoint = button.center;
        button.bounds = CGRectMake(0, 0, 40, 40);
        button.center = centerPoint;
        [button addTarget:weakSelf action:@selector(caloriesBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    };
    _caloriesRecordChart.shapeLayer.strokeStart = 0;
    _caloriesRecordChart.shapeLayer.strokeEnd = 0;

    [caloriesBgView addSubview:_caloriesRecordChart];

    //消耗脂肪数
    UIView *fatBgView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(caloriesBgView.frame), kScreenWidth, height)];
    fatBgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fatBgView];
    
    UILabel *fatsTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 30)];
    fatsTipLabel.textColor = kCOLOR_333333;
    fatsTipLabel.font = [UIFont systemFontOfSize:10];
    fatsTipLabel.text = [NSString stringWithFormat:@"最近7天消脂数(%@)",timeStr];
    [fatBgView addSubview:fatsTipLabel];
    
    UILabel *fatUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(caloriesBgView.frame.size.width-100, 0, 90, 30)];
    fatUnitLabel.textAlignment = NSTextAlignmentRight;
    fatUnitLabel.textColor = kCOLOR_333333;
    fatUnitLabel.font = [UIFont systemFontOfSize:10];
    fatUnitLabel.text = @"单位:g";
    [fatBgView addSubview:fatUnitLabel];
    
    _chartView = [[PillarChartView alloc]initWithFrame:CGRectMake(0, 25, fatBgView.frame.size.width, fatBgView.frame.size.height-28)];
    [fatBgView addSubview:_chartView];
    _chartView.coordinateLineWidth = 1;
    _chartView.coordinateLineColor = [UIColor grayColor];
    _chartView.chartEdgeInset = UIEdgeInsetsMake(10, 20, 20, 20);
    //列数
    _chartView.columns = 7;
    _chartView.layerCoordinate = ^(CALayer *coordinateLayer,NSArray *datas, PillarChartView *chartView){
        if (datas == nil) {
            return ;
        }
        coordinateLayer.sublayers = nil;
        CGFloat width = chartView.frame.size.width - chartView.chartEdgeInset.left - chartView.chartEdgeInset.right;
        CGFloat height = chartView.frame.size.height - chartView.chartEdgeInset.bottom - chartView.chartEdgeInset.top;
        
        //获取坐标的偏移量确定O点,(原点) PillarLayer（柱状图的view）
        for (int index = 0;index < datas.count;index++) {
            PillarLayer *lay = [PillarLayer layer];
            [lay.gradientLayer setColors:@[(__bridge id)[UIColor colorWithHex:0x00aaff].CGColor,(__bridge id)[UIColor colorWithHex:0x00e915].CGColor]];
            lay.topTitle = datas[index];
            lay.scale = [datas[index] floatValue]/chartView.yValue;
            lay.lineWidth = 8;
            CGFloat pillarLayerWidth = 30;
            lay.frame = CGRectMake(chartView.chartEdgeInset.left + (pillarLayerWidth + (width - pillarLayerWidth * chartView.columns)/(chartView.columns - 1))*index , chartView.chartEdgeInset.top , pillarLayerWidth, height);
            [lay layerPillar];
            [coordinateLayer addSublayer:lay];
        }
    };
}

#pragma mark - buttonaction
- (void)stepBtnClick:(UIButton *)button
{
    [self showCallOutIsStepRecordChart:YES btn:button];
}

- (void)caloriesBtnClick:(UIButton *)btn
{
    if (btn == _tempBtn) {
        return;
    }
    
    btn.selected = YES;
    _tempBtn.selected = NO;
    _tempBtn = btn;
    
    
    [self showCallOutIsStepRecordChart:NO btn:btn];
}

- (void)showCallOutIsStepRecordChart:(BOOL)isStepRecordChart btn:(UIButton *)btn
{
    BaseChartView *chatView = nil;
    WkCalloutView *callOutView = nil;
    NSArray *arr;
    if (isStepRecordChart) {
        chatView = _stepRecordChart;
        callOutView = self.stepCalloutView;
        arr = _stepsArray;
    }else{
        chatView = _caloriesRecordChart;
        callOutView = self.caloriesCalloutView;
        arr = _caloriesArray;
    }
    
    CGPoint btnCenter = [btn.superview convertPoint:btn.center toView:btn.superview.superview];
    CGFloat height = CGRectGetHeight(chatView.frame)*0.5;
    CGFloat width = CGRectGetWidth(chatView.frame)*0.5;
    CGFloat calloutViewX = btnCenter.x;
    CGFloat calloutViewY = btnCenter.y;
    CGFloat calloutViewHeight = 30;
    CGFloat calloutViewWidth = 60;
    CGFloat offset = 5;
    if (btnCenter.x<width&&btnCenter.y<height) {
        calloutViewX = btnCenter.x-kRowOffset-kRowWidth*0.5;
        calloutViewY = btnCenter.y+offset;
        callOutView.calloutViewType = kCalloutViewTopLeft;
    }else if (btnCenter.x<width&&btnCenter.y>=height){
        calloutViewX = btnCenter.x-kRowOffset-kRowWidth*0.5;
        calloutViewY = btnCenter.y-calloutViewHeight-offset;
        callOutView.calloutViewType = kCalloutViewBottomLeft;
    }else if (btnCenter.x>=width&&btnCenter.y<height){
        calloutViewX =  btnCenter.x-calloutViewWidth + kRowOffset+kRowWidth*0.5;
        calloutViewY = btnCenter.y + offset;
        callOutView.calloutViewType = kCalloutViewTopRight;
    }else if (btnCenter.x>=width&&btnCenter.y>=height){
        calloutViewX = btnCenter.x-calloutViewWidth + kRowOffset+kRowWidth*0.5;
        calloutViewY = btnCenter.y-calloutViewHeight-offset;
        callOutView.calloutViewType = kCalloutViewBottomRight;
    }
    
    callOutView.frame = CGRectMake(calloutViewX, calloutViewY, calloutViewWidth, calloutViewHeight);
    callOutView.contentLabel.text = arr[btn.tag-2016];
    [btn.superview.superview addSubview:callOutView];
}

#pragma mark - timerAction
- (void)stepChatHandle
{
    _stepRecordChart.shapeLayer.strokeEnd += 0.1;
    if (_stepRecordChart.shapeLayer.strokeEnd >= 1) {
        for (UIButton *button in _stepRecordChart.pointLayerArr) {
            [UIView animateWithDuration:0.5 animations:^{
                [button setImage:[UIImage imageNamed:@"wbz-tjzx-yuandian-nor"] forState:UIControlStateNormal];
            }];
        }
        if (_stepTimer) {
            [_stepTimer invalidate];
        }
    }
}

- (void)caloriesChatHandle
{
    _caloriesRecordChart.shapeLayer.strokeEnd += 0.1;
    if (_caloriesRecordChart.shapeLayer.strokeEnd >= 1) {
        for (UIButton *button in _caloriesRecordChart.pointLayerArr) {
            [UIView animateWithDuration:0.5 animations:^{
                [button setImage:[UIImage imageNamed:@"wbz-tjzx-yuandian-nor"] forState:UIControlStateNormal];
                [button setImage:[UIImage imageNamed:@"wbz-tjzx-yuandian-press"] forState:UIControlStateSelected];
            }];
        }
        if (_caloriesTimer) {
            [_caloriesTimer invalidate];
        }
    }
}

#pragma mark - controlAction
//到个人排名
- (void)toPersonalRankingAction
{
    GAMessage *message = [GAMessage uptodayActionFriendsStepsWithSteps:[NSUD objectForKey:@"totdaySteps"]];
    [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
        GACommonWebVC *webVC = [[GACommonWebVC alloc] init];
        webVC.title = @"个人排名";
        webVC.hasNavBar = YES;
        webVC.htmlStr = [GAHtmlAdress getHtmlAddress_WBZGeRenPaiMing];
        [self.navigationController pushViewController:webVC animated:YES];
    } fail:^(NSError *error) {
        GACommonWebVC *webVC = [[GACommonWebVC alloc] init];
        webVC.title = @"个人排名";
        webVC.hasNavBar = YES;
        webVC.htmlStr = [GAHtmlAdress getHtmlAddress_WBZGeRenPaiMing];
        [self.navigationController pushViewController:webVC animated:YES];
    }];
}

//到万步率排名
- (void)toPwanbulvRankingAction
{
    GACommonWebVC *vc = [[GACommonWebVC alloc] init];
    vc.htmlStr = [NSString stringWithFormat:@"http://sunroam.imgup.cn/Media/h5/step_rate/index.html?systemflag=%@&userId=%@&versionNo=%@",[GAGlobalData shareData].systemflag,[GAGlobalData shareData].userId,kVersionNo];
    vc.hasNavBar = YES;
    vc.title = @"万步率";
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark =- getter
- (GAWBZRankingBar *)rankingBar
{
    if (!_rankingBar) {
        _rankingBar = [[GAWBZRankingBar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 60)];
        [self.view addSubview:_rankingBar];
    }
    return _rankingBar;
}

- (GACalloutView *)stepCalloutView
{
    if (!_stepCalloutView) {
        _stepCalloutView = [[WkCalloutView alloc] init];
        _stepCalloutView.contentLabel.textColor = [UIColor colorWithHex:0x00aaff];
    }
    return _stepCalloutView;
}

- (GACalloutView *)caloriesCalloutView
{
    if (!_caloriesCalloutView) {
        _caloriesCalloutView = [[WkCalloutView alloc] init];
        _caloriesCalloutView.contentLabel.textColor = [UIColor colorWithHex:0x00aaff];
    }
    return _caloriesCalloutView;
}

@end
