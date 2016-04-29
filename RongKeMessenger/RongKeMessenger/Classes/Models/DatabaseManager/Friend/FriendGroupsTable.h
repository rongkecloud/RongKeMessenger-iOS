//
//  FriendGroupsTable.h
//  RongKeMessenger
//
//  Created by Jacob on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface FriendGroupsTable : SQLitePersistentObject

@property (nonatomic, copy) NSString *contactGroupsId;
@property (nonatomic, copy) NSString *contactGroupsName;
@property (nonatomic, assign) BOOL isShowFriendsList;   // 是否展示当前组对应的好友列表

@end
