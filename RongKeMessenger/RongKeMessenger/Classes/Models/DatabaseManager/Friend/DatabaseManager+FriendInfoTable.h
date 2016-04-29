//
//  DatabaseManager+UserInfoTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "DatabaseManager.h"
#import "FriendInfoTable.h"

@interface DatabaseManager (FriendInfoTable)

// 保存好友信息表
- (void)saveFriendInfoTable:(FriendInfoTable *)friendInfoTable;

/**
 *  根据friendAccout获取对应的FriendTable列表
 */
- (FriendInfoTable *)getFriendInfoTableByAccout:(NSString *)friendAccout;

/**
 *  根据FriendAccount删除FriendInfoTable表
 */
- (BOOL)deleteFriendInfoTableByAccount:(NSString *)friendAccount;

/**
 *  创建云视互动小秘书FriendInfoTable
 */
- (FriendInfoTable *)creatRKServiceFriendInfoTable;

@end
