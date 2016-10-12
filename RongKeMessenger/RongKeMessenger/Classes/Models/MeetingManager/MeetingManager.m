//
//  MeetingManager.m
//  RongKeMessenger
//
//  Created by WangGray on 15/8/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "MeetingManager.h"
#import "AppDelegate.h"

@interface MeetingManager ()

@property (nonatomic, weak) MeetingRoomViewController *meetingRoomViewController; // 多人会议视图

@property (nonatomic, strong) NSMutableDictionary *meetingUserAccountToUserObjectDict; // 会议与会者帐号（Account）对应的与会者对象（RKCloudMeetingUserObject）字典

@property (nonatomic, assign) JoinMeetingType joinMeetingType; // 加入会议模式

@end

@implementation MeetingManager

- (id)init {
    self = [super init];
    if (self) {
        self.meetingUserAccountToUserObjectDict = [NSMutableDictionary dictionary];
        self.joinMeetingType = JoinMeetingNoneType;
        self.isFirstInMeeting = YES;
        self.callSecondsTimeInterval = 0;
    }
    return self;
}


#pragma mark - Interface

/**
 *  获取当前用户加入会议时的时间戳
 *
 *  @return 用户与会时间戳
 */
- (long)getUserInMeetingTimeInterval
{
    // 加入会议 直接赋值
    if (self.callSecondsTimeInterval == 0)
    {
        self.callSecondsTimeInterval = [ToolsFunction getCurrentSystemDateSecond];
    }
        
    return self.callSecondsTimeInterval;
}

/**
 *  自己是否在会议中
 *
 *  @return YES:自己在会议中，NO:自己不再会议中
 */
- (BOOL)isOwnInMeeting
{
    // 如果当前会议进行中则认为自己在会议中
    if (self.joinMeetingType != JoinMeetingNoneType) {
        return YES;
    }
    return NO;
}

/**
 *  获取所有的会议参与者信息
 *
 *  @return 参与者帐号Account对应的RKCloudMeetingUserObject对象指针
 */
- (NSDictionary *)getAllMeetingUserObjectInfoDictionary
{
    return self.meetingUserAccountToUserObjectDict;
}

/**
 *  创建多人语音会议
 *
 *  @param meetingId    会议Id
 *  @param membersArray 会议成员
 *  @param viewController 跳转页面的上一个页面
 */
- (void)createMeetingRoomByMeetingId:(NSString *)meetingId
                   andMeetingMembers:(NSArray *)membersArray
                   andViewController:(UIViewController *)viewController
{
    NSLog(@"MEETING-MANAGER:: createMeetingRoom");
    // 进行参数判断
    if (meetingId == nil || [membersArray count] == 0 || viewController == nil) {
        return;
    }
    
    // 直接呼叫会议室
    [RKCloudMeeting dial:meetingId
               onSuccess:^(){
                   
                   self.sessionId = self.currentSessionObject.sessionID;

                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       NSLog(@"MEETING-MANAGER: createMeetingRoomByMeetingId - dail success");
                       
                       // 邀请成员加入多人语音会议
                       [self inviteMeetingMembers:membersArray forMeetingID:meetingId];
                       
                       // 重置计时
                       self.callSecondsTimeInterval = 0;
                       
                       self.joinMeetingType = JoinMeetingCreateType;
                       // 弹出会议页面
                       [self pushMeetingRoomViewControllerInViewController:viewController];
                       
                       // 发起多人语音
                       LocalMessage *callLocalMessage = [LocalMessage buildTipMsg:self.currentSessionObject.sessionID withMsgContent:NSLocalizedString(@"PROMPT_CREATE_MEETING_MYSELF", "我发起了多人语音") forSenderName:[AppDelegate appDelegate].userProfilesInfo.userAccount];
                       [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_GROUP_TYPE];
                   });
               }
                onFailed:^(int errorCode) {
                    NSLog(@"MEETING-MANAGER: fail dail Reason: %d", errorCode);
                }];
}

/**
 *  加入多人语音会议
 *
 *  @param meetingId 会议Id
 *  @param viewController 跳转页面的上一个页面
 */
- (void)joinMeetingRoomByMeetingId:(NSString *)meetingId
                 andViewController:(UIViewController *)viewController
{
    if ([AppDelegate appDelegate].meetingManager.sessionId != nil && [self.currentSessionObject.sessionID isEqualToString:[AppDelegate appDelegate].meetingManager.sessionId] == NO)
    {
        [UIAlertView showAutoHidePromptView:@"发起多人语音失败：当前有正在进行的多人语音" background:nil showTime:1.5];
        
        return;
    }
    
    NSLog(@"MEETING-MANAGER: joinMeetingRoomByMeetingId: meetingId = %@", meetingId);
    // 进行参数判断
    if (meetingId == nil || viewController == nil) {
        return;
    }
    
    // 加入到多人会议中
    int joinResult = [RKCloudMeeting joinMeeting:meetingId];
    // 0 加入成功 9 已在会议中
    if (joinResult == 0 || joinResult == 9) {
        NSLog(@"MEETING-MANAGER: join meeting success");
        self.sessionId = self.currentSessionObject.sessionID;
        
        // 邀请进入类型
        self.joinMeetingType = JoinMeetingInviteType;
        // 弹出会议页面
        [self pushMeetingRoomViewControllerInViewController:viewController];
        
        // 发起多人语音
        LocalMessage *callLocalMessage = [LocalMessage buildTipMsg:self.currentSessionObject.sessionID withMsgContent:nil forSenderName:[AppDelegate appDelegate].userProfilesInfo.userAccount];
        callLocalMessage.textContent = @"PROMPT_JOIN_MEETING_MYSELF";
        [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_GROUP_TYPE];
    }
    else {
        NSLog(@"MEETING-MANAGER: join meeting fail Reason: %d", joinResult);
    }
}

/**
 *  弹出会议页面
 *
 *  @param viewController 在这个Controller上进行Push
 */
- (void)pushMeetingRoomViewControllerInViewController:(UIViewController *)viewController
{
    if (viewController == nil) {
        return;
    }
    
    // 赋值 指针(有人邀请 直接弹出会议室界面)
    MeetingRoomViewController *vwcMeetingRoom = [[MeetingRoomViewController alloc] initWithNibName:@"MeetingRoomViewController" bundle:nil];
    self.meetingRoomViewController = vwcMeetingRoom;
    
    // 加入会议模式
    switch (self.joinMeetingType) {
        case JoinMeetingCreateType:
            self.meetingRoomViewController.isCreator = YES;
            break;
            
        case JoinMeetingInviteType:
            self.meetingRoomViewController.isCreator = NO;
            break;
            
        default:
            break;
    }
    
    [viewController.navigationController pushViewController:self.meetingRoomViewController animated:YES];
    
    // 更新参与者状态信息
    [self.meetingRoomViewController updateUserMeetingInfo:self.meetingUserAccountToUserObjectDict];
}


#pragma mark - 内部调用方法

/**
 *  邀请成员加入多人语音会议
 *
 *  @param meetingMembersArray 待邀请人员
 */
- (void)inviteMeetingMembers:(NSArray *)membersAccountArray forMeetingID:(NSString *)meetingId
{
    NSLog(@"MEETING-MANAGER: inviteMeetingMembers");
    // 进行参数判断
    if (meetingId == nil || [membersAccountArray count] == 0) {
        return;
    }
    
    // 邀请其它用户加入会议
    [RKCloudMeeting inviteAttendees:membersAccountArray
                  withExtensionInfo:meetingId
                          onSuccess:^{
                              
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  NSLog(@"MEETING-MANAGER: invite members sucsess");
                              });
                          }
                           onFailed:^(int errorCode) {
                               
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   
                                   NSLog(@"MEETING-MANAGER: invite members fail  Reason: %d", errorCode);
                                   
                               });
                           }];
}


#pragma mark - Save Local Message

// 插入消息记录中保存多人语音邀请记录
- (void)saveMeetingRecordToChatLocalMessage:(RKCloudMeetingInvitedInfoObject *)meetingInvitedInfoObject
{
    if (meetingInvitedInfoObject == nil) {
        return;
    }
    
    // 被叫端-接送端的消息
    LocalMessage *callLocalMessage = [LocalMessage buildReceivedMsg:meetingInvitedInfoObject.extensionInfo withMsgContent:meetingInvitedInfoObject.meetingID forSenderName:meetingInvitedInfoObject.invitorAccount];
    callLocalMessage.sendTime = meetingInvitedInfoObject.createTime;
    
    // 保存扩展信息: 多人语音
    callLocalMessage.extension = NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音");
    callLocalMessage.messageStatus = MESSAGE_STATE_RECEIVE_RECEIVED;
    
    // 向终端插入音视频通话记录消息
    [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_GROUP_TYPE];
    
    NSLog(@"MEETING-MANAGER: saveMeetingRecordToChatLocalMessage: peerAccount = %@, extension = %@", meetingInvitedInfoObject.invitorAccount, meetingInvitedInfoObject.extensionInfo);
}


#pragma mark - RKCloudMeetingDelegate

// 收到邀请加入多人会议的接口定义（RKCloudMeetingInviteCallBack）
/**
 *  收到邀请加入多人语音的回调接口
 *
 *  @param arrayMeetingInvitedInfo RKCloudMeetingInvitedInfoObject对象数组
 */
- (void)onInviteToMeeting:(NSArray *)arrayMeetingInvitedInfo
{
    NSLog(@"MEETING-DELEGATE: onInviteToMeeting: arrayMeetingInvitedInfo = %@", arrayMeetingInvitedInfo);
    
    if ([arrayMeetingInvitedInfo count] == 0) {
        return;
    }
    
    // 遍历获取所有会议对象，并保存会议邀请记录到群聊会话中
    for (RKCloudMeetingInvitedInfoObject *meetingInvitedInfoObject in arrayMeetingInvitedInfo)
    {
        // 插入消息记录中保存多人语音邀请记录
        [self saveMeetingRecordToChatLocalMessage:meetingInvitedInfoObject];
    }
}

// 定义多人语音会议状态、成员状态变更的接口（RKCloudMeetingStateCallBack）
/**
 *  会议成员状态有变更的回调
 *
 *  @param account 与会者成员帐号
 *  @param state   与会者成员状态（RKCloudMeetingConfMemberState枚举值）
 */
- (void)onConfMemberStateChangeCallBack:(NSString *)account
                        withMemberState:(RKCloudMeetingUserState)memberState
{
    NSLog(@"MEETING-DELEGATE: onConfMemberStateChangeCallBack: account = %@, memberState = %lu", account, (unsigned long)memberState);
    
    RKCloudMeetingUserObject *meetingUserObject = [self.meetingUserAccountToUserObjectDict objectForKey:account];
    if (meetingUserObject == nil) {
        meetingUserObject = [[RKCloudMeetingUserObject alloc] init];
        meetingUserObject.attendeeAccount = account;
        meetingUserObject.meetingConfMemberState = memberState;
        
        [self.meetingUserAccountToUserObjectDict setValue:meetingUserObject forKey:account];
    }
    else {
        meetingUserObject.meetingConfMemberState = memberState;
    }
    
    // 如果与会者离开则移除此帐号
    if (memberState == MEETING_USER_STATE_OUT) {
        [self.meetingUserAccountToUserObjectDict removeObjectForKey:account];
    }
    
    // 更新参与者状态信息
    if (self.meetingRoomViewController) {
        [self.meetingRoomViewController updateUserMeetingInfo:self.meetingUserAccountToUserObjectDict];
    }
}

/**
 *  会议信息有同步，包括会议本身的信息和会议参与者信息
 */
- (void)onConfInfoSYNCallBack
{
    NSLog(@"MEETING-DELEGATE: onConfInfoSYNCallBack");
    
    // 加入会议成功 获取会议成员
    NSDictionary *dicMembersInfo = [RKCloudMeeting getAttendeeInfos];
    if ([dicMembersInfo count] > 0)
    {
        [self.meetingUserAccountToUserObjectDict removeAllObjects];
        [self.meetingUserAccountToUserObjectDict setDictionary:dicMembersInfo];
        
        // 更新参与者状态信息
        if (self.meetingRoomViewController) {
            [self.meetingRoomViewController updateUserMeetingInfo:self.meetingUserAccountToUserObjectDict];
        }
    }
}

/**
 *  当前用户通话状态有变更的回调
 *
 *  @param callState 通话状态（RKCloudMeetingCallState枚举值）
 */
- (void)onCallStateCallBack:(RKCloudMeetingCallState)callState withReason:(NSInteger)reason
{
    NSLog(@"MEETING-DELEGATE: onCallStateCallBack: callState = %lu reason = %lu", (unsigned long)callState, (long)reason);
    
    switch (callState) {
        case MEETING_CALL_ANSWER: // 自己与会议电话已经接通
        {
            // 加入会议成功 开始计时
            self.callSecondsTimeInterval = [self getUserInMeetingTimeInterval];
            [self.meetingRoomViewController startDetectTalkingTime];
            
            // 加入会议成功 获取会议成员
            NSDictionary *dicMembersInfo = [RKCloudMeeting getAttendeeInfos];
            if ([dicMembersInfo count] > 0)
            {
                [self.meetingUserAccountToUserObjectDict removeAllObjects];
                [self.meetingUserAccountToUserObjectDict setDictionary:dicMembersInfo];
                
                // 更新参与者状态信息
                if (self.meetingRoomViewController) {
                    [self.meetingRoomViewController updateUserMeetingInfo:self.meetingUserAccountToUserObjectDict];
                }
            }
        }
            break;
            
        case MEETING_CALL_HANGUP: // 自己与会议电话断开
        {
            // 与会议室的电话已经挂断，清除与会议相关的数据信息
            self.sessionId = nil;
            self.callSecondsTimeInterval = 0;
            [self.meetingUserAccountToUserObjectDict removeAllObjects];
            
            // 停止计时
            [self.meetingRoomViewController stopDetectTalkingTime];
            
            // 是否第一次加入会议
            self.isFirstInMeeting = YES;
            
            // 挂断
            [self exitMeetingRoomWithReason:reason];
        }
            break;
            
        default:
            break;
    }
}

/**
 *  主动挂断会议
 *
 *  @return YES: 挂断成功 NO: 挂断失败
 */
- (BOOL)asyncHandUpMeeting
{
    // __block: 在 block 中用的变量值是被复制过来的，所以对于变量本身的修改并不会影响这个变量的真实值。而当我们用 __block 标记的时候，表示在 block 中的修改对于 block 外也是有效地,此处 GCD 中修改的 isHangUp 外部需要使用 采用 __block BOOL isHangUp
    __block BOOL isHangUp = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        // 挂断多人语音通话
        int nHangupResult = [RKCloudMeeting hangup];
        if (nHangupResult == RK_SUCCESS) {
            NSLog(@"MEETINGROOM： handup success");
            isHangUp = YES;
        }
        else {
            isHangUp = NO;
            NSLog(@"MEETINGROOM： handup fail Reason: %d", nHangupResult);
        }
    });
    
    return isHangUp;
}

/**
 *  被动挂断会议
 */
- (void)exitMeetingRoomWithReason:(NSInteger)reason
{
    if (![self isOwnInMeeting])
    {
        return;
    }
    
    // 重置会议状态
    self.joinMeetingType = JoinMeetingNoneType;
    [RKCloudMeeting hangup];

    if ([AppDelegate appDelegate].applicationRunState == APPSTATE_RESET_USER)
    {
        // 挂断 会议页面置空
        self.meetingRoomViewController = nil;
    } else {
        // 挂断
        [self.meetingRoomViewController.navigationController popViewControllerAnimated:YES];
        [self.meetingRoomViewController quitMeetingWithReason:reason];
    }
}

@end
