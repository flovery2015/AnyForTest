//
//  GAStepMethod.m
//  AeroSpace
//
//  Created by wxf on 15/11/7.
//  Copyright © 2015年 Sun Alex. All rights reserved.
//

#import "GAStepMethod.h"

@implementation GAStepMethod

-(instancetype)initWithDateStr:(NSString *)string andTodaySteps:(NSString *)step andUpdataSuccess:(NSString *)success stepsJson:(NSString *)jsonStr
{
    if (self = [super init]) {
        
        self.dateStr = string;
        self.steps = step;
        self.updataSuccess = success;
        self.stepsJson = jsonStr;
        
    }
    
    return self;
}
@end
