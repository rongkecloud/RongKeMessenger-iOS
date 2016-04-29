//
//  ContactTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface FriendTable : SQLitePersistentObject

@property(nonatomic, copy) NSString *friendAccount;
@property(nonatomic, copy) NSString *highGradeName;
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, copy) NSString *remarkName;

@end
