//
//  GAWanbuZouTodayDataVC.m
//  GuanAiJiaJia
//
//  Created by wxf on 16/10/13.
//  Copyright © 2016年 srgroup. All rights reserved.
//

#import "GAWanbuZouTodayDataVC.h"
#import "GAStepsView.h"
#import "GAWanBuZouDataDisplayBar.h"
#import "GAStepDisplayView.h"
#import "GATodayDataTopView.h"
#import "GAWBZTodayBottomBar.h"
#import "GAHealthKitManager.h"
#import "VHSCommon.h"
#import "PedStepSourceViewController.h"
#import "GAMessage+PedoStep.h"
#import "YuePaoViewController.h"
#import "PedoWebViewController.h"
#import "GAInterestListVC.h"
#import "GAZhaoSanMuSiCell.h"
#import "GAWBZOptionMenuCell.h"
#import "GAWBZXianLuTuCell.h"
#import "GACommonWebVC.h"
#import "GAUploadData.h"
#import "GAStepMethod.h"
NSString  *const kWBZTodayTargetSteps = @"kWBZTodayTargetSteps";
NSString *const kTotdaySteps = @"totdaySteps";

@interface GAWanbuZouTodayDataVC ()<GAStepsViewDelegate,GAWBZTodayBottomBarDelegate,GATodayDataTopViewDelegate,UITableViewDelegate,UITableViewDataSource,GAStepDisplayViewDelegate>
{
    NSInteger _tempSteps;
    GATodayDataTopView *_topView;
    
    UIImageView *_uploadImgView;
    UILabel *_showLabel;
    NSString *_xianLuTuBgUrl;
    UITableView *tab;
}

@property(nonatomic,weak)GAStepDisplayView *zhaosanmusiView;
@property(nonatomic,assign)NSInteger zhaosanSteps;
@property(nonatomic,assign)NSInteger musiSteps;
@property(nonatomic,copy)NSArray <GAWanBuZouAppModel*>*modularArr;

@end

@implementation GAWanbuZouTodayDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addSubviews];
    [self getData];
    [self getHistorySteps];
    [self getXianLuTuBg];
}

//获取线路图背景图
- (void)getXianLuTuBg{
    _xianLuTuBgUrl = @"";
    GAMessage *message = [GAMessage getHealthyStepWalkUrl];
    [[HttpRequestManager sharedInstance]sendMessage:message success:^(id resultObject) {
        if ([resultObject[@"data"] class] == [NSNull class]) {
            return;
        }
        if (![resultObject[@"data"] isKindOfClass:[NSDictionary class]]) {
            return ;
        }
        _xianLuTuBgUrl = resultObject[@"data"][@"lineMapImage"];
        [tab reloadData];
    } fail:^(NSError *error) {
        [MyToast showWithText:error.localizedDescription duration:1.5f];
    }];
}

//获取总步数
- (void)getHistorySteps
{
    GAMessage *message = [GAMessage getAllSteps];
    [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
        NSDictionary *dicDetail = [resultObject objectForKey:@"data"];
        NSString *totoalSteps = [NSString stringWithFormat:@"%@",[dicDetail objectForKey:@"step"]];
        _topView.dataDisplayBar.fat = [NSString separatedDigitStringWithStr:totoalSteps];
    } fail:^(NSError *error) {
        [MyToast showWithText:error.localizedDescription duration:1.5f];
    }];
}



- (void)addSubviews
{
   self.modularArr = [GAGlobalData shareData].loginInfo.wbzModularObjes;
    self.view.backgroundColor = GAJJ_RGBA(240, 240, 240, 1);
    CGFloat bottomMagin = GAFloat(45);
    CGFloat height = kScreenHeight - kNavBarHeight - bottomMagin;
    CGFloat margin = 5;

    CGFloat displayViewHeight = 155;
    CGFloat bottomBarHeight = GAFloat(85);
    CGFloat topViewHeight = height - displayViewHeight - bottomBarHeight -margin*3;

    tab = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, height) style:UITableViewStyleGrouped];
    [tab registerClass:[GAWBZOptionMenuCell class] forCellReuseIdentifier:@"GAWBZOptionMenuCell"];
    [tab registerClass:[GAWBZXianLuTuCell class] forCellReuseIdentifier:@"GAWBZXianLuTuCell"];
    [tab registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    tab.separatorStyle = UITableViewCellSeparatorStyleNone;
    tab.delegate = self;
    tab.dataSource = self;
    tab.backgroundColor = GAJJ_RGBA(240, 240, 240, 1);
    [self.view addSubview:tab];
    UIView *tabFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 5)];
    tabFooterView.backgroundColor = GAJJ_RGBA(240, 240, 240, 1);
    tab.tableFooterView = tabFooterView;
    
   //圆形图和数据条
    _topView = [[GATodayDataTopView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, topViewHeight)];
    _topView.delegate= self;
    _topView.circleProgressView.delegate = self;
    _topView.dataDisplayBar.distance = @"0";
    _topView.dataDisplayBar.calorie = @"0";
    _topView.dataDisplayBar.fat = @"0";
    tab.tableHeaderView = _topView;
    
    UIImage *image = [UIImage imageNamed:@"walk_update"];
    _uploadImgView = [[UIImageView alloc] init];
    _uploadImgView.backgroundColor = [UIColor whiteColor];
    _uploadImgView.frame = CGRectMake(30, 28, image.size.width, image.size.height);
    _uploadImgView.image = image;
    [_topView addSubview:_uploadImgView];
    _uploadImgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *single = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    [_uploadImgView addGestureRecognizer:single];
    
    UILabel *message = [[UILabel alloc]init];
    message.frame = CGRectMake(CGRectGetMaxX(_uploadImgView.frame)+10, CGRectGetMinY(_uploadImgView.frame), 120, image.size.height);
    message.text = @"";
    message.textColor = [UIColor themeColor];
    [_topView addSubview:message];
    _showLabel = message;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
     return self.modularArr.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *modularCode = [self.modularArr[indexPath.section] wbz_code];
    if ([modularCode isEqualToString:@"wbz_zsms"]) {
        static NSString *cellIdentifier = @"GAZhaoSanMuSiCell";
        GAZhaoSanMuSiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[GAZhaoSanMuSiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            self.zhaosanmusiView = cell.stepDisplayView;
            self.zhaosanmusiView.delegate = self;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }else if ([modularCode isEqualToString:@"wbz_ryb"]){
        GAWBZOptionMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GAWBZOptionMenuCell"];
        cell.optionMenuBar.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if([modularCode isEqualToString:@"wbz_lxt"]){
        GAWBZXianLuTuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GAWBZXianLuTuCell"];
        cell.titleLabel.text = @"线路图";
        [cell.coverImageView sd_setImageWithURL:[NSURL URLWithString:_xianLuTuBgUrl] placeholderImage:[UIImage imageNamed:@"wbz_luxiantu_img"] options:SDWebImageRetryFailed];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.activityRuleBtn addTarget:self action:@selector(xinlutuRule) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *modularCode = [self.modularArr[indexPath.section] wbz_code];
    return [self getCellHeightWithModularCode:modularCode];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *modularCode = [self.modularArr[indexPath.section] wbz_code];
    if ([modularCode isEqualToString:@"wbz_lxt"]) {//进入线路图
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        GAMessage *message = [GAMessage getAllSteps];
        [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSDictionary *dicDetail = [resultObject objectForKey:@"data"];
            NSString *totoalSteps = [NSString stringWithFormat:@"%@",[dicDetail objectForKey:@"step"]];
            [NSUD setObject:totoalSteps forKey:@"kTotalSteps"];
            [NSUD synchronize];
            PedoWebViewController *webVc = [[PedoWebViewController alloc]init];
            webVc.title = @"线路图";
            webVc.type = @"1";
            webVc.step = totoalSteps;
            [self.navigationController pushViewController:webVc animated:YES];
        } fail:^(NSError *error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MyToast showWithText:error.localizedDescription duration:1.5f];
        }];
    }
}

- (void)getData
{
    //获取当天的步数
    if ([GAHealthKitManager share].isHealthDataAvailable) {
        [[GAHealthKitManager share] authorizateHealthKit:^(BOOL isAuthorizateSuccess) {
            if (!isAuthorizateSuccess) {
                return ;
            }
            //iPhone iWatch xiaomi kDeviceName
            //获取当前数据源设备
            NSString *sourceName = [NSUD objectForKey:@"kDeviceName"];
            NSString *sourceStepNameKey = kIphoneStepData;
            NSString *sourceDistanceNameKey = kIphoneDistanceData;
            if ([sourceName isEqualToString:@"iPhone"]) {
                sourceStepNameKey = kIphoneStepData;
                sourceDistanceNameKey = kIphoneDistanceData;
            }else if ([sourceName isEqualToString:@"iWatch"]){
                sourceStepNameKey = kIwatchStepData;
                sourceDistanceNameKey = kIwatchDistanceData;
            }else if ([sourceName isEqualToString:@"xiaomi"]){
                sourceStepNameKey = kXiaoMIStepData;
                sourceDistanceNameKey = kXiaoMIDistanceData;
            }else if ([sourceName isEqualToString:@"华为穿戴"]){
                sourceStepNameKey = kHuaWeiStepData;
                sourceDistanceNameKey = kHuaWeiDistanceData;
            }

            //获取今天的步数
            [[GAHealthKitManager share] fetchTodaySteps:^(NSDictionary *todayStepDic,NSError *error) {
                if (error) {
                    [MyToast showWithText:@"获取步数失败" duration:1.5f];
                    return ;
                }
                
                NSInteger steps = [todayStepDic[sourceStepNameKey] integerValue];
                _tempSteps = steps;
                NSInteger targetStep = [[NSUD objectForKey:kWBZTodayTargetSteps] integerValue];
                if (targetStep <= 0) {
                    targetStep = 10000;
                }
                [_topView.circleProgressView startAnimationWithTargetStep:targetStep accuracyStep:steps animation:YES];
                
                CGFloat distance = [VHSCommon getDistance:steps];
                _topView.dataDisplayBar.distance = [NSString stringWithFormat:@"%.2f",distance];
                 CGFloat calorie = [VHSCommon getActionCalorie:distance speed:distance * 3600 / 24*60*60];
                _topView.dataDisplayBar.calorie = [NSString stringWithFormat:@"%.2f",calorie];
    
                //保存今天的步数
                [NSUD setObject:todayStepDic[sourceStepNameKey] forKey:kTotdaySteps];
                [NSUD synchronize];
            }];
        
            //获取0点到6点的步数
            [[GAHealthKitManager share] fetchZhaoSanStepsWithQueryResultBlock:^(NSDictionary *stepsDic, NSError *error) {
                if (error) {
                    [MyToast showWithText:@"获取数据" duration:1.5f];
                    return ;
                }
                self.zhaosanSteps = [stepsDic[sourceStepNameKey] integerValue];
                if (_zhaosanmusiView) {
                    [_zhaosanmusiView.zhaosanProgressView startAnimation:YES currentData:self.zhaosanSteps totoalData:3000];
                }
              }];

            //获取18点到24点的步数
            [[GAHealthKitManager share] fetchMuSiStepsWithQueryResultBlock:^(NSDictionary *stepsDic, NSError *error) {
                if (error) {
                    [MyToast showWithText:@"获取数据" duration:1.5f];
                    return ;
                }
                self.musiSteps = [stepsDic[sourceStepNameKey] integerValue];
                if (_zhaosanmusiView) {
                    [_zhaosanmusiView.musiProgressView startAnimation:YES currentData:self.musiSteps totoalData:4000];
                }
            }];
        }];
    }else{
        [MyToast showWithText:@"当前设备不支持健康数据获取" duration:1.5f];
    }
}

#pragma mark - GATodayDataTopViewDelegate
- (void)changeDataResource
{
    __weak typeof(self) weakSelf = self;
    PedStepSourceViewController *vc = [[PedStepSourceViewController alloc]init];
    vc.blocks = ^{
        [weakSelf getData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - GAStepsViewDelegate
- (void)didClickStepsView:(GAStepsView *)stepsView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"设定目标步数" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * textField = alert.textFields[0];
        NSInteger number = [textField.text integerValue];
        if (number<=0) {
            number = 10000;
        }
        if (number > 99999) {
            number = 99999;
        }
        [NSUD setObject:[NSString stringWithFormat:@"%ld",number] forKey:kWBZTodayTargetSteps];
        [NSUD synchronize];
        [_topView.circleProgressView startAnimationWithTargetStep:number accuracyStep:_tempSteps animation:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sureAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)didClickItemAtIndex:(NSInteger)index
{
    switch (index) {
        case 0://我要pk
        {
            GAInterestListVC *vc = [[GAInterestListVC alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1://荣誉榜
        {
            PedoWebViewController *webVc = [[PedoWebViewController alloc]init];
            webVc.title = @"荣誉榜";
            webVc.type = @"0";
            webVc.hasNavBar = YES;
            [self.navigationController pushViewController:webVc animated:YES];
            break;
        }
        case 2: //约跑
        {
            YuePaoViewController *rankVc = [[YuePaoViewController alloc] init];
            rankVc.title = @"约跑";
            [self.navigationController pushViewController:rankVc animated:YES];
            break;
        }
        default:
            break;
    }
}

#pragma mark - GAStepDisplayViewDelegate
//进入朝三暮四活动规则
- (void)enterActionRule
{
    GACommonWebVC *vc = [[GACommonWebVC alloc] init];
    vc.htmlStr = [NSString stringWithFormat:@"http://sunroam.imgup.cn/Media/h5/z3m4/index.html?systemflag=%@&userId=%@&versionNo=%@",[GAGlobalData shareData].systemflag,[GAGlobalData shareData].userId,kVersionNo];
    vc.hasNavBar = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - btnaction
//线路图规则
- (void)xinlutuRule
{
    GACommonWebVC *vc = [[GACommonWebVC alloc] init];
    vc.htmlStr = [NSString stringWithFormat:@"http://sunroam.imgup.cn/Media/h5/xianlutu/index.html?systemflag=%@&userId=%@&versionNo=%@",[GAGlobalData shareData].systemflag,[GAGlobalData shareData].userId,kVersionNo];
    vc.hasNavBar = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - set
- (void)setZhaosanmusiView:(GAStepDisplayView *)zhaosanmusiView
{
    _zhaosanmusiView = zhaosanmusiView;
    [_zhaosanmusiView.zhaosanProgressView startAnimation:YES currentData:self.zhaosanSteps totoalData:3000];
    [_zhaosanmusiView.musiProgressView  startAnimation:YES currentData:self.musiSteps totoalData:4000];
}

#pragma mark - help
- (CGFloat)getCellHeightWithModularCode:(NSString *)modularCode
{
    if ([modularCode isEqualToString:@"wbz_zsms"]) {
        return kGAZhaoSanMuSiCellHeight;
    }
    
    if ([modularCode isEqualToString:@"wbz_ryb"]) {
        return  GAFloat(85);
    }
    
    if ([modularCode isEqualToString:@"wbz_lxt"]) {
        return kGAZhaoSanMuSiCellHeight;
    }
    
    return 0;
}

#pragma mark -－ 上传7天步数
-(void)singleTap
{
    [self addAnimation];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *nowStr = [formatter stringFromDate:now];
    
    NSDate *start = [now dateByAddingTimeInterval:-7 * 24*60*60];
    NSString *startStr = [formatter stringFromDate:start];
    GAUploadData *upload = [[GAUploadData alloc] init];
    NSMutableArray *dataArray = [upload findDataFrom:startStr toDate:nowStr];
    [self uploadSevenDaysData:dataArray];
}

-(void)uploadSevenDaysData:(NSMutableArray *)postArray
{
    NSMutableArray *uploadArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc ]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    for (GAStepMethod *method in postArray) {
        NSMutableDictionary *setpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSString *steps = method.steps;
        NSString *json = method.stepsJson;
        NSString *dateStr = method.dateStr;
        float distance = [self getDistanceUp:[steps integerValue]];
        float calorie = [self getActionCalorieUp:distance speed:distance * 3600 / 24*60*60];
        
        NSString *distanceStr = [NSString stringWithFormat:@"%.1f",distance];
        NSString *calorieStrData = [NSString stringWithFormat:@"%.0f",calorie];
        NSDate *date = [dateFormatter dateFromString:dateStr];
        NSString *postStepDate = [NSString stringWithFormat:@"%lld", (long long)[date timeIntervalSince1970] * 1000];
        [setpDict setValue:postStepDate forKey:@"actionId"];
        [setpDict setValue:distanceStr forKey:@"distance"];
        [setpDict setValue:calorieStrData forKey:@"calorie"];
        [setpDict setValue:json forKey:@"step"];
        [setpDict setValue:@"1" forKey:@"seconds"];
        [setpDict setValue:dateStr forKey:@"start_time"];
        [uploadArray addObject:setpDict];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc ]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:8 * 3600];
    
    NSMutableArray *allDataArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i = 0 ; i < uploadArray.count; i ++) {
        NSDictionary *dic = uploadArray[i];
        
        NSString *string = dic[@"step"];
        NSString *cString = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSData *jsonData = [cString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSArray *arrays = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        long long action = [dic[@"actionId"] longLongValue];
        NSString *actionId = [NSString stringWithFormat:@"%lld",action];
        NSDate *dateTime = [NSDate dateWithTimeIntervalSince1970: action / 1000];
        NSString *dateString = [formatter stringFromDate:dateTime];
    
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
        [dictionary setObject:actionId forKey:@"actionId"];
        [dictionary setObject:dateString forKey:@"start_time"];
        [dictionary setObject:arrays forKey:@"step"];
        [allDataArray addObject:dictionary];
    }
    
    NSDictionary *paramDic = @{@"data":allDataArray};
    NSData *dicJsonData = [self toJSONData:paramDic];
    NSString *dicJsonString = [[NSString alloc] initWithData:dicJsonData
                                                    encoding:NSUTF8StringEncoding];
    if (!dicJsonString) {
        dicJsonString = @"0";
    }
    GAMessage *message = [GAMessage dataUploadStepsWithJson:dicJsonString];
    
    [[HttpRequestManager sharedInstance] sendMessage:message success:^(id resultObject) {
        _showLabel.text = @"上传成功";
        [self timer];
    } fail:^(NSError *error) {
        NSLog(@"%@",error.description);
        NSLog(@"%ld",(long)error.code);
        [self timer];
        if (error.code == 888) {
            _showLabel.text = @"上传成功";
        }else{
            _showLabel.text = @"上传失败";
        }
    }];
}

-(void)timer
{
    double delayInSeconds = 2.0;
    __block GAWanbuZouTodayDataVC *bself = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        [bself delayMethod];
    
    });
}

-(void)delayMethod
{
    _showLabel.text = @"";
    [_uploadImgView.layer removeAnimationForKey:@"rotation"];
}

//添加动画
- (void)addAnimation
{

    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = FLT_MAX;
    
    [_uploadImgView.layer addAnimation:rotationAnimation forKey:@"rotation"];
}

- (NSData *)toJSONData:(id)theData
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData options:NSJSONWritingPrettyPrinted error:nil];
    if (error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

- (float)getDistanceUp:(NSInteger)step
{
    float distance;
    distance = (float)step * 170 / 230000;
    return distance;
}

-(float)getActionCalorieUp:(float)distance speed:(float)speed
{
    // 运动强度系数
    float k = 0;
    k = 0.045f;
    float calorie =  [self getBMRes] * distance * k;
    return calorie;
}

// 人体基础代谢需要的基本热（BMR）
- (NSInteger)getBMRes
{
    int BMR;
    BMR = 13.7 * 60 + 5.0 * 170 -6.8 *30 + 66;
    return BMR;
}

@end
