//
//  LocalMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义本地类型消息类(主要适用于应用APP向终端插入自己定义的消息，该类型的消息不得转发、分享)

#import "RKCloudChatBaseMessage.h"

@interface LocalMessage : RKCloudChatBaseMessage

/// 构造接收的本地消息
+ (LocalMessage *)buildReceivedMsg:(NSString *)sessionId
                    withMsgContent:(NSString *)content
                     forSenderName:(NSString *)senderName;
/// 构造发送的本地消息
+ (LocalMessage *)buildSendMsg:(NSString *)sessionId
                withMsgContent:(NSString *)content
                 forSenderName:(NSString *)senderName;

/// 构造提示信息的本地消息
+ (LocalMessage *)buildTipMsg:(NSString *)sessionId
               withMsgContent:(NSString *)content
                forSenderName:(NSString *)senderName;

@end
