//
//  RKCloudChatBaseMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/5/28.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  云视互动即时通信中消息的抽象实体定义

#import <Foundation/Foundation.h>
#import "RKCloudChatBaseChat.h"

// 消息的发送接收方向枚举
typedef NS_ENUM(NSUInteger, MessageDirection) {
    MESSAGE_SEND = 1, // 发送
    MESSAGE_RECEIVE = 2, // 接收
};

// MMS消息状态枚举
typedef NS_ENUM(NSUInteger, MessageStatus) {
    MESSAGE_STATE_SEND_SENDING = 1, // 发送中
    MESSAGE_STATE_SEND_FAILED = 2, // 发送失败
    MESSAGE_STATE_SEND_SENDED = 3, // 已发送
    MESSAGE_STATE_SEND_ARRIVED = 4, // 已送达
    MESSAGE_STATE_RECEIVE_RECEIVED = 5, // 已接收
    MESSAGE_STATE_RECEIVE_DOWNING = 6, // 媒体文件下载中
    MESSAGE_STATE_RECEIVE_DOWNFAILED = 7, // 媒体文件下载失败
    MESSAGE_STATE_RECEIVE_DOWNED = 8, // 媒体文件下载成功
    MESSAGE_STATE_READED = 9, // 已读
};

// MMS消息类型枚举
typedef NS_ENUM(NSUInteger, MessageType) {
    MESSAGE_TYPE_TEXT = 1,	// 文本消息
    MESSAGE_TYPE_IMAGE = 2, // 图片消息
    MESSAGE_TYPE_VOICE = 3, // 语音消息
    MESSAGE_TYPE_FILE = 4,  // 附件消息
    MESSAGE_TYPE_LOCAL = 5, // 本地消息记录（音视频/会议 呼叫记录）
    MESSAGE_TYPE_CUSTOM = 6, // 自定义消息
    MESSAGE_TYPE_VIDEO = 7, // 视频消息
    
    MESSAGE_TYPE_GROUP_JOIN = 8,  // 加入群消息
    MESSAGE_TYPE_GROUP_LEAVE = 9, // 离开群消息
    
    MESSAGE_TYPE_TIME = 255,   // 时间字符串(不存数据库)
};

@interface RKCloudChatBaseMessage : NSObject

@property (nonatomic, copy) NSString *sessionID; // 消息所属的会话ID(可能是单聊会话的ID 或是 群ID)
@property (nonatomic, copy) NSString *senderName; // MMS的消息发送者互动分配的账号
@property (nonatomic, copy) NSString *messageID; // 消息的唯一标识

@property (nonatomic, copy) NSString *mimeType; // MIME类型
@property (nonatomic, copy) NSString *textContent; // 消息文本内容
@property (nonatomic, copy) NSString *extension; // 消息的扩展内容

@property (nonatomic) MessageDirection msgDirection; // 消息的发送接收方向
@property (nonatomic) MessageStatus messageStatus; // 消息的状态
@property (nonatomic) MessageType messageType; // 消息的类型（MessageType）

@property (nonatomic) long indexStorage; // 消息在客户端存储的自增索引值
@property (nonatomic) long createTime; // 消息在客户端的创建时间，为秒级时间戳
@property (nonatomic) long sendTime; // 消息的发送时间（发送方的本地时间）为级时间戳（发送的消息时为实际发送的时间，收到的消息时为服务器端传递的时间）
@end
