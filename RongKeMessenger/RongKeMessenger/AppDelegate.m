//
//  AppDelegate.m
//  RKCloudDemo
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "RKNavigationController.h"
#import "LoginViewController.h"
#import "RKChatSessionListViewController.h"
#import "RKCloudSettingViewController.h"
#import "ToolsFunction.h"
#import "RKCloudUIContactViewController.h"
#import "UserProfilesInfo.h"
#import "Definition.h"
#import "DatabaseManager+FriendsNotifyTable.h"
#import "DatabaseManager+FriendTable.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "LogManager.h"

@interface AppDelegate ()

// #define DEBUG_WRITE_LOG

@property (nonatomic, strong) RKNavigationController *loginNavController; // Navigation for Login

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = COLOR_VIEW_BACKGROUND;
    
#ifdef DEBUG_WRITE_LOG
    // 重定向NSLog到文件中
    [LogManager redirectNSLogToFile];
#endif // DEBUG_WRITE_LOG
    
    NSLog(@"SYS: %@ Application Start, AppVersion: %@, RKCloudSDKVersion: %@", APP_DISPLAY_NAME, APP_WHOLE_VERSION, [RKCloudBase sdkVersion]);
    
    // 初始化应用程序实例中所有数据
    [self applicationInitialize];
    
//#ifdef DEBUG_WRITE_LOG
//    [LogManager saveLogInfoToDatabase:logName];
//#endif // DEBUG_WRITE_LOG
  
    // 启动App系统
    [self launchApp:launchOptions];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"SYS: applicationWillResignActive");
    
    // 通过前台模式切换到非激活状态时清理获取Push状态
    self.applicationGetPushMsgState &= ~PUSHMSG_ENTER_FOREGROUND;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"SYS: applicationDidEnterBackground");
    
    // 开始接收远端控制事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    // 手动切换到后台时清理获取Push状态
    self.applicationGetPushMsgState = 0;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    NSLog(@"SYS: applicationWillEnterForeground");
    
    // 结束接收远端控制事件
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    // Gray.Wang:2015.08.30:因目前无法准确得到自动接听的
    // 通过后台模式切换到非激活状态时，获取到Push后，需要自动接听电话
    self.applicationGetPushMsgState |= PUSHMSG_ENTER_FOREGROUND;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"SYS: applicationDidBecomeActive");
    
    // 已经切换到前台时清理获取Push状态
    self.applicationGetPushMsgState = 0;
    
    // 清除主程序图标的BadgeNumber
    application.applicationIconBadgeNumber = 0;
    // 清除通知中心上的所有留存记录
    [application cancelAllLocalNotifications];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"SYS: applicationWillTerminate");
}


#pragma mark -
#pragma mark APNS Push Service Delegate - UIApplicationDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"APNS: didRegisterForRemoteNotificationsWithDeviceToken: deviceToken = %@", deviceToken);
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"APNS: didRegisterUserNotificationSettings notificationSettings: %@", notificationSettings);
    
    [application registerForRemoteNotifications];
}
#endif

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"APNS: didFailToRegisterForRemoteNotificationsWithError error: %@", error);
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注册推送失败"
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"APNS: didReceiveRemoteNotification received:\n%@\n length = %lu Bytes",
          [userInfo description], (unsigned long)[[userInfo description] lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
    
    /*
     {
     aps =     {
     alert =         {
     "action-loc-key" = A;
     "loc-args" =             (
     wanglei
     );
     "loc-key" = C;
     };
     sound = "1.caf";
     };
     }
     */
    // 如果声音为：sound = "1.caf"; 则为新来电，准确判断来电通知
    if ([[[userInfo objectForKey:@"aps"] objectForKey:@"sound"] isEqualToString:@"1.caf"]) {
        // 收到Push通知
        self.applicationGetPushMsgState |= PUSHMSG_RECEIVED_NCR;
    }
    else {
        // 清理获取Push状态
        self.applicationGetPushMsgState = 0;
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    NSLog(@"APNS: didReceiveLocalNotification received:\n%@", notification);
    
    // 如果声音为：sound = "1.caf"; 则为新来电，准确判断来电通知
    if ([[[notification.userInfo objectForKey:@"aps"] objectForKey:@"sound"] isEqualToString:@"1.caf"]) {
        // 收到Push通知
        self.applicationGetPushMsgState |= PUSHMSG_RECEIVED_NCR;
    }
    else {
        // 清理获取Push状态
        self.applicationGetPushMsgState = 0;
    }
}


#pragma mark -
#pragma mark Get AppDelegate

+ (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}


#pragma mark -
#pragma mark Initialize All Data

// 初始化应用程序实例中所有数据
- (void)applicationInitialize
{
    NSLog(@"APP: applicationInitialize");
    
    // 默认启动时隐藏，所以启动后将状态栏显示出来
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
#if defined(DEBUG_LOG) || defined(DEBUG_WRITE_LOG)
    // 设置云视互动库日志输出模式
    [RKCloudBase setDebugMode:YES];
    
    // 增加异常捕获机制
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
#endif // DEBUG_LOG || DEBUG_WRITE_LOG
    
#ifndef LAN_SERVER // 使用公网服务器
    // 发布版本证书名称
    NSString *strAPNsCerName = @"pro_RongKeMessenger";
#ifdef DEBUG
    // 开发版本证书名称
    strAPNsCerName = @"dev_RongKeMessenger";
#endif
    
#else // 使用内网服务器
    // 发布版本证书名称（voip_services为使用Apple的VoIP Push服务做测试使用）
    NSString *strAPNsCerName = @"pro_RongKeMessengerLan";//@"voip_services";
#ifdef DEBUG
    // 开发版本证书名称
    strAPNsCerName = @"dev_RongKeMessengerLan";
#endif
    
#endif
    
    // 注册云视互动SDK
    [RKCloudBase registerSDKWithAppKey:RKCLOUD_SDK_APPKEY withDelegate:self withAPNsCertificates:strAPNsCerName];
    // 设置启动RKCloud的host地址
    [RKCloudBase setRootHost:DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS withPort:DEFAULT_RKCLOUD_ROOT_SERVER_PORT];
    
    // 注册APNS Push通知
    [ToolsFunction registerAPNSNotifications];
    
    // 数据库管理类
    self.databaseManager = [[DatabaseManager alloc] init];
    // 当前用户身份信息
    self.userProfilesInfo = [[UserProfilesInfo alloc] init];
    // 读取用户信息
    [self.userProfilesInfo loadUserProfiles];
    
    // 线程管理类
    self.threadsManager = [[ThreadsManager alloc] initThreadsManager:self];
    // 联系人管理类
    self.contactManager = [[ContactManager alloc] init];
    // 当前帐号管理类
    self.userInfoManager = [[UserInfoManager alloc] init];
    
    // 创建聊天模块管理类
    self.chatManager = [[ChatManager alloc] init];
    // 音视频通话管理类
    self.callManager = [[CallManager alloc] init];
    // 多人语音会议管理类
    self.meetingManager = [[MeetingManager alloc] init];
}

// 启动App系统
- (void)launchApp:(NSDictionary *)launchOptions
{
    // 用户是否已经登录
    if ([self.userProfilesInfo isLogined]) {
        // 已经登录则执行登录成后的处理
        [self.threadsManager doLoginSuccess];
        
        NSDictionary * dictAPNSUserInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        // 不到登陆页面且网络通并且PushSession存在，获取Push通知并处理
        if (dictAPNSUserInfo) {
            NSLog(@"APNS: launchApp -> didReceiveRemoteNotification received:\n%@\n length = %lu Bytes",
                  [dictAPNSUserInfo description], (unsigned long)[[dictAPNSUserInfo description] lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            
            // 如果声音为：sound = "1.caf"; 则为新来电，准确判断来电通知
            if ([[[dictAPNSUserInfo objectForKey:@"aps"] objectForKey:@"sound"] isEqualToString:@"1.caf"]) {
                // 通过第一次启动应用。收到APNS Push并自动接听电话
                self.applicationGetPushMsgState = PUSHMSG_RECEIVED_NCR | PUSHMSG_ENTER_FOREGROUND;
            }
            else {
                self.applicationGetPushMsgState = 0;
            }
        }
    }
    else {
        // 构建登录页面
        [self createLoginNavigation];
    }
}


#pragma mark -
#pragma mark UI Components

// 构建登录页面
- (void)createLoginNavigation
{
    NSLog(@"APP: createLoginNavigator");
    
    if (self.loginNavController != nil) {
        NSLog(@"DEBUG: createLoginNavigation--loginNavController != nil return");
        return;
    }
    
    // 清空mainTabController
    if (self.mainTabController) {
        // Release Main Tabbar
        [self.mainTabController.view removeFromSuperview];
        self.mainTabController = nil;
    }
    
    // 登录页面
    LoginViewController *loginViewController = [[LoginViewController alloc] init];
    self.loginNavController = [[RKNavigationController alloc] initWithRootViewController:loginViewController];
    self.window.rootViewController = self.loginNavController;
}

// 构建tabbar主页面
- (void)createMainTabbarController
{
    if (self.mainTabController != nil) {
        NSLog(@"DEBUG: createMainTabbarController != nil return");
        return;
    }
    
    // 设置状态栏默认风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // release login views
    if (self.loginNavController)
    {
        [self.loginNavController.view removeFromSuperview];
        self.loginNavController = nil;
    }
    
    NSLog(@"APP: createMainTabbarController");
    
    // Create TabController
    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.delegate = self;
    [tabController.tabBar setTintColor:[UIColor colorWithRed:0/255.0f green:153/255.0f blue:219/255.0f  alpha:1]];
    [tabController.tabBar setBarTintColor:[UIColor whiteColor]];
    
    // 聊天会话列表页面
    RKChatSessionListViewController *vwcChatSessionList = [[RKChatSessionListViewController alloc] initWithNibName:@"RKChatSessionListViewController" bundle:[NSBundle mainBundle]];
    RKNavigationController *navChatSessionListViewController = [[RKNavigationController alloc] initWithRootViewController:vwcChatSessionList];
    self.rkChatSessionListViewController = vwcChatSessionList;
    
    // 通讯录列表页面
    RKCloudUIContactViewController *vwcCloudContact = [[RKCloudUIContactViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    RKNavigationController *navChatContactViewController = [[RKNavigationController alloc] initWithRootViewController:vwcCloudContact];
    
    // 设置页面
    RKCloudSettingViewController *vwcCloudSetting = [[RKCloudSettingViewController alloc] initWithNibName:@"RKCloudSettingViewController" bundle:[NSBundle mainBundle]];
    RKNavigationController *navChatSettingsViewController = [[RKNavigationController alloc] initWithRootViewController:vwcCloudSetting];
    
    // 添加view到TabController
    tabController.viewControllers = [NSArray arrayWithObjects:navChatSessionListViewController,navChatContactViewController, navChatSettingsViewController, nil];
    self.window.rootViewController = tabController;
    self.mainTabController = tabController;
    self.mainTabController.delegate = self;
    
    // 默认为显示第一个Tab页面
    self.mainTabController.selectedIndex = 0;
}


#pragma mark -
#pragma mark Uncaught Exception Handler

static void uncaughtExceptionHandler(NSException * exception)
{
    NSLog(@"APP-CRASH: uncaughtExceptionHandler: exception = %@", exception);
    
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    // 异常发生时的调用栈
    NSArray *symbols = [exception callStackSymbols];
    //将调用栈拼成输出日志的字符串
    NSMutableString *strSymbols = [[NSMutableString alloc] init];
    for (NSString *item in symbols)
    {
        [strSymbols appendString:item];
        [strSymbols appendString:@"\n"];
    }
    
    // 根据当前时间的毫秒生成crash文件名称，如：“20141215192145368.crash”
    NSString *logName = [NSString stringWithFormat:@"%@.crash", [ToolsFunction getCurrentSystemDateMillisecondString]];
    // 将crash日志保存到Library/Caches目录下的DebugLog文件夹下
    NSString *crashFilePath = [NSString stringWithFormat:@"%@/%@", LIBRARY_DEBUG_LOG_PATH, logName];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [dateFormatter setLocale:locale];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *crashString = [NSString stringWithFormat:@"<- %@ ->[ Uncaught Exception ]\r\nName: %@, Reason: %@\r\n[ Fe Symbols Start ]\r\n%@[ Fe Symbols End ]\r\n\r\n", dateStr, name, reason, strSymbols];
    
    NSLog(@"CRASH: uncaughtExceptionHandler - crashString = \n%@", crashString);
    
    // 获取FileManager对象
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    // 把错误日志写到文件中
    if (![fileManager fileExistsAtPath:crashFilePath]) {
        [crashString writeToFile:crashFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    else {
        NSFileHandle *outFile = [NSFileHandle fileHandleForWritingAtPath:crashFilePath];
        [outFile seekToEndOfFile];
        [outFile writeData:[crashString dataUsingEncoding:NSUTF8StringEncoding]];
        [outFile closeFile];
    }
}


#pragma mark -
#pragma mark RKCloudBaseDelegate

/**
 * @brief 代理方法: 账号异常的回调处理
 *
 * @param errorCode 错误码 1：重复登录，2：账号被禁
 * @return
 */
- (void)didRKCloudFatalException:(int)errorCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 异常错误的处理
        switch (errorCode) {
            case 1: // 重复登录
            {
                // 开发者需要提示用户重复登录，并注销此用户回到用户登录页面
                // CS SessionID失效则提示用户重新登录CS
                [self.userProfilesInfo promptRepeatLogin];
            }
                break;
                
            case 2: // 账号被禁
            {
                // 开发者需要提示此用户被禁止使用，并注销此用户回到用户登录页面
                // 提示用户被禁止使用
                [self.userProfilesInfo promptBannedUsers];
            }
                break;
                
            default:
                break;
        }
    });
}

/**
 * @brief 代理方法: 接收到用户接收到自定义消息
 *
 * @param arrayCustomMessages 返回信息体如: [{"content":"***","sender":"***"},{"content":"***","sender":"***"},...,{"content":"***","sender":"***"}]，其中sender表示消息发送者；content表示应用推送的消息内容
 * @return
 */
- (void)didReceivedCustomUserMsg:(NSArray *)arrayCustomMessages
{
    for (NSString *customMessage in arrayCustomMessages) {
        NSDictionary *customMessageDic = [customMessage JSONValue];
        
        NSLog(@"RKCLOUD-CHAT: didReceivedCustomUserMsg: dictCustomMessage = %@", customMessageDic);
        
        NSArray *requestStrArray = [((NSString *)[customMessageDic objectForKey:@"content"]) componentsSeparatedByString:@","];
        if (requestStrArray.count > 0) {
            NSString *contentTitle = [requestStrArray objectAtIndex:0];
            NSString *friendAccount = [customMessageDic objectForKey:@"srcname"];
            if ([contentTitle isEqualToString:@"add_request"])
            {
                // 好友申请添加
                [self.contactManager friendRequestToAddFriend:friendAccount andRequestStrArray:requestStrArray];
            }
            else if ([contentTitle isEqualToString:@"add_confirm"])  
            {
                // 对方通过验证添加
                [self.contactManager friendAcceptAddReuest:friendAccount andRequestStrArray:requestStrArray];
            }
            else if ([contentTitle isEqualToString:@"delete_friend"])
            {
                // 删除好友
                [self.contactManager deleteByFriendMethod:friendAccount];
            }
            
            // 更新好友列表
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
        }
    }
}

@end
