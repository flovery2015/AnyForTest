//
//  DBManager.h
//  DBManager
//
//  Created by wxf on 15/12/19.
//  Copyright © 2015年 srgroup. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface GADBManager : NSObject
{
    NSString *databasePath;
    NSString *dbName;
    NSString *sqliteName;
}

@property (nonatomic, copy) NSString *fileNameStr;
@property (nonatomic, copy) NSString *databasePath;

+(id)shareSingleton;

- (BOOL)open;
/**
 *  保存每天步数数据
 *
 *  @param dateStr  时间
 *  @param steps    步数
 *  @param success  标识（0 ｜ 1）
 *  @param stepsJson   处理好的json
 *  @return BOOL    状态
 */
- (BOOL)savaStepDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success stepsJson:(NSString *)stepsJson;
/**
 *  更新特定日期的数据
 *
 *  @param dateStr  时间
 *  @param steps    步数
 *  @param success  标识（0 ｜ 1）
 *  @param stepsJson   处理好的json
 */
- (void)updataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andSuccess:(NSString *)success stepsJson:(NSString *)stepsJson;
/**
 *  查询这一天数据
 *
 *  @param dateStr    日期
 *  @return model类型数据（所有数据）
 */
- (NSMutableArray*) findByDateStr:(NSString *)dateStr;
/**
 *  查询一段时间内的数据
 *
 *  @param startDate 开始时间
 *  @param toDate   结束时间
 *  @return model类型数组（设定时间段的数据）
 */
- (NSMutableArray *) findByFromDateStr:(NSString *)startDate andToDateStr:(NSString *)toDate;
/**
 *  查询所有数据
 *
 *  @return model类型数据（所有数据）
 */
- (NSMutableArray *) findAllData;

@end

