//
//  TextMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义文本类型消息类

#import "RKCloudChatBaseMessage.h"

@interface TextMessage : RKCloudChatBaseMessage

@property (nonatomic) BOOL isDraftMsg; // 是否为草稿消息

/// 构造发送的文本消息
+ (TextMessage *)buildMsg:(NSString *)sessionId withMsgContent:(NSString *)content;

@end
