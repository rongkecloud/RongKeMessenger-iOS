//
//  DatabaseManager.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseManager : NSObject
{
    NSLock *dataBaseLock;
}

@property (nonatomic, assign) BOOL isOpenSuccess; // 是否打开数据库成功

#pragma mark -
#pragma mark DataBase Operation methods  数据库操作

/// 创建数据库通过userId
- (void)openDataBase:(NSString *)userId;
/// 关闭数据库
- (void)closeDataBase;
/// 删除指定的数据库
- (void)deleteDataBase:(NSString *)userId;


#pragma mark -
#pragma mark SQL Operation methods sql语句执行操作

// 通过表的名字删除该表中的所有的数据
- (BOOL)deleteAllDataOfTableByTableName:(NSString *)tableName;
// 执行SQL语句
- (BOOL)executeSqlCommand:(NSString *)sqlCommand;
// 查询
- (void)querySqlCommand:(NSString *)selectSqlCommand result:(void(^)(sqlite3_stmt * stateStmt))result;

@end
