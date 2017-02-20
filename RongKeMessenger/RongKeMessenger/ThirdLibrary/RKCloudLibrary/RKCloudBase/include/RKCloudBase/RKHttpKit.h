//
//  RKHttpKit.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RKHttpRequest.h"
#import "RKHttpResult.h"
#import "RKHttpProgress.h"

#define RKCLOUD_URL_HTTP_TYPE				@"https"
#define RKCLOUD_HTTP_GET                    @"GET"
#define RKCLOUD_HTTP_POST					@"POST"
#define RKCLOUD_HTTP_BODY_SEPARATOR         @"----------7db220630e70"

#define RKCLOUD_API_SERVER_PATH		        @"/3.0/"

// Try connect count
#define RKCLOUD_TRYCOUNT_1	    1
#define RKCLOUD_TRYCOUNT_3	    3
#define RKCLOUD_TIMEOUT_15     15 // http访问超时时间
#define RKCLOUD_TIMEOUT       120 // 使用POST方式提交和下载的超时时间

typedef NS_ENUM(NSUInteger, RKCloudRequestType) {
    RKCLOUD_HTTP_TYPE_VALUE = 1, /**< KEY-VALUE返回值    */
    RKCLOUD_HTTP_TYPE_TEXT = 2, /**< 纯文本返回值    */
    RKCLOUD_HTTP_TYPE_FILE = 3, /**< 二进制文件返回值    */
    RKCLOUD_HTTP_TYPE_MESSAGE = 4, /**< MMS消息格式返回值    */
    RKCLOUD_HTTP_TYPE_JSON = 5, /**< JSON返回值    */
};

#define MSG_JSON_KEY_RET_CODE @"errcode" // 访问API返回的错误码字段
#define MSG_JSON_KEY_RET_ERROR_MESSAGE @"errmsg" // 对错误码的描述


// HTTP API Client Error Code
typedef enum : NSInteger {
    OK = 0, /**< 请求成功    */
    NO_NETWORK = 1, /**< 无网络    */
    CLIENT_HTTP_PROTOCOL_PARSEERROR = 2, /**< 客户端协议解析错误    */
    CLIENT_HTTP_RESULT_PARSE_ERROR = 3, /**< 客户端对服务器端的返回结果解析错误    */
    URL_NOT_FOUND = 4, /**< 请求的url地址不存在    */
    ERROR_API_TIMEROUT = 5, /**< API访问超时    */
    ERROR_API_WARNING = 6, /**< API返回值错误(脚本有报错)    */
    ERROR_API_VALUE_NULL = 7, /**< API返回值为空(请求成功，服务器返回值不正确)    */
    ERROR_DOWNLOAD_FAIL = 8, /**< 下载文件失败    */
    ERROR_NO_CONNECT_SERVER = 9, /**< （无法访问）无法连接服务器或者域名不存在    */
    
    // 服务器端Api返回的基本错误码值
    SERVER_ERROR = 9998, /**< 服务器端系统错误    */
    SERVER_PARAM_MISSED = 9999, /**< 请求参数错误    */
} RKHttpKitErrorCode;

/// 云视互动HTTP代理接口
@protocol RKHttpKitDelegate <NSObject>

@optional
// 回调请求API的结果
- (void)onHttpCallBack:(RKHttpResult *)result;
// 上传进度回调方法
- (void)onUploadProgress:(RKHttpProgress *)progress;
// 下载进度回调方法
- (void)onDownLoadProgress:(RKHttpProgress *)progress;
@end


/// 云视互动HTTP请求接口
@interface RKHttpKit : NSObject

/// 获取单例的RKHttpKit对象指针
+ (RKHttpKit *)sharedRKCloudHttpKit;


#pragma mark -
#pragma mark HTTP API Common Function

/// 解析解析云视互动SDK服务器API返回Error Code值为多语言提示的字符串
+ (NSString *)parseAPIResult:(NSInteger)result;


#pragma mark -
#pragma mark Asynchronous Execute RKHttpRequest

/// 异步执行HTTP请求，将下载的信息加入队列中执行下载
- (void)execute:(RKHttpRequest *)rkRequest;

/// 判断下载队列中是否存在数据的请求ID
- (BOOL)isExistsRequestId:(NSString *)requestId;

// 取消所有的请求
- (void)cancelAllRequest;


#pragma mark -
#pragma mark Synchronous Send HTTP Request

/// 即时通信Chat SDK适用的HTTP发送接口(Chat)
+ (RKHttpResult *)sendChatHTTPRequest:(RKHttpRequest *)rkRequest;

/// 音视频SDK使用的HTTP发送接口(Audio)
+ (RKHttpResult *)sendAVHTTPRequest:(RKHttpRequest *)rkRequest;

/// 多人语音SDK使用的HTTP发送接口(Meeting)
+ (RKHttpResult *)sendMutilVoiceHTTPRequest:(RKHttpRequest *)rkRequest;


#pragma mark -
#pragma mark Synchronous Execute RKHttpRequest

/**
 * @brief 使用HTTP访问网络的方法，内部控制重试几次
 *
 * @param rkRequest 请求RKHttpRequest对象
 *
 * @return RKHttpResult指针对象
 */
+ (RKHttpResult *)sendHTTPRequest:(RKHttpRequest *)rkRequest;
@end
