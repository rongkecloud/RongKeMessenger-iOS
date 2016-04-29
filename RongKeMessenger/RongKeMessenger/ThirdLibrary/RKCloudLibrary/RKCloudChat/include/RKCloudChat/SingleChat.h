//
//  SingleChat.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  云视互动即时通信中单聊会话的实体定义

#import "RKCloudChatBaseChat.h"

@interface SingleChat : RKCloudChatBaseChat

/// 构造单聊会话的对象
+ (SingleChat *)buildSingleChat:(NSString *)userName
                      onSuccess:(void (^)())onSuccess
                       onFailed:(void (^)(int errorCode))onFailed;

/// 设置联系人显示的名称
- (void)setContactShowName:(NSString *)showName;

@end
