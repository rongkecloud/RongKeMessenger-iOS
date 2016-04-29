//
//  ThreadsManager.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "ThreadsManager.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "UIAlertView+CustomAlertView.h"
#import "RKCloudBase.h"
#import "AppDelegate.h"
#import "DatabaseManager+FriendGroupsTable.h"
#import "DatabaseManager+FriendInfoTable.h"

@interface ThreadsManager ()

@property (nonatomic, assign) id callbackClassHander; // 回调的类指针
@property (nonatomic, assign) SEL callbackFunctionSelector; // 回调类的方法指针

@property (nonatomic, strong) NSThread *loginThread; // 登录线程
@property (nonatomic, strong) NSThread *checkUpdateThread; // 检查更新线程

@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, copy) NSString *downloadAPPUrl; // 更新下载App新版本的Url地址

@end

@implementation ThreadsManager

#pragma mark -
#pragma mark Init Threads Manager

// 初始化Threads Manager
- (id)initThreadsManager:(id)delegate {
    self = [super init];
    if (self)
    {
        self.appDelegate = delegate;
        self.downloadAPPUrl = APP_STORE_DOWNLOAD_URL;
        
        self.callbackClassHander = nil; // 回调的类指针
        self.callbackFunctionSelector = nil; // 回调类的方法指针
    }
    
    return self;
}

- (void)dealloc {
    self.downloadAPPUrl = nil;
    
    if (self.loginThread) {
        [self.loginThread cancel];
        self.loginThread = nil;
    }
    
    if (self.checkUpdateThread) {
        [self.checkUpdateThread cancel];
        self.checkUpdateThread = nil;
    }
}


#pragma mark -
#pragma mark Callback Function Hander

// 设置回调类和方法指针
- (void)setCallbackFunctionHander:(id)classHander withFunctionSelector:(SEL)functionSelector
{
    NSLog(@"THREAD: setCallbackFunctionHander");
    
    if (classHander == nil || functionSelector == nil) {
        return;
    }
    
    self.callbackClassHander = classHander;
    self.callbackFunctionSelector = functionSelector;
}


#pragma mark -
#pragma mark Send Pincode Thread

// 同步发送发送手机验证码
- (BOOL)syncSendPincode:(NSString *)mobile withPincodeModeType:(SendPincodeMode)sendType
{
    if (mobile == nil) {
        return NO;
    }
    
    /*
     功能	注册、重置密码前发送验证码
     URL	http://airport.server/1.0/SendPincode
     Param	POST提交。参数表：
     	mobile：  手机号码(必填）
     	type:；类型（必填） 注册服务：1，找回密码：2
     
     Error Code(操作失败)
     ret_code=
     1006: 当天超次数
     9998：系统错误
     9999：参数错误
     1005: pincode发送失败
     1004: pincode发送次数超出
     1001：号码格式不对
     1002: 号码已经注册 （type =1 时会返回）
     
     Return(操作成功)	
     ret_code=0
     */
    
    BOOL bSendSuccess = NO;
    @autoreleasepool {
        // 调用发送pincode接口，进行验证手机号码
        
        // rkcloud base request
        HttpRequest *rkRequest = [[HttpRequest alloc] init];
        rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
        
        [rkRequest.params setValue:mobile forKey:@"mobile"];
        [rkRequest.params setValue:[NSNumber numberWithInt:sendType] forKey:@"type"];
        
//        rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_SEND_PINCODE, self.appDelegate.userProfilesInfo.mobileAPIServer];
        
        NSLog(@"API: syncSendPincode - apiUrl = %@, params = %@", rkRequest.apiUrl, [rkRequest getStringParams]);
        
        // rkcloud base result
        HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
        
        NSLog(@"API: syncSendPincode - opCode = %d, values = %@", httpResult.opCode, httpResult.values);
        
        // 发送成功
        if (httpResult.opCode == 0) {
            bSendSuccess = YES;
        }
        
        // 返回到主线程进行完成注册错误的处理操作
        [self performSelectorOnMainThread:@selector(finishSendPincodeError:)
                               withObject:httpResult
                            waitUntilDone:NO];
    }
    
    return bSendSuccess;
}

- (void)finishSendPincodeError:(HttpResult *)httpResult
{
    // 取消提示等待框
    [UIAlertView hideWaitingMaskView];
    
    if (httpResult == nil)
    {
        return;
    }
    
    /*
     Error Code(操作失败)
     ret_code=
     1006: 当天超次数
     9998：系统错误
     9999：参数错误
     1005: pincode发送失败
     1004: pincode发送次数超出
     1001：号码格式不对
     1002: 号码已经注册 （type =1 时会返回）
     
     Return(操作成功)
     ret_code=0
     */
    
    // 获取错误的返回码
    switch (httpResult.opCode)
    {
        case OK: // 成功
        {
        }
            break;
            
        case ERROR_API_TIMEROUT: // Timeout
        {
            NSLog(@"ERROR: finishSendPincodeError Timeout error: %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_SENDPINCODE_TIMEOUT", "短信发送超时，请重试。")
                               withTitle:NSLocalizedString(@"TITLE_VERIFY_ERROR", "验证手机")
                              withButton:NSLocalizedString(@"STR_OK", "确定")
                                toTarget:nil];
        }
            break;
            
        default:
        {
            NSLog(@"ERROR: finishSendPincodeError error: %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            [UIAlertView showSimpleAlert:[HttpClientKit parseAPIResult:httpResult.opCode]
                               withTitle:NSLocalizedString(@"TITLE_VERIFY_ERROR", "验证手机")
                              withButton:NSLocalizedString(@"STR_OK", "确定")
                                toTarget:nil];
        }
            break;
    }
}


#pragma mark -
#pragma mark Register Account Thread

// 启动注册线程
- (void)startRegisterThread:(RegisterAccountInfo *)registerAccount
{
    if (registerAccount == nil || registerAccount.userAccount == nil || registerAccount.userPassword == nil)
    {
        NSLog(@"ERROR: startRegisterThread: registerAccount = %@", registerAccount.description);
        return;
    }
    
    @autoreleasepool {
        // 调用注册接口，进行注册
        /*
         功能	用户注册手机客户端
         URL	http://demo.rongkecloud.com/rkdemo/register.php
         Param	POST提交。参数表：
         	account：账号（必填）
         	pwd: 登录密码(必填)
         	type: 注册类型(必填) enterprise：企业用户，normal：普通用户
         
         Error Code (操作失败)	
         oper_result=
         1004：账号已存在
         9998：系统错误
         9999：参数错误
         
         Return(操作成功)	
         oper_result=0
         */
        // rkcloud base request
        HttpRequest *rkRequest = [[HttpRequest alloc] init];
        rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
        
        [rkRequest.params setValue:registerAccount.userAccount forKey:@"account"];
        [rkRequest.params setValue:registerAccount.userPassword forKey:@"pwd"];
        [rkRequest.params setValue:@"1" forKey:@"type"];
        
        rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_REGISTER, self.appDelegate.userProfilesInfo.mobileAPIServer];
        
        // rkcloud base result
        HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
        
        // 注册成功
        if (httpResult.opCode == 0)
        {
            // 暂时记录帐号和密码
            self.appDelegate.userProfilesInfo.userPassword = registerAccount.userPassword;
            self.appDelegate.userProfilesInfo.userAccount = registerAccount.userAccount;
            
            // Start login CS Thread
            [self startLoginThread:registerAccount.userPassword];
        }
        else
        {
            // 返回到主线程进行完成注册错误的处理操作
            [self performSelectorOnMainThread:@selector(finishRegisterError:)
                                   withObject:httpResult
                                waitUntilDone:NO];
        }
    }
}

// 处理注册失败
- (void)finishRegisterError:(HttpResult *)httpResult
{
    // 取消提示等待框
    [UIAlertView hideWaitingMaskView];
    
    if (httpResult == nil)
    {
        return;
    }
    
    /*
     Error Code (操作失败)
     ret_code=
     1001：号码格式错误
     1007：pincode 验证错误
     1008：pincode验证超时
     9998：系统错误，创建用户失败
     9999：参数错误
     */
    // 获取错误的返回码
    switch (httpResult.opCode)
    {
        case ERROR_API_TIMEROUT: // Timeout
        {
            NSLog(@"ERROR: finishRegisterError Timeout error: %d, %@", httpResult.opCode, [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_REGISTER_TIMEOUT", "注册超时，请重试。")
                               withTitle:NSLocalizedString(@"TITLE_REGISTER_ERROR", "注册失败")
                              withButton:NSLocalizedString(@"STR_OK", "确定")
                                toTarget:nil];
        }
            break;
            
        case API_ERR_USERNAME_IS_EXIST: // 已注册过的账号
        {
            [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_HAS_REGISTER_ACCOUNT", "已注册过的账号")
                                                    background:nil
                                                      showTime:TIMER_NETWORK_ERROR_PROMPT];
        }
            break;
            
        default:
        {
            NSLog(@"ERROR: finishRegisterError error: %d, %@", httpResult.opCode, [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            // 提示注册失败
            [UIAlertView showAutoHidePromptView:[HttpClientKit parseAPIResult:httpResult.opCode]
                                                    background:nil
                                                      showTime:TIMER_NETWORK_ERROR_PROMPT];
        }
            break;
    }
}


#pragma mark -
#pragma mark Login Thread

// 登录CS Server服务器
- (BOOL)loginServer:(NSString *)password
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                                background:nil
                                                  showTime:TIMER_NETWORK_ERROR_PROMPT];
        return NO;
    }
    
    // 判断是否上次线程执行完成，保证当前只有一个获取消息的线程运行
    if (self.loginThread != nil &&
        ([self.loginThread isExecuting] == YES || [self.loginThread isFinished] == NO)) {
        NSLog(@"DEBUG: loginCSThread isExecuting = %d, isFinished = %d, return YES",
              [self.loginThread isExecuting], [self.loginThread isFinished]);
        return YES;  // avoid multiple thread for query credits
    }
    
    // 如果参数password有值，则使用该参数，如果没有值，则使用保存的用户密码
    // 这样做的目的是为了接口的统一
    NSString *userPassword = nil;
    if (password)
    {
        userPassword = [NSString stringWithString:password];
    }
    else
    {
        userPassword = [NSString stringWithString:self.appDelegate.userProfilesInfo.userPassword];
    }
    
    // 启动获取当前通知消息线程
    self.loginThread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(startLoginThread:)
                                                 object:userPassword];
    
    self.loginThread.name = @"startLoginThread";
    [self.loginThread start];
    
    return YES;
}

// 启动登录CS服务器线程
- (void)startLoginThread:(NSString *)userPassword
{
    if (userPassword == nil) {
        return;
    }
    
    if (self.appDelegate.applicationRunState & APPSTATE_LOGIN_USER/*YES, logining*/) {
        NSLog(@"DEBUG: startLoginCSThread is Running");
        return;
    }
    
    // 开始登录
    NSLog(@"THREAD: Start Login CS Server Thread Begin!!!");
    
    self.appDelegate.applicationRunState |= APPSTATE_LOGIN_USER;
    
    @autoreleasepool {
            /*
             功能	用户登录手机客户端
             URL	http://demo.rongkecloud.com/rkdemo/login.php
             Param	POST提交。参数表：
             	account： 账号（必填）
             	pwd:  登录密码(必填)
             
             Error Code(操作失败)	
             oper_result=
             1002: 账号密码错误
             9998：系统错误
             9999：参数错误
             
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
            
            // rkcloud base request
            HttpRequest *rkRequest = [[HttpRequest alloc] init];
            rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
            
            [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userAccount forKey:@"account"];
            [rkRequest.params setValue:userPassword forKey:@"pwd"];
            
            rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_LOGIN, self.appDelegate.userProfilesInfo.mobileAPIServer];
        
            // rkcloud base result
            HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
            if (httpResult.opCode == 0)
            {
                // 登录成功后将密码保存
                self.appDelegate.userProfilesInfo.userPassword = userPassword;
            }
        
            // 回到主线程中验证登录结果
            [self performSelectorOnMainThread:@selector(finishLogin:)
                               withObject:httpResult
                            waitUntilDone:YES];
    }
    
    
    self.appDelegate.applicationRunState &= ~APPSTATE_LOGIN_USER; /*Not logining*/;
    
    NSLog(@"THREAD: Start Login CS Server Thread  End!!!");
}

// 处理CS服务器的登录结果
- (void)finishLogin:(HttpResult *)httpResult
{
    NSLog(@"THREAD: finishLogin: resultLoginDict = %@", httpResult.values);
    
    // 若需要隐藏活动提示框
    [UIAlertView hideWaitingMaskView];
    
    if (httpResult == nil) {
        return;
    }
    
    /*
     Error Code(操作失败)
     ret_code=
     1002: 账号密码错误
     9998：系统错误
     9999：参数错误
     */
    // 判断返回值
    switch (httpResult.opCode)
    {
        case OK: // Succeed
        {
            NSLog(@"THREAD: App Mobile LoginCS Succeeded!");
            
            // 关闭数据库
            [self.appDelegate.databaseManager closeDataBase];
            // 打开数据库
            [self.appDelegate.databaseManager openDataBase:self.appDelegate.userProfilesInfo.userAccount];
            
            // 更新最后的App信息
            self.appDelegate.userProfilesInfo.lastAppVersion = APP_WHOLE_VERSION;
            self.appDelegate.userProfilesInfo.lastSystemVersion = [ToolsFunction getCurrentiOSVersion];
            //self.appDelegate.userProfilesInfo.lastSyncProfileDate = [NSDate date];
            
            // 多人语音会议管理类(存在多人语音直接退出账号 重新初始化meeting)
            if (self.appDelegate.meetingManager == nil)
            {
                self.appDelegate.meetingManager = [[MeetingManager alloc] init];
            }
            
            // 获取服务器登录API返回的Prfoile信息并保存到本地数据库中
            NSDictionary *dictUserPrfoileResult = [[httpResult.values objectForKey:@"result"] JSONValue];
            if (dictUserPrfoileResult && [dictUserPrfoileResult count] > 0) {
                // 导入CS服务器的配置信息
                [self.appDelegate.userProfilesInfo importMyProfile:dictUserPrfoileResult];
            }
            else {
                // 保存当前帐号和帐号相关的个人profile信息
                [self.appDelegate.userProfilesInfo saveUserProfiles];
            }
            
            // 创建与用户数据相关的文件夹
            [self.appDelegate.userProfilesInfo createUserDataDirectory];
            
            // 创建默认的我的好友分析FriendGroupsTable
            [self.appDelegate.databaseManager creatMyFriendGroupsTable];
            
            // 创建云视互动小秘书
            [self.appDelegate.databaseManager creatRKServiceFriendInfoTable];
            
            // Gray.Wang:2014.06.20:使用回调方法来触发调用者的函数
            if (self.callbackClassHander && self.callbackFunctionSelector &&
                [self.callbackClassHander respondsToSelector:self.callbackFunctionSelector])
            {
                // 回调调用者方法
                [self.callbackClassHander performSelector:self.callbackFunctionSelector
                                               withObject:httpResult
                                               afterDelay:0.0];
                
                // 清空Hander和Selector
                [self setCallbackFunctionHander:nil withFunctionSelector:nil];
            }
            else {
                // 登录成功后，则直接进入系统
                [self doLoginSuccess];
            }
        }
            return;
            
        case ERROR_API_TIMEROUT: // Timeout
        {
            NSLog(@"ERROR: finishLogin Timeout error: %d", httpResult.opCode);
            
            [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_LOGIN_TIMEOUT", nil)
                               withTitle:NSLocalizedString(@"TITLE_LOGIN_ERROR", nil)
                              withButton:NSLocalizedString(@"STR_OK", nil)
                                toTarget:nil];
        }
            break;
            
        case API_ERR_ACCOUNT_OR_PASSWD: // 用户名密码错误
        {
            NSLog(@"ERROR: finishLogin Result %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            // 显示用户名密码错误提示信息
            [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_INPUT_PASSWORD_ERROR", "用户名或密码不匹配，请重新输入")
                               withTitle:NSLocalizedString(@"TITLE_LOGIN_ERROR", nil)
                              withButton:NSLocalizedString(@"STR_OK", nil)
                                toTarget:nil];
        }
            break;
            
        default: // Error
        {
            NSLog(@"ERROR: finishLogin Return %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            
            // 修改失败显示提示信息
            [UIAlertView showSimpleAlert:[HttpClientKit parseAPIResult:httpResult.opCode]
                               withTitle:NSLocalizedString(@"TITLE_LOGIN_ERROR", nil)
                              withButton:NSLocalizedString(@"STR_OK", nil)
                                toTarget:nil];
        }
            break;
    }
    
    // 如果没有注册或者网络不通、登录失败则显示登录页面
    NSLog(@"ERROR: App Mobile LoginCS failed!");
}


#pragma mark -
#pragma mark Login Finish or Launch Success Dispose

// 登录成功后的处理
- (void)doLoginSuccess
{
    NSLog(@"THREAD: doLoginSuccess");
    
    // Goto Main Tabbar View Controller
    [self.appDelegate createMainTabbarController];
    
    // Jacky.Chen:2016.02.24,登录成功后添加是否展示引导页
    // 显示引导页
    [ToolsFunction showNewFeatureView];
    
    // 登入云视互动帐号
    [self.appDelegate.userProfilesInfo loginRKCloudAccount];

    // 开始检查程序是否有更新
    [self beginCheckUpdate];
}

//#pragma mark -
//#pragma mark GetProfile Function
//
//// 使用GetProfile API重新获取自己的Profile
//- (void)syncProfileInfo
//{
//    if (self.appDelegate.userProfilesInfo.lastSyncProfileDate)
//    {
//        // 得到当前的系统时间(秒)
//        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
//        
//        // 得到最后获取已关注的航班的时间
//        NSTimeInterval lastSyncProfileDate = [self.appDelegate.userProfilesInfo.lastSyncProfileDate timeIntervalSince1970];
//        
//        if (currentTimeInterval - lastSyncProfileDate <= TIMER_UPDATE_PROFILE_DATE) {
//            return;
//        }
//    }
//    
//    /*
//     Param	POST提交。参数表：
//     	ss: session（必填）
//     
//     Error Code(操作失败)
//     ret_code=
//     1011：session错误
//     9998：系统错误
//     9999：参数错误
//     1012: 分配服务器地址失败
//     
//     Return(操作成功)
//     ret_code=0
//     fdfs=225.225.225.225:2021   文件服务器地址
//     api=192.168.6.66:8080       api服务器地址：端口
//     */
//    
//    // rkcloud base request
//    HttpRequest *rkRequest = [[HttpRequest alloc] init];
//    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
//    
//    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
//    
//    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_PROFILE, self.appDelegate.userProfilesInfo.mobileAPIServer];
//    
//    // rkcloud base result
//    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
//    
//    // 回到主线程中验证登录结果
//    [self performSelectorOnMainThread:@selector(finishGetProfile:)
//                           withObject:httpResult
//                        waitUntilDone:YES];
//}

// 处理CS服务器的获取自己的Profile结果
- (void)finishGetProfile:(HttpResult *)httpResult
{
    // 若需要隐藏活动提示框
    [UIAlertView hideWaitingMaskView];
    
    if (httpResult == nil) {
        return;
    }
    
    /*
     Error Code(操作失败)
     ret_code=
     1011：session错误
     9998：系统错误
     9999：参数错误
     1012: 分配服务器地址失败
     */
    // 判断返回值
    switch (httpResult.opCode)
    {
        case OK: // Succeed
        {
            NSLog(@"DEBUG: App Mobile GetMyProfile Succeeded!");
            
            // 保存app完整三段版本号
            self.appDelegate.userProfilesInfo.lastAppVersion = APP_WHOLE_VERSION;
            // 登陆成功后将当前的系统版本保存
            self.appDelegate.userProfilesInfo.lastSystemVersion = [ToolsFunction getCurrentiOSVersion];
            
            // 导入CS服务器的配置信息
            [self.appDelegate.userProfilesInfo importMyProfile:httpResult.values];
            
            // 用户是否已经登录
            if ([self.appDelegate.userProfilesInfo isLogined]) {
                // 已经登录则执行登录成后的处理
                [self doLoginSuccess];
            }
        }
            break;
            
        case ERROR_API_TIMEROUT: // Timeout
            NSLog(@"ERROR: finishGetProfile Result: %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            break;
            
        case API_ERR_INVALID_SESSION: // session错误
            NSLog(@"ERROR: finishGetProfile Result %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            // CS SessionID失效则提示用户重新登录CS
            [self.appDelegate.userProfilesInfo promptRepeatLogin];
            break;
            
//        case API_ERR_USER_PROHIBITED: // 用户被禁用
//            NSLog(@"ERROR: finishGetProfile Result %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
//            // CS SessionID失效则提示用户重新登录CS
//            [self.appDelegate.userProfilesInfo promptBannedUsers];
//            break;
            
        default: // Error
            NSLog(@"ERROR: finishGetProfile Return %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            break;
    }
}


#pragma mark -
#pragma mark GetServerAddr Function

// 账号没登录时 获取host地址信息
- (void)syncGetServerAddr
{
    /*
     功能	无需登录时获取服务器IP地址
     URL	http://airport.server/1.0/GetServerAddr
     
     Param	POST提交。参数表：
     
     Error Code(操作失败)	
     ret_code=
     9998：系统错误
     9999：参数错误
     1012: 分配服务器地址失败
     
     Return(操作成功)	
     ret_code=0
     fdfs=225.225.225.225:2021   文件服务器地址
     api=192.168.6.66:8080       api服务器地址：端口
     */
    
    // rkcloud base request
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    
//    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_SERVER_ADDRESS, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    // 回到主线程中验证登录结果
    [self performSelectorOnMainThread:@selector(finishGetProfile:)
                           withObject:httpResult
                        waitUntilDone:YES];
}


#pragma mark -
#pragma mark Check Updates Thread

- (BOOL)beginCheckUpdate
{
    //NSLog(@"DEBUG: beginCheckUpdate");
    
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        return NO;
    }
    
    // 判断是否上次线程执行完成，保证当前只有一个获取消息的线程运行
    if (self.checkUpdateThread != nil &&
        ([self.checkUpdateThread isExecuting] == YES || [self.checkUpdateThread isFinished] == NO)) {
        NSLog(@"DEBUG: checkUpdateThread isExecuting = %d, isFinished = %d, return YES",
              [self.checkUpdateThread isExecuting], [self.checkUpdateThread isFinished]);
        return YES;  // avoid multiple thread for query credits
    }
    
    // 启动获取当前通知消息线程
    self.checkUpdateThread = [[NSThread alloc] initWithTarget:self
                                                selector:@selector(startCheckUpdatesThread)
                                                  object:nil];
    
    self.checkUpdateThread.name = @"startCheckUpdatesThread";
    [self.checkUpdateThread start];
    
    return YES;
}

// Gray.Wang:20110812:同步客户端和服务器的数据，包括：更新程序版本、通讯录、号码E.164规则、
// Sticker包信息、更新服务器的设置信息、更新Outbound Call路由码的信息
// Gray.Wang:20131105:查看是否存在有最后一次通话的统计缓存信息未发送，如果存在则尝试在此发送
- (void)startCheckUpdatesThread
{
    NSLog(@"THREAD: startCheckUpdatesThread Begin");
    
    // 判断网络是否连接有效
    if ([ToolsFunction checkInternetReachability])
    {
        // 1.根据条件判断是否下载个人头像及更新个人信息
        [self.appDelegate.userInfoManager asyncUpdateMyInfo];
        
        // 2.获取联系人分组以及所有联系人信息，并保存到数据库中
        [self.appDelegate.contactManager syncGetContactGroups];
        
        // 3.获取账号对应的好友列表
        [self.appDelegate.contactManager syncGetMyFriendsInfo];
        
        // 4.更新小秘书信息
        [self.appDelegate.contactManager asynGetContactInfoByUserAccounts:RONG_KE_SERVICE];

        // 同步检查App版本更新
        //[self syncCheckAppVersionUpdate:UpdateSoftwareTypeAuto];
    }
    
    NSLog(@"THREAD: startCheckUpdatesThread End");
}

#pragma mark - Check App Version Update

// 同步检查App版本更新
- (void)syncCheckAppVersionUpdate:(UpdateSoftwareType)updateSoftwareType
{
    /*
     功能	用户登录手机客户端
     URL	http://demo.rongkecloud.com/rkdemo/check_update.php
     Param	POST提交。参数表：
     	os： OS类型，如android, iphone（必填）
     	cv:  客户端软件版本号(必填)
     Error Code
     (操作失败)	oper_result=
     9998：系统错误
     9999：参数错误
     Return
     (操作成功)	oper_result=0 
     
     */
    
    // rkcloud base request
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.lastSystemVersion forKey:@"cv"];
    [rkRequest.params setValue:@"ios" forKey:@"os"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_CHECK_UPDATA, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    // Goto Main Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self finishCheckAppVersionUpdate:httpResult withUpdateSoftwareType:updateSoftwareType];
    });
}

// 处理CheckAppVersionUpdate结果
- (void)finishCheckAppVersionUpdate:(HttpResult *)httpResult withUpdateSoftwareType:(UpdateSoftwareType)updateSoftwareType
{
    // 若需要隐藏活动提示框
    [UIAlertView hideWaitingMaskView];
    
    if (httpResult == nil) {
        return;
    }
    
    /*
     Error Code(操作失败)	
     ret_code=
     9998：系统错误
     9999：参数错误
     
     Return(操作成功)
     ret_code=0
     download_url=***     //更新文件的下载地址
     update_version=***    //更新文件的版本，如1.1.1、2.0.1
     update_description=*** //更新文件的描述
     file_name=***     //可执行安装文件的名称
     file_size=***       //可执行文件大小
     upload_date=***    //更新软件的发布日期
     min_version=***    //最小安全版本。若用户当前的版本低于此版本，则必须更新。（可以不设定）
     */
    
    // 判断返回值
    switch (httpResult.opCode) {
            
        case OK: // Succeed
        {
            NSString *downloadUrl = [ToolsFunction urlDecodeUTF8String:[httpResult.values objectForKey:@"download_url"]];
            NSString *updateVersion = [httpResult.values objectForKey:@"update_version"];
            NSString *minVersion = [httpResult.values objectForKey:@"min_version"];
            
            if (downloadUrl) {
                self.downloadAPPUrl = downloadUrl;
            }
            
            // 服务器要求的最低版本号比当前版本大则提示
            if (minVersion && [ToolsFunction compareAllVersions:minVersion withCompare:APP_WHOLE_VERSION] == YES) {
                // 提示用户强制升级程序版本
                [UIAlertView showForcedUpdateVersionAlert:self];
            }
            else if (updateVersion && [ToolsFunction compareAllVersions:updateVersion withCompare:APP_WHOLE_VERSION] == YES) {
                // 服务器告知有更新的版本号比当前版本大则提示
                [UIAlertView showUpdateVersionAlert:self];
            }
            else if (updateSoftwareType == UpdateSoftwareTypeManual) {
                // 无需更新的提示
                [UIAlertView showNoUpdateVersionAlert:self];
            }
        }
            break;
            
//        case API_ERR_APP_NO_NEW_VERSION: //app没有最新版本。
//        {
//            if (updateSoftwareType == UpdateSoftwareTypeManual) {
//                // 无需更新的提示
//                [UIAlertView showNoUpdateVersionAlert:self];
//            }
//        }
            
        default: // Error
            NSLog(@"ERROR: finishCheckUpdateVersion Return %@", [HttpClientKit parseAPIResult:httpResult.opCode]);
            break;
    }
}


#pragma mark -
#pragma mark UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ALERT_FORCED_UPDATE_VERSION_TAG:
        {
            // 如果版本有更新，并且用户点击了更新按钮
            if (buttonIndex == 0 && self.downloadAPPUrl) {
                // 跳转到app store中去更新下载"App"
                //NSLog(@"self.downloadAPPUrl = %@", self.downloadAPPUrl);
                //@"http://itunes.apple.com/app/App/id1008662057?mt=8"
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadAPPUrl]];
            }
        }
            break;
            
        case ALERT_UPDATE_VERSION_TAG: // 检查版本更新提示
        {
            // 如果版本有更新，并且用户点击了更新按钮
            if (buttonIndex == 1 && self.downloadAPPUrl) {
                // 跳转到app store中去更新下载"App"
                //NSLog(@"self.downloadAPPUrl = %@", self.downloadAPPUrl);
                //@"http://itunes.apple.com/app/App/id1008662057?mt=8"
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.downloadAPPUrl]];
            }
        }
            break;
    }
}



@end
