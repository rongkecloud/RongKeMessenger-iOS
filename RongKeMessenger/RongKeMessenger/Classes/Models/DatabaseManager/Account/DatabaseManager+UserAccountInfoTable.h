//
//  DatabaseManager+AccountTable.h
//  RongKeMessenger
//
//  Created by Gray on 15/4/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "UserAccountInfoTable.h"

@interface DatabaseManager (UserAccountInfoTable)

#pragma mark -
#pragma mark AccountTable Records

// 保存AccountTable
- (void)saveAccountTable:(UserAccountInfoTable *)accountTable;

// 获取AccountTable
- (UserAccountInfoTable *)getAccountTable;

// 删除AccountTable
- (void)deleteAccountTable;

@end
