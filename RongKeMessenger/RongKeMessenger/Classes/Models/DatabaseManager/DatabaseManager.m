//
//  DatabaseManager.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "SQLiteInstanceManager.h"
#import "SQLitePersistentObject.h"
#import "Definition.h"

@interface DatabaseManager ()

@end

@implementation DatabaseManager

- (id)init
{
    self = [super init];
    if (self) {
        dataBaseLock = [[NSLock alloc] init];
        
        self.isOpenSuccess = NO;
    }
    return self;
}


#pragma mark -
#pragma mark DataBase Operation methods  数据库操作

// 创建数据库通过userId
- (void)openDataBase:(NSString *)userId
{
    if (userId == nil) {
        return;
    }
    
    NSLog(@"DATABASE: openDataBase userId = %@ begin", userId);
    
    SQLiteInstanceManager *sqliteInstanceManager = [SQLiteInstanceManager sharedManager];
    if (sqliteInstanceManager)
    {
        // 设置数据库的文件夹
        NSString *sqliteFilePath = [NSString stringWithFormat:USER_HOME_DIRECTORY, userId];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:sqliteFilePath] == NO)
        {
            [fileManager createDirectoryAtPath:sqliteFilePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // 设置数据库的全路径
        NSString *databaseFilePath = [[NSString alloc] initWithFormat:@"%@/%@.db", sqliteFilePath, userId];
        
        // 设置数据库的路径与名字
        [sqliteInstanceManager setDatabaseFilepath:databaseFilePath];
        
        // 打开数据库
        if ([sqliteInstanceManager database]) {
            self.isOpenSuccess = YES;
            NSLog(@"DATABASE: openDataBase success databaseFilePath = %@", databaseFilePath);
        }
        else
        {
            NSLog(@"ERROR: openDataBase failure ");
        }
    }
    NSLog(@"DATABASE: openDataBase end");
}

// 关闭数据库
- (void)closeDataBase
{
    NSLog(@"DATABASE: closeDataBase begin");
    SQLiteInstanceManager *sqliteInstanceManager = [SQLiteInstanceManager sharedManager];
    if (sqliteInstanceManager) {
        NSLog(@"DATABASE: closeDataBase databaseFilePath = %@", sqliteInstanceManager.databaseFilepath);
        [sqliteInstanceManager closeDatabase];
    }
    NSLog(@"DATABASE: closeDataBase end");
    
    self.isOpenSuccess = NO;
}

// 删除指定的数据库
- (void)deleteDataBase:(NSString *)userName
{
    if (userName == nil) {
        return;
    }
    NSString *sqliteFilePath = [[NSString alloc] initWithFormat:USER_HOME_DIRECTORY, userName];
    // 设置数据库的全路径
    NSString *filePath = [[NSString alloc] initWithFormat:@"%@/%@.db", sqliteFilePath, userName];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if ([filemanager removeItemAtPath:filePath error:nil]) {
        NSLog(@"DATABASE: deleteDataBase success dataBasePath = %@", filePath);
    }
    else
    {
        NSLog(@"ERROR: deleteDataBase failure ");
    }
}


#pragma mark -
#pragma mark SQL Operation methods sql语句执行操作

// 通过表的名字删除该表中的所有的数据
- (BOOL)deleteAllDataOfTableByTableName:(NSString *)tableName
{
    BOOL isSuccessDelete = NO;
    NSString *sqlCommand = [NSString stringWithFormat:@"delete from %@", tableName];
    if ([self executeSqlCommand: sqlCommand])
    {
        isSuccessDelete = YES;
    }
    
    return isSuccessDelete;
}

/*
 删除
 DELETE FROM 表名称 WHERE 列名称 = 值
 
 eg：
 删除某列
 DELETE FROM Person WHERE LastName = 'Wilson'
 删除所有的数据
 DELETE FROM table_name 或者DELETE * FROM table_name
 */
- (BOOL)executeSqlCommand:(NSString *)sqlCommand
{
    if (sqlCommand == nil || [[SQLiteInstanceManager sharedManager] database] == nil) {
        return NO;
    }
    
    __block BOOL isSuccess = NO;
    [[SQLiteInstanceManager sharedManager] performUsingDBOperationQueue:^{
        char *errorMsg = NULL;
        
        if (sqlite3_exec([[SQLiteInstanceManager sharedManager] database], [sqlCommand UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK)
        {
            isSuccess = YES;
        }
        else
        {
            NSLog(@"WARNING: executeSqlCommand sqlCommand = %@, error = %s", sqlCommand, errorMsg);
        }
    }];
    
    return isSuccess;
}

// 查询
- (void)querySqlCommand:(NSString *)selectSqlCommand result:(void(^)(sqlite3_stmt * stateStmt))result
{
    if (selectSqlCommand == nil || [[SQLiteInstanceManager sharedManager] database] == nil) {
        return;
    }
    
    [[SQLiteInstanceManager sharedManager] performUsingDBOperationQueue:^{
        sqlite3_stmt *stateStmt = NULL;
        
        if (sqlite3_prepare_v2([[SQLiteInstanceManager sharedManager] database], [selectSqlCommand UTF8String], -1, &stateStmt, nil)==SQLITE_OK)
        {
            result(stateStmt);
        }
        else
        {
            NSLog(@"DATABASE: querySqlCommand selectSqlCommand = %@ no find", selectSqlCommand);
        }
        if (stateStmt) {
            sqlite3_finalize(stateStmt);
            stateStmt = NULL;
        }
    }];
}

@end
