//
//  DatabaseManager+UserInfoTable.m
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager+FriendInfoTable.h"
#import "Definition.h"
#import "ToolsFunction.h"

@implementation DatabaseManager (FriendInfoTable)

// 保存好友信息表
- (void)saveFriendInfoTable:(FriendInfoTable *)friendInfoTable
{
    if (friendInfoTable == nil) {
        return;
    }
    
    [dataBaseLock lock];
    [friendInfoTable save];
    [dataBaseLock unlock];
}

/**
 *  根据friendAccout获取对应的FriendTable列表
 */
- (FriendInfoTable *)getFriendInfoTableByAccout:(NSString *)friendAccount
{
    NSString *filterString = [[NSString alloc] initWithFormat:@"where account = '%@'", friendAccount];
    
    [dataBaseLock lock];
    FriendInfoTable *friendInfoTable = (FriendInfoTable *)[FriendInfoTable findFirstByCriteria: filterString];
    [dataBaseLock unlock];
    
    return friendInfoTable;
}

/**
 *  根据FriendAccount删除FriendInfoTable表
 */
- (BOOL)deleteFriendInfoTableByAccount:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return NO;
    }
    
    NSString *sqlCommand = [NSString stringWithFormat:@"delete from %@ where account = '%@'", [FriendInfoTable tableName], friendAccount];
    
    // 删除对应的表
    BOOL isSuccessDelete = [self executeSqlCommand:sqlCommand];
    
    return isSuccessDelete;
    
}

/**
 *  创建云视互动小秘书FriendInfoTable
 */
- (FriendInfoTable *)creatRKServiceFriendInfoTable
{
    FriendInfoTable *rkServiceFriendInfoTable = [self getFriendInfoTableByAccout:RONG_KE_SERVICE];
    if (rkServiceFriendInfoTable == nil) {
        rkServiceFriendInfoTable = [[FriendInfoTable alloc] init];
        rkServiceFriendInfoTable.account = RONG_KE_SERVICE;
        
        [rkServiceFriendInfoTable save];
    }
    return rkServiceFriendInfoTable;
}




@end
