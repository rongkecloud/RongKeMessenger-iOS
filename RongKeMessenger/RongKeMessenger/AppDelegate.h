//
//  AppDelegate.h
//  RKCloudDemo
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RKCloudBase.h"
#import "RKCloudChat.h"
#import "RKCloudMeeting.h"
#import "RKCloudAV.h"

#import "UserProfilesInfo.h"
#import "ChatManager.h"
#import "RKChatSessionListViewController.h"
#import "DatabaseManager.h"
#import "ThreadsManager.h"
#import "ContactManager.h"
#import "UserInfoManager.h"
#import "CallManager.h"
#import "MeetingManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, RKCloudBaseDelegate, RKCloudChatDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UITabBarController *mainTabController;

@property (nonatomic, weak) RKChatSessionListViewController *rkChatSessionListViewController; // 消息会话列表

@property (strong, nonatomic) UserProfilesInfo *userProfilesInfo; // 当前帐号信息类
@property (strong, nonatomic) DatabaseManager *databaseManager; // 数据库管理类
@property (strong, nonatomic) ThreadsManager *threadsManager; // Threads Manager
@property (strong, nonatomic) ChatManager *chatManager; // Chat MMS
@property (strong, nonatomic) ContactManager *contactManager; // 联系人管理类
@property (strong, nonatomic) UserInfoManager *userInfoManager; // 当前帐号管理类
@property (strong, nonatomic) CallManager *callManager; // 音视频通话管理类
@property (strong, nonatomic) MeetingManager *meetingManager; // 多人语音会议管理类

@property (nonatomic) BOOL isEnterBackground; // 判断是否进入后台
@property (nonatomic) short applicationRunState; // 程序运行状态的标志位
/* 程序运行状态的标志位
 BIT0: 是否重置帐号过程中
 BIT1: 是否登录账号过程中
 */
@property (nonatomic) short applicationGetPushMsgState; // 得到获取消息前的程序状态，为判断是否要自动接听使用

#pragma mark -
#pragma mark Get AppDelegate

+ (AppDelegate *)appDelegate;


#pragma mark -
#pragma mark UI Components

// 构建登录页面
- (void)createLoginNavigation;

// 构建tabbar主页面
- (void)createMainTabbarController;

@end

