//
//  HttpClientKit.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpRequest.h"
#import "httpResult.h"
#import "HttpProgress.h"

#define RKCLOUD_URL_HTTPS_TYPE				@"https"
#define RKCLOUD_URL_HTTP_TYPE				@"http"
#define RKCLOUD_HTTP_GET                    @"GET"
#define RKCLOUD_HTTP_POST					@"POST"
#define RKCLOUD_HTTP_BODY_SEPARATOR         @"----------7db220630e70"

#define RKCLOUD_API_SERVER_PATH		        @"/rkdemo3/" // HTTP Server Path

// Try connect count
#define RKCLOUD_TRYCOUNT_1	  1
#define RKCLOUD_TRYCOUNT_3	  3
#define RKCLOUD_TIMEOUT_15   15 // http访问超时时间
#define RKCLOUD_TIMEOUT     120 // 使用POST方式提交和下载的超时时间

typedef NS_ENUM(NSUInteger, RequestType) {
    RKCLOUD_HTTP_TYPE_VALUE = 1, /**< KEY-VALUE返回值    */
    RKCLOUD_HTTP_TYPE_TEXT = 2, /**< 纯文本返回值    */
    RKCLOUD_HTTP_TYPE_FILE = 3, /**< 二进制文件返回值    */
    RKCLOUD_HTTP_TYPE_MESSAGE = 4, /**< MMS消息格式返回值    */
    RKCLOUD_HTTP_TYPE_JSON = 5, /**< JSON返回值    */
};

#define HTTP_RESPONSE_RESULT_ERRCODE @"oper_result" // 访问API返回的错误码字段

// API Client Error Code
static const int OK = 0; // 请求成功
static const int NO_NETWORK = 1; // 无网络
static const int CLIENT_HTTP_PROTOCOL_PARSEERROR = 2; // 客户端协议解析错误
static const int CLIENT_HTTP_RESULT_PARSE_ERROR = 3; // 客户端对服务器端的返回结果解析错误
static const int URL_NOT_FOUND = 4; // 请求的url地址不存在
static const int ERROR_API_TIMEROUT = 5; // API访问超时
static const int ERROR_API_WARNING = 6; // API返回值错误(脚本有报错)
static const int ERROR_API_VALUE_NULL = 7; // API返回值为空(请求成功，服务器返回值不正确)
static const int ERROR_DOWNLOAD_FAIL = 8; // 下载文件失败
static const int ERROR_NO_CONNECT_SERVER = 9; //（无法访问）无法连接服务器或者域名不存在

// 服务器端Api返回的基本错误码值
static const int SYSTEM_ERR                = 9998;   //系统错误
static const int API_ERR_MISSED_PARAMATER  = 9999;   //参数错误(名称错误，或者参数缺失)

// modify pwd
static const int API_ERR_INVALID_SESSION    =   1001; // 无效session
// login
static const int API_ERR_ACCOUNT_OR_PASSWD  =   1002; // 账号或密码错误
// register
static const int API_ERR_USERNAME_IS_EXIST  =   1004; // 账号已存在
static const int API_ERR_OLD_PWD_ERROR      =   1005; // 旧密码错
// get avatar
static const int API_DOWNLOAD_AVATAR_FAIL   =   1025; // 下载头像失败
// upload avatar
static const int API_IPLOAD_AVATAR_FAIL =   1026; // 上传头像失败
// Contact Group Name Exist
static const int API_GROUP_NAME_EXIST   = 1030; // 分组名已存在


/// 云视互动HTTP代理接口
@protocol HttpClientKitDelegate <NSObject>

@optional
- (void)onHttpCallBack:(HttpResult *) result;
- (void)onUploadProgress:(HttpProgress *) progress;
- (void)onDownLoadProgress:(HttpProgress *) progress;
@end


/// 云视互动HTTP请求接口
@interface HttpClientKit : NSObject

// 获取单例的HttpClientKit对象指针
+ (HttpClientKit *)sharedRKCloudHttpKit;

// 解析服务器API返回Error Code值为多语言提示的字符串
+ (NSString *)parseAPIResult:(NSInteger)result;

/**
 *  错误码信息方法
 *
 *  @param errorCode 非正确的提示码
 */
+ (void)errorCodePrompt:(int)errorCode;

// 异步执行HTTP请求，将下载的信息加入队列中执行下载
- (void)execute:(HttpRequest *)rkRequest;

// 取消所有的请求
- (void)cancelAllRequest;


#pragma mark -
#pragma mark Send HTTP Request

/// sendHTTPRequest.
+ (HttpResult *)sendHTTPRequest:(HttpRequest *)rkRequest;
@end
