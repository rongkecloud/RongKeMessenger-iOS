//
//  DatabaseManager+FriendsNotifyTable.m
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager+FriendsNotifyTable.h"


@implementation DatabaseManager (FriendsNotifyTable)

// 保存好友通知表
- (void)saveFriendsNotifyTable:(FriendsNotifyTable *)friendsNotifyTable
{
    if (friendsNotifyTable == nil || friendsNotifyTable.friendAccount == nil) {
        return;
    }
    
    [dataBaseLock lock];
    [friendsNotifyTable save];
    [dataBaseLock unlock];
}

// 获取所有的FriendsNotifyTable
- (NSArray *)getAllFriendsNotifyTable
{
    NSString *filterString = [NSString stringWithFormat:@"order by pk desc"];
    
    [dataBaseLock lock];
    // 查询所有的ShoppingCartTable表
    NSArray *contactGroupsArray = [FriendsNotifyTable findByCriteria:filterString];
    [dataBaseLock unlock];
    
    return contactGroupsArray;
}


// 获取所有的FriendsNotifyTable
- (FriendsNotifyTable *)getFriendsNotifyTableByFriendAccout:(NSString *)friendAccout
{
    if (friendAccout == nil) {
        return nil;
    }
    
    NSString *filterString = [[NSString alloc] initWithFormat:@"where friend_account = '%@'", friendAccout];
    
    [dataBaseLock lock];
    FriendsNotifyTable *friendsNotifyTable = (FriendsNotifyTable *)[FriendsNotifyTable findFirstByCriteria: filterString];
    [dataBaseLock unlock];
    
    return friendsNotifyTable;
}


/**
 *  根据friendAccount删除对应的FriendsNotifyTable
 */
- (BOOL)deleteFriendsNotifyTable:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return NO;
    }
    
    NSString *sqlCommand = [NSString stringWithFormat:@"delete from %@ where friend_account = '%@'", [FriendsNotifyTable tableName], friendAccount];
    
    // 删除对应的表
    BOOL isSuccessDelete = [self executeSqlCommand:sqlCommand];
    
    return isSuccessDelete;
}

@end
