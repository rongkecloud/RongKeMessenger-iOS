//
//  UserInfoTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SQLitePersistentObject.h"

@interface FriendInfoTable : SQLitePersistentObject

@property (nonatomic, copy) NSString *account; // 用户名
@property (nonatomic, copy) NSString *name; // 姓名
@property (nonatomic, copy) NSString *address; // 地址
@property (nonatomic, copy) NSString *mobile; // 电话号码
@property (nonatomic, copy) NSString *type; // 用户类型
@property (nonatomic, copy) NSString *email; // 邮件
@property (nonatomic, copy) NSString *sex; // 性别

@property (nonatomic, copy) NSString *friendInfoVersion; // 个人信息版本号
@property (nonatomic, copy) NSString *friendOriginalAvatarVersion; // 用户原始头像版本号
@property (nonatomic, copy) NSString *friendThumbnailAvatarVersion; // 用户缩略头像版本号

@property (nonatomic, copy) NSString *friendServerAvatarVersion; // 用户在服务器上头像版本号

@property (nonatomic) long infoSyncLastTime; // 最后更新时间
@end
