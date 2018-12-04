//
//  UploadData.m
//  DBManager
//
//  Created by wxf on 15/12/19.
//  Copyright © 2015年 srgroup. All rights reserved.
//

#import "GAUploadData.h"
#import "GAStepMethod.h"
#import "GADBManager.h"
#import "GAHealthKitManager.h"
#define NSUserDefaultsStandard [NSUserDefaults standardUserDefaults]

@implementation GAUploadData

-(instancetype)initWithToday:(NSDate *)today andStartYesterday:(NSDate *)startYesterday;
{
    self = [super init];
    if (self) {
        _today = today;
        _startYesterday = startYesterday;
        _postArray = [[NSMutableArray alloc] initWithCapacity:0];
        deviceName = [[NSUserDefaults standardUserDefaults] objectForKey:@"kDeviceName"];
    }
    return self;
}
#pragma mark -- 读取本机未上传数据
- (void)uploadDataWithDateStart
{
    if(![HKHealthStore isHealthDataAvailable])
    {
        NSLog(@"设备不支持healthKit");
    }
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];

    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount1 = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet1 = [NSSet setWithObjects:stepCount1, nil];
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet1 completion:^(BOOL success, NSError * _Nullable error) {
        if (success)
        {
            NSLog(@"获取步数权限成功");
        }
        else
        {
            NSLog(@"获取步数权限失败");
        }
    }];
    
#if 1
    
    NSMutableArray *allStepsArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *allStepsDict = [[NSMutableDictionary alloc] init];
    if([_today timeIntervalSinceDate:_startYesterday] >= 24*60*60)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        formatter.dateFormat = @"yyyy-MM-dd";
        GADBManager *manager = [GADBManager shareSingleton];

        NSString *dString = [formatter stringFromDate:_startYesterday];
        NSMutableArray *array = [manager findByDateStr:dString];
        GAStepMethod *methods = [[GAStepMethod alloc] init];
        if (array.count > 0) {
            methods = [array objectAtIndex:0];
        }
        NSDate *start = [formatter dateFromString:dString];
//        NSTimeZone *zone = [NSTimeZone systemTimeZone];
//        NSInteger interval = [zone secondsFromGMTForDate: start];
//        NSDate *startDay = [start  dateByAddingTimeInterval: interval];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:start];
        [components setHour:0];
        [components setMinute:0];
        [components setSecond: 0];
        NSDate *startDate = [calendar dateFromComponents:components];//当天0点的时间
        _startYesterday = startDate;

        __weak __typeof (manager) weekManger = manager;
        __weak __typeof (self) weekSelf = self;
        NSMutableDictionary *setpDict = [[NSMutableDictionary alloc] init];
        if (array.count == 0 || [methods.dateStr isEqualToString:@""] || methods.dateStr == nil || methods.dateStr.length == 0) {
            
            self.healthStore = [[HKHealthStore alloc] init];
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc ]init];
            [formatter2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
            HKQuantityType *quantityType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
            NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = 1;
            
            NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
            
            HKStatisticsCollectionQuery *collectionQuery = [[HKStatisticsCollectionQuery alloc] initWithQuantityType:quantityType quantitySamplePredicate:predicate options: HKStatisticsOptionCumulativeSum | HKStatisticsOptionSeparateBySource anchorDate:[NSDate dateWithTimeIntervalSince1970:0] intervalComponents:dateComponents];
            collectionQuery.initialResultsHandler = ^(HKStatisticsCollectionQuery *query, HKStatisticsCollection * __nullable result, NSError * __nullable error) {
                float numberOfSteps = 0;
                for (HKStatistics *statistic in result.statistics) {
                    NSString *endStr = [formatter2 stringFromDate:statistic.endDate];
                    NSString *key = [endStr substringWithRange:NSMakeRange(11, 2)];
                    float s = 0.0;
                    for (HKSource *source in statistic.sources) {//deviceName
                        if ([source.name isEqualToString:deviceName]) {
                            float steps = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                            numberOfSteps += steps;
                            s = steps;
                        }
                        if ([deviceName isEqualToString:@"iPhone"]) {
                            if ([source.name isEqualToString:[UIDevice currentDevice].name]) {
                                float steps = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                                numberOfSteps += steps;
                                s = steps;
                            }
                        }else if ([deviceName isEqualToString:@"iWatch"] && ![source.name isEqualToString:[UIDevice currentDevice].name]){
                            if ([source.bundleIdentifier hasPrefix:@"com.apple.health"]) {
                                float steps = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                                numberOfSteps += steps;
                                s = steps;
                            }
                        }else if ([deviceName isEqualToString:@"xiaomi"]){
                            if ([source.name isEqualToString:@"小米运动"] || [source.bundleIdentifier isEqualToString:@"HM.wristband"]) {
                                float steps = [[statistic sumQuantityForSource:source] doubleValueForUnit:[HKUnit countUnit]];
                                numberOfSteps += steps;
                                
                                s = steps;
                            }
                        }
                        NSInteger k = [key integerValue];
                        [allStepsDict setObject:[NSNumber numberWithFloat:s] forKey:[NSNumber numberWithInteger:k]];
                    }
                }
              
                for (int i = 0; i < 24; i ++) {
                    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
                    NSNumber *num = [NSNumber numberWithInt:i];
                    NSValue *steps = [allStepsDict objectForKey:num];
                    if (steps == nil) {
                        [mutableDict setObject:@"0" forKey:@"step"];
                    }else
                        [mutableDict setObject:steps forKey:@"step"];
                    [mutableDict setObject:num forKey:@"time"];
                    [allStepsArray addObject:mutableDict];
                    
                }
            
                [self step:^(CGFloat value){
            
                    NSMutableArray *_mArray = [[NSMutableArray alloc] init];
                    for (int i = 0; i < allStepsArray.count; i ++) {
                        NSMutableDictionary *_mDict = [[NSMutableDictionary alloc] init];
                        NSInteger stepNum = 0;
                        for (int j = 0; j < i; j ++) {
                            NSDictionary *dict = allStepsArray[j+1];
                            NSString *value = dict[@"step"];
                            stepNum += [value integerValue];
                        }
                        
                        if (i==23) {
                            [_mDict setObject:[NSNumber numberWithFloat:value] forKey:@"step"];
                            [_mDict setObject:@"23" forKey:@"time"];
                        }else{
                            [_mDict setObject:[NSNumber numberWithInteger:stepNum] forKey:@"step"];
                            [_mDict setObject:[NSNumber numberWithInt:i] forKey:@"time"];
                        }
                        [_mArray addObject:_mDict];
                    }
            
                    NSString *jsonStr = [_mArray yy_modelToJSONString];
                    
                    NSString *cString = [jsonStr stringByReplacingOccurrencesOfString:@" " withString:@""];
                    NSString *stepsNum = [NSString stringWithFormat:@"%f",value];
                    //保存本地
                    [weekManger savaStepDataWithDateStr:[formatter stringFromDate:_startYesterday] andStepNumber:stepsNum andUpdataSuccess:@"0" stepsJson:cString];
                    
                    float distance = [self getDistanceUp:numberOfSteps];
                    float calorie = [self getActionCalorieUp:distance speed:distance * 3600 / 24*60*60];
                    
                    NSString *distanceStr = [NSString stringWithFormat:@"%.1f",distance];
                    NSString *calorieStrData = [NSString stringWithFormat:@"%.0f",calorie];
                    NSString *postStepDate = [NSString stringWithFormat:@"%ld", (long)[_startYesterday timeIntervalSince1970] * 1000];
                    
                    [setpDict setValue:postStepDate forKey:@"actionId"];
                    [setpDict setValue:distanceStr forKey:@"distance"];
                    [setpDict setValue:calorieStrData forKey:@"calorie"];
                    [setpDict setValue:jsonStr forKey:@"step"];
                    [setpDict setValue:@"1" forKey:@"seconds"];
                    [setpDict setValue:[formatter stringFromDate:_startYesterday] forKey:@"start_time"];
                    
                    [_postArray addObject:setpDict];
                    _startYesterday = [_startYesterday dateByAddingTimeInterval:24*60*60];
                    [self performSelector:@selector(uploadDataWithDateStart) withObject:nil];

                }];
            };
            [self.healthStore executeQuery:collectionQuery];
            
        }else if (array.count > 0 && [methods.updataSuccess isEqualToString:@"0"]){
            
            NSString *allStepStr = [NSString stringWithFormat:@"%@",methods.steps];
            long  numberOfSteps = [allStepStr longLongValue];
            
            NSString *stepsNum = [NSString stringWithFormat:@"%ld",(long)numberOfSteps];
            
            [manager updataWithDateStr:[formatter stringFromDate:_startYesterday] andStepNumber:stepsNum andSuccess:@"0" stepsJson:methods.stepsJson];
            float distance = [weekSelf getDistanceUp:numberOfSteps];
            float calorie = [weekSelf getActionCalorieUp:distance speed:distance * 3600 / 24*60*60];
            
            NSString *distanceStr = [NSString stringWithFormat:@"%.1f",distance];
            NSString *calorieStrData = [NSString stringWithFormat:@"%.0f",calorie];
            NSString *postDate = [formatter stringFromDate:_startYesterday];
            NSArray *arr = [postDate componentsSeparatedByString:@" "];
            NSString *heard = arr[0];
            
            NSDate *d = [NSDate date];
            NSDateFormatter *m = [[NSDateFormatter alloc]init];
            
            m.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            NSString *str = [m stringFromDate:d];
            NSArray *arr2 = [str componentsSeparatedByString:@" "];
            NSString *w = [arr2 lastObject];
            
            NSString *string = [NSString stringWithFormat:@"%@ %@",heard,w];
            NSDate *dStr = [m dateFromString:string];
            
            NSString *postStepDate = [NSString stringWithFormat:@"%ld", (long)[dStr timeIntervalSince1970] * 1000];
            [setpDict setValue:postStepDate forKey:@"actionId"];
            [setpDict setValue:distanceStr forKey:@"distance"];
            [setpDict setValue:calorieStrData forKey:@"calorie"];
            
            NSString *cString = [methods.stepsJson stringByReplacingOccurrencesOfString:@" " withString:@""];

            [setpDict setValue:cString  forKey:@"step"];
            [setpDict setValue:@"1" forKey:@"seconds"];
            [setpDict setValue:heard forKey:@"start_time"];
            [_postArray addObject:setpDict];
            
            _startYesterday = [_startYesterday dateByAddingTimeInterval:24*60*60];
            [self performSelector:@selector(uploadDataWithDateStart) withObject:nil];
        }else{
            _startYesterday = [_startYesterday dateByAddingTimeInterval:24*60*60];
            [self performSelector:@selector(uploadDataWithDateStart) withObject:nil];
        }
    }else{
        if (_postArray.count != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stepsCenter" object:self userInfo:@{@"steps":_postArray}];
        }
    }
    
    
#endif
    
}

-(void)step:(void(^)(CGFloat x))com
{
    [[GAHealthKitManager share] fetchStepsWithDate:_startYesterday QueryResultBlock:^(NSDictionary *stepsDic, NSError *error) {
        
        NSString *sourceName = [NSUserDefaultsStandard objectForKey:@"kDeviceName"];
        NSString *sourceStepNameKey = kIphoneStepData;
        if ([sourceName isEqualToString:@"iPhone"]) {
            sourceStepNameKey = kIphoneStepData;
        }else if ([sourceName isEqualToString:@"iWatch"]){
            sourceStepNameKey = kIwatchStepData;
        }else if ([sourceName isEqualToString:@"xiaomi"]){
            sourceStepNameKey = kXiaoMIStepData;
        }else if ([sourceName isEqualToString:@"华为穿戴"]){
            sourceStepNameKey = kHuaWeiStepData;
        }
        NSString *stepNum = stepsDic[sourceStepNameKey];
        com([stepNum floatValue]);
        
    }];
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

// 日期转换处理（Date --> yyyy-MM-dd）
-(NSString *)getYmdFromDateUp:(NSDate *)date
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init] ;
    df.dateFormat  = @"yyyy-MM-dd";
    NSString *strYmd = [df stringFromDate:date];
    return strYmd;
}
//修改本地数据库
-(void)updateLocalStepCategory:(NSMutableArray *)stepArr
{
    for (NSDictionary *dic in stepArr) {
        GADBManager *manger = [GADBManager shareSingleton];
        NSString *dataString = dic[@"start_time"];
        NSString *steps = [NSString stringWithFormat:@"%@",dic[@"step"]];
        [manger updataWithDateStr:dataString andStepNumber:steps andSuccess:@"1" stepsJson:steps];
    }
}

- (void)savaOldLocalDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success
{
    DBManager *manger = [DBManager shareSingleton];
    [manger updataWithDateStr:dateStr andStepNumber:steps andSuccess:success stepsJson:nil];
}

- (NSMutableArray *)findDataFrom:(NSString *)fromDate toDate:(NSString *)toDate
{
    DBManager *manager = [DBManager shareSingleton];
    NSMutableArray *findArr = [manager findByFromDateStr:fromDate andToDateStr:toDate];
    return findArr;
}

-(NSMutableArray *)findAllDatas
{
    GADBManager *manger = [GADBManager shareSingleton];
    NSMutableArray *allData = [manger findAllData];
    return allData;
}

-(BOOL)savaStepDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success
{
    GADBManager *manger = [GADBManager shareSingleton];
    BOOL savasuccess = [manger savaStepDataWithDateStr:dateStr andStepNumber:steps andUpdataSuccess:success stepsJson:nil];
    return savasuccess;
}
-(void)updataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andSuccess:(NSString *)success
{
    GADBManager *manger = [GADBManager shareSingleton];
    [manger updataWithDateStr:dateStr andStepNumber:steps andSuccess:success stepsJson:nil];
}
-(NSMutableArray*)findByDateStr:(NSString *)dateStr
{
    GADBManager *manager = [GADBManager shareSingleton];
    NSMutableArray *findArray = [manager findByDateStr:dateStr];
    return findArray;
}

@end
