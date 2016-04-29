//
//  AudioMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义音频类型消息类

#import "RKCloudChatBaseMessage.h"

@interface AudioMessage : RKCloudChatBaseMessage

@property (nonatomic) int mediaDuration; // 语音消息的播放时长，单位：秒
@property (nonatomic) long fileSize; // 语音文件大小，单位：字节(bytes)

@property (nonatomic, copy) NSString *fileName; // 语音文件名称
@property (nonatomic, copy) NSString *fileLocalPath; // 文件的本地路径
@property (nonatomic, copy) NSString *fileID; // 语音消息在服务器端存储的文件Id值

/// 构造发送的音频消息
+ (AudioMessage *)buildMsg:(NSString *)sessionId
             withLocalPath:(NSString *)audioPath
              withDuration:(int)duration;
@end
