//
//  ImageMessage.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  定义图片类型消息类

#import <UIKit/UIKit.h>
#import "RKCloudChatBaseMessage.h"

@interface ImageMessage : RKCloudChatBaseMessage

@property (nonatomic, copy) NSString *fileName; // 图片名称（SDK内部自动生成的文件名称）
@property (nonatomic, copy) NSString *fileLocalPath; // 图片文件的本地路径
@property (nonatomic, copy) NSString *thumbnailPath; // 图片缩略图本地路径
@property (nonatomic, copy) NSString *fileID; // 原图在服务器端存储的文件Id值

@property (nonatomic) long fileSize; // 原始图片大小，单位：字节(byte)

@property (nonatomic) int imageHeight; // 获取原始图片的高度
@property (nonatomic) int imageWidth; // 获取原始图片的宽度


/// 构造发送的图片消息
+ (ImageMessage *)buildMsg:(NSString *)sessionId withImageData:(UIImage *)imageSource;

@end
