//
//  DatabaseManager+ContactTable.m
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager+FriendTable.h"

@implementation DatabaseManager (FriendTable)

// 保存好友表
- (void)saveFriendTable:(FriendTable *)friendTable
{
    if (friendTable == nil) {
        return;
    }
    
    [dataBaseLock lock];
    [friendTable save];
    [dataBaseLock unlock];
}

// 根据friendAccount获取对应的ContactTable
- (FriendTable *)getContactTableByFriendAccount:(NSString *)friendAccount
{
    if (friendAccount == nil)
    {
        return nil;
    }
    
    [dataBaseLock lock];
    NSString *filterString = [NSString stringWithFormat:@"where friend_account = '%@'", friendAccount];
    FriendTable *contactTable = (FriendTable *)[FriendTable findFirstByCriteria: filterString];
    [dataBaseLock unlock];
    
    return contactTable;
}

// 根据friendAccount查询是否有ContactTable
- (BOOL)isHaveContactTable:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return NO;
    }
    BOOL isHaveContactTable = NO;
    if ([self getContactTableByFriendAccount:friendAccount] != nil) {
        isHaveContactTable = YES;
    }
    
    return isHaveContactTable;
}

/**
 *  根据GroupsId获取对应的FriendTable列表
 */
- (NSArray *)getFriendTableByGrooupId:(NSString *)groupId
{
    if (groupId == nil) {
        return nil;
    }
     NSString *filterString = [[NSString alloc] initWithFormat:@"where group_id = '%@'", groupId];
    
    [dataBaseLock lock];
    // 查询所有的ShoppingCartTable表
    NSArray *contactArray = [FriendTable findByCriteria:filterString];
    [dataBaseLock unlock];
    
    return contactArray;
}

/**
 *  根据friendAccount删除对应的FriendInfoTable
 */
- (BOOL)deleteFriendTable:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return NO;
    }
    NSString *sqlCommand = [NSString stringWithFormat:@"delete from %@ where friend_account = '%@'", [FriendTable tableName], friendAccount];
    
    // 删除对应的表
    BOOL isSuccessDelete = [self executeSqlCommand:sqlCommand];
    
    return isSuccessDelete;
}

/**
 *  获取所有的FriendInfoTable
 */
- (NSArray *)getAllFriendTable
{
    NSString *filterString = [NSString stringWithFormat:@"order by friend_account"];
    
    // 查询所有的ShoppingCartTable表
    NSArray *shoppingCartTableArray = [FriendTable findByCriteria:filterString];
    
    return shoppingCartTableArray;
}

- (void)changeFriendTaleGroupIdAndSaveToDB:(NSString *)groupsId
{
    if (groupsId == nil) {
        return;
    }
    
    NSArray * friendTableArray = [self getFriendTableByGrooupId:groupsId];
    
    if (friendTableArray.count > 0) {
        for (int i = 0; i<friendTableArray.count; i++)
        {
            FriendTable *friendTable = [friendTableArray objectAtIndex:i];
            friendTable.groupId = @"0";
            [self saveFriendTable:friendTable];
        }
    }
    
}

/**
 *  获取好友的备注名
 *
 *  @param friendAccount 好友账号
 */
- (NSString*)getFriendRemarkNameByFriendAccount:(NSString *)friendAccount
{
    NSString *filterString = [[NSString alloc] initWithFormat:@"where friend_account = '%@'", friendAccount];
    
    [dataBaseLock lock];
    
    FriendTable *friendTable = (FriendTable *)[FriendTable findFirstByCriteria: filterString];
    NSString *friendRemarkName = friendTable.remarkName;
    
    [dataBaseLock unlock];
    
    return friendRemarkName;
}

@end
