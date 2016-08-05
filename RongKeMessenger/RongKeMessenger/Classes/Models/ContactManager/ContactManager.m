//
//  ContactManage.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/20.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "ContactManager.h"
#import "HttpRequest.h"
#import "HttpClientKit.h"
#import "AppDelegate.h"
#import "DatabaseManager+FriendGroupsTable.h"
#import "FriendGroupsTable.h"
#import "UIAlertView+CustomAlertView.h"
#import "DatabaseManager+FriendTable.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "DatabaseManager+FriendsNotifyTable.h"
#import "ToolsFunction.h"


@interface ContactManager()

@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *getContactInfoArray;

@end

@implementation ContactManager

- (id)init {
    self = [super init];
    if (self) {
        
        self.appDelegate = [AppDelegate appDelegate];
        self.getContactInfoArray = [NSMutableArray array];
    }
    
    return self;
}

/**
 *  同步获取联系人分组信息
 *
 *  @param session 用户session
 */
- (void)syncGetContactGroups
{
    /*功能	获取分组信息
     URL	http://demo.rongkecloud.com/rkdemo/get_group_infos.php
     Param	POST提交。参数表：
     	ss：session（必填）
     Error Code
     (操作失败)	1001：非法session
     9998：系统错误
     9999：参数错误
     Return
     (操作成功)	oper_result=0
     result=[{“gid”:”1”,”gname”:”朋友”},{“gid”:”2”,”gname”:”家人”}……]；
     其中，gid=分组id
     gname=分组名称*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_CONTACT_GROUPS_INFO, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    NSArray *resultArray= nil;
    // 注册成功
    if (httpResult.opCode == 0)
    {
        resultArray = [[httpResult.values objectForKey:@"result"] JSONValue];
        if (resultArray)
        {
            // 创建联系人分组信息
            [self.appDelegate.databaseManager creatAndUpdateFriendGroupsTableToDB:resultArray];
        }
        
        // 更新分组通知
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_GROUPS_INFO object:nil];
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
}

/**
 *  操作分组信息：1.添加，2.修改，3.删除
 *
 *  @param session 用户session
 */
- (BOOL)asyncContactGroupsOpration:(FriendGroupsTable *)friendGroupsTable withOprationType:(ContactGroupsOprationType)oprationType
{
    /*功能	对分组进行操作
     URL	http://demo.rongkecloud.com/rkdemo/operation_group.php
     Param
     POST提交，参数表：
     	ss: 会话session(必填)
     	type:操作类型（必填），1.添加，2.修改，3.删除
     	type=1时：gname：分组名称
     	type=2时：gid:分组id，gname：分组名称
     Error Code
     (操作失败)	1001：非法session
     9998：系统错误
     9999：参数错误
     Return
     (操作成功)	oper_result=0
*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:[NSString stringWithFormat:@"%ld", (long)oprationType] forKey:@"type"];
    switch (oprationType) {
        case ContactGroupsOprationTypeChange:
        {
            [rkRequest.params setValue:friendGroupsTable.contactGroupsId forKey:@"gid"];
            [rkRequest.params setValue:friendGroupsTable.contactGroupsName forKey:@"gname"];
        }
            break;
        case ContactGroupsOprationTypeAdd:
        {
            [rkRequest.params setValue:friendGroupsTable.contactGroupsName forKey:@"gname"];
        }
            break;
        case ContactGroupsOprationTypeDelete:
        {
            [rkRequest.params setValue:friendGroupsTable.contactGroupsId forKey:@"gid"];
        }
            break;
        default:
            break;
    }
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_CONTACT_GROUPS_OPERATION, self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    BOOL isSuccess = NO;
    // 注册成功
    if (httpResult.opCode == 0)
    {
        switch (oprationType) {
            case ContactGroupsOprationTypeChange:
            {
                // 保存FriendGroupsTable到DB中
                [self.appDelegate.databaseManager saveFriendGroupsTable:friendGroupsTable];
            }
                break;
                
            case ContactGroupsOprationTypeAdd:
            {
                NSDictionary *resultDic = [[httpResult.values objectForKey:@"result"] JSONValue];
                friendGroupsTable.contactGroupsId = [NSString stringWithFormat:@"%@", [resultDic objectForKey:@"gid"]];
                // 保存FriendGroupsTable到DB中
                [self.appDelegate.databaseManager saveFriendGroupsTable:friendGroupsTable];
            }
                break;
                
            case ContactGroupsOprationTypeDelete:
            {
                // 修改当前分组中所有的好友FriendTable中的GroupId为我的好友分组groupid（groupid=0）
                [self.appDelegate.databaseManager changeFriendTaleGroupIdAndSaveToDB:friendGroupsTable.contactGroupsId];
                
                // 从DB中删除对s应的FriendGroupsTable
                [self.appDelegate.databaseManager deleteFriendGroupsTable:friendGroupsTable];
            }
                break;
                
            default:
                break;
        }

        isSuccess = YES;
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    
    return isSuccess;
}

/**
 *  搜索联系人
 *
 *  factorString:搜索添加
 */
- (NSMutableArray *)searchContactWithFilterString:(NSString *)filterString
{
  /*  功能	搜索匹配的好友
    URL	http://demo.rongkecloud.com/rkdemo/search_contact_info.php
    Param	POST提交。参数表：
    	ss：session（必填）
    	filter：搜索条件（必填）
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误
    Return
    (操作成功)	oper_result=0
    result=[{”account”:”张三”}……]；
    其中：account=用户名
    服务器流程*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:filterString forKey:@"filter"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_SEARCH_CONTACT_INFOS,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    NSMutableArray *contactArray= nil;
    // 注册成功
    if (httpResult.opCode == 0)
    {
        // 获取返回的联系人数组
        NSMutableArray *resultArray = [[httpResult.values objectForKey:@"result"] JSONValue];
        if (resultArray && resultArray.count > 0)
        {
            contactArray = [NSMutableArray array];
            for (int i = 0; i<resultArray.count; i++) {
                NSDictionary *contactDic = [resultArray objectAtIndex:i];
                
                // 创建联系人ContactTable
                FriendsNotifyTable *friendsNotifyTable = [[FriendsNotifyTable alloc] init];
                friendsNotifyTable.friendAccount = [contactDic objectForKey:@"account"];
                friendsNotifyTable.status = [NSString stringWithFormat:@"%ld",(long)AddFriendCurrentStateNomal];
                [contactArray addObject:friendsNotifyTable];
            }
        }
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    
    return contactArray;
}

/**
 *  发起添加好友申请
 *
 *  applyString:申请信息
 */
- (BOOL)syncAddFriend:(FriendsNotifyTable *)friendsNotifyTable
{
    if (friendsNotifyTable.friendAccount == nil) {
        NSLog(@"CONTACT-ERROR: syncAddFriend: friendsNotifyTable.friendAccount == nil, return NO");
        return NO;
    }
    
    /*功能	获取信息
    URL	http://demo.rongkecloud.com/rkdemo/add_friend.php
    Param	POST提交。参数表：
    	ss：session（必填）
    	account：好友账号
    	content：加好友的验证信息
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误*/
    
    BOOL isNotNeedModify = NO;
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:friendsNotifyTable.content forKey:@"content"];
    [rkRequest.params setValue:friendsNotifyTable.friendAccount forKey:@"account"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_ADD_FRIEND,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    // 注册成功
    switch (httpResult.opCode) {
        case 0:   // 无需验证直接加为好友
        {
            friendsNotifyTable.status = [NSString stringWithFormat:@"%ld", (long)AddFriendCurrentStateSuccess];
            // 保存到本地
            [self.appDelegate.databaseManager saveFriendsNotifyTable:friendsNotifyTable];
            
            // 保存好友到本地
            FriendTable *contactTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:friendsNotifyTable.friendAccount];
            if (contactTable == nil)
            {
                contactTable = [[FriendTable alloc] init];
                contactTable.groupId = @"0";
            }
            contactTable.friendAccount = friendsNotifyTable.friendAccount;
            [self.appDelegate.databaseManager saveFriendTable:contactTable];
            
            // 直接添加好友成功  添加通知
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
            
            isNotNeedModify = YES;
            
        }
            break;
            
        case 1021:  // 需要对方验证，等待对方验证中
        {
            isNotNeedModify = NO;
        }
            break;
            
        default:
            break;
    }
    
    return isNotNeedModify;
}

/**
 *  通过好友申请的验证
 *
 *  friendsNotifyTable对象
 */
- (void)asyncaConfirmAddFriend:(FriendsNotifyTable *)friendsNotifyTable
{
    /*功能	获取信息
    URL	http://demo.rongkecloud.com/rkdemo/confirm_add_friend.php
    Param	POST提交。参数表：
    	ss：session（必填）
    	account：好友账号
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:friendsNotifyTable.friendAccount forKey:@"account"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_CONFIRM_ADD_FRIEND,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    if (httpResult.opCode == 0)
    {
        // 设置friendsNotifyTable的状体
        friendsNotifyTable.status = [NSString stringWithFormat:@"%ld", (long)AddFriendCurrentStateSuccess];
        // 保存到本地
        [self.appDelegate.databaseManager saveFriendsNotifyTable:friendsNotifyTable];
        
        // 创建联系人并保存到本地
        FriendTable *contactTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:friendsNotifyTable.friendAccount];
        if (contactTable == nil)
        {
            contactTable = [[FriendTable alloc] init];
        }
        contactTable.friendAccount = friendsNotifyTable.friendAccount;
        contactTable.groupId = @"0";
        [self.appDelegate.databaseManager saveFriendTable:contactTable];
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
}

/**
 *  获取好友列表信息
 *
 *  登录成功后调用
 */
- (void)syncGetMyFriendsInfo
{
    /*功能	获取该用户的好友信息
    URL	http://demo.rongkecloud.com/rkdemo/get_friend_infos.php
    Param	POST提交。参数表：
    第一部分，必填项：
    	ss   会话Session(必填)
     
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误
    Return
    (操作成功)	oper_result=0
    result=[{”gid”:”1”,”account”:”lisi”,”remark”:”李四”,”avatar_version”:”0”,
        ”name”:”姓名”,”address”:”陕西省西安市”,”info_version”:”1”,”sex”:”1”
        ,”mobile”:”18322222222”,”email”:235555555@qq.com,”type”:”normal”}……]；
    其中：
    gid=分组id
    account=好友姓名
    remark=好友备注
    name=姓名
    address=住址
    mobile=手机号码
    email=邮箱
    type=用户类型
    sex=性别
    info_version=个人信息版本号
    avatar_version=头像版本号*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_FRIEND_INFOS,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    
    if (httpResult.opCode == 0)
    {
        NSArray *resultArray = [[httpResult.values objectForKey:@"result"] JSONValue];
        if (resultArray && resultArray.count > 0)
        {
            for (NSDictionary *friendInfoDic in resultArray)
            {
                // 保存好友列表到DB中
                NSString *account = [friendInfoDic objectForKey:@"account"];
                if (account == nil) {
                    continue;
                }
                
                FriendTable *contactTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:account];
                if (!contactTable)
                {
                    contactTable = [[FriendTable alloc] init];
                }
                
                contactTable.friendAccount = [friendInfoDic objectForKey:@"account"];
                contactTable.groupId = [NSString stringWithFormat:@"%@", [friendInfoDic objectForKey:@"gid"]];
                [self.appDelegate.databaseManager saveFriendTable:contactTable];
                
                // 获取账号对应的FriendInfoTable
                FriendInfoTable *friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:account];
                
                if (friendInfoTable == nil)
                {
                   friendInfoTable = [[FriendInfoTable alloc] init];
                }
                
                friendInfoTable.account = [friendInfoDic objectForKey:@"account"];
                friendInfoTable.name = [friendInfoDic objectForKey:@"name"];
                friendInfoTable.address = [friendInfoDic objectForKey:@"address"];
                friendInfoTable.mobile = [friendInfoDic objectForKey:@"mobile"];
                friendInfoTable.type = [friendInfoDic objectForKey:@"type"];
                friendInfoTable.sex = [friendInfoDic objectForKey:@"sex"];
                friendInfoTable.email = [friendInfoDic objectForKey:@"email"];
                friendInfoTable.friendInfoVersion = [friendInfoDic objectForKey:@"info_version"];
                friendInfoTable.friendServerAvatarVersion = [friendInfoDic objectForKey:@"avatar_version"];
                friendInfoTable.infoSyncLastTime = [ToolsFunction getCurrentSystemDateSecond];
                
                [self.appDelegate.databaseManager saveFriendInfoTable:friendInfoTable];
                
                // 根据条件 在程序启动时 获取好友图片
                NSString *stringAvatarFilePath = [ToolsFunction getFriendThumbnailAvatarPath:friendInfoTable.account];
                
                if ([friendInfoTable.friendServerAvatarVersion intValue] > 0 &&
                    ([friendInfoTable.friendThumbnailAvatarVersion intValue] < [friendInfoTable.friendServerAvatarVersion intValue] ||
                     [ToolsFunction isFileExistsAtPath:stringAvatarFilePath] == NO))
                {
                    [self.appDelegate.userInfoManager asyncDownloadThumbnailAvatarWithAccount:friendInfoTable.account];
                }
            }
            
            // 发送通知更新好友列表
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
        }
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
}


#pragma mark - Get Contact Info Interface

/**
 *  获取联系人信息，进行并发请求服务器，如果存在当前数据库则返回FriendInfoTable
 *
 *  @param userAccount 用户的帐号信息
 *
 *  @return FriendInfoTable对象指针
 */
- (FriendInfoTable *)getContactInfoByUserAccount:(NSString *)userAccount
{
    //NSLog(@"DEBUG: getContactInfoByUserAccount: userAccount = %@", userAccount);
    
    // 排除自己如果是自己返回为nil
    if (userAccount == nil || [self.appDelegate.userProfilesInfo.userAccount isEqualToString:userAccount])
    {
        return nil;
    }
    
    // 获取个人头像及信息时间间隔5min
    FriendInfoTable *friendInfoTable = [[AppDelegate appDelegate].databaseManager getFriendInfoTableByAccout:userAccount];
    
    // 当friendInfoTable不为空时，进行排除处理，防止新用户friendInfoTable不存在 不进行［非好友用户-陌生人或者时间间隔大于5分钟］逻辑
    if (friendInfoTable)
    {
        // 排除处理
        for (NSString *strUserAccount in self.getContactInfoArray) {
            if ([strUserAccount isEqualToString:userAccount])
            {
                return friendInfoTable;
            }
        }
    }
    
    // 如果是新用户或者超过同步时间的用户进行网络请求
    if (friendInfoTable == nil || ([ToolsFunction getCurrentSystemDateSecond] - friendInfoTable.infoSyncLastTime) > TIMER_UPDATE_USER_INFO_DATE)
    {
        NSString *strAccounts = [self.getContactInfoArray componentsJoinedByString:@","];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(asynGetContactInfoByUserAccounts:) object:strAccounts];
        
        // 非好友用户-陌生人或者时间间隔大于5分钟，需要获取联系人信息
        [self.getContactInfoArray addObject:userAccount];
        
        strAccounts = [self.getContactInfoArray componentsJoinedByString:@","];
        [self performSelector:@selector(asynGetContactInfoByUserAccounts:) withObject:strAccounts afterDelay:2];
    }
    
    return friendInfoTable;
}

/**
 *  异步从服务器上获取联系人信息
 *
 *  @param userAccount 用户帐号，支持逗号间隔的多个帐号
 */
- (void)asynGetContactInfoByUserAccounts:(NSString *)userAccount
{
    NSLog(@"CONTACTS: asynGetContactInfoByUserAccounts: userAccount = %@", userAccount);
    
    if (userAccount == nil) {
        NSAssert(userAccount != nil, @"ERROR: asynGetContactInfoByUserAccounts: userAccount = %@", userAccount);
    }
    
    /*功能	客户端更新检查
    URL	 http://demo.rongkecloud.com/rkdemo/get_personal_infos.php
    Param	POST提交。参数表：
    	ss： 会话session（必填）
    	accounts：需要获取的用户名
    Error Code
    (操作失败)	1001：session错误
    9998：系统错误
    9999：参数错误
    Return
    (操作成功)	oper_result=0
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
    remark=好友备注*/
    
    // 获取信息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        HttpRequest *rkRequest = [[HttpRequest alloc] init];
        rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
        
        [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
        [rkRequest.params setValue:userAccount forKey:@"accounts"];
        
        rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_GET_PERSONAL_INFOS,self.appDelegate.userProfilesInfo.mobileAPIServer];
        
        // rkcloud base result
        HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
        FriendInfoTable *friendInfoTable = nil;
        if (httpResult.opCode == 0)
        {
            NSArray *friendInfoArray = [[httpResult.values objectForKey:@"result"] JSONValue];
            if ([friendInfoArray count] > 0)
            {
                for (NSDictionary *friendInfoDic in friendInfoArray)
                {
                    NSString *stringAccount = [friendInfoDic objectForKey:@"account"];
                    // 获取账号对应的FriendInfoTable
                    friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:stringAccount];
                    if (friendInfoTable == nil)
                    {
                        friendInfoTable = [[FriendInfoTable alloc] init];
                    }
                    
                    friendInfoTable.account = [friendInfoDic objectForKey:@"account"];
                    friendInfoTable.name = [friendInfoDic objectForKey:@"name"];
                    friendInfoTable.address = [friendInfoDic objectForKey:@"address"];
                    friendInfoTable.mobile = [friendInfoDic objectForKey:@"mobile"];
                    friendInfoTable.type = [friendInfoDic objectForKey:@"type"];
                    friendInfoTable.sex = [friendInfoDic objectForKey:@"sex"];
                    friendInfoTable.email = [friendInfoDic objectForKey:@"email"];
                    friendInfoTable.friendInfoVersion = [friendInfoDic objectForKey:@"info_version"];
                    friendInfoTable.friendServerAvatarVersion = [friendInfoDic objectForKey:@"avatar_version"];
                    friendInfoTable.infoSyncLastTime = [ToolsFunction getCurrentSystemDateSecond];
                    
                    [self.appDelegate.databaseManager saveFriendInfoTable:friendInfoTable];
                    
                    NSString *stringAvatarFilePath = [ToolsFunction getFriendThumbnailAvatarPath:stringAccount];
                    
                    if ([friendInfoTable.friendServerAvatarVersion intValue] > 0 &&
                        ([friendInfoTable.friendThumbnailAvatarVersion intValue] < [friendInfoTable.friendServerAvatarVersion intValue] ||
                         [ToolsFunction isFileExistsAtPath:stringAvatarFilePath] == NO))
                    {
                        [self.appDelegate.userInfoManager asyncDownloadThumbnailAvatarWithAccount:stringAccount];
                    }
                }                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
            }
            
            [self.getContactInfoArray removeAllObjects];
        }
    });
}


#pragma mark - Delete Contact Interface

/**
 *  删除联系人
 */
- (BOOL)syncDeleteFriendByFriendAccount:(NSString *)friendAccount
{
    /*功能	获取信息
    URL	http://demo.rongkecloud.com/rkdemo/del_friend.php
    Param	POST提交。参数表：
    	ss：session（必填）
    	account：好友账号
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误*/
    
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:friendAccount forKey:@"account"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_DELETE_FRIEND,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    BOOL isDeleteFriend = NO;
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    if (httpResult.opCode == 0)
    {
        isDeleteFriend = YES;
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    return isDeleteFriend;
}

/**
 *  分组好友
 */
- (BOOL)asynOperationGroupMembers:(NSString *)accounts withGroupId:(NSString *)groupId
{
    /*功能	操作用户的好友信息
    URL	http://demo.rongkecloud.com/rkdemo/operation_group_members.php
    Param	POST提交。参数表：
    	ss：session值（必填）
    	gid：分组id
    	accounts：需要操作的好友账号
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误
    Return
    (操作成功)	oper_result=0*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:accounts forKey:@"accounts"];
    [rkRequest.params setValue:groupId forKey:@"gid"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_OPERATION_CONTACT_GROUPS_MEMBERS,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    BOOL isDeleteFriend = NO;
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    if (httpResult.opCode == 0)
    {
        isDeleteFriend = YES;
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    return isDeleteFriend;
}

/**
 *  修改备注名称
 */
- (BOOL)syncModifyFriendInfo:(FriendTable *)friendTable
{
    /*功能	获取信息
    URL	http://demo.rongkecloud.com/rkdemo/modify_friend_info.php
    Param	POST提交。参数表：
    	ss：session（必填）
    	account：好友账号
    	remark：好友备注
    Error Code
    (操作失败)	1001：非法session
    9998：系统错误
    9999：参数错误*/
    
    HttpRequest *rkRequest = [[HttpRequest alloc] init];
    rkRequest.requestType = RKCLOUD_HTTP_TYPE_VALUE;
    
    [rkRequest.params setValue:self.appDelegate.userProfilesInfo.userSession forKey:@"ss"];
    [rkRequest.params setValue:friendTable.friendAccount forKey:@"account"];
    [rkRequest.params setValue:friendTable.remarkName forKey:@"remark"];
    
    rkRequest.apiUrl = [NSString stringWithFormat:HTTP_API_MODIFY_FRIEND_INFO,self.appDelegate.userProfilesInfo.mobileAPIServer];
    
    BOOL isDeleteFriend = NO;
    // rkcloud base result
    HttpResult *httpResult = [HttpClientKit sendHTTPRequest:rkRequest];
    if (httpResult.opCode == 0)
    {
        isDeleteFriend = YES;
        [self.appDelegate.databaseManager saveFriendTable:friendTable];
    }
    else
    {
        [HttpClientKit errorCodePrompt:httpResult.opCode];
    }
    return isDeleteFriend;
    
}

/**
 *  显示好友优先级最高的名字
 *
 *  @return 要显示的名字
 */
- (NSString*)displayFriendHighGradeName:(NSString *)friendAccount
{
    // 获取账号对应的friendTable的账户备注名
    NSString *friendRemarkName = [self.appDelegate.databaseManager getFriendRemarkNameByFriendAccount:friendAccount];
    
    NSString *friendName = nil;
    // 获取账号对应的FriendInfoTable
    FriendInfoTable *friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:friendAccount];
    if (friendInfoTable) {
        friendName = friendInfoTable.name;
    }
    
    // 从备注名->好友姓名->帐号
    if (friendRemarkName != nil && [friendRemarkName length] > 0)
    {
        return friendRemarkName;
    }
    else if (friendName != nil && [friendName length] > 0)
    {
        return friendName;
    }
    else {
        return friendAccount;
    }
}

/**
 *  用户是否为自己好友
 *
 *  @param userAccount 用户账号
 *
 *  @return YES: 是  NO: 否
 */
- (BOOL)isOwnFriend:(NSString *)userAccount
{
    FriendTable *friendTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:userAccount];
    if (friendTable != nil)
    {
        return YES;
    } else {
        return NO;
    }
}

/**
 *  被好友删除的方法
 *
 *  @param friendAccount 好友账号
 */
- (void)deleteByFriendMethod:(NSString *)friendAccount
{
    // 删除联系人
    FriendTable *friendTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:friendAccount];
    if (friendTable)
    {
        [self.appDelegate.databaseManager deleteFriendTable:friendAccount];
        [self.appDelegate.databaseManager deleteFriendsNotifyTable:friendAccount];
        [self.appDelegate.databaseManager deleteFriendInfoTableByAccount:friendAccount];
        // 删除对应的单聊会话
        [RKCloudChatMessageManager deleteChat:friendAccount withFile:YES];
    }
}

/**
 *  好友通过请求
 *
 *  @param friendAccount 好友账号
 */
- (void)friendAcceptAddReuest:(NSDictionary *)customMessageDic andRequestStrArray:(NSArray *)requestStrArray
{
    NSLog(@"CONTACT-DEBUG: friendAcceptAddReuest: friendAccount = %@, requestStrArray = %@", customMessageDic, requestStrArray);
    
    NSString *friendAccount = [customMessageDic objectForKey:@"srcname"];
    
    BOOL isSelfSend = NO;
    if ([friendAccount isEqualToString: [RKCloudBase getUserName]])
    {
        // 多终端的登录
        isSelfSend = YES;
        friendAccount = [customMessageDic objectForKey: @"dest"];
    }
    
    FriendsNotifyTable *friendsNotifyTable = [self.appDelegate.databaseManager getFriendsNotifyTableByFriendAccout:friendAccount];
    if (friendsNotifyTable == nil)
    {
        friendsNotifyTable = [[FriendsNotifyTable alloc] init];
        friendsNotifyTable.content = [requestStrArray objectAtIndex:1];
        friendsNotifyTable.friendAccount = friendAccount;
        NSLog(@"[requestStrArray objectAtIndex:1] = %@", [requestStrArray objectAtIndex:1]);
        // 无需验证 添加好友
        if ([[requestStrArray objectAtIndex:1] isEqualToString:@"isNotActivited"])
        {
            friendsNotifyTable.content = nil;
        }
    }
    
    friendsNotifyTable.status = [NSString stringWithFormat:@"%ld",(long)AddFriendCurrentStateSuccess];
    // 保存到本地
    [self.appDelegate.databaseManager saveFriendsNotifyTable:friendsNotifyTable];
    
    // 保存FriendTable
    FriendTable *friendTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:friendsNotifyTable.friendAccount];
    if (friendTable == nil) {
        friendTable = [[FriendTable alloc] init];
    }
    friendTable.friendAccount = friendsNotifyTable.friendAccount;
    friendTable.groupId = @"0";
    [self.appDelegate.databaseManager saveFriendTable:friendTable];
    
    [self getContactInfoByUserAccount:friendsNotifyTable.friendAccount];
    
    
    // 新建一个聊天会话,如果会话存在，打开聊天页面
    [SingleChat buildSingleChat:friendAccount
                      onSuccess:^{
                          if (isSelfSend)
                          {
                              // 对方发送验证通过的消息
                              LocalMessage *callLocalMessage = [LocalMessage buildSendMsg:friendsNotifyTable.friendAccount withMsgContent:NSLocalizedString(@"RKCLOUD_SINGLE_CHAT_MSG_CALL", nil) forSenderName:friendsNotifyTable.friendAccount];
                              [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
                          }
                          else
                          {
                              // 对方发送验证通过的消息
                              LocalMessage *callLocalMessage = [LocalMessage buildReceivedMsg:friendsNotifyTable.friendAccount withMsgContent:NSLocalizedString(@"RKCLOUD_SINGLE_CHAT_MSG_CALL", nil) forSenderName:friendsNotifyTable.friendAccount];
                              [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
                          }
                      }
                       onFailed:^(int errorCode) {
                       }];
}

/**
 *  好友请求添加好友
 *
 *  @param friendAccount 好友账号
 */
- (void)friendRequestToAddFriend:(NSString *)friendAccount andRequestStrArray:(NSArray *)requestStrArray
{
    FriendsNotifyTable *friendsNotifyTable = [self.appDelegate.databaseManager getFriendsNotifyTableByFriendAccout:friendAccount];
    if (friendsNotifyTable == nil) {
        friendsNotifyTable = [[FriendsNotifyTable alloc] init];
    }
    friendsNotifyTable.content = [requestStrArray objectAtIndex:1];
    friendsNotifyTable.friendAccount = friendAccount;
    friendsNotifyTable.status = [NSString stringWithFormat:@"%ld",(long)AddFriendCurrentStateWaitingAuthorize];
    // 保存到本地
    [self.appDelegate.databaseManager saveFriendsNotifyTable:friendsNotifyTable];
    
    self.appDelegate.userProfilesInfo.isHaveNewfriendNotice = YES;
    [self.appDelegate.userProfilesInfo saveUserProfiles];
}

@end
