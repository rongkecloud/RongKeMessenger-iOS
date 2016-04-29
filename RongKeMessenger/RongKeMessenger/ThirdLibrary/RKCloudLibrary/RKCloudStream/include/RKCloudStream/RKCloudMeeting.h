//
//  RKCloudMeeting.h
//  RKCloudMeeting
//
//  Created by WangGray on 15/7/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

/*!
 @header RKCloudMeeting.h
 @abstract 云视互动Meeting SDK头文件
 @author 西安融科通信技术有限公司 (www.rongkecloud.com)
 @version 2.2.5 2016/02/22 Update
 */

#import <Foundation/Foundation.h>

/*! 
 *  @enum
 *  @brief 多人语音通话状态码值定义
 *
 */
typedef enum : NSUInteger {
    MEETING_CALL_IDLE = 0, /**< 空闲状态    */
    MEETING_CALL_PREPARING = 1, /**< 呼叫准备中    */
    MEETING_CALL_RINGBACK = 2, /**< 呼叫中，回铃声状态(主叫方呼通后被叫方接通前的状态)        */
    MEETING_CALL_ANSWER = 3, /**< 已应答    */
    MEETING_CALL_HANGUP = 4, /**< 通话挂断/结束    */
    MEETING_CALL_INVITING = 5, /**< 被邀请加入中    */
} RKCloudMeetingCallState;

/*! 
 *  @enum
 *  @brief 多人语音会议室状态码值定义 (暂未实现)
 *
 */
typedef enum : NSUInteger {
    MEETING_STATE_INIT = 0, /**< 0：会议初始化 */
    MEETING_STATE_START = 1, /**< 1：会议开始 */
    MEETING_STATE_END = 2, /**< 2：会议结束 */
} RKCloudMeetingConfState;

/*! 
 *  @enum
 *  @brief 多人语音通话中会议参与人员状态发生变化的码值定义
 *
 */
typedef enum : NSUInteger {
    MEETING_USER_STATE_IN = 1, /**< 参与者进入    */
    MEETING_USER_STATE_OUT = 2, /**< 参与者退出    */
    MEETING_USER_STATE_UNMUTE = 3, /**< 参与者为发言状态    */
    MEETING_USER_STATE_MUTE = 4, /**< 参与者为静音状态    */
} RKCloudMeetingUserState;

/*! 
 *  @enum
 *  @brief RKCloudMeeting错误码（4001-5000）
 * 公共SDK错误码参考：RKCloudErrorCode
 * 基础SDK错误码参考：RKCloudBaseErrorCode
 */
typedef enum : NSInteger {
    MEETING_CONF_NO_REASON = 4000,   /**< 无原因  */
    MEETING_CONF_NOT_EXIST = 4001,   /**< 加入或邀请进入的会议室不存在  */
    MEETING_CONF_CANNOT_INVITE_OWN = 4002,   /**< 不能邀请自己进入会议室  */
    MEETING_CONF_DIAL_TIMEOUT = 4003,   /**< 呼叫会议室超时  */
} RKCloudMeetingErrorCode;


/*!
 *  @class
 *  @brief 会议信息实体类定义
 */
@interface RKCloudMeetingInfo : NSObject

@property (nonatomic, assign) RKCloudMeetingCallState currentMeetingCallState; /**< 当前与会者与会议的通话状态，RKCloudMeetingCallState枚举值  */
@property (nonatomic, assign) RKCloudMeetingConfState currentMeetingConfState; /**< 当前会议的状态，currentMeetingConfState枚举值  */
@property (nonatomic, strong) NSString *meetingExtension; /**< 会议扩展信息  */

@end

/*!
 *  @class
 *  @brief 收到邀请加入多人语音时包括含相关信息的实体类定义
 */
@interface RKCloudMeetingInvitedInfoObject : NSObject

@property (nonatomic, strong) NSString *meetingID; // 会议ID
@property (nonatomic, strong) NSString *invitorAccount; // 邀请者帐号
@property (nonatomic, strong) NSString *extensionInfo; // 会议扩展信息
@property (nonatomic, assign) long createTime; // 会议创建时间，秒级时间戳
@end

/*!
 *  @class
 *  @brief 多人语音参与者信息的实体类定义
 */
@interface RKCloudMeetingUserObject : NSObject

@property (nonatomic, strong) NSString *attendeeAccount; // 参与者的帐号
@property (nonatomic) RKCloudMeetingUserState meetingConfMemberState; // 参与人员状态
@end


#pragma mark - RKCloudMeetingDelegate

/*!
 *  @protocol
 *  @brief RKCloudMeeting代理
 */
@protocol RKCloudMeetingDelegate <NSObject>

#pragma mark - 收到邀请加入多人会议的接口定义（RKCloudMeetingInviteCallBack）

/*!
 *  @brief 收到邀请加入多人语音的回调接口
 *
 *  @param arrayMeetingInvitedInfo RKCloudMeetingInvitedInfoObject对象数组
 */
- (void)onInviteToMeeting:(NSArray *)arrayMeetingInvitedInfo;


#pragma mark - 定义多人语音会议状态、成员状态变更的接口（RKCloudMeetingStateCallBack）

/*!
 *  @brief 会议成员状态有变更的回调
 *
 *  @param account      与会者成员帐号
 *  @param memberState  与会者成员状态（RKCloudMeetingConfMemberState枚举值）
 */
- (void)onConfMemberStateChangeCallBack:(NSString *)account
                        withMemberState:(RKCloudMeetingUserState)memberState;

/*!
 *  @brief 当前用户通话状态有变更的回调
 *
 *  @param callState 通话状态（RKCloudMeetingCallState枚举值）
 */
- (void)onCallStateCallBack:(RKCloudMeetingCallState)callState withReason:(NSInteger)reason;

/*!
 *  @brief 会议信息有同步，包括会议本身的信息和会议参与者信息
 */
- (void)onConfInfoSYNCallBack;

@optional

/*!
 *  @brief 当前会议状态有变更的回调 (暂未实现)
 *
 *  @param confState 会议状态（RKCloudMeetingConfState枚举值）
 */
- (void)onConfStateCallBack:(RKCloudMeetingConfState)confState;

@end


#pragma mark - RKCloudMeeting Interface

/*!
 *  @class
 *  @brief RKCloudMeeting接口
 */
@interface RKCloudMeeting : NSObject

#pragma mark - Meeting Init/UnInit

/*!
 *  @brief 初始化多人语音功能，请确保Base SDK已经初始化成功，防止后面工作异常
 *
 *  @param delegate 代理指针
 */
+ (void)init:(id)delegate;

/*!
 *  @brief 取消多人语音的初化操作
 */
+ (void)unInit;


#pragma mark - Meeting Call Create/Join/Invite/Dial Interface

/*!
 *  @brief 直接呼叫会议室
 *
 *  @param meetingId 会议室的唯一标识
 *  @param onSuccess 成功的回调方法
 *  @param onFailed  失败的回调方法，errorCode错误码：int 发起多人语音的结果，参考RKCloudErrorCode和RKCloudMeetingErrorCode枚举值定义。
 */
+ (void)dial:(NSString *)meetingId
   onSuccess:(void (^)())onSuccess
    onFailed:(void (^)(int errorCode))onFailed;

/*!
 *  @brief 收到会议邀请后，加入到多人会议中
 *
 *  @param meetingId 会议室号码
 *
 *  @return int 发起多人语音的结果，参考RKCloudErrorCode和RKCloudMeetingErrorCode枚举值定义。
 */
+ (int)joinMeeting:(NSString *)meetingId;

/*!
 *  @brief 邀请其它用户加入会议
 *
 *  @param arrayAttendeesAccounts 与会者用户名列表
 *  @param ext                  用于业务上的扩展信息，用户可自定义
 *  @param onSuccess 成功的回调方法
 *  @param onFailed  失败的回调方法，errorCode错误码：int 发起多人语音的结果，参考RKCloudErrorCode和RKCloudMeetingErrorCode枚举值定义。
 */
+ (void)inviteAttendees:(NSArray *)arrayAttendeesAccounts
      withExtensionInfo:(NSString *)ext
              onSuccess:(void (^)())onSuccess
               onFailed:(void (^)(int errorCode))onFailed;


#pragma mark - Meeting Call Info Interface

/*!
 *  @brief 获取当前多人会议的参与者信息
 *
 *  @return NSDictionary参与者帐号Account对应的RKCloudMeetingUserObject对象的字典。
 */
+ (NSDictionary *)getAttendeeInfos;

/*!
 *  @brief 获取当前多人会议的信息对象
 *
 *  @return 多人语音对象RKCloudMeetingInfo值，如果当前不存在会议则返回为nil。
 */
+ (RKCloudMeetingInfo *)getMeetingInfo;


#pragma mark - Meeting Call Hangup/Mute Interface

/*!
 *  @brief 挂断多人语音通话
 *
 *  @return int 挂断的结果，参考RKCloudErrorCode和RKCloudMeetingErrorCode枚举值定义。
 */
+ (int)hangup;

/*!
 *  @brief 静音或者取消静音的操作
 *
 *  @param isMute YES:静音操作 NO:取消静音操作
 *
 *  @return int 静音的结果，参考RKCloudErrorCode和RKCloudMeetingErrorCode枚举值定义。
 */
+ (int)mute:(BOOL)isMute;

@end
