//
//  UploadAndDownloadCenter.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/27.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "UploadAndDownloadCenter.h"
#import "HttpClientKit.h"

#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "PersonalInfos.h"
#import "DatabaseManager+FriendInfoTable.h"

@interface UploadAndDownloadCenter () <HttpClientKitDelegate>

@end

@implementation UploadAndDownloadCenter

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    
    // 取消所有的请求
    [[HttpClientKit sharedRKCloudHttpKit] cancelAllRequest];
}

#pragma mark - Upload Avatar Interface

/**
 *  上传自己的头像
 *
 *  @param fileLocalPath 文件的本地路径
 */
- (void)addUploadAvatarFileQueueFromLocalPath:(NSString *)fileLocalPath
                               withUploadType:(UploadAndDownloadRequestType)uploadAndDownloadRequestType
{
    if (fileLocalPath == nil) {
        return;
    }
    
    /*
     用户上传头像信息
     http://demo.rongkecloud.com/rkdemo/upload_personal_avatar.php
     POST提交。参数表：
     	ss：session（必填）
     	file:：头像文件(必填)
     1001：非法session
     9998：系统错误
     9999：参数错误
     1026：头像上传失败
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

    // rkcloud base request
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    rkRequest.uploadDownloadType = uploadAndDownloadRequestType;
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_UPLOAD_PERSONAL_AVATAR, appDelegate.userProfilesInfo.mobileAPIServer];
    
    NSLog(@"UP-DOWNLOAD: addUploadAvatarFileQueueFromLocalPath: apiUrl = %@, localPath = %@", rkRequest.apiUrl, fileLocalPath);
    
    [rkRequest.params setValue:appDelegate.userProfilesInfo.userSession forKey:MSG_JSON_KEY_SESSION];

    
    // 如果上传的是文件则赋值文件路径
    [rkRequest.uploadFile setValue:fileLocalPath forKey:@"file"];
    
    rkRequest.httpClientKitDelegate = self;
    [[HttpClientKit sharedRKCloudHttpKit] execute:rkRequest];
}


#pragma mark - Download Avatar Interface

/**
 *  下载自己或好友的头像
 *
 *  @param localPath                    存储的本地路径
 *  @param type                         获取的图像大小：1.缩略图，2.大图
 *  @param account                      获取头像的账号
 *  @param uploadAndDownloadRequestType 获取头像的类型
 */
- (void)addDownloadAvatarQueueToLocalPath:(NSString *)localPath
                           andUserAccount:(NSString *)account
                        isAvatarThumbnail:(BOOL)isThumbnail
                         withDownloadType:(UploadAndDownloadRequestType)uploadAndDownloadRequestType
{
    if (localPath == nil || account == nil) {
        return;
    }
    
    /*
     获取头像信息
     http://demo.rongkecloud.com/rkdemo/get_avatar.php
     POST提交。参数表：
     	ss：session（必填）
     	type: 头像类型(必填)1.缩略图，2.大图
      account: 账户名
     1001：非法session
     1025：头像下载失败
     9998：系统错误
     9999：参数错误
     oper_result=0
     文件直接返回
     */
    HttpRequest * rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestMethod = RKCLOUD_HTTP_GET;
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_FILE;
    
    NSLog(@"UP-DOWNLOAD: addDownloadQueue: localPath = %@", localPath);
    
    [rkRequest.params setValue:[AppDelegate appDelegate].userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:account forKey:@"account"];
    
    // 是否缩略图
    if (isThumbnail) {
        [rkRequest.params setValue:@"1" forKey:@"type"];
    }
    else {
        [rkRequest.params setValue:@"2" forKey:@"type"];
    }
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_AVATAR, [AppDelegate appDelegate].userProfilesInfo.mobileAPIServer];
    rkRequest.downloadFilePath = localPath;
    rkRequest.obj = account;
    rkRequest.uploadDownloadType = uploadAndDownloadRequestType;
    
    rkRequest.httpClientKitDelegate = self;
    [[HttpClientKit sharedRKCloudHttpKit] execute:rkRequest];
}


#pragma mark - HttpClientKitDelegate

- (void)onHttpCallBack:(HttpResult *)result
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    PersonalInfos *personalInfos = [[PersonalInfos alloc] init];
    personalInfos.userAccount = result.obj;
    personalInfos.avatarType = [NSString stringWithFormat:@"%d", result.uploadDownloadType];
    
    switch (result.uploadDownloadType)
    {
        case UploadAndDownloadRequestTypeUpAvatar: // 个人中心上传图片
        {
            if (result.opCode == 0)
            {
                //  收到代理，进行结果的解析，使用通知或者代理告知Controller进行UI刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_AVATAR_SUCCESS object:result.values];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPLOAD_AVATAR_FAIL object:result.values];
            }
        }
            break;
            
        case UploadAndDownloadRequestTypeDownloadBigAvatar: // 个人中心下载大图片
        {
            if (result.opCode == 0)
            {
                FriendInfoTable *friendInfoTable = [appDelegate.databaseManager getFriendInfoTableByAccout:personalInfos.userAccount];
                if (friendInfoTable) {
                    friendInfoTable.friendOriginalAvatarVersion = friendInfoTable.friendServerAvatarVersion;
                    [appDelegate.databaseManager saveFriendInfoTable:friendInfoTable];
                }
                
                // 收到代理，进行结果的解析，使用通知或者代理告知Controller进行UI刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:personalInfos];
            }
        }
            break;
            
        case UploadAndDownloadRequestTypeDownloadThumbNailAvatar: // 首次登录下载小图片
        {
            if (result.opCode == 0)
            {
                // 当下载自己的小图时
                if ([result.obj isEqualToString:appDelegate.userProfilesInfo.userAccount])
                {
                    // 保存版本号 防止每次进入程序下载个人缩略图
                    appDelegate.userProfilesInfo.userThumbnailAvatarVersion = appDelegate.userProfilesInfo.userServerAvatarVersion;
                    [appDelegate.userProfilesInfo saveUserProfiles];
                }
                else {
                    FriendInfoTable *friendInfoTable = [appDelegate.databaseManager getFriendInfoTableByAccout:personalInfos.userAccount];
                    if (friendInfoTable) {
                        friendInfoTable.friendThumbnailAvatarVersion = friendInfoTable.friendServerAvatarVersion;
                        [appDelegate.databaseManager saveFriendInfoTable:friendInfoTable];
                    }
                }
            
                //  收到代理，进行结果的解析，使用通知或者代理告知Controller进行UI刷新
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:personalInfos];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
