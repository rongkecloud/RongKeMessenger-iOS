//
//  RKCloudChatBaseChat.h
//  RKCloudChat
//
//  Created by WangGray on 15/5/28.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

// 会话的类型（0单聊，1群聊）
typedef NS_ENUM(NSUInteger, SessionType) {
    SESSION_SINGLE_TYPE = 0, // 0-单聊
    SESSION_GROUP_TYPE = 1 // 1-群聊
};

// 会话的类型（1：主动离开；2：被群主踢出；3：解散群）
typedef NS_ENUM(NSUInteger, LeaveType) {
    LEAVE_ACTIVE_TYPE = 1,     // 1：主动离开
    LEAVE_PASSIVE_TYPE = 2,    // 2：被群主踢出
    LEAVE_DISSOLVE_TYPE = 3,   // 3：解散群
};

@class RKCloudChatBaseMessage;

@interface RKCloudChatBaseChat : NSObject

@property (nonatomic, copy) NSString *sessionID; // 获取会话ID(单聊会话时为对方的云视互动账号，群聊会话时为群ID)
@property (nonatomic, copy) NSString *sessionShowName; // 获取会话显示的名称 如果是单聊会话，则显示顺序为：应用APP联系人名称 -> 对方的账号 如果是群聊会话，则显示顺序为：群备注->群名称->群ID
@property (nonatomic, copy) NSString *backgroundImagePath; // 获取会话在聊天页面使用的背景图片路径
@property (nonatomic, strong) RKCloudChatBaseMessage *lastMessageObject; // 获取会话中的最后一条消息对象

@property (nonatomic) SessionType sessionType; // 会话的类型（参考：SessionType，0单聊，1群聊）
@property (nonatomic) int userCounts; // 获取成员总个数，包括自己
@property (nonatomic) int unReadMsgCnt; // 获取会话中的未读消息条数

@property (nonatomic) BOOL isRemindStatus; // 会话中收到新消息后是否需要提醒（0: 不提醒，1: 提醒）
@property (nonatomic) BOOL isTop; // 会话是否置顶（0：代表没有置顶 1:代表置顶聊天）

@property (nonatomic) long createdTime; // 获取会话在终端的创建时间，为秒级的时间戳
@property (nonatomic) long lastMsgCreatedTime; // 获取会话中最后一条消息在终端的创建时间，为秒级时间戳
@property (nonatomic) long setTopTime; // 置顶时间，单位：秒级时间戳

@end
