//
//  SettingsManager.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/7/31.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "UserInfoManager.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "UploadAndDownloadCenter.h"

@interface UserInfoManager ()

@property (assign, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UploadAndDownloadCenter *uploadAndDownloadCenter;


@end

@implementation UserInfoManager

- (id)init {
    self = [super init];
    if (self) {
        
        self.appDelegate = [AppDelegate appDelegate];
        self.uploadAndDownloadCenter = [[UploadAndDownloadCenter alloc] init];
    }
    
    return self;
}

/**
 *  上传个人图片
 */
/**
 *  上传个人图片
 *
 *  @param localImagePath 图片存储的本地路径
 */
- (void)asyncUploadPersonalOriginalAvatarWithLocalImagePath:(NSString *)localImagePath
{
    NSLog(@"USERINFO: asyncUploadPersonalOriginalAvatarWithLocalImagePath");
    
    [self.uploadAndDownloadCenter addUploadAvatarFileQueueFromLocalPath:localImagePath withUploadType:UploadAndDownloadRequestTypeUpAvatar];
}

/**
 *  同步操作个人信息
 *
 *  @param key     键：服务器对应的键
 *  @param content 值：用户改变的内容
 */
- (void)syncOperationPersonalInfoWithKey:(NSString *)key andContent:(NSString *)content
{
    NSLog(@"USERINFO: syncOperationPersonalInfo");
    /*
     
     获取信息
     http://demo.rongkecloud.com/rkdemo/operation_personal_info.php
     POST提交。参数表：
     	ss：session（必填）
     	key：包含（name,address,email,sex,mobile,permission）
     	content：key值对应的内容
     1001：非法session
     9998：系统错误
     9999：参数错误
     oper_result=0
     
     */
    
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    [UIAlertView showWaitingMaskView:@""];
    
    // rkcloud base request
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;

    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:key forKey:@"key"];
    [rkRequest.params setValue:content forKey:@"content"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_OPERATION_PERSONAL_INFO, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    if (httpResult.opCode == 0)
    {
        // 姓名
        if ([key isEqualToString:@"name"])
        {
            self.appDelegate.userProfilesInfo.userName = content;
        // 地址
        }else if ([key isEqualToString:@"address"])
        {
            self.appDelegate.userProfilesInfo.userAddress = content;
        // 邮件
        }else if ([key isEqualToString:@"email"])
        {
            self.appDelegate.userProfilesInfo.userEmail = content;
        // 性别
        }else if ([key isEqualToString:@"sex"])
        {
            self.appDelegate.userProfilesInfo.userSex = content;
        // 电话
        }else if ([key isEqualToString:@"mobile"])
        {
            self.appDelegate.userProfilesInfo.userMobile = content;
        // 是否允许加好友
        }else if ([key isEqualToString:@"permission"])
        {
            self.appDelegate.userProfilesInfo.friendPermission = content;
        }
        
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_PERSONAL_INFO_CHANGE_SUCCESS", "个人信息修改成功")
                                   background:nil
                                     showTime:DEFAULT_TIMER_WAITING_VIEW];
        
    }else{
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    
    [UIAlertView hideWaitingMaskView];
}

/**
 *  异步获取个人头像(小图)
 *
 *  @param account 账户名
 */
- (void)asyncDownloadThumbnailAvatarWithAccount:(NSString *)account
{
    if (account == nil) {
        NSAssert(account != nil, @"ERROR: asyncDownloadThumbnailAvatarWithAccount: account = %@", account);
    }
    
    NSLog(@"USERINFO: asyncDownloadThumbnailAvatarWithAccount: account = %@", account);
    
    // 设置一个文件路径
    NSString *imagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, account]];
    
    [self.uploadAndDownloadCenter addDownloadAvatarQueueToLocalPath:imagePath andUserAccount:account isAvatarThumbnail:YES withDownloadType:UploadAndDownloadRequestTypeDownloadThumbNailAvatar];
}

/**
 *  异步下载原始头像（自己或好友的）
 *
 *  @param account 自己或好友的帐号
 */
- (void)asyncDownloadOriginalAvatarWithAccount:(NSString *)account
{
    NSLog(@"USERINFO: asyncDownloadOriginalAvatarWithAccount");
    // 设置文件路径
    NSString *imagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", account]];
    
    [self.uploadAndDownloadCenter addDownloadAvatarQueueToLocalPath:imagePath andUserAccount:account isAvatarThumbnail:NO withDownloadType:UploadAndDownloadRequestTypeDownloadBigAvatar];
}

/**
 *  获取个人信息
 *
 *  @param account 账户名
 */
- (PersonalInfos*)syncGetPersonalInfos
{
    /*
     客户端更新检查
     http://demo.rongkecloud.com/rkdemo/get_personal_infos.php
     POST提交。参数表：
     	ss： 会话session（必填）
     	accounts：需要获取的用户名
     1001：session错误
     9998：系统错误
     9999：参数错误
     oper_result=0
     result=[{”account”:”lisi”,”name”:”李四”,”address”:”陕西省西安市”,”sex”:”man”,
     ”info_version”:”1”,”avatar_version”:”2”,” remark”:”李四”,
     ”mobile”:”18322222222”,”email”:235555555@qq.com,”type”:”normal”}……]
     其中：
     account=用户名
     name=姓名
     address=住址
     sex=性别
     info_version=个人信息版本号
     avatar_version=头像信息版本号
     mobile=手机号码
     email=邮箱
     type=用户类型
     remark=好友备注
     */
    NSLog(@"USERINFO: syncGetPersonalInfos");
    
    PersonalInfos *personalInfos = [[PersonalInfos alloc] init];
    
    // rkcloud base request
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userAccount forKey:@"accounts"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_PERSONAL_INFOS, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    if (httpResult.opCode == 0)
    {
        NSArray *arrayResult = [[httpResult.values objectForKey:@"result"] JSONValue];
        NSDictionary *dicResult = [arrayResult lastObject];
        
        personalInfos.userAccount = [dicResult objectForKey:@"account"];
        personalInfos.userName = [dicResult objectForKey:@"name"];
        personalInfos.userAddress = [dicResult objectForKey:@"address"];
        personalInfos.userSex = [dicResult objectForKey:@"sex"];
        personalInfos.userInfoVersion = [dicResult objectForKey:@"info_version"];
        personalInfos.userAvatarVersion = [dicResult objectForKey:@"avatar_version"];
        personalInfos.userMobile = [dicResult objectForKey:@"mobile"];
        personalInfos.userEmail = [dicResult objectForKey:@"email"];
        personalInfos.userAccountType = [dicResult objectForKey:@"type"];
        personalInfos.userRemark = [dicResult objectForKey:@"remark"];
    }
    
    return personalInfos;

}

#pragma mark - Async Update Info

/**
 *  根据条件判断是否下载个人头像以及更新个人信息
 */
- (void)asyncUpdateMyInfo
{
    NSLog(@"USERINFO: asyncUpdateMyInfo");
    
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 得到个人的信息对象 get_personal_infos.php
        PersonalInfos *personalInfos = [self.appDelegate.userInfoManager syncGetPersonalInfos];
        
        // avatar版本号小于服务器  文件不存在
        if ([personalInfos.userAvatarVersion intValue] > 0 &&
            ([self.appDelegate.userProfilesInfo.userThumbnailAvatarVersion intValue] < [personalInfos.userAvatarVersion intValue] ||
             ![ToolsFunction isFileExistsAtPath:[ToolsFunction getFriendThumbnailAvatarPath:self.appDelegate.userProfilesInfo.userAccount]]))
        {
            [self.appDelegate.userInfoManager asyncDownloadThumbnailAvatarWithAccount:self.appDelegate.userProfilesInfo.userAccount];
        }
        
        if ([self.appDelegate.userProfilesInfo.userInfoVersion intValue] < [personalInfos.userInfoVersion intValue])
        {
            // 保存个人信息
            self.appDelegate.userProfilesInfo.userAccount = personalInfos.userAccount;
            self.appDelegate.userProfilesInfo.userName = personalInfos.userName;
            self.appDelegate.userProfilesInfo.userMobile = personalInfos.userMobile;
            self.appDelegate.userProfilesInfo.userEmail = personalInfos.userEmail;
            self.appDelegate.userProfilesInfo.userAddress = personalInfos.userAddress;
            self.appDelegate.userProfilesInfo.userSex = personalInfos.userSex;
            self.appDelegate.userProfilesInfo.userAccountType = personalInfos.userAccountType;
        }
        
        // 保存服务器头像版本号 用于下次比较是否重新下载头像
        self.appDelegate.userProfilesInfo.userServerAvatarVersion = personalInfos.userAvatarVersion;
        // 保存服务器个人信息版本号 用于下次比较是否保存信息
        self.appDelegate.userProfilesInfo.userInfoVersion = personalInfos.userInfoVersion;
        
        [self.appDelegate.userProfilesInfo saveUserProfiles];
    });
}

/**
 *  显示个人优先级最高的名字
 *
 *  @return 要显示的名字
 */
- (NSString*)displayPersonalHighGradeName
{
    if (self.appDelegate.userProfilesInfo.userName != nil && [self.appDelegate.userProfilesInfo.userName length] > 0)
    {
        return self.appDelegate.userProfilesInfo.userName;
    } else {
        return self.appDelegate.userProfilesInfo.userAccount;
    }
}

@end

