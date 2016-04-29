//
//  MeetingManager.h
//  RongKeMessenger
//
//  Created by WangGray on 15/8/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MeetingRoomViewController.h"
#import "RKCloudMeeting.h"
#import "Definition.h"
#import "RKCloudChatBaseChat.h"
#import "ToolsFunction.h"

@interface MeetingManager : NSObject <RKCloudMeetingDelegate>

@property (nonatomic, strong) RKCloudChatBaseChat * currentSessionObject; // 当前的会话对象
@property (nonatomic, copy) NSString *sessionId; // 在多人语音会议的sessionId
@property (assign, nonatomic) long callSecondsTimeInterval; // 记录通话时开始时间的时间戳
@property (assign, nonatomic) BOOL isFirstInMeeting; // 判断自己是否首次进入会议

#pragma mark - Interface

/**
 *  获取当前用户加入会议时的时间戳
 *
 *  @return 用户与会时间戳
 */
- (long)getUserInMeetingTimeInterval;

/**
 *  自己是否在会议中
 *
 *  @return YES:自己在会议中，NO:自己不再会议中
 */
- (BOOL)isOwnInMeeting;

/**
 *  获取所有的会议参与者信息
 *
 *  @return 参与者帐号Account对应的RKCloudMeetingUserObject对象指针
 */
- (NSDictionary *)getAllMeetingUserObjectInfoDictionary;

/**
 *  创建多人语音会议
 *
 *  @param meetingId    会议Id
 *  @param membersArray 会议成员
 *  @param viewController 跳转页面的上一个页面
 */
- (void)createMeetingRoomByMeetingId:(NSString *)meetingId
                   andMeetingMembers:(NSArray *)membersArray
                   andViewController:(UIViewController *)viewController;

/**
 *  加入多人语音会议
 *
 *  @param meetingId 会议Id
 *  @param viewController 跳转页面的上一个页面
 */
- (void)joinMeetingRoomByMeetingId:(NSString *)meetingId
                 andViewController:(UIViewController *)viewController;

/**
 *  弹出会议页面
 *
 *  @param viewController 在这个Controller上进行Push
 */
- (void)pushMeetingRoomViewControllerInViewController:(UIViewController *)viewController;

/**
 *  主动挂断会议
 *
 *  @return YES: 挂断成功 NO: 挂断失败
 */
- (BOOL)asyncHandUpMeeting;

/**
 *  被动挂断会议
 *
 *  @param reason 挂断会议原因（用于Dial超时）
 */
- (void)exitMeetingRoomWithReason:(NSInteger)reason;

@end
