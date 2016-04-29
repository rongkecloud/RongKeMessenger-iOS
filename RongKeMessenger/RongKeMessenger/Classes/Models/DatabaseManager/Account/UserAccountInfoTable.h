//
//  AccountTable.h
//  RongKeMessenger
//
//  Created by WangGray on 15/3/9.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLitePersistentObject.h"

@interface UserAccountInfoTable : SQLitePersistentObject

@property (copy, nonatomic) NSString *userAccount;          // 用户帐号
@property (copy, nonatomic) NSString *userAccountType;      // 用户类型
@property (copy, nonatomic) NSString *userPassword;         // 用户密码
@property (copy, nonatomic) NSString *userName;             // 用户姓名
@property (copy, nonatomic) NSString *userSex;              // 用户性别
@property (copy, nonatomic) NSString *rkCloudSDKPassword;   // 云视互动SDK密码
@property (copy, nonatomic) NSString *userMobile;           // 用户手机号码
@property (copy, nonatomic) NSString *userEmail;            // 用户Email
@property (copy, nonatomic) NSString *userAddress;          // 用户地址

@property (copy, nonatomic) NSString *userInfoVersion;      // 个人信息版本号
@property (copy, nonatomic) NSString *userOriginalAvatarVersion;    // 用户原始头像版本号
@property (copy, nonatomic) NSString *userThumbnailAvatarVersion;   // 用户缩略头像版本号

@property (nonatomic, copy) NSString *userServerAvatarVersion; // 用户在服务器上头像版本号

@property (copy, nonatomic) NSString *userSession;          // User Session
@property (copy, nonatomic) NSString *mobileAPIServer;      // API服务器地址
@property (copy, nonatomic) NSString *friendPermission;     // 加好友权限

@end
