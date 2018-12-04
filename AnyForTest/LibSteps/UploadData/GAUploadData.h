//
//  UploadData.h
//  DBManager
//
//  Created by wxf on 15/12/19.
//  Copyright © 2015年 srgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>
typedef void (^GAStepMethodBlock) (NSMutableArray *);

@interface UploadData : NSObject
{
    NSDate *_today;
    NSDate *_startYesterday;
    NSMutableArray *_postArray;
    NSString *deviceName;
}

@property (nonatomic, strong) HKHealthStore *healthStore;

/**    @"uname"必须在登陆成功后设置  **********************
 *   NSString *loginNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"uname"];
 dbName = [NSString stringWithFormat:@"stepMethod%@.db",loginNum];
 sqliteName = [NSString stringWithFormat:@"stepMethod%@",loginNum];
 */


@property (nonatomic, strong) CMStepCounter *stepCounter;
@property (nonatomic, strong) NSOperationQueue *operationQueue;


//返回需要上传的数据
@property (nonatomic, copy) GAStepMethodBlock blocks;
/**
 *  初始化
 *
 *  @param today          今天的日期
 *  @param startYesterday 程序安装的日期
 *
 *  
 */
- (instancetype)initWithToday:(NSDate *)today andStartYesterday:(NSDate *)startYesterday;
/**
 *  根据初始化传的 today和startYesterday 来查询所有需要上传的数据
 */
- (void)uploadDataWithDateStart;
/**
 *  上传成功后更新本地数据库
 *
 *  @param stepArr 需要更新到本地的所有数据
 */
- (void)updateLocalStepCategory:(NSMutableArray *)stepArr;

/**
 *  保存以前数据的数据放到新的数据库中
 *
 *  @param dateStr 日期
 *  @param steps   步数
 *  @param success 0/1  标识
 */
- (void)savaOldLocalDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success;
/**
 *  查询一段时间内的数据
 *
 *  @param fromDate 开始时间
 *  @param toDate   结束时间
 *  @return model类型数组（设定时间段的数据）
 */
- (NSMutableArray *)findDataFrom:(NSString *)fromDate toDate:(NSString *)toDate;
/**
 *  查询所有数据
 *
 *  @return model类型数据（所有数据）
 */
-(NSMutableArray *)findAllDatas;
/**
 *  保存数据
 *
 *  @param dateStr 日期
 *  @param steps   步数
 *  @param success 标识（0 ｜ 1）
 *
 *  @return 插入数据库成功失败标识
 */
-(BOOL)savaStepDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success;
/**
 *  更新操作
 *
 *  @param dateStr      日期
 *  @param steps        步数
 *  @param success 此条数据的标识
 */
-(void)updataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andSuccess:(NSString *)success;
/**
 *  根据具体日期查询数据
 *
 *  @param dateStr 日期
 *
 *  @return model类型数据（一条）
 */
-(NSMutableArray*)findByDateStr:(NSString *)dateStr;


@end
