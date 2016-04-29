//
//  FileMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义文件类型消息类

#import "RKCloudChatBaseMessage.h"

@interface FileMessage : RKCloudChatBaseMessage

@property (nonatomic, copy) NSString *fileName; // 文件名称（应用层传递的文件名称）
@property (nonatomic, copy) NSString *fileLocalPath; // 文件的本地真实名称(通过此名称获取文件路径)
@property (nonatomic, copy) NSString *fileID; // 文件在服务器端存储的文件Id值

@property (nonatomic) long fileSize; // 文件大小，单位：字节(byte)

/// 构造发送的文件消息
+ (FileMessage *)buildMsg:(NSString *)sessionId withFilePath:(NSString *)filePath;

@end
