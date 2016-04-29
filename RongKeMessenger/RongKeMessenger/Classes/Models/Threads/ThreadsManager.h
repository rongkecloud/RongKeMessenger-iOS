//
//  ThreadsManager.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RegisterAccountInfo.h"
#import "Definition.h"

@interface ThreadsManager : NSObject


#pragma mark -
#pragma mark Init Threads Manager

// 初始化Threads Manager
- (id)initThreadsManager:(id)delegate;


#pragma mark -
#pragma mark Callback Function Hander

// 设置回调类和方法指针
- (void)setCallbackFunctionHander:(id)classHander withFunctionSelector:(SEL)functionSelector;


#pragma mark -
#pragma mark Send Pincode Thread

// 同步发送发送手机验证码
- (BOOL)syncSendPincode:(NSString *)mobile withPincodeModeType:(SendPincodeMode)sendType;

#pragma mark -
#pragma mark Register Account Thread

// 启动注册线程
- (void)startRegisterThread:(RegisterAccountInfo *)registerAccount;

#pragma mark -
#pragma mark Login/GetProfile Thread

// 登录CS Server服务器
- (BOOL)loginServer:(NSString *)password;
// Login CS Server Thread，启动登录CS服务器线程
- (void)startLoginThread:(NSString *)userPassword;


#pragma mark -
#pragma mark Login Finish or Launch Success Dispose

// 登录成功后的处理
- (void)doLoginSuccess;


#pragma mark - Synchronize Check All Info

// 同步检查App版本更新
- (void)syncCheckAppVersionUpdate:(UpdateSoftwareType)updateSoftwareType;



@end
