//
//  ContactManage.h
//  RongKeMessenger
//
//  Created by Jacob on 15/7/20.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//  联系人网络数据的请求与管理，以及本地数据库保存查询等

#import <Foundation/Foundation.h>
#import "FriendGroupsTable.h"
#import "Definition.h"
#import "FriendTable.h"
#import "FriendsNotifyTable.h"
#import "FriendInfoTable.h"

@interface ContactManager : NSObject

/**
 *  同步获取联系人分组信息
 *
 *  @param session 用户session
 */
- (void)syncGetContactGroups;

/**
 *  操作分组信息：1.添加，2.修改，3.删除
 *
 *  @param session 用户session
 */
- (BOOL)asyncContactGroupsOpration:(FriendGroupsTable *)friendGroupsTable withOprationType:(ContactGroupsOprationType)oprationType;

/**
 *  搜索联系人
 *
 *  factorString:搜索添加
 */
- (NSMutableArray *)searchContactWithFilterString:(NSString *)filterString;

/**
 *  发起添加好友申请
 *
 *  applyString:申请信息
 */
- (BOOL)syncAddFriend:(FriendsNotifyTable *)friendsNotifyTable;

/**
 *  通过好友申请的验证
 *
 *  friendsNotifyTable对象
 */
- (void)asyncaConfirmAddFriend:(FriendsNotifyTable *)friendsNotifyTable;

/**
 *  获取好友列表信息
 *
 *  登录成功后调用
 */
- (void)syncGetMyFriendsInfo;


/**
 *  获取联系人信息，进行并发请求服务器，如果存在当前数据库则返回FriendInfoTable
 *
 *  @param userAccount 用户的帐号信息
 *
 *  @return FriendInfoTable对象指针
 */
- (FriendInfoTable *)getContactInfoByUserAccount:(NSString *)userAccount;

/**
 *  删除联系人
 */
- (BOOL)syncDeleteFriendByFriendAccount:(NSString *)friendAccount;

/**
 *  分组好友
 */
- (BOOL)asynOperationGroupMembers:(NSString *)accounts withGroupId:(NSString *)groupId;

/**
 *  修改备注名称
 */
- (BOOL)syncModifyFriendInfo:(FriendTable *)friendTable;

/**
 *  显示好友优先级最高的名字
 *
 *  @return 要显示的名字
 */
- (NSString*)displayFriendHighGradeName:(NSString *)friendAccount;

/**
 *  用户是否为自己好友
 *
 *  @param userAccount 用户账号
 *
 *  @return YES: 是  NO: 否
 */
- (BOOL)isOwnFriend:(NSString *)userAccount;

/**
 *  被好友删除的方法
 *
 *  @param friendAccount 好友账号
 */
- (void)deleteByFriendMethod:(NSString *)friendAccount;

/**
 *  好友通过请求
 *
 *  @param friendAccount 好友账号
 *
 *  @param requestStrArray 所有通过好友数组
 */
- (void)friendAcceptAddReuest:(NSDictionary *)customMessageDic andRequestStrArray:(NSArray *)requestStrArray;

/**
 *  好友请求添加好友
 *
 *  @param friendAccount 好友账号
 *
 *  @param requestStrArray 所有请求好友数组
 */
- (void)friendRequestToAddFriend:(NSString *)friendAccount andRequestStrArray:(NSArray *)requestStrArray;

- (void)asynGetContactInfoByUserAccounts:(NSString *)userAccount;

@end
