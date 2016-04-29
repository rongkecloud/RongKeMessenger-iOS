//
//  DatabaseManager+FriendGroups.h
//  RongKeMessenger
//
//  Created by Jacob on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "FriendGroupsTable.h"

@interface DatabaseManager (FriendGroupsTable)

// 保存好友群组表
- (void)saveFriendGroupsTable:(FriendGroupsTable *)friendGroupsTable;

/**
 *  创建我的好友分组
 */
- (void)creatMyFriendGroupsTable;

/**
 *  生成FriendGroupsTable
 *  groupsInfoDic：联系人分组信息
 */
- (void)creatAndUpdateFriendGroupsTableToDB:(NSArray *)contactGroupsArray;

/**
 *  获取contactGroupsDic
 *  contactGroupsId分组ID
 */
- (FriendGroupsTable *)getFriendGroupsTableById:(NSString *)contactGroupsId;

/**
 *  查询所有的FriendGroupsTable
 */
- (NSArray *)getAllFriendGroupsTable;

/**
 *  删除FriendGroupsTable
 */
- (BOOL)deleteFriendGroupsTable:(FriendGroupsTable *)friendGroupsTable;

@end
