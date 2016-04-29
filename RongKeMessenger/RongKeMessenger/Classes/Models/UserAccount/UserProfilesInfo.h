//
//  UserAccountInfo.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/14.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfilesInfo : NSObject

// Save DB
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

// Save user_profiles_info.plist
@property (copy, nonatomic) NSString *lastAppVersion; // 最后一次用户使用App的版本号s
@property (copy, nonatomic) NSString *lastSystemVersion; // 最后一次保存的系统版本

//@property (nonatomic) NSDate *lastSyncProfileDate; // 最后同步Profile的时间

// No Save
@property (assign, nonatomic) BOOL isPromptLogoutOrBannedUser; // 是否提示为被踢或被禁止的用户
@property (assign, nonatomic) BOOL isHaveNewfriendNotice; // 是否有新联系人的提示红点标记

@property (copy, nonatomic) NSString *userAvatarDirectory; // 所有从服务器上下载的图片缓存目录
@property (copy, nonatomic) NSString *imageCachesDirectory; // 所有从服务器上下载的图片缓存目录
@property (copy, nonatomic) NSString *dataFileDirectory; // 公共的数据文件目录


#pragma mark -
#pragma mark Load/Save User Profile from Plist

/// 读取用户信息
- (BOOL)loadUserProfiles;
/// 保存用户信息
- (void)saveUserProfiles;


#pragma mark -
#pragma mark User Data Directory

// 创建与用户数据相关的文件夹
- (void)createUserDataDirectory;

/// 清空缓存数据
- (void)clearCacheUserData;


#pragma mark -
#pragma mark Get User Info Methods

/// 用户是否已注册账号
- (BOOL)isRegistered;
/// 用户是否已经登录
- (BOOL)isLogined;
/// 获取当前用户的帐号
- (NSString *)getCurrentUserAccount;


#pragma mark -
#pragma mark User Account Data Operations

/// 清除用户信息.
- (void)resetUserProfile;

/// Wether the phone number is my own number.
- (BOOL)isOwnUserName:(NSString*)userName;

/// Import CS profile for user.
- (void)importMyProfile:(NSDictionary*)resultDict;

/// 登入云视互动帐号
- (void)loginRKCloudAccount;
/// 登出当前帐号
- (void)logoutRKCloudAccount;

/// 提示重复登录帐号并自动登出
- (void)promptRepeatLogin;
/// 提示用户被禁止使用
- (void)promptBannedUsers;

@end
