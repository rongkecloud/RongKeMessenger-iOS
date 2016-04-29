//
//  DatabaseManager+ContactTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "FriendTable.h"
#import "FriendsNotifyTable.h"

@interface DatabaseManager (FriendTable)

// 保存好友表
- (void)saveFriendTable:(FriendTable *)friendTable;

// 根据friendAccount获取对应的ContactTable
- (FriendTable *)getContactTableByFriendAccount:(NSString *)friendAccount;

// 根据friendAccount查询是否有ContactTable
- (BOOL)isHaveContactTable:(NSString *)friendAccount;

/**
 *  根据GroupsId获取对应的FriendTable列表
 */
- (NSArray *)getFriendTableByGrooupId:(NSString *)groupId;

/**
 *  根据friendAccount删除对应的FriendInfoTable
 */
- (BOOL)deleteFriendTable:(NSString *)friendAccount;

/**
 *  获取所有的FriendInfoTable
 */
- (NSArray *)getAllFriendTable;

/**
 *  修改FriendTable中的GroupId为0，删除分组时需要将此分组对应的好友默认改成我的好友列表中
 */
- (void)changeFriendTaleGroupIdAndSaveToDB:(NSString *)groupsId;

/**
 *  获取好友的备注名
 *
 *  @param friendAccount 好友账号
 */
- (NSString*)getFriendRemarkNameByFriendAccount:(NSString *)friendAccount;

@end
