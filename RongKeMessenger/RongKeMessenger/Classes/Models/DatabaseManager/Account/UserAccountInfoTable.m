//
//  AccountTable.m
//  RongKeMessenger
//
//  Created by WangGray on 15/3/9.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "UserAccountInfoTable.h"

@implementation UserAccountInfoTable

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.userAccount = nil;          // 用户帐号
    self.userAccountType = nil;      // 用户类型
    self.userPassword = nil;         // 用户密码
    self.userName = nil;             // 用户姓名
    self.userSex = nil;              // 用户性别
    self.rkCloudSDKPassword = nil;   // 云视互动SDK密码
    self.userMobile = nil;           // 用户手机号码
    self.userEmail = nil;            // 用户Email
    self.userAddress = nil;          // 用户地址
    self.userInfoVersion = nil;      // 个人信息版本号
    self.userOriginalAvatarVersion = nil;    // 用户原始头像版本号
    self.userThumbnailAvatarVersion = nil;   // 用户缩略头像版本号
    
    self.userSession = nil;          // User Session
    self.mobileAPIServer = nil;      // API服务器地址
    self.friendPermission = nil;     // 加好友权限
}

@end
