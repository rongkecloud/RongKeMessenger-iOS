//
//  UserAccountInfo.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/14.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "UserProfilesInfo.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "RKCloudBase.h"
#import "DatabaseManager+UserAccountInfoTable.h"

// User Profile Info
#define USER_DEFAULTS_KEY_LAST_LOGIN_ACCOUNT            @"LastLoginAccount"
#define USER_DEFAULTS_KEY_LAST_APP_VERSION              @"LastAppVersion"
#define USER_DEFAULTS_KEY_LAST_SYSTEM_VERSION           @"LastSystemVersion"
//#define USER_DEFAULTS_KEY_LAST_GET_PROFILE_DATE			@"LastGetProfileDate"

#define USER_DEFAULTS_KEY_MOBILE_API_SERVER				@"APIServer"

@implementation UserProfilesInfo

#pragma mark -
#pragma mark Load/Save User Profile from Plist

/// 读取用户信息
- (BOOL)loadUserProfiles {
    NSLog(@"USE-PROFILES: loadUserProfiles");
    
    self.isPromptLogoutOrBannedUser = NO;
    self.isHaveNewfriendNotice = NO;
    
    /************* userAccount是当前登录的帐号，直接保存到系统的standardUserDefaults **********/
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
#ifdef LAN_SERVER  // WAN_TEST_SERVER
    // Mobile API Server
    self.mobileAPIServer = DEFAULT_HTTP_API_SERVER_ADDRESS;
#else
    
#ifdef WAN_TEST_SERVER
    self.mobileAPIServer = DEFAULT_HTTP_API_SERVER_ADDRESS;
#else
    if ([defaults objectForKey:USER_DEFAULTS_KEY_MOBILE_API_SERVER]) {
        self.mobileAPIServer = [defaults objectForKey:USER_DEFAULTS_KEY_MOBILE_API_SERVER];
    }
    else
    {
        self.mobileAPIServer = DEFAULT_HTTP_API_SERVER_ADDRESS;
        [defaults setValue:self.mobileAPIServer forKey:USER_DEFAULTS_KEY_MOBILE_API_SERVER];
        // save changes to disk
        [defaults synchronize];
    }
#endif
#endif
    NSLog(@"USE-PROFILES: mobileAPIServer = %@", self.mobileAPIServer);
    
    // User Account
    self.userAccount = [defaults stringForKey:USER_DEFAULTS_KEY_LAST_LOGIN_ACCOUNT];
    NSLog(@"USE-PROFILES: userAccount = %@", self.userAccount);
    if (self.userAccount == nil)
    {
        NSLog(@"USE-PROFILES: userAccount = %@, return", self.userAccount);
        return NO;
    }
    
    // 创建与用户数据相关的文件夹
    [self createUserDataDirectory];
    
    /************************** User Profile Config Info *********************************/
    // 设置plist的文件夹
    NSString *profilePlistFilePath = [[NSString alloc] initWithFormat:USER_HOME_DIRECTORY, [self.userAccount lowercaseString]];
    // 如果没有文件夹就新建一个文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:profilePlistFilePath] == NO)
    {
        [fileManager createDirectoryAtPath:profilePlistFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 加载已经存在的用户信息
    NSMutableDictionary *dictAppConfigInfo = [ToolsFunction loadResourceFromPlist:APP_CONFIG_INFO withDictionaryPath:profilePlistFilePath];
    if (dictAppConfigInfo)
    {
        // Last App Version
        self.lastAppVersion = [dictAppConfigInfo objectForKey:USER_DEFAULTS_KEY_LAST_APP_VERSION];
        NSLog(@"USE-PROFILES: lastAppVersion = %@", self.lastAppVersion);
        
        // Last System Version
        self.lastSystemVersion = [dictAppConfigInfo objectForKey:USER_DEFAULTS_KEY_LAST_SYSTEM_VERSION];
        NSLog(@"USE-PROFILES: lastSystemVersion = %@", self.lastSystemVersion);
        
        /*
         // 最后的同步Profile的时间
         self.lastSyncProfileDate = [dictAppConfigInfo objectForKey:USER_DEFAULTS_KEY_LAST_GET_PROFILE_DATE];
         NSLog(@"USE-PROFILES: lastSyncProfileDate = %@ -- currentLocale = %@", self.lastSyncProfileDate, [self.lastSyncProfileDate descriptionWithLocale:[NSLocale currentLocale]]);
         */
    }
    /************************** User Profile Config Info *********************************/
    
    /************************** User Account Info Table *********************************/
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 关闭数据库
    [appDelegate.databaseManager closeDataBase];
    // 打开数据库
    [appDelegate.databaseManager openDataBase:self.userAccount];
    
    UserAccountInfoTable *accountTable = [appDelegate.databaseManager getAccountTable];
    if (accountTable) {
        // User Session
        self.userSession = accountTable.userSession;
        NSLog(@"USE-PROFILES: userSession = %@", self.userSession);
        
        self.userName = accountTable.userName;
        NSLog(@"USE-PROFILES: userName = %@", self.userName);
        
        // user Password
        NSString *aesPassword = accountTable.userPassword;
        self.userPassword = [ToolsFunction AESDecryptString:aesPassword
                                                    withKey:APP_AES_PASSPHRASE
                                                     withIV:APP_AES_IV
                                                     useBit:AES_128_BIT];
        NSLog(@"USE-PROFILES: userPassword = %@", self.userPassword);
        
        // RKCloud SDK Password
        NSString *aesSDKPassword = accountTable.rkCloudSDKPassword;
        self.rkCloudSDKPassword = [ToolsFunction AESDecryptString:aesSDKPassword
                                                          withKey:APP_AES_PASSPHRASE
                                                           withIV:APP_AES_IV
                                                           useBit:AES_128_BIT];
        NSLog(@"USE-PROFILES: rkCloudSDKPassword = %@", self.rkCloudSDKPassword);
        
        // user email
        if (accountTable.userEmail) {
            self.userEmail = accountTable.userEmail;
        }
        NSLog(@"USE-PROFILES: userEmail = %@", self.userEmail);
        
        // user permission
        if (accountTable.friendPermission) {
            self.friendPermission = accountTable.friendPermission;
        }
        NSLog(@"USE-PROFILES: permission = %@", self.friendPermission);
        
        // user userInfoVersion
        if (accountTable.userInfoVersion) {
            self.userInfoVersion = accountTable.userInfoVersion;
        }
        NSLog(@"USE-PROFILES: userInfoVersion = %@", self.userInfoVersion);
        
        // userServerAvatarVersion
        if (accountTable.userServerAvatarVersion) {
            self.userServerAvatarVersion = accountTable.userServerAvatarVersion;
        }
        NSLog(@"USE-PROFILES: userServerAvatarVersion = %@", self.userServerAvatarVersion);
        
        // userOriginalAvatarVersion
        if (accountTable.userOriginalAvatarVersion) {
            self.userOriginalAvatarVersion = accountTable.userOriginalAvatarVersion;
        }
        NSLog(@"USE-PROFILES: userOriginalAvatarVersion = %@", self.userOriginalAvatarVersion);
        
        // userThumbnailAvatarVersion
        if (accountTable.userThumbnailAvatarVersion) {
            self.userThumbnailAvatarVersion = accountTable.userThumbnailAvatarVersion;
        }
        NSLog(@"USE-PROFILES: userThumbnailAvatarVersion = %@", self.userThumbnailAvatarVersion);
        
        // user userAccountType
        if (accountTable.userAccountType) {
            self.userAccountType = accountTable.userAccountType;
        }
        NSLog(@"USE-PROFILES: userAccountType = %@", self.userAccountType);
        
        // userMobile
        if (accountTable.userMobile) {
            self.userMobile = accountTable.userMobile;
        }
        NSLog(@"USE-PROFILES: userMobile = %@", self.userMobile);
        
        // userSex
        if (accountTable.userSex) {
            self.userSex = accountTable.userSex;
        }
        NSLog(@"USE-PROFILES: userSex = %@", self.userSex);
        
        // userAddress
        if (accountTable.userAddress) {
            self.userAddress = accountTable.userAddress;
        }
        NSLog(@"USE-PROFILES: userAddress = %@", self.userAddress);
        
#ifdef LAN_SERVER  // WAN_TEST_SERVER
        // Mobile API Server
        self.mobileAPIServer = DEFAULT_HTTP_API_SERVER_ADDRESS;
#else
        
#ifdef WAN_TEST_SERVER
        self.mobileAPIServer = DEFAULT_HTTP_API_SERVER_ADDRESS;
#else
        // Mobile API Server
        if (accountTable.mobileAPIServer) {
            self.mobileAPIServer = accountTable.mobileAPIServer;
        }
#endif
#endif
        
        NSLog(@"USE-PROFILES: mobileAPIServer = %@", self.mobileAPIServer);
    }
    /************************** User Account Info Table *********************************/
    
    return ([self isLogined]);
}


// Save User Profile to Plist
- (void)saveUserProfiles {
    if (self.userAccount == nil) {
        return;
    }
    
    NSLog(@"USE-PROFILES: saveUserProfiles");
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    /************* userAccount是当前登录的帐号，直接保存到系统的standardUserDefaults **********/
    [defaults setValue:[self.userAccount lowercaseString] forKey:USER_DEFAULTS_KEY_LAST_LOGIN_ACCOUNT];
    [defaults setValue:self.mobileAPIServer forKey:USER_DEFAULTS_KEY_MOBILE_API_SERVER];
    // save changes to disk
    [defaults synchronize];
    
    /************************** APP Config Info *************************/
    // 设置plist的文件夹
    NSString *profilePlistFilePath = [[NSString alloc] initWithFormat:USER_HOME_DIRECTORY, [self.userAccount lowercaseString]];
    // 如果没有文件夹就新建一个文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:profilePlistFilePath] == NO)
    {
        [fileManager createDirectoryAtPath:profilePlistFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 加载已经存在的用户信息
    NSMutableDictionary *dictAppConfigInfo = [NSMutableDictionary dictionary];
    // Last App Version
    [dictAppConfigInfo setValue:self.lastAppVersion forKey:USER_DEFAULTS_KEY_LAST_APP_VERSION];
    // Last System Version
    [dictAppConfigInfo setValue:self.lastSystemVersion forKey:USER_DEFAULTS_KEY_LAST_SYSTEM_VERSION];
    // 最后的同步Profile的时间
    //[dictAppConfigInfo setValue:self.lastSyncProfileDate forKey:USER_DEFAULTS_KEY_LAST_GET_PROFILE_DATE];
    // 保存账号信息到本地plist文件中
    [ToolsFunction saveResourceToPlist:dictAppConfigInfo
                          withFileName:APP_CONFIG_INFO
                    withDictionaryPath:profilePlistFilePath];
    /************************** APP Config Info *********************************/
    
    /************************** User Account Info Table *********************************/
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    if (appDelegate.databaseManager.isOpenSuccess == NO) {
        return;
    }
    
    UserAccountInfoTable *accountTable = [appDelegate.databaseManager getAccountTable];
    if (accountTable == nil) {
        accountTable = [[UserAccountInfoTable alloc] init];
    }
    accountTable.userAccount = self.userAccount;
    // user name
    if (self.userName) {
        accountTable.userName = self.userName;
    }
    
    // user password
    if (self.userPassword) {
        NSString *aesPassword = [ToolsFunction AESEncryptString:self.userPassword
                                                        withKey:APP_AES_PASSPHRASE
                                                         withIV:APP_AES_IV
                                                         useBit:AES_128_BIT];
        
        accountTable.userPassword = aesPassword;
    }
    else {
        accountTable.userPassword = nil;
    }
    
    // RKCloud SDK password
    if (self.rkCloudSDKPassword) {
        NSString *aesPassword = [ToolsFunction AESEncryptString:self.rkCloudSDKPassword
                                                        withKey:APP_AES_PASSPHRASE
                                                         withIV:APP_AES_IV
                                                         useBit:AES_128_BIT];
        
        accountTable.rkCloudSDKPassword = aesPassword;
    }
    else {
        accountTable.rkCloudSDKPassword = nil;
    }
    
    // user email
    if (self.userEmail) {
        accountTable.userEmail = self.userEmail;
    }
    
    // user permission
    if (self.friendPermission) {
        accountTable.friendPermission = self.friendPermission;
    }
    
    // user userAccountType
    if (self.userAccountType) {
        accountTable.userAccountType = self.userAccountType;
    }
    
    // user userInfoVersion
    if (self.userInfoVersion) {
        accountTable.userInfoVersion = self.userInfoVersion;
    }
    
    // userServerAvatarVersion
    if (self.userServerAvatarVersion) {
        accountTable.userServerAvatarVersion = self.userServerAvatarVersion;
    }
    
    // userOriginalAvatarVersion
    if (self.userOriginalAvatarVersion) {
        accountTable.userOriginalAvatarVersion = self.userOriginalAvatarVersion;
    }
    
    // userThumbnailAvatarVersion
    if (self.userThumbnailAvatarVersion) {
        accountTable.userThumbnailAvatarVersion = self.userThumbnailAvatarVersion;
    }
    
    // user mobile
    if (self.userMobile) {
        accountTable.userMobile = self.userMobile;
    }
    
    // user sex
    if (self.userSex) {
        accountTable.userSex = self.userSex;
    }
    
    // user address
    if (self.userAddress) {
        accountTable.userAddress = self.userAddress;
    }
    
    // User Session
    if (self.userSession) {
        accountTable.userSession = self.userSession;
    }
    else {
        accountTable.userSession = nil;
    }
    
    // Mobile API Server
    if (self.mobileAPIServer) {
        accountTable.mobileAPIServer = self.mobileAPIServer;
    }
    
    [appDelegate.databaseManager saveAccountTable:accountTable];
    /************************** User Account Info Table *************************/
}


#pragma mark -
#pragma mark User Data Directory

// 创建与用户数据相关的文件夹
- (void)createUserDataDirectory
{
    // 获取FileManager对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSError *error = nil;
    
    // 保存有关用户头像文件的路径，创建“Documents/%@/UserAvatar”目录
    NSString *avatarPath = [NSString stringWithFormat:USER_AVATAR_PATH, [self.userAccount lowercaseString]];
    if (NO == [fileManager fileExistsAtPath:avatarPath isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:avatarPath withIntermediateDirectories:YES attributes:nil error:&error];
    }
    self.userAvatarDirectory = avatarPath;
    
    // 创建公共的缓存文件目录: Library/Caches/Image
    NSString *imageDirectory = LIBRARY_CACHES_IMAGE_PATH;
    if (NO == [fileManager fileExistsAtPath:imageDirectory isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.imageCachesDirectory = imageDirectory;
    
    // 创建公共的缓存文件目录: Library/PlistFile
    NSString *plistFileDirectory = LIBRARY_PLIST_PATH;
    if (NO == [fileManager fileExistsAtPath:plistFileDirectory isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:plistFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // 创建公共的缓存文件目录: Library/DataFile
    NSString *dataFileDirectory = LIBRARY_DATAFILE_PATH;
    if (NO == [fileManager fileExistsAtPath:dataFileDirectory isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:dataFileDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    self.dataFileDirectory = dataFileDirectory;
}

/// 清空缓存数据
- (void)clearCacheUserData
{
    // 删除临时文件夹中所有的文件
    [ToolsFunction deleteAllFilesOfTempDirectory];
    
    // 删除公共的缓存文件目录文件
    [ToolsFunction deleteFileOrDirectoryForPath:LIBRARY_CACHES_IMAGE_PATH];
    
    // 删除缓存文件目录后，将重新创建用户目录文件夹
    [self createUserDataDirectory];
}


#pragma mark -
#pragma mark Get User Info Methods

// 用户是否已注册账号
- (BOOL)isRegistered
{
    return (self.userAccount != nil && self.userPassword != nil);
}

// 用户是否已经登录
- (BOOL)isLogined
{
    return (self.userSession != nil && self.userAccount != nil && self.userPassword != nil);
}

/// 获取当前用户的帐号
- (NSString *)getCurrentUserAccount {
    return self.userAccount;
}


#pragma mark -
#pragma mark User Account Data Operations

// Reset user account
- (void)resetUserProfile {
    
    // 清空个人信息资料
    self.userPassword = nil;
    self.rkCloudSDKPassword = nil;
    self.userSession = nil;
    
    // 重置最后同步Profile的时间
    //self.lastSyncProfileDate = nil;
    
    // 保存用户的Profiles
    [self saveUserProfiles];
    
    NSLog(@"USE-PROFILES: resetUserProfile");
}

// Wether the phone number is my own number
- (BOOL)isOwnUserName:(NSString*)userName
{
    // 严格比较
    return [self.userAccount isEqualToString:userName];
}

/* 导入CS Profile, 输入参数格式参见mobileLogin的返回值 */
- (void)importMyProfile:(NSDictionary *)resultDict
{
    /*
     Return(操作成功)
     oper_result=0
     ss=分配的session
     sdk_pwd=云视互动账号对应的密码
     type=用户类型
     name=姓名
     address=住址
     email=邮箱
     mobile=手机号码
     sex=性别
     permission=加好友权限
     info_version=个人信息版本号
     avatar_version=头像信息版本号
     */
    
    // 如果存在SessionID才保存
    if ([resultDict objectForKey:MSG_JSON_KEY_SESSION]) {
        // 记录User SessionID
        self.userSession = (NSString *)[resultDict objectForKey:MSG_JSON_KEY_SESSION];
    }
    
    // 云视互动用户sdk 登陆密码
    if ([resultDict objectForKey:@"sdk_pwd"]) {
        self.rkCloudSDKPassword = (NSString *)[resultDict objectForKey:@"sdk_pwd"];
    }
    
    // 用户名称
    if ([resultDict objectForKey:@"name"]) {
        self.userName = [resultDict objectForKey:@"name"];
    }
    
    // 邮箱地址
    if ([resultDict objectForKey:@"email"]) {
        self.userEmail = [resultDict objectForKey:@"email"];
    }
    
    // 地址信息
    if ([resultDict objectForKey:@"address"]) {
        self.userAddress = [resultDict objectForKey:@"address"];
    }
    
    // 性别
    if ([resultDict objectForKey:@"sex"]) {
        self.userSex = [resultDict objectForKey:@"sex"];
    }
    
    // 电话号码
    if ([resultDict objectForKey:@"mobile"]) {
        self.userMobile = [resultDict objectForKey:@"mobile"];
    }
    
    // 账号类型
    if ([resultDict objectForKey:@"type"]) {
        self.userAccountType = [resultDict objectForKey:@"type"];
    }
    
    // 加好友权限
    if ([resultDict objectForKey:@"permission"]) {
        self.friendPermission = [resultDict objectForKey:@"permission"];
    }
    
    // 个人信息版本号
    if ([resultDict objectForKey:@"info_version"]) {
        self.userInfoVersion = [resultDict objectForKey:@"info_version"];
    }
    
    // 保存最后一次登录成功的时间(为了定时获取一次自己的Porfile)
    //self.lastSyncProfileDate = [NSDate date];
    
    // 保存UserProfiles
    [self saveUserProfiles];
}

// 登入云视互动帐号
- (void)loginRKCloudAccount
{
    NSLog(@"USER-PROFILE: loginRKCloudAccount");
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 调用接口（初始化云视互动服务）
    // 初始化云视互动SDK服务
    [RKCloudBase init:[appDelegate.userProfilesInfo.userAccount lowercaseString]
             password:appDelegate.userProfilesInfo.rkCloudSDKPassword
            onSuccess:^{
                // 初始化RKCloudChat服务
                [RKCloudChat init:appDelegate.rkChatSessionListViewController];
                
                // 加载所有的会话列表
                [appDelegate.rkChatSessionListViewController loadAllChatSessionList];
                
                // 设置消息提示声音
                NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"rkcloud_chat_sound_custom" ofType:@"caf"];
                [RKCloudChatConfigManager setNotifyRingUri:soundPath];
                
                // 初始化RKCloudMeeting服务
                [RKCloudMeeting init:appDelegate.meetingManager];
                
                // 初始化RKCloudAV服务
                [RKCloudAV init:appDelegate.callManager];
                
                // 设置回铃声和来电铃声
                NSString *ringinFilePath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"caf"];
                [RKCloudAV setInCallRing:ringinFilePath];
                // NSString *ringbackFilePath = [[NSBundle mainBundle] pathForResource:@"ringback" ofType:@"wav"];
                [RKCloudAV setOutCallRing:ringinFilePath];
                
            }
             onFailed:^(int errorCode) {
                 
                 // 构建登录页面
                 [appDelegate createLoginNavigation];
                 
                 NSString *errString = @"操作失败";
                 switch (errorCode) {
                     case RK_PARAMS_ERROR:   /**< 请求参数错误    */
                         errString = @"请求参数错误";
                         break;
                         
                     case RK_SDK_UNINIT:   /**< Base SDK还未初始化成功    */
                         errString = @"Base SDK还未初始化成功";
                         break;
                         
                     case BASE_APP_KEY_AUTH_FAIL: /**< 客户端key值认证失败，原因可能为：key不存在、key验证失败、应用或者包名错误 */
                         errString = @"客户端key值认证失败，原因可能为：key不存在、key验证失败、应用或者包名错误";
                         break;
                         
                     case BASE_ACCOUNT_PW_ERROR: /**< 初始化失败：账号或密码不匹配 */
                         errString = @"初始化失败：账号或密码不匹配";
                         break;
                         
                     case BASE_ACCOUNT_BANNED: /**< 初始化失败：账号被禁 */
                         errString = @"初始化失败：账号被禁";
                         break;
                         
                     default:
                         break;
                 }
                 
                 // 弹出提示信息
                 [UIAlertView showSimpleAlert:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                    withTitle:nil
                                   withButton:NSLocalizedString(@"STR_OK", "确定")
                                     toTarget:nil];
             }];
}

// 登出当前帐号
- (void)logoutRKCloudAccount
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    if (appDelegate.applicationRunState & APPSTATE_RESET_USER) {
        return;
    }
    
    NSLog(@"USER-PROFILE: logoutCurrentAccount");
    appDelegate.applicationRunState = APPSTATE_RESET_USER;
    
    // 登出账号，存在会议，退出
    [appDelegate.meetingManager exitMeetingRoomWithReason:MEETING_CONF_NO_REASON];
    
    // 清理用户信息
    [self resetUserProfile];
    
    // 关闭数据库
    [appDelegate.databaseManager closeDataBase];
    
    // 退出云视互动服务
    [RKCloudBase unInit];
    [RKCloudChat unInit];
    [RKCloudMeeting unInit];
    [RKCloudAV unInit];
    
    // 取消注册Push Notification通知
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    
    // 删除状态栏的提示窗口
    [ToolsFunction removeStatusBarPrompt];
    [ToolsFunction destroyStatusBarPrompt];
    
    // 重置帐号状态复位
    appDelegate.applicationRunState &= ~APPSTATE_RESET_USER;
    
    // 构建登录页面
    [appDelegate createLoginNavigation];
}

/// 提示重复登录帐号并自动登出
- (void)promptRepeatLogin
{
    // 如果已经提示过则不再提示
    if (!self.isPromptLogoutOrBannedUser)
    {
        NSLog(@"USER-PROFILE: promptRepeatLogin");
        
        self.isPromptLogoutOrBannedUser = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 重复登录提示窗口
            [UIAlertView showRepeatLoginAlert:self];
        });
    }
}

/// 提示用户被禁止使用
- (void)promptBannedUsers
{
    // 如果已经提示过则不再提示
    if (!self.isPromptLogoutOrBannedUser)
    {
        NSLog(@"USER-PROFILE: promptBannedUsers");
        
        self.isPromptLogoutOrBannedUser = YES;
        
        // 登出当前帐号
        [self logoutRKCloudAccount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 提示当前用户已经被禁止
            [UIAlertView showBannedUsersAlert:self];
        });
    }
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case ALERT_REPEAT_LOGIN_TAG:
        case ALERT_BANNED_USERS_TAG:
        {
            self.isPromptLogoutOrBannedUser = NO;
            
            // 登出云视互动帐号
            [self logoutRKCloudAccount];
        }
            break;
            
        default:
            break;
    }
}

@end
