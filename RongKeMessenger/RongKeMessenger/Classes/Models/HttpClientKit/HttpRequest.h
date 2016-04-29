//
//  HttpRequest.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 15/3/17.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HttpClientKitDelegate;

@interface HttpRequest : NSObject

@property (nonatomic, strong) NSString *apiUrl; // 请求API的URL地址
@property (nonatomic, strong) NSMutableDictionary *params; // API所需要的参数字典
@property (nonatomic, strong) NSMutableDictionary *uploadFile; // 上传文件的字典(参数-文件路径)
@property (nonatomic, strong) NSString *downloadFilePath; // 下载到本地的文件路径
@property (nonatomic, strong) NSString *requestMethod; // 请求使用的HTTP方法（POST/GET），默认为POST请求
@property (nonatomic, strong) NSString *requestId; // 请求的ID(Chat:messageID)

@property (nonatomic) int requestType; // 请求的类型，参考RequestType宏定义，默认为RKCLOUD_HTTP_TYPE_VALUE类型
@property (nonatomic) int uploadDownloadType; // 上传下载文件类型
@property (nonatomic) int tryCount; // 重试请求次数，默认为1次
@property (nonatomic) int timeoutInterval; // 请求API的超时时间，默认为120秒

@property (nonatomic, assign) id <HttpClientKitDelegate> httpClientKitDelegate; // HTTP Client请求API使用的代理

@property (nonatomic, strong) NSString *arg0; // 附加扩展字符串参数0
@property (nonatomic, strong) NSString *arg1; // 附加扩展字符串参数1
@property (nonatomic, strong) id obj; // 附加扩展的对象参数

- (NSString *)getStringParams;

@end
