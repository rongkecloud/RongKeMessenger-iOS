//
//  PersonalInfos.h
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonalInfos : NSObject

@property (copy, nonatomic) NSString *userAccount;          // 用户帐号
@property (copy, nonatomic) NSString *userName;             // 用户姓名
@property (copy, nonatomic) NSString *userAddress;          // 用户地址
@property (copy, nonatomic) NSString *userSex;              // 用户性别
@property (copy, nonatomic) NSString *userInfoVersion;      // 个人信息版本号
@property (copy, nonatomic) NSString *userAvatarVersion;    // 用户小头像版本号
@property (copy, nonatomic) NSString *userMobile;           // 用户手机号码
@property (copy, nonatomic) NSString *userEmail;            // 用户Email
@property (copy, nonatomic) NSString *userAccountType;      // 用户类型
@property (copy, nonatomic) NSString *userRemark;           // 好友备注
@property (copy, nonatomic) NSString *avatarType;           // 图片类型

@end
