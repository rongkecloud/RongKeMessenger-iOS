//
//  HttpClientKit.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "HttpClientKit.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

#import "ASIProgressDelegate.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

#define MAX_QUEUE_CONCURRENT_COUNT  10 // 最大的上传下载并发数量

// 客户端类型（必填），1代表android、2代表IOS、3代表winphone
enum _mobile_client_type {
    MOBILE_CLIENT_ANDROID = 1, // 1代表android
    MOBILE_CLIENT_IOS = 2,     // 2代表IOS
    MOBILE_CLIENT_WINPHONE = 3 // 3代表winphone
};


@interface HttpClientKit () <ASIProgressDelegate>

/// ASIHttpRequest Queue 上传MMS队列.
@property (nonatomic, retain) ASINetworkQueue * httpQueue;

@end

@implementation HttpClientKit

static HttpClientKit * instanceHttpKit = nil;
/**
 * @brief 创建HttpClientKit单例.
 *
 * @return 返回HttpClientKit单例对象.
 */
+ (HttpClientKit *)sharedRKCloudHttpKit
{
    @synchronized(self) {
        if (instanceHttpKit == nil) {
            instanceHttpKit = [[[self class] alloc] init];
        }
    }
    return instanceHttpKit;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.httpQueue = [[ASINetworkQueue alloc] init];
        [self.httpQueue reset];
        [self.httpQueue setShowAccurateProgress:YES];
        [self.httpQueue setMaxConcurrentOperationCount:MAX_QUEUE_CONCURRENT_COUNT];
        [self.httpQueue setName:@"uploadMMSQueue"];
    }
    return self;
}

#pragma mark -
#pragma mark HTTP API Common Function

/*
 // 服务器端Api返回的基本错误码值
 static const int API_ERR_PARAMETER_VALUES       		= 9997;   //参数值错误(参数的值不符合要求)
 static const int SYSTEM_ERR                      		= 9998;   //系统错误
 static const int API_ERR_MISSED_PARAMATER        		= 9999;   //参数错误(名称错误，或者参数缺失)
 
 // register
 static const int API_ACCOUNT_EXIST  = 1004; // 账号已存在
 
 // login
 static const int API_ERR_ACCOUNT_OR_PASSWORD_ERROR  = 1002; // 账号或密码错误
 
 // modify pwd
 static const int API_ERR_INVALID_SESSION    = 1001; // 无效session
 
 // get avatar
 static const int API_DOWNLOAD_AVATAR_FAIL   = 1025; // 下载头像失败
 
 // upload avatar
 static const int API_IPLOAD_AVATAR_FAIL =1026; // 上传头像失败
 */
// 解析服务器服务器API返回值为多语言提示的字符串
+ (NSString *)parseAPIResult:(NSInteger)result {
    NSString* message = nil;
    switch (result) {
            // 以下为客户端定义的错误代码
        case NO_NETWORK:
            message = NSLocalizedString(@"PROMPT_NETWORK_ERROR", "无网络，请检查您的网络连接...");
            break;
        case ERROR_API_TIMEROUT: // API访问超时
        case ERROR_API_WARNING: // API返回值错误(脚本有报错) Notice & Warning
            message = NSLocalizedString(@"PROMPT_SYSTEM_ERROR_OTHER", "服务器无响应，请稍候再试。");
            break;
        case ERROR_API_VALUE_NULL: // API返回值为空(请求成功，服务器返回值不正确)
            message = NSLocalizedString(@"STR_CONNECT_FAIL_RETRY", "连接失败，请重试");
            break;
            
            // 以下为服务器定义的错误码
        case OK:
            message = NSLocalizedString(@"ERROR_RK_0", "成功");
            break;
            
        case API_ERR_USERNAME_IS_EXIST:
            message = NSLocalizedString(@"ERROR_RK_1004", "用户名已存在");
            break;
            
        case API_ERR_ACCOUNT_OR_PASSWD:
            message = NSLocalizedString(@"ERROR_RK_1002", "账号或密码错误");
            break;
            
        case API_ERR_OLD_PWD_ERROR:
            message = NSLocalizedString(@"ERROR_RK_1005", "旧密码错误");
            break;
            
        case API_ERR_INVALID_SESSION:
            message = NSLocalizedString(@"ERROR_RK_1001", "无效session");
            break;
            
        case API_DOWNLOAD_AVATAR_FAIL:
            message = NSLocalizedString(@"ERROR_RK_1025", "下载头像失败");
            break;
            
        case API_IPLOAD_AVATAR_FAIL:
            message = NSLocalizedString(@"ERROR_RK_1026", "上传头像失败");
            break;
            
        case API_GROUP_NAME_EXIST:
            message = NSLocalizedString(@"ERROR_RK_1030", "分组名已存在");
            break;
            
        case SYSTEM_ERR: // 9998;   //系统错误
            message = NSLocalizedString(@"ERROR_RK_9998", "系统错误");
            break;
            
        case API_ERR_MISSED_PARAMATER: // 9999;   //参数错误(名称错误，或者参数缺失)
            message = NSLocalizedString(@"ERROR_RK_9999", "参数错误(名称错误，或者参数缺失)");
            break;
            
        default: // 连接失败，请重试
            message = NSLocalizedString(@"STR_CONNECT_FAIL_RETRY", "连接失败，请重试");
            break;
    }
    
    // 增加提示中的错误码信息
    NSString * errorCode = [NSString stringWithFormat:@"\n(%ld)", (long)result];
    message = [message stringByAppendingString:errorCode];
    return message;
}

// 错误码信息方法
+ (void)errorCodePrompt:(int)errorCode
{
    dispatch_async(dispatch_get_main_queue(), ^{
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        switch (errorCode)
        {
            case ERROR_API_TIMEROUT: // Timeout
                NSLog(@"ERROR: errorCodePrompt Result: %@", [HttpClientKit parseAPIResult:errorCode]);
                [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_SYSTEM_ERROR_OTHER", "服务器无响应，请稍候再试。")
                                   withTitle:NSLocalizedString(@"ERROR_9998", "系统错误")
                                  withButton:NSLocalizedString(@"STR_OK", "确定")
                                    toTarget:nil];
                break;
                
            case API_ERR_INVALID_SESSION: // session错误
                NSLog(@"ERROR: errorCodePrompt Result %@", [HttpClientKit parseAPIResult:errorCode]);
                // CS SessionID失效则提示用户重新登录CS
                [appDelegate.userProfilesInfo promptRepeatLogin];
                break;
                
            case API_ERR_OLD_PWD_ERROR: // 旧密码错误
                NSLog(@"ERROR: errorCodePrompt Result %@", [HttpClientKit parseAPIResult:errorCode]);
                
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"TITLE_OLD_PWD_ERROR", "旧密码错误") background:nil showTime:1.5];
                
                break;
                
            case API_GROUP_NAME_EXIST: // 分组名存在
                NSLog(@"ERROR: errorCodePrompt Result %@", [HttpClientKit parseAPIResult:errorCode]);
                
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"ERROR_RK_1030", nil) background:nil showTime:1.5];
                
                break;
                
            case API_IPLOAD_AVATAR_FAIL: // 上传头像失败
                NSLog(@"ERROR: errorCodePrompt Result %@", [HttpClientKit parseAPIResult:errorCode]);
                
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"ERROR_RK_1026", "上传头像失败") background:nil showTime:1.5];
                
                break;
                
            case API_DOWNLOAD_AVATAR_FAIL: // 下载头像失败
                NSLog(@"ERROR: errorCodePrompt Result %@", [HttpClientKit parseAPIResult:errorCode]);
                
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"ERROR_RK_1025", "下载头像失败") background:nil showTime:1.5];
                break;
                
            default: // Error
            {
                NSLog(@"ERROR: errorCodePrompt Return %@", [HttpClientKit parseAPIResult:errorCode]);
                [UIAlertView showAutoHidePromptView:[HttpClientKit parseAPIResult:errorCode] background:nil showTime:1.5];
            }
                break;
        }
    });
}


#pragma mark -
#pragma mark Get HTTP Header - User Agent

// 默认的云视互动 User-Agent: AppName/2.9.5.139 (31003998; iPhone; iPhone OS 6.1; zh_CN)
+ (NSString *)defaultHTTPUserAgentString
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Attempt to find a name for this application
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
    
    // If we couldn't find one, we'll give up (and ASIHTTPRequest will use the standard CFNetwork user agent)
    if (!appName) {
        return nil;
    }
    
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    }
    else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    
#if TARGET_OS_IPHONE
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [device model];
    OSName = [device systemName];
    OSVersion = [device systemVersion];
    
#else
    deviceName = @"Macintosh";
    OSName = @"Mac OS X";
    
    // From http://www.cocoadev.com/index.pl?DeterminingOSVersion
    // We won't bother to check for systems prior to 10.4, since ASIHTTPRequest only works on 10.5+
    OSErr err;
    SInt32 versionMajor, versionMinor, versionBugFix;
    err = Gestalt(gestaltSystemVersionMajor, &versionMajor);
    if (err != noErr) return nil;
    err = Gestalt(gestaltSystemVersionMinor, &versionMinor);
    if (err != noErr) return nil;
    err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
    if (err != noErr) return nil;
    OSVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
#endif
    
    // Takes the form "AppName/1.1.0 (iPhone; iPhone OS 6.1; zh_CN)"
    return [NSString stringWithFormat:@"%@/%@ (%@; %@ %@; %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
}

#pragma mark -
#pragma mark Synchronous Execute HttpRequest

/**
 * @brief 使用HTTP访问网络的方法，内部控制重试几次
 *
 * @param rkRequest 请求HttpRequest对象
 *
 * @return HttpResult指针对象
 */
+ (HttpResult *)sendHTTPRequest:(HttpRequest *)rkRequest
{
    NSLog(@"HTTPKIT: sendHTTPRequest: Url = %@, Params = %@", rkRequest.apiUrl, [rkRequest getStringParams]);
    
    ASIFormDataRequest *sendASIRequest = nil;
    int tryCount = rkRequest.tryCount;
    
    // 尝试重试次数
    while (tryCount > 0)
    {
        //NSLog(@"HTTPKIT: retrySendHTTPRequest: rkRequest.apiUrl = %@", rkRequest.apiUrl);
        sendASIRequest = [HttpClientKit retrySendHTTPRequest:rkRequest.apiUrl
                                             timeoutInterval:rkRequest.timeoutInterval
                                              withHTTPMethod:rkRequest.requestMethod
                                                   withParam:rkRequest.params
                                                  withCookie:nil
                                                    withFile:rkRequest.uploadFile];
        
        if (sendASIRequest != nil) {
            break;
        }
        
        // 如果重试次数大于1次则采用二进制指数退避的算法得到退避时间来重试
        if (tryCount > 1) {
            int powCount = pow(2, tryCount);
            long waitTime = random()%powCount + 5; // 到下次连接时的等待时间 单位：秒 //arc4random()%7 + 6;
            
            NSLog(@"HTTPKIT: sendHTTPRequest - url = %@, tryCount = %d, waitTime = %ld", rkRequest.apiUrl, tryCount, waitTime);
            // 尝试不成功后sleep waitTime秒再次尝试
            [NSThread sleepForTimeInterval:waitTime];
        }
        
        tryCount--;
    }
    
    // 返回的结果对象
    HttpResult *rkHttpResult = [[HttpResult alloc] init];
    rkHttpResult.uploadDownloadType = rkRequest.uploadDownloadType;
    rkHttpResult.requestId = rkRequest.requestId;
    rkHttpResult.arg0 = rkRequest.arg0;
    rkHttpResult.arg1 = rkRequest.arg1;
    rkHttpResult.obj = rkRequest.obj;
    
    // HTTP Status Code
    int nHttpStatusCode = sendASIRequest.responseStatusCode;
    // 解析API脚本返回值
    NSString *responseString = [sendASIRequest responseString];
    // 二进制数据值
    NSData * responseData = [sendASIRequest responseData];
    // 错误码信息
    NSError *error = [sendASIRequest error];
    
    // 如果出现错误则将日志输出
    if (error != nil) {
        NSLog(@"HTTPKIT: receiveHTTPResponse - apiUrl = %@, nHttpStatusCode = %d, responseString = %@, responseData.length = %lu, error = %@", rkRequest.apiUrl, nHttpStatusCode, responseString, (unsigned long)[responseData length], error);
    }
    
    // get http header
    NSDictionary *dictHeader = [sendASIRequest responseHeaders];
    //NSLog(@"HTTPKIT: sendHTTPRequest - dictHeader = %@", dictHeader);
    
    BOOL bBinaryData = NO;
    // 如果返回的类型不是文件数据
    if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/octet-stream"] ||
        [[dictHeader objectForKey:@"Content-Type"] hasPrefix:@"image/"]) {
        // get http body = string
        bBinaryData = YES;
    }
    
    // 解析HTTP Status Code
    switch (nHttpStatusCode)
    {
        case 200: // 请求成功
        {
            // HTTP请求成功
            if (bBinaryData == NO && responseString && [responseString length] != 0)
            {
                // 不同类型做不同的解析结果处理
                switch (rkRequest.requestType)
                {
                    case RKCLOUD_HTTP_TYPE_VALUE: // KEY-VALUE返回值
                    {
                        [[HttpClientKit sharedRKCloudHttpKit] parseToValueResult:responseString forHttpResult:rkHttpResult];
                    }
                        break;
                        
                    case RKCLOUD_HTTP_TYPE_TEXT: // 纯文本返回值
                    {
                        rkHttpResult.opCode = OK;
                        rkHttpResult.textResult = responseString;
                    }
                        break;
                        
                    case RKCLOUD_HTTP_TYPE_MESSAGE: // MMS消息格式返回值
                    {
                        [[HttpClientKit sharedRKCloudHttpKit] parseToMessageResult:responseString forHttpResult:rkHttpResult];
                    }
                        break;
                        
                    case RKCLOUD_HTTP_TYPE_JSON: // JSON返回值
                    {
                        // 如果返回的类型不是JSON则不做解析
                        if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/json;charset=UTF-8"])
                        {
                            // 解析API的JSON结果
                            [[HttpClientKit sharedRKCloudHttpKit] parseToJSONResult:responseString forHttpResult:rkHttpResult];
                        }
                        else {
                            rkHttpResult.opCode = ERROR_API_WARNING;
                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
                // 解析导致RKCloud不能继续工作的异常错误码
                [[HttpClientKit sharedRKCloudHttpKit] parseRKCloudFatalException:rkHttpResult.opCode];
            }
            else if (bBinaryData == YES && responseData && [responseData length] != 0)
            {
                // 二进制数据类型
                [responseData writeToFile:rkRequest.downloadFilePath atomically:YES];
                rkHttpResult.downloadFilePath = rkRequest.downloadFilePath;
                rkHttpResult.opCode = OK;
            }
            else {
                rkHttpResult.opCode = ERROR_API_VALUE_NULL;
            }
        }
            break;
            
        case 0: //（无法访问）无法连接服务器或者域名不存在
        {
//            if ([ToolsFunction checkInternetReachability] == YES) {
//                rkHttpResult.opCode = ERROR_NO_CONNECT_SERVER;
//            }
//            else {
//                rkHttpResult.opCode = NO_NETWORK;
//            }
            rkHttpResult.opCode = NO_NETWORK;
        }
            break;
            
        case 404: // 未找到，服务器找不到请求的网页
            rkHttpResult.opCode = URL_NOT_FOUND;
            break;
            
        case 408: // 请求超时
        case 504: // 网关超时
            rkHttpResult.opCode = ERROR_API_TIMEROUT;
            break;
            
        default:
            rkHttpResult.opCode = ERROR_API_WARNING;
            // HTTP请求失败
            NSLog(@"HTTPKIT-ERROR: sendHTTPRequest ***** apiUrl = %@, responseString = %@, nHttpStatusCode = %d, error = %@, sendASIRequest = %@ *****", rkRequest.apiUrl, responseString, nHttpStatusCode, error, sendASIRequest);
            break;
    }
    
    NSLog(@"HTTPKIT: receiveHTTPResponse - apiUrl = %@, nHttpStatusCode = %d, responseString = %@, responseData.length = %lu, \nResultCode = %d, ResultValues = %@, messages = %@", rkRequest.apiUrl, nHttpStatusCode, responseString, (unsigned long)[responseData length],  rkHttpResult.opCode, rkHttpResult.values, rkHttpResult.messages);
    
    return rkHttpResult;
}

/**
 * @brief 尝试使用HTTP访问网络的方法，重试几次有调用者决定
 *
 * @param url   访问API的地址
 * @param timeoutInterval  设置访问网络超时时间
 * @param method HTTP访问方法（GET/POST）
 * @param param 参数字符串
 * @param cookie 放到HTTP header中的Cookie
 * @param path 上传文件的路径
 *
 * @return ASIFormDataRequest指针对象
 */
+ (ASIFormDataRequest *)retrySendHTTPRequest:(NSString *)url
                             timeoutInterval:(NSTimeInterval)timeoutInterval
                              withHTTPMethod:(NSString *)method
                                   withParam:(NSDictionary *)dictParams
                                  withCookie:(NSString *)cookie
                                    withFile:(NSDictionary *)dictUploadFile
{
    // Use ASIHttpRequest Send HTTP Request
    ASIFormDataRequest *sendASIRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:url]];
    
    // GET/POST
    [sendASIRequest setRequestMethod:method];
    
    // 解析参数并添加到请求中
    if (dictParams && [dictParams count] > 0)
    {
        // 循环取出Key和Value
        NSArray *arrayParamKey = [dictParams allKeys];
        for (int i = 0; i < [arrayParamKey count]; i++)
        {
            // 得到每行的key和value并保存到字典中
            NSString * paramKey = [arrayParamKey objectAtIndex:i];
            if (paramKey)
            {
                NSString * paramValue = [dictParams objectForKey:paramKey];
                if (paramValue) {
                    // 赋值请求的参数
                    [sendASIRequest setPostValue:paramValue forKey:paramKey];
                }
            }
        }
    }
    
    // 解析文件参数和路径，并添加到请求中
    if (dictUploadFile && [dictUploadFile count] > 0)
    {
        // 循环取出Key和Value
        NSArray *arrayParamKey = [dictUploadFile allKeys];
        for (int i = 0; i < [arrayParamKey count]; i++)
        {
            // 得到每行的key和value并保存到字典中
            NSString * paramKey = [arrayParamKey objectAtIndex:i];
            if (paramKey)
            {
                NSString * path = [dictParams objectForKey:paramKey];
                if (path) {
                    // 赋值上传的附件
                    [sendASIRequest addFile:path forKey:paramKey];
                }
            }
        }
    }
    
    // 是否需要添加Cookie
    if (cookie != nil) {
        [sendASIRequest addRequestHeader:@"Cookie" value:cookie];
    }
    
    // User-Agent: AppName/2.9.5.139 (31003998; iPhone; iPhone OS 6.1; zh_CN)
    [sendASIRequest setUserAgentString:[HttpClientKit defaultHTTPUserAgentString]];
    
    // ASIHttpRequest Settings
    [sendASIRequest setTimeOutSeconds:timeoutInterval];
    // 由外层控制重试次数
    //[sendASIRequest setNumberOfTimesToRetryOnTimeout:RKCLOUD_TRYCOUNT_1];
    [sendASIRequest setShouldContinueWhenAppEntersBackground:YES];
    [sendASIRequest setUploadProgressDelegate:nil];
    [sendASIRequest setShowAccurateProgress:NO];
    [sendASIRequest setResponseEncoding:NSUTF8StringEncoding];
    [sendASIRequest setDefaultResponseEncoding:NSUTF8StringEncoding];
    
    // TODO: HTTPS Gray.Wang:2015.03.14: 使用HTTPS加密传输
     [sendASIRequest setShouldPresentCredentialsBeforeChallenge:YES];
     // 是否验证服务器端证书，如果此项为yes那么服务器端证书必须为合法的证书机构颁发的，而不能是自己用openssl 或java生成的证书
     [sendASIRequest setValidatesSecureCertificate:NO];
     
    
    /* Gray.Wang:2015.03.14: 使用加密证书
     SecIdentityRef secIdentityRef = NULL;
     SecTrustRef secTrustRef = NULL;
     NSData * pkcs12Data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"smartrouterapp" ofType:@"p12"]];
     
     // 从P12证书中取出Identity
     BOOL bCertificateIdentity = [RouterServerAPI extractUserIdentity:&secIdentityRef
     andTrust:&secTrustRef
     fromPKCS12Data:(CFDataRef)pkcs12Data];
     if (bCertificateIdentity) {
     // 附带证书请求
     [sendASIRequest setClientCertificateIdentity:secIdentityRef];
     }
     */
    
    // 启动同步请求
    [sendASIRequest startSynchronous];
    
    return sendASIRequest;
}


/***********************************************************************/

#pragma mark -
#pragma mark ASIProgressDelegate

// Called when the request receives some data - bytes is the length of that data
- (void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    unsigned long long receiveTotalBytes = request.totalBytesRead + request.partialDownloadSize;
    unsigned long long downloadTotalBytes = request.contentLength + request.partialDownloadSize;
    
    if (receiveTotalBytes <= 0 || downloadTotalBytes <= 0) {
        return;
    }
    
    float receivesProgress = (float)(receiveTotalBytes*1.0)/(downloadTotalBytes*1.0);
    
    NSLog(@"ASIProgressDelegate: +++++ didReceiveBytes: downloadTotalBytes = %lld bytes, receiveTotalBytes = %lld bytes, didReceiveBytes = %lld bytes, receivesProgress = %f, receivesPercent = %0.f%% +++++", downloadTotalBytes, receiveTotalBytes, bytes, receivesProgress, receivesProgress*100);
    
    HttpRequest * rkRequest = (HttpRequest*)[[request userInfo] objectForKey:@"request"];
    
    // 获取当前进度
    HttpProgress * rkProgress = [[HttpProgress alloc] init];
    rkProgress.uploadDownloadType = rkRequest.uploadDownloadType;
    rkProgress.requestId = rkRequest.requestId;
    rkProgress.progress = receivesProgress;
    
    if (rkRequest.httpClientKitDelegate &&
        [rkRequest.httpClientKitDelegate respondsToSelector:@selector(onDownLoadProgress:)]) {
        [rkRequest.httpClientKitDelegate onDownLoadProgress:rkProgress];
    }
}

// Called when the request sends some data
// The first 32KB (128KB on older platforms) of data sent is not included in this amount because of limitations with the CFNetwork API
// bytes may be less than zero if a request needs to remove upload progress (probably because the request needs to run again)
- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    unsigned long long sendTotalBytes = request.totalBytesSent - request.uploadBufferSize;
    unsigned long long uploadTotalBytes = request.postLength - request.uploadBufferSize;
    
    if (sendTotalBytes <= 0 || uploadTotalBytes <= 0) {
        return;
    }
    
    float sendProgress = (float)(sendTotalBytes*1.0)/(uploadTotalBytes*1.0);
    
    NSLog(@"ASIProgressDelegate: +++++ didSendBytes: uploadTotalBytes = %lld, sendTotalBytes = %lld, didSendBytes = %lld bytes, sendProgress = %f, sendPercent = %0.f%% +++++",
          uploadTotalBytes, sendTotalBytes, bytes, sendProgress, sendProgress*100);
    
    HttpRequest * rkRequest = (HttpRequest*)[[request userInfo] objectForKey:@"request"];
    
    // 获取当前进度
    HttpProgress * rkProgress = [[HttpProgress alloc] init];
    rkProgress.uploadDownloadType = rkRequest.uploadDownloadType;
    rkProgress.requestId = rkRequest.requestId;
    rkProgress.progress = sendProgress;
    
    if (rkRequest.httpClientKitDelegate &&
        [rkRequest.httpClientKitDelegate respondsToSelector:@selector(onUploadProgress:)]) {
        [rkRequest.httpClientKitDelegate onUploadProgress:rkProgress];
    }
}


#pragma mark -
#pragma mark Execute HttpRequest

// 异步执行HTTP请求，将下载的信息加入队列中执行下载
- (void)execute:(HttpRequest *)rkRequest
{
    // 如果在队列中已存在则不添加，否则添加到下载队列中下载
    if (![self requestIsExists:rkRequest])
    {
        ASIFormDataRequest * request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:rkRequest.apiUrl]];
        
        NSLog(@"HTTPKIT: RequestUrl = %@", rkRequest.apiUrl);
        if (rkRequest.params)
        {
            for (NSString * key in rkRequest.params) {
                NSLog(@"HTTPKIT: http Request params = key: %@, value: %@", key, rkRequest.params[key]);
                [request setPostValue:rkRequest.params[key] forKey:key];
            }
        }
        
        if (rkRequest.downloadFilePath) {
            // 得到临时文件路径，为了断点续传
            NSString *tempFilePath = [[NSString alloc] initWithFormat:@"%@%@.tmp", NSTemporaryDirectory(), [ToolsFunction getCurrentSystemDateMillisecondString]];
            [request setTemporaryFileDownloadPath:tempFilePath];
            [request setDownloadDestinationPath:rkRequest.downloadFilePath];
        }
        
        if(rkRequest.uploadFile){
            for (NSString *key in rkRequest.uploadFile){
                [request setFile:[rkRequest.uploadFile valueForKey:key] forKey:key];
            }
            
        }
        NSMutableDictionary * userInfoDict = [[NSMutableDictionary alloc] init];
        [userInfoDict setObject:rkRequest forKey:@"request"];
        [request setUserInfo:userInfoDict];
        
        
        [request setShouldPresentCredentialsBeforeChallenge:YES];
        // 是否验证服务器端证书，如果此项为yes那么服务器端证书必须为合法的证书机构颁发的，而不能是自己用openssl 或java生成的证书
        [request setValidatesSecureCertificate:NO];

        
        // User-Agent: AppName/2.9.5.139 (31003998; iPhone; iPhone OS 6.1; zh_CN)
        [request setUserAgentString:[HttpClientKit defaultHTTPUserAgentString]];
        
        // ASIRequest Settings
        [request setRequestMethod:rkRequest.requestMethod];
        [request setTimeOutSeconds:RKCLOUD_TIMEOUT];
        [request setNumberOfTimesToRetryOnTimeout:rkRequest.tryCount];
        [request setShouldContinueWhenAppEntersBackground:YES];
        
        if (rkRequest.downloadFilePath){
            [request setDownloadProgressDelegate:self];
        }
        else if(rkRequest.uploadFile){
            [request setUploadProgressDelegate:self];
        }
        
        [request setShowAccurateProgress:YES];
        [request setResponseEncoding:NSUTF8StringEncoding];
        [request setDefaultResponseEncoding:NSUTF8StringEncoding];
        [request setDelegate:self];
        [request setDidFailSelector:@selector(requestFailDo:)];
        [request setDidFinishSelector:@selector(requestFinishDo:)];
        
        // 增加到下载队列中
        [self.httpQueue addOperation:request];
        
        // 如果队列被挂起则开始下载
        if ([self.httpQueue isSuspended] == YES) {
            [self.httpQueue go];
        }
    }
}

- (void)requestFailDo:(ASIHTTPRequest *)request
{
    NSString *stringResult = [request responseString];
    int httpStatusCode = [request responseStatusCode];
    
    NSLog(@"HTTPKIT: requestFailDo responseString = %@", stringResult);
    
    HttpRequest *rkRequest = (HttpRequest*)[[request userInfo] valueForKey:@"request"];
    HttpResult *rkHttpResult = [[HttpResult alloc] init];
    
    // get http header
    NSDictionary *dictHeader = [[NSDictionary alloc] initWithDictionary:[request responseHeaders]];
    //RKCloudDebugLog(@"HTTPKIT: retrySendHTTPRequest - dictHeader = %@", dictHeader);
    
    // 解析HTTP Status Code
    switch (httpStatusCode)
    {
        case 200:
        {
            switch (rkRequest.requestType) {
                case RKCLOUD_HTTP_TYPE_VALUE: // KEY-VALUE返回值
                {
                    [self parseToValueResult:stringResult forHttpResult:rkHttpResult];
                }
                    break;
                    
                case RKCLOUD_HTTP_TYPE_TEXT: // 纯文本返回值
                {
                    rkHttpResult.opCode = OK;
                    rkHttpResult.textResult = stringResult;
                }
                    break;
                    
                case RKCLOUD_HTTP_TYPE_FILE: // 二进制文件返回值
                {
                    // 如果返回的类型是否为JSON类型
                    if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/json;charset=UTF-8"])
                    {
                        // 解析API的JSON结果
                        [[HttpClientKit sharedRKCloudHttpKit] parseToJSONResult:stringResult forHttpResult:rkHttpResult];
                    }
                    else {
                        [self parseToValueResult:stringResult forHttpResult:rkHttpResult];
                    }
                }
                    break;
                    
                case RKCLOUD_HTTP_TYPE_MESSAGE: // MMS消息格式返回值
                {
                    [self parseToMessageResult:stringResult forHttpResult:rkHttpResult];
                }
                    break;
                    
                case RKCLOUD_HTTP_TYPE_JSON: // JSON返回值
                {
                    // 如果返回的类型是否为JSON类型
                    if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/json;charset=UTF-8"])
                    {
                        // 解析API的JSON结果
                        [[HttpClientKit sharedRKCloudHttpKit] parseToJSONResult:stringResult forHttpResult:rkHttpResult];
                    }
                    else {
                        rkHttpResult.opCode = ERROR_API_WARNING;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            
            // 解析导致RKCloud不能继续工作的异常错误码
            [self parseRKCloudFatalException:rkHttpResult.opCode];
        }
            break;
            
        case 0: //（无法访问）无法连接服务器或者域名不存在
        {
            if ([ToolsFunction checkInternetReachability] == YES) {
                rkHttpResult.opCode = ERROR_NO_CONNECT_SERVER;
            }
            else {
                rkHttpResult.opCode = NO_NETWORK;
            }
        }
            break;
            
        case 404: // 未找到，服务器找不到请求的网页
            rkHttpResult.opCode = URL_NOT_FOUND;
            break;
            
        case 408: // 请求超时
        case 504: // 网关超时
            rkHttpResult.opCode = ERROR_API_TIMEROUT;
            break;
            
        default:
            rkHttpResult.opCode = ERROR_DOWNLOAD_FAIL;
            break;
    }
    
    rkHttpResult.uploadDownloadType = rkRequest.uploadDownloadType;
    rkHttpResult.requestId = rkRequest.requestId;
    rkHttpResult.arg0 = rkRequest.arg0;
    rkHttpResult.arg1 = rkRequest.arg1;
    rkHttpResult.obj = rkRequest.obj;
    
    if (rkRequest.httpClientKitDelegate &&
        [rkRequest.httpClientKitDelegate respondsToSelector:@selector(onHttpCallBack:)]) {
        [rkRequest.httpClientKitDelegate onHttpCallBack:rkHttpResult];
    }
}

- (void)requestFinishDo:(ASIHTTPRequest *)request
{
    NSString * stringResult = [request responseString];
    NSLog(@"HTTPKIT: requestFinishDo responseString = %@", [request responseString]);
    
    HttpResult *rkHttpResult = [[HttpResult alloc] init];
    HttpRequest *rkRequest = (HttpRequest *)[[request userInfo] valueForKey:@"request"];
    
    // get http header
    NSDictionary *dictHeader = [[NSDictionary alloc] initWithDictionary:[request responseHeaders]];
    //RKCloudDebugLog(@"HTTPKIT: retrySendHTTPRequest - dictHeader = %@", dictHeader);
    
    if (stringResult == nil)
    {
        rkHttpResult.opCode = OK;
        rkHttpResult.downloadFilePath = rkRequest.downloadFilePath;
    }
    else {
        switch (rkRequest.requestType) {
                
            case RKCLOUD_HTTP_TYPE_VALUE: // KEY-VALUE返回值
                [self parseToValueResult:stringResult forHttpResult:rkHttpResult];
                break;
                
            case RKCLOUD_HTTP_TYPE_TEXT: // 纯文本返回值
            {
                rkHttpResult.opCode = OK;
                rkHttpResult.textResult = stringResult;
            }
                break;
                
            case RKCLOUD_HTTP_TYPE_FILE: // 二进制文件返回值
            {
                // 如果返回的类型是否为JSON类型
                if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/json;charset=UTF-8"])
                {
                    // 解析API的JSON结果
                    [[HttpClientKit sharedRKCloudHttpKit] parseToJSONResult:stringResult forHttpResult:rkHttpResult];
                }
                else {
                    [self parseToValueResult:stringResult forHttpResult:rkHttpResult];
                }
            }
                break;
                
            case RKCLOUD_HTTP_TYPE_MESSAGE: // MMS消息格式返回值
            {
                [self parseToMessageResult:stringResult forHttpResult:rkHttpResult];
            }
                break;
                
            case RKCLOUD_HTTP_TYPE_JSON: // JSON返回值
            {
                // 如果返回的类型是否为JSON类型
                if ([[dictHeader objectForKey:@"Content-Type"] isEqualToString:@"application/json;charset=UTF-8"])
                {
                    // 解析API的JSON结果
                    [[HttpClientKit sharedRKCloudHttpKit] parseToJSONResult:stringResult forHttpResult:rkHttpResult];
                }
                else {
                    rkHttpResult.opCode = ERROR_API_WARNING;
                }
            }
                break;
                
            default:
                break;
        }
        
        // 解析导致RKCloud不能继续工作的异常错误码
        [self parseRKCloudFatalException:rkHttpResult.opCode];
    }
    
    rkHttpResult.uploadDownloadType = rkRequest.uploadDownloadType;
    rkHttpResult.requestId = rkRequest.requestId;
    rkHttpResult.arg0 = rkRequest.arg0;
    rkHttpResult.arg1 = rkRequest.arg1;
    rkHttpResult.obj = rkRequest.obj;
    
    if (rkRequest.httpClientKitDelegate &&
        [rkRequest.httpClientKitDelegate respondsToSelector:@selector(onHttpCallBack:)]) {
        [rkRequest.httpClientKitDelegate onHttpCallBack:rkHttpResult];
    }
}

// 判断下载队列中是否存在数据的名称或类型
- (BOOL)requestIsExists:(HttpRequest *)rkRequest
{
    NSArray * arrayOperations = [self.httpQueue operations];
    
    // 查找发送队列中是否存在此消息记录
    for (int i = 0 ; i < [arrayOperations count] ; i++) {
        ASIHTTPRequest * asRequest = [arrayOperations objectAtIndex:i];
        NSDictionary * userInfo = [asRequest userInfo];
        HttpRequest * request = (HttpRequest*)[userInfo valueForKey:@"request"];
        
        // 查找消息ID是否存在
        if ([request.requestId isEqualToString:rkRequest.requestId]) {
            return YES;
        }
    }
    
    return NO;
}

// 取消所有的请求
- (void)cancelAllRequest
{
    [self.httpQueue cancelAllOperations];
}


#pragma mark -
#pragma mark Parse HttpResult

// 解析API的key-value结果
- (void)parseToValueResult:(NSString *)stringResult forHttpResult:(HttpResult *)httpResult
{
    //NSLog(@"HTTPKIT: parseToValueResult: stringResult = %@", stringResult);
    
    httpResult.values = [[NSMutableDictionary alloc] init];
    // 解析mobileSendMMS返回结果
    NSArray *valueArray = [stringResult componentsSeparatedByString:@"\n"];
    
    // 将所有Key和Value保存到字典中以便查找
    for (NSString *lineString in valueArray)
    {
        if (lineString != nil && ![lineString isEqualToString:@""])
        {
            NSRange rangeEqualSign = [lineString rangeOfString:@"="];
            if (rangeEqualSign.location != NSNotFound && rangeEqualSign.length > 0)
            {
                // 得到每行的key和value并保存到字典中
                NSString *key = [lineString substringToIndex:rangeEqualSign.location];
                NSString *value = [lineString substringFromIndex:(rangeEqualSign.location+1)];
                if (key && value)
                {
                    if ([key isEqualToString:HTTP_RESPONSE_RESULT_ERRCODE]){
                        httpResult.opCode = [value intValue];
                    }
                    else {
                        [httpResult.values setValue:value forKey:key];
                    }
                }
            }
        }
    }
}

// 解析MMS API的结果
- (void)parseToMessageResult:(NSString *)stringResult forHttpResult:(HttpResult *)httpResult
{
    // 解析mobileSendMMS返回结果
    NSArray *valueArray = [stringResult componentsSeparatedByString:@"\n"];
    
    // 将所有Key和Value保存到字典中以便查找
    for (NSString *lineString in valueArray)
    {
        if (lineString != nil && ![lineString isEqualToString:@""])
        {
            // 得到每行的key和value并保存到字典中
            NSRange rangeEqualSign = [lineString rangeOfString:@"="];
            if (rangeEqualSign.location != NSNotFound && rangeEqualSign.length > 0)
            {
                // 得到每行的key和value并保存到字典中
                NSString * key = [lineString substringToIndex:rangeEqualSign.location];
                NSString * value = [lineString substringFromIndex:(rangeEqualSign.location+1)];
                
                if ([key isEqualToString:HTTP_RESPONSE_RESULT_ERRCODE])
                {
                    httpResult.opCode = [value intValue];
                }
                else if ([key isEqualToString:@"msg"])
                {
                    [httpResult.messages addObject:value];
                    NSLog(@"HTTPKIT: msg=%@",value);
                }
                else {
                    [httpResult.values setValue:value forKey:key];
                }
            }
        }
    }
}

// 解析API的JSON结果
- (void)parseToJSONResult:(NSString *)stringResult forHttpResult:(HttpResult *)httpResult
{
    NSError *error = nil;
    
    // 解析JSON字符串
    NSData *dataJSON = [stringResult dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictResult = [NSJSONSerialization JSONObjectWithData:dataJSON options:NSJSONReadingMutableLeaves error:&error];
    
    // 校验JSON对象的有效性并且item大于0
    if ([dictResult count] > 0 && [NSJSONSerialization isValidJSONObject:dictResult])
    {
        if ([dictResult objectForKey:HTTP_RESPONSE_RESULT_ERRCODE]) {
            httpResult.opCode = [[dictResult objectForKey:HTTP_RESPONSE_RESULT_ERRCODE] intValue];
        }
        
        httpResult.values = [[NSMutableDictionary alloc] initWithDictionary:dictResult];
    }
}


// 解析导致RKCloud不能继续工作的异常错误码
- (void)parseRKCloudFatalException:(int)errorCode
{
    switch (errorCode) {
        case API_ERR_INVALID_SESSION: // 重复登录
            // 提示重复登录帐号并自动登出
            [[AppDelegate appDelegate].userProfilesInfo promptRepeatLogin];
            break;
            
//        case API_ERR_USER_PROHIBITED: // 账号被禁
//            // 提示用户被禁止使用
//            [[AppDelegate appDelegate].userProfilesInfo promptBannedUsers];
//            break;
            
        default:
            break;
    }
}

@end
