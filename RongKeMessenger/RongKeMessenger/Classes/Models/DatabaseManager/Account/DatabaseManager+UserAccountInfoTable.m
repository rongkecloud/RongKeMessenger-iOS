//
//  DatabaseManager+AccountTable.m
//  RongKeMessenger
//
//  Created by Gray on 15/4/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager+UserAccountInfoTable.h"
#import "UserAccountInfoTable.h"

@implementation DatabaseManager (UserAccountInfoTable)

#pragma mark -
#pragma mark AccountTable Records

// 保存AccountTable
- (void)saveAccountTable:(UserAccountInfoTable *)accountTable
{
    if (accountTable == nil) {
        return;
    }
    [dataBaseLock lock];
    [accountTable save];
    [dataBaseLock unlock];
}

// 获取AccountTable
- (UserAccountInfoTable *)getAccountTable
{
    UserAccountInfoTable *accountTable = nil;
    
    [dataBaseLock lock];
    NSArray *accountTableArray = [UserAccountInfoTable allObjects];
    [dataBaseLock unlock];
    
    if (accountTableArray && [accountTableArray count] > 0)
    {
        accountTable = [accountTableArray objectAtIndex: 0];
    }
    return accountTable;
}

// 删除所有的会话
- (void)deleteAccountTable
{
    [self deleteAllDataOfTableByTableName: [UserAccountInfoTable tableName]];
    
    // 删除缓存中的数据
    //[self clearTableCache: [AccountTable className]];
}

@end
