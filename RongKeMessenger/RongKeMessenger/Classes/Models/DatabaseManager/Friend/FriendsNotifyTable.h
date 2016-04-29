//
//  FriendsNotifyTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface FriendsNotifyTable : SQLitePersistentObject

@property (nonatomic, copy) NSString *friendAccount;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *sysName;
@property (nonatomic, copy) NSString *readStatus;

@end
