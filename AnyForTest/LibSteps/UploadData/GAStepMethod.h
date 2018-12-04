//
//  GAStepMethod.h
//  AeroSpace
//
//  Created by wxf on 15/11/7.
//  Copyright © 2015年 Sun Alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GAStepMethod : NSObject

@property(nonatomic,copy)NSString *dateStr;
@property(nonatomic,copy)NSString *steps;
@property(nonatomic,copy)NSString *updataSuccess;
@property(nonatomic,copy)NSString *stepsJson;

/**
 *  初始化
 *
 *  @param dateStr        今天的日期
 *  @param step           步数
 *  @param success        状态
 *  @param jsonStr        json
 *
 */
-(instancetype)initWithDateStr:(NSString *)dateStr andTodaySteps:(NSString *)step andUpdataSuccess:(NSString *)success stepsJson:(NSString *)jsonStr;

@end




