//
//  VideoMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义视频类型消息类

#import "RKCloudChatBaseMessage.h"

@interface VideoMessage : RKCloudChatBaseMessage

@property (nonatomic) int mediaDuration; // 视频消息的播放时长，单位：秒

@property (nonatomic, copy) NSString *fileName; // 视频文件名称（应用层传递的文件名称）
@property (nonatomic, copy) NSString *fileLocalPath; // 视频的本地路径
@property (nonatomic, copy) NSString *thumbnailPath; // 视频缩略图路径
@property (nonatomic, copy) NSString *fileID; // 视频消息在服务器端存储的文件Id值

@property (nonatomic) long fileSize; // 视频文件大小，单位：字节(bytes)

@property (nonatomic) int imageHeight; // 获取缩略图的高度
@property (nonatomic) int imageWidth; // 获取缩略图的宽度

/// 构造发送的视频消息
+ (VideoMessage *)buildMsg:(NSString *)sessionId
             withVideoPath:(NSString *)videoPath
              withDuration:(int)duration;

@end
