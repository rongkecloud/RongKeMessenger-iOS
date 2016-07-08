//
//  GroupChat.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  云视互动即时通信中群聊会话的实体定义

#import "RKCloudChatBaseChat.h"

@interface GroupChat : RKCloudChatBaseChat

@property (nonatomic, copy) NSString *groupDescription; // 群的描述信息
@property (nonatomic, copy) NSString *groupCreater; // 获取群聊会话的创建者信息，为云视互动分配的账号
@property (nonatomic) BOOL isEnableInvite; // 是否开放邀请人权限（0：代表禁止 1:代表允许）

@property (nonatomic) long lastInfoSyncTime; // 最后一次与服务器的同步群聊信息时间，单位：秒级时间戳
@property (nonatomic) long lastMemberSyncTime; // 最后一次与服务器的同步成员时间，单位：秒级时间戳

// 初始化群聊会话对象
- (GroupChat *)initGroupChat:(NSString *)groupId;

@end
