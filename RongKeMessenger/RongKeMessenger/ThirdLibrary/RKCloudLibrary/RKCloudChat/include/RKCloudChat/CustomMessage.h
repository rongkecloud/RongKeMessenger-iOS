//
//  CustomMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义自定义类型消息类

#import "RKCloudChatBaseMessage.h"

@interface CustomMessage : RKCloudChatBaseMessage

/// 构造发送的自定义消息
+ (CustomMessage *)buildMsg:(NSString *)sessionId withCustomContent:(NSString *)content;

@end
