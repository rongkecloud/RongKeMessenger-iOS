//
//  RKCloudAV.h
//  RKCloudAV
//
//  Created by WangGray on 15/7/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

/*!
 @header RKCloudAV.h
 @abstract 云视互动Audio Video SDK头文件
 @author 西安融科通信技术有限公司 (www.rongkecloud.com)
 @version 2.2.5 2016/02/22 Update
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 *  @enum
 *  @brief 视频通话、语音通话状态枚举值定义
 *
 */
typedef enum : NSUInteger {
    AV_CALL_STATE_IDLE = 0, /**< 空闲状态    */
    AV_CALL_STATE_PREPARING = 1, /**< 呼叫准备中    */
    AV_CALL_STATE_RINGBACK = 2, /**< 回铃声状态(主叫方呼通后被叫方接通前的状态)    */
    AV_CALL_STATE_RINGIN = 3, /**< 新来电(被叫方收到新来电后在电话接通前的状态)    */
    AV_CALL_STATE_ANSWER = 4, /**< 通话已接通    */
    AV_CALL_STATE_HANGUP = 5, /**< 通话挂断    */
    
    AV_CALL_STATE_VIDEO_INIT = 11, /**< 通话建立后的动作(即通话状态为CALL_ANSWER时)：视频初始化成功    */
    AV_CALL_STATE_VIDEO_START = 12, /**< 通话建立后的动作(即通话状态为CALL_ANSWER时)：切换为视频通话    */
    AV_CALL_STATE_VIDEO_STOP = 13, /**< 通话建立后的动作(即通话状态为CALL_ANSWER时)：切换为语音通话    */
} RKCloudAVCallState;

/*!
 *  @enum
 *  @brief 通话类型枚举值定义
 *
 */
typedef enum : NSUInteger {
    AV_MISSED_CALL_TYPE = 1, /**< 未接来电类型    */
    AV_OUTGOING_CALL_TYPE = 2, /**< 外拨电话类型    */
    AV_INCOMING_CALL_TYPE = 3, /**< 呼入电话类型    */
} RKCloudAVCallType;

/*!
 *  @enum
 *  @brief 摄像头的ID枚举值定义
 *
 */
typedef enum : NSInteger {
    CAMERA_REAR = 0, /**< 后置摄像头    */
    CAMERA_FRONT = 1, /**< 前置摄像头    */
} RKAVCameraDevice;

/*!
 *  @enum
 *  @brief 视频质量的ID枚举值定义
 *
 */
typedef enum : NSInteger {
    VIDEO_QUALITY_LOW = 0, /**< 质量低 适合蜂窝移动网络传输192*144  */
    VIDEO_QUALITY_MEDIUM = 1, /**< 质量中 较清晰480P--640*480   */
    VIDEO_QUALITY_HIGH = 2, /**< 质量高 高清720P--1280*720   */
} RKAVVideoQuality;


// 视频设置的Key字段枚举值
typedef enum : NSInteger
{
    RKAVVideoResolutionKey = 1, // 设置分辨率KEY
    RKAVVideoBitrateKey = 2, // 设置码率KEY
    RKAVVideoFPSKey = 3, // 设置帧率KEY
} RKAVVideoOptionsKey;

// 视频分辨率支持枚举值
typedef enum : NSInteger
{
    RKAVResolution_352 = 0, // "352 x 288"(默认)
    RKAVResolution_640 = 1, // "640 x 480"
    RKAVResolution_1280 = 2, // "1280 x 720"
} RKAVVideoResolutionValue;

// 视频码率支持枚举值
typedef enum : NSInteger
{
    RKAVBitrate_60 = 1, // "60kbps（默认）"
    RKAVBitrate_80 = 2, // "80kbps"
    RKAVBitrate_100 = 3, // "100kbps"
    RKAVBitrate_150 = 4, // "150kbps"
    RKAVBitrate_200 = 5, // "200kbps"
    RKAVBitrate_300 = 6, // "300kbps"
    RKAVBitrate_500 = 7, // "500kbps"
    RKAVBitrate_800 = 8, // "800kbps"
    RKAVBitrate_1000 = 9, // "1Mbps"
    RKAVBitrate_1500 = 10, // "1.5Mbps"
    RKAVBitrate_2000 = 11, // "2Mbps"
} RKAVVideoBitrateValue;

// 视频帧率支持枚举
typedef enum : NSInteger
{
    RKAVFPS_2 = 1, // "2 FPS"
    RKAVFPS_4 = 2, // "4 FPS"
    RKAVFPS_6 = 3, // "6 FPS"
    RKAVFPS_8 = 4, // "8 FPS"
    RKAVFPS_10 = 5, // "10FPS（默认）"
    RKAVFPS_15 = 6, // "15FPS"
    RKAVFPS_20 = 7, // "20FPS"
    RKAVFPS_25 = 8, // "25FPS"
} RKAVVideofpsValue;

/*!
 *  @enum
 *  @brief RKCloudAV错误码（3001-4000）
 *  公共SDK错误码参考：RKCloudErrorCode
 *  基础SDK错误码参考：RKCloudBaseErrorCode
 */
typedef enum : NSInteger {
    AV_NO_REASON = 3000, /**< 无原因    */
    AV_CANNOT_CALL_OWN = 3001, /**< 不能呼叫自己的错误码  */
    AV_CALLEE_UNLINE = 3003, /**< 被叫不在线    */
    AV_CALLEE_REJECT = 3004, /**< 被叫拒接    */
    AV_CALLEE_BUSY = 3005, /**< 被叫正在通话中    */
    AV_CALLEE_NO_ANSWER = 3006, /**< 被叫未接听，主要给主叫呼叫超时使用    */
    AV_CALLEE_ANSWER_TIMEOUT = 3007, /**< 被叫未接听应答超时，或者被叫接听后接听超时   */
    AV_CALLER_CANCEL = 3008, /**< 主叫取消通话    */
    AV_CALL_OTHER_FAIL = 3009, /**< 其它原因导致呼叫失败    */
    AV_CALLEE_OTHER_PLATFORM_ANSWER = 3010, /**< 同一个账号在其它平台接听电话    */

    AV_CALLING_NOT_EXIST = 3020, /**< 不存在当前正进行的通话  */
    AV_MICROPHONE_NOT_OPEN = 3021, /**< 麦克风权限未开启错误码  */
    AV_CAMERA_NOT_OPEN = 3022, /**< 摄像头权限未开启错误码  */
    
} RKCloudAVErrorCode;

/*!
 *  @class
 *  @brief 通话的信息对象实体类定义
 */
@interface RKCloudAVCallInfo : NSObject

@property (nonatomic, copy) NSString *peerAccount; // 字符串，对端的云视互动账号

@property (nonatomic, assign) BOOL isCaller; // BOOL，是否为主叫, YES:主叫 NO:被叫
@property (nonatomic, assign) BOOL isStartVideoCall; // BOOL，呼叫发起时是否为视频通话, YES:视频通话 NO:音频通话
@property (nonatomic, assign) BOOL isCurrVideoOpen; // BOOL，当前视频是否为打开状态, YES:视频开启 NO:视频关闭

@property (nonatomic, assign) RKCloudAVCallState callState; // 整型，通话状态

@property (nonatomic, assign) long callStartTime; // long整型，通话开始时间，单位：秒级时间戳
@property (nonatomic, assign) long callAnswerTime; // long整型，通话接通的开始时间，单位：秒级时间戳
@end

/*!
 *  @class
 *  @brief 通话记录的实体类定义
 */
@interface RKCloudAVCallLog : NSObject

@property (nonatomic, strong) NSString *peerAccount; /**< 获取对端在云视互动中的账号 */

@property (nonatomic) long callDuration; /**< 获取通话时长，单位：秒 */
@property (nonatomic) long callLogId; /**< 获取通话记录的ID值 */
@property (nonatomic) long callStartTime; /**< 获取通话开始时间，为秒级的时间戳 */

@property (nonatomic) RKCloudAVCallType callType; /**< 获取通话类型 */
@property (nonatomic) BOOL isVideoCall; /**< 是否为视频通话 */

@end


#pragma mark -
#pragma mark RKCloudAVDelegate

/*!
 *  @protocol
 *  @brief RKCloudAV代理
 */
@protocol RKCloudAVDelegate <NSObject>

#pragma mark - RKCloudAVNewCallCallBack

/*!
 *  @brief 有新电话到达的通知
 *
 *  @param callerAccount 主叫方在云视互动中的账号
 *  @param isVideo       是否为视频通话 YES:视频通话 NO:语音通话
 */
- (void)onNewCall:(NSString *)callerAccount withIsVideo:(BOOL)isVideo;

/*!
 *  @brief 有未接来电的通知
 *
 *  @param callerAccount 主叫方在云视互动中的账号
 *  @param isVideo       是否为视频通话 YES:视频通话 NO:语音通话
 *  @param callTime      通话开始时间，单位：毫秒级时间戳
 */
- (void)onMissedCall:(NSString *)callerAccount
         withIsVideo:(BOOL)isVideo
        withCallTime:(long)callTime;


#pragma mark - RKCloudAVStateCallBack

/*!
 *  @brief 通话状态发生变更的回调接口
 *
 *  @param state   通话状态对应的码值，请参考RKCloudAVCallState类文件中常量值定义
 *  @param reason  通话失败对应的错误码值，参见RKCloudAVErrorCode和RKCloudErrorCode类文件中常量值定义
 */
- (void)onStateCallBack:(RKCloudAVCallState)state withReason:(NSInteger)reason;

@end


#pragma mark - RKCloudAV Interface

/*!
 *  @class
 *  @brief 云视互动一对一音视频通话功能类，实现云视互动音视频通话功能。
 */
@interface RKCloudAV : NSObject

#pragma mark - Audio Video Call Init/UnInit

/*!
 *  @brief 初始化音视频互动操作，请确保Base SDK已经初始化成功，防止后面工作异常
 *
 *  @param delegate 代理指针
 */
+ (void)init:(id)delegate;

/*!
 *  @brief 取消音视频互动的初始化操作
 */
+ (void)unInit;


#pragma mark - Call Dial/Answer/Hangup/Mute Interface

/*!
 *  @brief 发起音频或视频通话
 *
 *  @param calleeAccount 被叫方在云视互动中的账号
 *  @param isVideoCall   是否为视频通话 YES:视频通话 NO:语音通话
 *
 *  @return int 呼出结果，参考RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)dial:(NSString *)calleeAccount withVideCall:(BOOL)isVideoCall;

/*!
 *  @brief 接听新来电
 *
 *  @return 返回错误码，具体参见RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)answer;

/*!
 *  @brief 挂断当前电话
 *
 *  @return 返回错误码，具体参见RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)hangup;

/*!
 *  @brief 静音或取消静音一个已接听的通话
 *
 *  @param mute YES:静音，NO:取消静音
 *
 *  @return 返回错误码，具体参见RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)mute:(BOOL)mute;

/*!
	*  @brief 设置强制Relay通话模式打开或关闭
	*
	*  @param bOpenForceRelay TRUE=打开，FALSE=关闭
	*/
+ (void)setForceRelayCallMode:(BOOL) bOpenForceRelay;


#pragma mark - Video Call Control Interface

/*!
	*  @brief 设置视频的选项参数，在调用dial之前设置
	*
	*  @param videoOptionsKey 枚举值，视频设置的选项KEY，参考RKAVVideoOptionsKey枚举值
	*  @param videoOptionsValue 枚举值，视频设置的选项值，参考RKAVVideoResolutionValue/RKAVVideoBitrateValue/RKAVVideoFPSValue枚举值
	*/
+ (void)setVideoOptions:(RKAVVideoOptionsKey)videoOptionsKey videoOptionsValue:(int)videoOptionsValue;


/*!
 *  @brief 设置视频的质量，在调用dial之前设置
 *
 *  @param videoQuality 整型，视频质量等级，参考RKAVVideoQuality枚举值，默认为VIDEO_QUALITY_MEDIUM-视频质量为中
 */
+ (void)setVideoQuality:(RKAVVideoQuality)videoQuality;

/*!
 *  @brief 设置音视频通话是横屏还是竖屏显示，并且请在调用setCamera()和initVideoInfo()方法之前调用
 *
 *  @param isPortrait 显示方式 YES:竖屏显示 NO:横屏显示
 */
+ (void)setOrientation:(BOOL)isPortrait;

/*!
 *  @brief 启动视频
 */
+ (void)startVideo;

/**
 *  @brief 停止视频
 */
+ (void)stopVideo;


#pragma mark - 媒体I/O接口

/*!
 *  @brief 设置当前视频通话所使用的摄像头
 *
 *  @param cameraId 整型，设备标识符，参考RKAVCameraDevice枚举值，默认为1-前置摄像头，例如：0 - 后置摄像头；1 - 前置摄像头
 *
 *  @return 整型－操作是否成功，参考RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)setCamera:(RKAVCameraDevice)cameraId;

/*!
 *  @brief 设置视频通话中用于显示视频的窗口对象。
 *
 *  @param displayRemote  UIView对象，用于显示远端视频的窗口对象。
 *  @param displayPreview UIView对象，用于显示近端视频的窗口对象。
 *
 *  @return 整型－操作是否成功或失败的错误码，具体参见RKCloudErrorCode和RKCloudAVErrorCode枚举值定义。
 */
+ (int)setVideoDisplay:(UIView *)displayRemote withLocalVideo:(UIView *)displayPreview;


#pragma mark - Call Info Interface

/*!
 *  @brief 获取当前通话的信息对象RKCloudAVCallInfo
 *
 *  @return 返回RKCloudAVCallInfo对象指针
 */
+ (RKCloudAVCallInfo *)getAVCallInfo;


#pragma mark - Call Config Interface

/*!
 *  @brief 设置来电话时的铃声路径(该铃声文件存放于工程的[NSBundle mainBundle]目录)
 *
 *  @param ringFilePath 铃声文件路径，如果内容为空表示取消设置
 *
 *  @return YES:设置成功 NO:设置失败，有可能是文件类型不正确
 */
+ (BOOL)setInCallRing:(NSString *)ringFilePath;

/*!
 *  @brief 获取来电话时的铃声路径(该铃声文件存放于工程的[NSBundle mainBundle]目录)
 *
 *  @return 来电话时的铃声文件路径字符串
 */
+ (NSString *)getInCallRing;

/*!
 *  @brief 设置外拨电话时的铃声路径(该铃声文件存放于工程的[NSBundle mainBundle]目录)
 *
 *  @param ringFilePath 铃声文件路径，如果内容为空表示取消设置
 *
 *  @return YES:设置成功 NO:设置失败，有可能是文件类型不正确
 */
+ (BOOL)setOutCallRing:(NSString *)ringFilePath;

/*!
 *  @brief 获取外拨电话时的铃声路径(该铃声文件存放于工程的[NSBundle mainBundle]目录)
 *
 *  @return 外拨电话时的铃声路径字符串
 */
+ (NSString *)getOutCallRing;


#pragma mark - Call Log Control Interface

/*!
 *  @brief 查询当前所有的通话记录，按通话时间倒序排列
 *
 *  @return RKCloudAVCallLog指针对象的数组
 */
+ (NSArray *)getAllCallLogs;

/*!
 *  @brief 清除所有通话记录
 *
 *  @return YES:成功，NO:失败
 */
+ (BOOL)delAllCallLog;

/*!
 *  @brief 删除与某个用户的所有通话记录
 *
 *  @param account 通话记录（RKCloudAVCallLog）中对端在云视互动中的账号。
 *
 *  @return YES:成功，NO:失败
 */
+ (BOOL)delCallLogByAccount:(NSString *)account;

/*!
 *  @brief 删除一条通话记录
 *
 *  @param callLogId 通话记录（RKCloudAVCallLog）中通话记录的callLogId值。
 *
 *  @return YES:成功，NO:失败
 */
+ (BOOL)delCallLogById:(long)callLogId;

@end
