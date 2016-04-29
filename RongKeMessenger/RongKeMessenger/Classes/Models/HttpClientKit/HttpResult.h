//
//  HttpResult.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 15/3/17.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpResult : NSObject

@property (nonatomic, strong) NSString *requestId; // 请求的ID(Chat:messageID)
@property (nonatomic, strong) NSMutableDictionary *values; // 请求API返回的结果字典
@property (nonatomic, strong) NSMutableArray *messages; // 请求GetMessage API返回的消息数组列表
@property (nonatomic, strong) NSString *downloadFilePath; // 下载到本地的文件路径
@property (nonatomic, strong) NSString *textResult; // 请求的API返回的字符串结果或错误描述

@property (nonatomic, strong) NSString *arg0; // 附加扩展字符串参数0
@property (nonatomic, strong) NSString *arg1; // 附加扩展字符串参数1
@property (nonatomic, strong) id obj; // 附加扩展的对象参数

@property (nonatomic, strong) NSString *errorMsg;  // 服务器返回的错误提示信息("errmsg")
@property (nonatomic) int opCode; // 服务器返回的错误码值（"errcode"，0为成功，其他为错误）

@property (nonatomic) int uploadDownloadType; // 上传下载文件类型

@end
