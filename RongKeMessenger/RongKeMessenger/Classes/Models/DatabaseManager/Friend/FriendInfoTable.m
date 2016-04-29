//
//  UserInfoTable.m
//  RongKeMessenger
//
//  Created by WangGray on 15/7/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "FriendInfoTable.h"

@implementation FriendInfoTable

- (id)init {
    self = [super init];
    if (self) {
        self.account = nil; // 用户名
        self.name = nil; // 姓名
        self.address = nil; // 地址
        self.mobile = nil; // 电话号码
        self.type = nil; // 用户类型
        self.email = nil; // 邮件
        self.sex = nil; // 性别
        
        self.friendInfoVersion = @"0"; // 个人信息版本号
        self.friendOriginalAvatarVersion = @"0"; // 用户原始头像版本号
        self.friendThumbnailAvatarVersion = @"0"; // 用户缩略头像版本号
        self.friendServerAvatarVersion = @"0"; // 用户在服务器上头像版本号
        
        self.infoSyncLastTime = 0; // 最后更新时间
    }
    return self;
}

@end
