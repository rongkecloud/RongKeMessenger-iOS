//
//  DatabaseManager+FriendGroups.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager+FriendGroupsTable.h"
#import "FriendGroupsTable.h"
#import "Definition.h"

@implementation DatabaseManager (FriendGroupsTable)

// 保存好友群组表
- (void)saveFriendGroupsTable:(FriendGroupsTable *)friendGroupsTable
{
    if (friendGroupsTable == nil) {
        return;
    }
    
    [dataBaseLock lock];
    [friendGroupsTable save];
    [dataBaseLock unlock];
}

/**
 *  创建我的好友分组
 */
- (void)creatMyFriendGroupsTable
{
    // 创建默认的分组
    FriendGroupsTable *contactGroupsTable = [self getFriendGroupsTableById:@"0"];
    if (!contactGroupsTable) {
        contactGroupsTable = [[FriendGroupsTable alloc] init];
        contactGroupsTable.contactGroupsId = @"0";
        contactGroupsTable.contactGroupsName = NSLocalizedString(@"STR_MY_FRIENDS", @"我的好友");
        contactGroupsTable.isShowFriendsList = NO;
        
        [self saveFriendGroupsTable:contactGroupsTable];
    }
}

/**
 *  生成FriendGroupsTable
 *  groupsInfoDic：联系人分组信息
 */
- (void)creatAndUpdateFriendGroupsTableToDB:(NSArray *)contactGroupsArray
{
    if (contactGroupsArray == nil || contactGroupsArray.count == 0) {
        return;
    }
    
    for (int i = 0; i<contactGroupsArray.count; i++)
    {
        // 获取联系人分组
        NSDictionary *contactGroupsDic = [contactGroupsArray objectAtIndex:i];
        
        // 获取联系人分组Id
        NSString *contactGroupsId = [NSString stringWithFormat:@"%@", [contactGroupsDic objectForKey:@"gid"]];
        
        // 查询对应的FriendGroupsTable
        FriendGroupsTable *contactGroupsTable = [self getFriendGroupsTableById:contactGroupsId];
        if (contactGroupsTable == nil)
        {
            // 创建FriendGroupsTable
            contactGroupsTable = [[FriendGroupsTable alloc] init];
            contactGroupsTable.contactGroupsId = contactGroupsId;
        }
        
        contactGroupsTable.contactGroupsName = [contactGroupsDic objectForKey:@"gname"];
        [self saveFriendGroupsTable:contactGroupsTable];
    }
}

/**
 *  获取contactGroupsDic
 *
 */
- (FriendGroupsTable *)getFriendGroupsTableById:(NSString *)contactGroupsId
{
    if (contactGroupsId == nil)
    {
        return nil;
    }
    
    NSString *filterString = [[NSString alloc] initWithFormat:@"where contact_groups_id = '%@'", contactGroupsId];
    
    [dataBaseLock lock];
    FriendGroupsTable *contactGroupsTable = (FriendGroupsTable *)[FriendGroupsTable findFirstByCriteria:filterString];
    [dataBaseLock unlock];
    
    return contactGroupsTable;
}

/**
 *  查询所有的FriendGroupsTable
 *
 */
- (NSArray *)getAllFriendGroupsTable
{
    NSString *filterString = [NSString stringWithFormat:@"order by contact_groups_id asc"];
    
    [dataBaseLock lock];
    // 查询所有的ShoppingCartTable表
    NSArray *contactGroupsArray = [FriendGroupsTable findByCriteria:filterString];
    [dataBaseLock unlock];
    
    return contactGroupsArray;
}

/**
 *  删除FriendGroupsTable
 */
- (BOOL)deleteFriendGroupsTable:(FriendGroupsTable *)friendGroupsTable
{
    if (friendGroupsTable == nil) {
        return NO;
    }
    
    NSString *sqlCommand = [NSString stringWithFormat:@"delete from %@ where contact_groups_id = %@", [FriendGroupsTable tableName], friendGroupsTable.contactGroupsId];
    
    // 删除对应的表
    BOOL isSuccessDelete = [self executeSqlCommand:sqlCommand];
    return isSuccessDelete;
}

@end
