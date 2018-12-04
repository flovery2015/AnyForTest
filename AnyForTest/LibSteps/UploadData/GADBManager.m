//
//  DBManager.m
//  DBManager
//
//  Created by wxf on 15/12/19.
//  Copyright © 2015年 srgroup. All rights reserved.
//


#import "GADBManager.h"
#import "GAStepMethod.h"

static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;
static GADBManager *manager = nil;

#define NSUserDefaultsStandard [NSUserDefaults standardUserDefaults]

@implementation GADBManager

@synthesize databasePath;

+(id)shareSingleton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GADBManager alloc] init];
        [manager open];
        [manager addNewKey];
    });
    return manager;
}
/**
    sqlit更新新的key
    兼容老版本
 */
-(void)addNewKey
{
    
    BOOL addKey = [NSUserDefaultsStandard boolForKey:kAddSqliteKey];
    if (!addKey) {
        return;
    }
    NSString *querySQL = [NSString stringWithFormat:@"select * from \"%@\" ",sqliteName];
    const char *query_stmt = [querySQL UTF8String];
    char *errMsg;
    sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL);
    if(sqlite3_step(statement) == SQLITE_ROW){
        
        char *sqlTxt= (char *)sqlite3_column_text(statement,0);
        NSString *sqlString = [[NSString alloc] initWithUTF8String:sqlTxt];
        
        if ([sqlString rangeOfString: @"stepsJson"].length <= 0 ) {
            NSString *string = [NSString stringWithFormat:@"ALTER TABLE %@ ADD stepsJson text",sqliteName];
            
            if (sqlite3_exec(database, [string UTF8String], NULL, NULL, &errMsg)!=SQLITE_OK) {
                 NSLog(@"%@", @"成功插入字段");
                //
                [NSUserDefaultsStandard setBool:NO forKey:kAddSqliteKey];
                [NSUserDefaultsStandard synchronize];
            }
        }
        sqlite3_finalize(statement);
    }
}

-(BOOL) open
{
    NSString *loginNum = [GAGlobalData shareData].loginInfo.userName;
    dbName = [NSString stringWithFormat:@"stepMethod%@.db",loginNum];
    sqliteName = [NSString stringWithFormat:@"stepMethod%@",loginNum];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    databasePath = [documentsDirectory stringByAppendingPathComponent:dbName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL find = [fileManager fileExistsAtPath:databasePath];
    
    //找到数据库文件mydb.sql
    if (find) {
        NSLog(@"Database file have already existed.");
        if(sqlite3_open([databasePath UTF8String], &database) != SQLITE_OK) {
            sqlite3_close(database);
            NSLog(@"Error: open database file.");
            return NO;
        }
        return YES;
    }
    if(sqlite3_open([databasePath UTF8String], &database) == SQLITE_OK) {

        [self createChannelsTable:database];
        
        return YES;
    } else {
        sqlite3_close(database);
        NSLog(@"Error: open database file.");
        return NO;
    }
    return NO;
}


- (BOOL) createChannelsTable:(sqlite3*)db
{
    char *str1 = "create table if not exists ";
    const char *str2 = [sqliteName UTF8String];
    char *str3 = " (dateStr text primary key, steps text, success text, stepsJson text)";
    char * sql_stmt;
    sql_stmt = (char*)malloc(strlen(str1) + strlen(str2) + strlen(str3) + 1); //str1的长度 + str2的长度 + \0;
    if(!sql_stmt){ //如果内存动态分配失败
        printf("Error: malloc failed in concat! \n");
        exit(EXIT_FAILURE);
    }
    strcpy(sql_stmt,str1);
    strcat(sql_stmt,str2); //字符串拼接
    strcat(sql_stmt,str3);
    
    NSLog(@"%s",sql_stmt);
    sqlite3_stmt *statement;
    if(sqlite3_prepare_v2(db, sql_stmt, -1, &statement, nil) != SQLITE_OK) {
        NSLog(@"Error: failed to prepare statement:create channels table");
        sqlite3_close(database);
        return NO;
    }
    int success = sqlite3_step(statement);
    sqlite3_finalize(statement);
    if ( success != SQLITE_DONE) {
        NSLog(@"Error: failed to dehydrate:CREATE TABLE channels");
        sqlite3_close(database);
        return NO;
    }
    
    sqlite3_close(database);
    
    NSLog(@"Create table 'channels' successed.");
    return YES;
}
//增
-(BOOL)savaStepDataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andUpdataSuccess:(NSString *)success stepsJson:(NSString *)stepsJson
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *str1 = "INSERT INTO ";
        const char *str2 = [sqliteName UTF8String];
        char *str3 = " (dateStr, steps, success, stepsJson) VALUES (?,?,?,?)";
        char * sql;
        sql = (char*)malloc(strlen(str1) + strlen(str2) + strlen(str3) + 1); //str1的长度 + str2的长度 + \0;
        if(!sql){ //如果内存动态分配失败
            printf("Error: malloc failed in concat! \n");
            exit(EXIT_FAILURE);
        }
        strcpy(sql,str1);
        strcat(sql,str2); //字符串拼接
        strcat(sql,str3);
        
        int success2 = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (success2 != SQLITE_OK) {
            NSLog(@"Error: failed to insert:testTable");
            sqlite3_close(database);
            return NO;
        }
        
        //这里的数字1，2，3代表上面的第几个问号，这里将三个值绑定到三个绑定变量
        sqlite3_bind_text(statement, 1, [dateStr UTF8String],-1,SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [steps UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [success UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [stepsJson UTF8String], -1, SQLITE_TRANSIENT);

        //执行插入语句
        success2 = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果插入失败
        if (success2 == SQLITE_ERROR) {
            NSLog(@"Error: failed to insert into the database with message.");
            //关闭数据库
            sqlite3_close(database);
            return NO;
        }
        //关闭数据库
        sqlite3_close(database);
        return YES;
    }
    return NO;
}
//改
//更新数据
-(void)updataWithDateStr:(NSString *)dateStr andStepNumber:(NSString *)steps andSuccess:(NSString *)successOrNot stepsJson:(NSString *)stepsJson
{
    
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;//这相当一个容器，放转化OK的sql语句
        //        NSString *sqlStr = @"INSERT OR REPLACE INTO stepMethod18221969411 (dateStr, steps, success) VALUES (?,?,?)";
        //等价下面 c语言  创建动态数据库名称
        char *str1 = "INSERT OR REPLACE INTO ";
        const char *str2 = [sqliteName UTF8String];
        char *str3 = " (dateStr, steps, success, stepsJson) VALUES (?,?,?,?)";
        char * sql;
        sql = (char*)malloc(strlen(str1) + strlen(str2) + strlen(str3) + 1); //str1的长度 + str2的长度 + \0;
        if(!sql){ //如果内存动态分配失败
            printf("Error: malloc failed in concat! \n");
            exit(EXIT_FAILURE);
        }
        strcpy(sql,str1);
        strcat(sql,str2); //字符串拼接
        strcat(sql,str3);
        
        //将SQL语句放入sqlite3_stmt中
        int success = sqlite3_prepare_v2(database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            NSLog(@"Error: failed to update:testTable");
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return;
        }
        //绑定text类型的数据库数据
        sqlite3_bind_text(statement, 4, [stepsJson UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [successOrNot UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [steps UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 1, [dateStr UTF8String], -1, SQLITE_TRANSIENT);
        
        //执行SQL语句。这里是更新数据库
        success = sqlite3_step(statement);
        //释放statement
        sqlite3_finalize(statement);
        
        //如果执行失败
        if (success == SQLITE_ERROR) {
            NSLog(@"Error: failed to update the database with message.");
            //关闭数据库
            sqlite3_close(database);
            
        }else{
            NSLog(@"update success !!! ");
        }
        //执行成功后依然要关闭数据库
        sqlite3_close(database);
    }
}
//查
-(NSMutableArray*) findByDateStr:(NSString *)dateStr
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select dateStr, steps, success, stepsJson from \"%@\" where dateStr=\"%@\"",sqliteName,dateStr];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c0 = (const char *) sqlite3_column_text(statement, 0);
                
                NSString *date;
                if (c0 == NULL){
                    date = nil;
                }else
                    date = [[NSString alloc] initWithUTF8String:c0];
                
                const char *c1 = (const char *) sqlite3_column_text(statement, 1);
                NSString *stepNumber;
                if (c1 == NULL){
                    stepNumber = nil;
                }else
                    stepNumber = [[NSString alloc] initWithUTF8String:c1];
                
                const char *c2 = (const char *) sqlite3_column_text(statement, 2);
                NSString *success;
                if (c2 == NULL)
                    success = @"1";
                else
                    success = [[NSString alloc] initWithUTF8String:c2];
                
                const char *c3 = (const char *) sqlite3_column_text(statement, 3);
                NSString *stepsJson;
                if (c3 == NULL){
                    stepsJson = @"";
                }else
                    stepsJson = [[NSString alloc] initWithUTF8String:c3];
                GAStepMethod *method = [[GAStepMethod alloc] initWithDateStr:date andTodaySteps:stepNumber andUpdataSuccess:success stepsJson:stepsJson];
                [resultArray addObject:method];
                sqlite3_finalize(statement);
                sqlite3_close(database);
                return resultArray;
            }
            else{
                sqlite3_close(database);
                return nil;
            }
        }
        sqlite3_close(database);
    }
    return nil;
}
//查询一段时间的数据
-(NSMutableArray*) findByFromDateStr:(NSString *)startDate andToDateStr:(NSString *)toDate;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *start = [formatter dateFromString:startDate];
    NSDate *end = [formatter dateFromString:toDate];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select dateStr, steps, success, stepsJson from \"%@\" where dateStr >= \"%@\" and dateStr <= \"%@\"",sqliteName,start,end];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c0 = (const char *) sqlite3_column_text(statement, 0);
                NSString *date;
                if (c0 == NULL){
                    date = nil;
                    continue;
                }else
                    date = [[NSString alloc] initWithUTF8String:c0];
                const char *c1 = (const char *) sqlite3_column_text(statement, 1);
                NSString *stepNumber;
                if (c1 == NULL){
                    stepNumber = nil;
                    continue;
                }else
                    stepNumber = [[NSString alloc] initWithUTF8String:c1];
                const char *c2 = (const char *) sqlite3_column_text(statement, 2);
                NSString *success;
                if (c2 == NULL)
                    success = @"1";
                else
                    success = [[NSString alloc] initWithUTF8String:c2];
             
                const char *c3 = (const char *) sqlite3_column_text(statement, 3);
                NSString *stepsJson;
                if (c3 == NULL){
                    stepsJson = nil;
                }else
                    stepsJson = [[NSString alloc] initWithUTF8String:c3];
                
                GAStepMethod *method = [[GAStepMethod alloc] initWithDateStr:date andTodaySteps:stepNumber andUpdataSuccess:success stepsJson:stepsJson];
                
                [resultArray addObject:method];
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(database);
            
            return resultArray;
        }
        sqlite3_close(database);
    }
    return nil;
}

//查询所有本地数据
-(NSMutableArray *)findAllData
{
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"select dateStr, steps, success, stepsJson from \"%@\" ",sqliteName];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                const char *c0 = (const char *) sqlite3_column_text(statement, 0);
                NSString *date;
                if (c0 == NULL){
                    date = nil;
                    continue;
                }else
                    date = [[NSString alloc] initWithUTF8String:c0];
                const char *c1 = (const char *) sqlite3_column_text(statement, 1);
                NSString *stepNumber;
                if (c0 == NULL){
                    stepNumber = nil;
                    continue;
                }else
                    stepNumber = [[NSString alloc] initWithUTF8String:c1];
                const char *c2 = (const char *) sqlite3_column_text(statement, 2);
                NSString *success;
                if (c2 == NULL)
                    success = @"1";
                else
                    success = [[NSString alloc] initWithUTF8String:c2];
                
                const char *c3 = (const char *) sqlite3_column_text(statement, 3);
                NSString *stepsJson;
                if (c3 == NULL){
                    stepsJson = nil;
                }else
                    stepsJson = [[NSString alloc] initWithUTF8String:c3];
                GAStepMethod *method = [[GAStepMethod alloc] initWithDateStr:date andTodaySteps:stepNumber andUpdataSuccess:success stepsJson:stepsJson];
                [resultArray addObject:method];
            }
            sqlite3_finalize(statement);
            sqlite3_close(database);
            return resultArray;
        }
        sqlite3_close(database);
    }
    return nil;
}

@end
