//
//  RKCloudChat.h
//  云视互动即时通讯SDK
//
//  Created by www.xa-rongke.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//
//  云视互动即时通信SDK使用的入口类

/*!
 @header RKCloudChat.h
 @abstract 云视互动Chat SDK头文件 (云视互动即时通信SDK使用的入口类)
 @author 西安融科通信技术有限公司 (www.rongkecloud.com)
 @version 2.2.5 2016/02/22 Update
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RKCloudChatConfigManager.h"
#import "RKCloudChatMessageManager.h"
#import "RKCloudChatBaseMessage.h"
#import "RKCloudChatBaseChat.h"
#import "GroupChat.h"
#import "SingleChat.h"

/*!
 *  @brief 更新MMS下载进度通知
 */
extern NSString *kRKCloudUpdateMMSProgressNotification; // 更新MMS下载进度通知

// 服务器发送消息使用
extern NSString *kMessageMimeTypeText; // "TEXT" (纯文本)
extern NSString *kMessageMimeTypeImage; // "IMAGE" (图片)
extern NSString *kMessageMimeTypeAudio; // "AUDIO" (语音短信)
extern NSString *kMessageMimeTypeFile; // "FILE" (文件)
extern NSString *kMessageMimeTypeVideo; // "VIDEO" (视频片段)
extern NSString *kMessageMimeTypeCustom; // "CUSTOM" (自定义消息)

// 客户端本地使用
extern NSString *kMessageMimeTypeLocal; // "LOCAL" (本地消息)
extern NSString *kMessageMimeTypeTip; // "TIP" (提示类消息,加入群、离开群、会议进入离开信息)


/*!
 * @enum
 * @brief RKCloudChat错误码（2001-3000）
 * 公共SDK错误码参考：RKCloudErrorCode
 * 基础SDK错误码参考：RKCloudBaseErrorCode
 */
typedef enum : NSInteger {
    CHAT_MMS_NOTEXIST = 2001, /**< 消息不存在    */
    CHAT_MMS_DURATION_EXCEED_LIMIT = 2002, /**< 语音或视频文件的时长超出限制    */
    CHAT_MMS_SIZE_EXCEED_LIMIT = 2003, /**< 文件大小超出限制    */
    CHAT_MMS_NONSUPPORT = 2004, /**< 不支持发送的消息类型    */
    CHAT_MMS_CANNOT_SEND_OWN = 2005, /**< 禁止发消息给自己    */
    CHAT_MMS_CANNOT_INVITE_OWN = 2006, /**< 禁止邀请自己到群中    */
    
    CHAT_GROUP_NOT_EXIST = 2021, /**< 群号码或会话不存在    */
    CHAT_GROUP_USER_NOT_EXIST = 2022, /**< 非群用户    */
    CHAT_GROUP_COUNT_EXCEED_LIMIT = 2023, /**< 群个数已达上限    */
    CHAT_GROUP_USER_NUMBER_EXCEED_LIMIT = 2024, /**< 群用户人数已达上限    */
    CHAT_GROUP_UNAUTH_MODIFYINVITE = 2025, /**< 群内非群主成员禁止修改邀请或取消邀请的权限    */
    CHAT_GROUP_UNAUTH_INVITE = 2026, /**< 无邀请权限    */
    CHAT_GROUP_UNAUTH_KICKUSER = 2027, /**< 无踢人操作    */
    CHAT_GROUP_UNMASTER = 2028, /**< 非群主    */
    CHAT_GROUP_USER_HAS_EXIST = 2029, /**< 部分成员已存在，邀请失败    */
    
} RKCloudChatErrorCode;


#pragma mark -
#pragma mark RKCloudChatDelegate

/*!
 *  @protocol
 *  @abstract 云视互动Chat SDK代理类。
 */
@protocol RKCloudChatDelegate <NSObject>

@optional

#pragma mark -
#pragma mark RKCloudChatReceivedMsg
// 云视互动即时通信收到消息之后的回调接口

/*!
 * @brief 代理方法: 消息内容发生变化之后的回调
 *
 * @param messageObject 消息对象指针（RKCloudChatBaseMessage）
 *
 * @return
 */
- (void)didMsgHasChanged:(RKCloudChatBaseMessage *)messageObject;

/*!
 * @brief 代理方法: 收到单条消息之后的回调
 *
 * @param messageObject   RKCloudChatBaseMessage对象 收到的消息
 * @param sessionObject  RKCloudChatBaseChat对象 消息所属的会话信息
 *
 * @return
 */
- (void)didReceivedMsg:(RKCloudChatBaseMessage *)messageObject
        withForSession:(RKCloudChatBaseChat *)sessionObject;

/*!
 * @brief 代理方法: 收到多条消息之后的回调
 * @attention 收到的消息按照不同的会话进行划分，并且每个会话中的消息按照产生的时间升序排列
 * @param arrayChatMessages 数组类型，值为RKCloudChatBaseMessage对象数组
 *
 * @return
 */
- (void)didReceivedMsgs:(NSArray *)arrayChatMessages;

/*!
 * @brief 代理方法: 改变会话中的未读消息总条数
 *
 * @param totalCount 整型，未读消息总条数
 *
 * @return
 */
- (void)didUnReadMessageTotal:(int)totalCount;


#pragma mark -
#pragma mark RKCloudChatGroup
// 云视互动即时通信对于群的回调接口

/*!
 * @brief 代理方法: 单个群信息有变化
 *
 * @param groupId NSString 群ID
 *
 * @return
 */
- (void)didGroupInfoChanged:(NSString *)groupId;

/*!
 * @brief 代理方法: 移除群
 *
 * @param groupId NSString 群ID
 * @param removeType int 移除类型 1：主动退出 2：被踢除 3：群解散
 *
 * @return
 */
- (void)didGroupRemoved:(NSString *)groupId withRemoveType:(LeaveType)removeType;

/*!
 * @brief 代理方法: 群成员有变化
 *
 * @param groupId NSString 群ID
 *
 * @return
 */
- (void)didGroupUsersChanged:(NSString *)groupId;


#pragma mark -
#pragma mark RKCloudChatSession

/**
 *  @brief 代理方法:SDK同步完所有群信息后的代理
 *
 *  @param chatSessionList 所有聊天会话session
 *
 *  @return
 */
- (void)didAllGroupInfoSynComplete:(NSArray *)chatSessionList;

/*!
 * @brief 代理方法:更新整个会话列表数据
 *
 * @param chatSessionList 所有聊天会话session
 *
 * @return
 */
- (void)didUpdateChatSessionList:(NSArray *)chatSessionList;

/*!
 * @brief 代理方法: 更新指定的会话信息
 *
 * @param chatSession 此聊天对象的session数据
 *
 * @return
 */
- (void)didUpdateChatSessionInfo:(RKCloudChatBaseChat *)chatSession;

/*!
 * @brief 代理方法: 显示一个聊天会话页面
 *
 * @param chatSession 此聊天对象的session数据
 *
 * @return
 */
- (void)didShowChatViewWithChatSession:(RKCloudChatBaseChat *)chatSession;


#pragma mark -
#pragma mark RKCloudChatContact
// 云视互动即时通信中调用应用层的通讯录使用的接口

/*!
 * @brief 代理方法: 根据云视互动中分配的账号获取应用AP通讯录中的联系人头像信息
 *
 * @param userName 用户在云视互动中分配的账号
 *
 * @return userName头像路径字符串
 */
- (NSString *)getContactAvatarPhotoPath:(NSString *)userName;

/*!
 * @brief 代理方法: 批量获取应用APP通讯录中指定用户的头像信息
 *
 * @param arrayUserName 批量的用户在云视互动中分配的账号数组
 *
 * @return NSDictionary userName对应的头像路径字符串
 */
- (NSDictionary *)getContactsAvatarPhotoPath:(NSArray *)arrayUserName;

/*!
 * @brief 代理方法: 根据云视互动中分配的账号获取应用APP通讯录中的联系人昵称
 *
 * @param userName 用户在云视互动中分配的账号
 *
 * @return uuserName对应的昵称字符串
 */
- (NSString *)getContactNicknameString:(NSString *)userName;

/*!
 * @brief 代理方法: 批量获取应用APP通讯录中指定的用户昵称
 *
 * @param arrayUserName 批量的用户在云视互动中分配的账号数组
 *
 * @return NSDictionary userName对应的昵称字符串
 */
- (NSDictionary *)getContactsNicknameString:(NSArray *)arrayUserName;

@end


#pragma mark - RKCloudChat Interface

/*!
 *  @class
 *  @abstract 云视互动聊天会话功能类，实现云视互动聊天会话功能。
 */
@interface RKCloudChat : NSObject

/*!
 * @brief 初始化云视互动聊天会话功能
 *
 * @param delegate 上层代理指针
 *
 * @return
 */
+ (void)init:(id)delegate;

/*!
 * @brief 取消初始化云视互动聊天会话功能
 *
 * @return
 */
+ (void)unInit;

@end
