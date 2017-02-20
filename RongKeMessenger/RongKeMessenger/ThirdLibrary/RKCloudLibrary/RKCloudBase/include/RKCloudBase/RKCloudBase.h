//
//  RKCloudBase.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

/*!
 @header RKCloudBase.h
 @abstract 云视互动Base SDK头文件
 @author 西安融科通信技术有限公司 (www.rongkecloud.com)
 @version 2.2.5 2016/02/22 Update
 */

#import <Foundation/Foundation.h>

/*!
 * @enum
 * @brief RKCloud支持功能类型枚举 0：基础通信能力，1：即时通讯能力 2：音视频通话能力 3：多人语音能力
 */
typedef enum : NSUInteger {
    RKCLOUD_CAPABILITY_BASE = 0, /**< 基础通信能力    */
    RKCLOUD_CAPABILITY_IM  = 1,  /**< 即时通讯能力    */
    RKCLOUD_CAPABILITY_AV  = 2,  /**< 音视频通话能力    */
    RKCLOUD_CAPABILITY_MEETING = 3,  /**< 多人语音能力    */
} RKCloudCapability;

/*!
 * @enum
 * @brief 公共的错误码值定义（0-1000）
 *
 */
typedef enum : NSInteger {
    RK_SUCCESS = 0,    /**< 成功    */
    RK_FAILURE = 1,     /**< 操作失败    */
    RK_NOT_NETWORK = 2,   /**< 无网络    */
    RK_PARAMS_ERROR = 3,   /**< 请求参数错误    */
    RK_SDK_UNINIT = 4,   /**< Base SDK还未初始化成功    */
    RK_INVALID_USER = 5,  /**< 非法用户，即非云视互动用户或是该用户从未登录使用过    */
    RK_NONSUPPORT_AVCALL = 6, /**< 不支持音视频通话    */
    RK_NONSUPPORT_MEETING = 7, /**< 不支持多人语音    */
    RK_EXIST_AV_CALLING = 8,  /**< 当前有正在进行的音视频通话    */
    RK_EXIST_MEETINGING = 9,  /**< 当前有正在进行的多人会议    */
    RK_BEING_EXECUTION = 10,  /**< 请求正在进行中    */
} RKCloudErrorCode;

/*! 
 * @enum
 * @brief RKCloudBase错误码（1001-2000）
 *
 */
typedef enum : NSInteger {
    BASE_APP_KEY_AUTH_FAIL = 1001, /**< 客户端key值认证失败，原因可能为：key不存在、key验证失败、应用或者包名错误 */
    BASE_CLOUD_KEY_AUTH_FAIL = 1002, /**< 服务器端key值认证失败，原因可能为：key不存在、key验证失败、应用或者包名错误 */
    BASE_ACCOUNT_PW_ERROR = 1003, /**< 初始化失败：账号或密码不匹配 */
    BASE_ACCOUNT_BANNED = 1004, /**< 初始化失败：账号被禁 */
} RKCloudBaseErrorCode;

/*!
 * @enum
 * @brief 网络状态枚举定义
 *
 */
typedef enum : NSUInteger {
    NETWORK_NOT = 0, /**< 无网络    */
    NETWORK_WIFI = 1, /**< WiFi网络    */
    NETWORK_WWAN = 2, /**< Wan网络（数据蜂窝网络）    */
} RKNetworkStatus;

/*!
 *  @brief 通知用户下载所有群聊信息
 */
extern NSString *kRKCloudUpdateAllGroupInfoNotification; /**< 通知用户下载所有群聊信息    */
/*!
 *  @brief 通知即时通讯模块处理消息
 */
extern NSString *kRKCloudPushMessageChatNotification; /**< 通知即时通讯模块处理消息    */
/*!
 *  @brief 通知音视频通话模块处理消息
 */
extern NSString *kRKCloudPushMessageAudioVideoNotification; /**< 通知音视频通话模块处理消息    */
/*!
 *  @brief 通知多人语音模块处理消息
 */
extern NSString *kRKCloudPushMessageMeetingNotification; /**< 通知多人语音模块处理消息    */
/*!
 *  @brief 程序进入前台的通知
 */
extern NSString *kRKCloudPushMessageEnterForegroundNotification; /**< 程序进入前台的通知    */


#pragma mark -
#pragma mark Global Interface

/*!
 *  RK Cloud Debug Log Output Console Function
 *
 *  @param format 日志格式输出
 *  @param ...    日志输出的参数
 */
FOUNDATION_EXPORT void RKCloudDebugLog(NSString *format, ...);


#pragma mark -
#pragma mark RKCloudBaseDelegate

/*!
 *  @protocol
 *  @abstract 云视互动Base SDK代理类。
 */
@protocol RKCloudBaseDelegate <NSObject>

/*!
 * @brief 代理方法: 账号异常的回调处理
 *
 * @param errorCode 错误码 1：重复登录，2：账号被禁
 */
- (void)didRKCloudFatalException:(int)errorCode;

/*!
 * @brief 代理方法: 云视互动收到应用推送的消息的回调接口
 *
 * @param arrayCustomMessages 返回信息体如: [{"content":"***","sender":"***"},{"content":"***","sender":"***"},...,{"content":"***","sender":"***"}]，其中sender表示消息发送者；content表示应用推送的消息内容
 */
- (void)didReceivedCustomUserMsg:(NSArray *)arrayCustomMessages;

@optional

/**
 * @brief 代理方法: LPS的状态改变的回调接口
 *
 * @param status 状态 1：在线；2：离线
 * @return
 */
- (void)didRKCloudLPSChangeStatus:(int)status;

@end


#pragma mark -
#pragma mark RKCloudBase Interface

/*!
 *  @class
 *  @abstract 云视互动Base SDK基础类，负责Http请求管理，消息管理，DB管理，推送管理，用户资料管理.
 */
@interface RKCloudBase : NSObject

#pragma mark -
#pragma mark RKCloud Base Info Interface

/*!
 * @brief 获取云视互动SDK版本号
 *
 * @return NSString 如：1.0.1
 */
+ (NSString *)sdkVersion;

/*!
 * @brief 获取云视互动Debug Mode
 *
 * @return BOOL 云视互动Debug Mode
 */
+ (BOOL)getDebugMode;

/*!
 * @brief 设置SDK的Debug模式
 *
 * @param bEnabled 是否打开云视互动Debug Mode
 */
+ (void)setDebugMode:(BOOL)bEnabled;

/*!
 *  检查当前网络的状态
 *
 *  @return RKNetworkStatus枚举值
 */
+ (RKNetworkStatus)checkInternetReachabilityStatus;

/*!
 * @brief 设置发送者在对方通知栏中显示的名字
 *
 * @attention 发送消息或者拨打语音电话时，对方通知栏上显示的名字
 *
 * @param displayName 显示的名字
 */
+ (void)setNotificationDisplayName:(NSString *)displayName;


/*!
 * @brief 获取发送者在对方通知栏中显示的名字
 *
 * @return NSString 发送者在对方通知栏中显示的名字
 */
+ (NSString *)notificationDisplayName;

#pragma mark -
#pragma mark RKCloudBase User Profile Interface

/*!
 * @brief 获取当前登录用户的用户名
 *
 * @return NSString 云视互动用户名
 */
+ (NSString *)getUserName;

/*!
 * @brief 获取当前登录用户的密码
 *
 * @return NSString 云视互动用户密码
 */
+ (NSString *)getPwd;

/*!
 * @brief 获取当前登录用户的UID，框架层使用，用户不需要关心此方法
 *
 * @return NSString 云视互动用户的UID
 */
+ (NSString *)getUid;

/*!
 * @brief 获取云视互动API Server:Port
 *
 * @return NSString 云视互动API Server:Port
 */
+ (NSString *)getAPIHost;


#pragma mark -
#pragma mark RKCloudBase Config Interface

/*!
 * @brief 获取创建群的最大个数
 *
 * @return int 创建群的最大个数或错误码
 */
+ (int)getMaxNumOfCreateGroups;

/*!
 * @brief 获取群内成员的最大人数
 *
 * @return int 群内成员的最大人数或错误码
 */
+ (int)getMaxNumOfGroupUsers;

/*!
 * @brief 获取文本内容的最大长度，单位：字符
 *
 * @return int 文本内容的最大长度或错误码
 */
+ (int)getTextMaxLength;

/*!
 * @brief 获取媒体文件的最大尺寸，单位：字节
 *
 * @return long 媒体文件的最大尺寸或错误码
 */
+ (long)getMediaMmsMaxSize;

/*!
 * @brief 获取录音文件的最大播放时长，单位：秒
 *
 * @return long 录音文件的最大播放时长或错误码
 */
+ (int)getAudioMaxDuration;

/*!
 * @brief 获取视频的最大播放时长，单位：秒
 *
 * @return long 视频的最大播放时长或错误码
 */
+ (int)getVideoMaxDuration;

/*!
 * @brief 获取撤销消息的超时时间，单位：秒
 *
 * @return long 撤销消息的超时时间或错误码
 */
+ (int)getRevokeMessageTimeout;

/*!
 * @brief 获取是否支持获取历史消息
 *
 * @return bool 支持为YES，否则为NO
 */
+ (BOOL)isSupportHistoryMessage;

#pragma mark -
#pragma mark RKCloudBase Register Interface

/*!
 *  @brief 注册AppKey和代理
 *  @attention RKCloudBase库调用的第一个接口，在application:didFinishLaunchingWithOptions:中进行注册云视互动SDK
 *
 *  @param yourAppKey 云视互动AppKey,注册云视互动服务获取
 *  @param delegate   Base SDK的代理指针
 *  @param cerName    当前使用的APNs证书的名称（请到云视互动开发者中心创建应用后获取）
 *
 *  @return YES=SUCCESS, NO=FAIL
 */
+ (BOOL)registerSDKWithAppKey:(NSString *)yourAppKey
                 withDelegate:(id)delegate
         withAPNsCertificates:(NSString *)cerName;

/*!
 *  @brief 设置启动RKCloud的host地址，如果不设置使用RKCloud默认地址
 *  @attention 如果设置需要在registerSDKWithAppKey接口调用之后调用此接口
 *
 *  @param host 服务器地址
 *  @param port 端口号
 */
+ (void)setRootHost:(NSString *)host withPort:(int)port;


#pragma mark -
#pragma mark RKCloudBase Initialization/UnInit Interface

/*!
 * @brief 云视互动框架初始化方法，必须调用此方法后，才可以进行业务层的处理。
 * @attention 在登录成功后或进程启动后，进行初始化云视互动服务。
 *
 * @param userName     云视互动用户名
 * @param password     云视互动用户密码
 * @param onSuccess    初始化云视互动成功
 * @param onFailed     初始化云视互动失败，返回错误信息
 *
 * @return void
 */
+ (void)init:(NSString *)userName
    password:(NSString *)password
   onSuccess:(void (^)())onSuccess
    onFailed:(void (^)(int errorCode))onFailed;

/*!
 * @brief 当用户的APP不在使用SDK时，需要调用此方法，清理当前已经初始化的SDK。
 *
 * @return void
 */
+ (void)unInit;

/*!
 * @brief SDK是否初始化成功
 *
 * @return BOOL YES=SUCCESS, NO=FAIL
 */
+ (BOOL)isSDKInitSuccess;

/*!
 * @brief 是否App进入后台
 *
 *  @return YES=进入后台模式，NO=App在前台模式
 */
+ (BOOL)isEnterBackground;

@end

