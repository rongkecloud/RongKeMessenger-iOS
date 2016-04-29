//
//  DatabaseManager+FriendsNotifyTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "FriendsNotifyTable.h"

@interface DatabaseManager (FriendsNotifyTable)

// 保存好友通知表
- (void)saveFriendsNotifyTable:(FriendsNotifyTable *)friendsNotifyTable;

// 获取所有的FriendsNotifyTable
- (NSArray *)getAllFriendsNotifyTable;

// 获取所有的FriendsNotifyTable
- (FriendsNotifyTable *)getFriendsNotifyTableByFriendAccout:(NSString *)friendAccout;

/**
 *  根据friendAccount删除对应的FriendsNotifyTable
 */
- (BOOL)deleteFriendsNotifyTable:(NSString *)friendAccount;

@end
