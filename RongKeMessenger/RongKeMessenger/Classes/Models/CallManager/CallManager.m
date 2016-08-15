//
//  CallManager.m
//  RongKeMessenger
//
//  Created by WangGray on 15/8/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "CallManager.h"
#import "RKNavigationController.h"
#import "AppDelegate.h"
#import "RKCloudUICallViewController.h"
#import "ToolsFunction.h"
#import "RKCloudChatMessageManager.h"
#import "UserProfilesInfo.h"

@interface CallManager ()

@property (nonatomic, strong) NSString *strCallRecordMsgContent; // 通话记录消息记录内容值
@end

@implementation CallManager

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Call Dial Interface

// 呼叫语音电话
- (int)dialAudioCall:(NSString *)calleeAccount
{
    if (calleeAccount == nil) {
        return RK_PARAMS_ERROR;
    }
    
    // 没有网络则提示没有连接
    if ([ToolsFunction checkInternetReachability] == NO)
    {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return RK_NOT_NETWORK;
    }
    
    // 开始呼叫被叫
    int nResult = [RKCloudAV dial:calleeAccount withVideCall:NO];
    if (nResult == RK_SUCCESS) {
        // 初始化通话页面
        RKCloudUICallViewController *vwcCall = [[RKCloudUICallViewController alloc] initWithNibName:@"RKCloudUICallViewController" bundle:nil];
        vwcCall.peerAccount = calleeAccount;
        vwcCall.isVideoCall = NO;
        vwcCall.isIncomingCall = NO;
        self.callViewController = vwcCall;
        
        // 弹出通话页面
        [self pushCallViewController];
    }
    else if (nResult == RK_EXIST_MEETINGING) {
        [UIAlertView showAutoHidePromptView:@"呼叫失败：您当前有正在进行的多人语音会议。" background:nil showTime:1.5];
    }
    
    return nResult;
}

// 呼叫视频电话
- (int)dialVideoCall:(NSString *)calleeAccount
{
    if (calleeAccount == nil) {
        return RK_PARAMS_ERROR;
    }
    
    // 没有网络则提示没有连接
    if ([ToolsFunction checkInternetReachability] == NO)
    {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return RK_NOT_NETWORK;
    }
    
    // 开始呼叫被叫
    int nResult = [RKCloudAV dial:calleeAccount withVideCall:YES];
    if (nResult == RK_SUCCESS) {
        // 初始化通话页面
        RKCloudUICallViewController *vwcCall = [[RKCloudUICallViewController alloc] initWithNibName:@"RKCloudUICallViewController" bundle:nil];
        vwcCall.peerAccount = calleeAccount;
        vwcCall.isVideoCall = YES;
        vwcCall.isIncomingCall = NO;
        self.callViewController = vwcCall;
        
        // 弹出通话页面
        [self pushCallViewController];
    }
    else if (nResult == RK_EXIST_MEETINGING) {
        [UIAlertView showAutoHidePromptView:@"呼叫失败：您当前有正在进行的多人语音会议。" background:nil showTime:1.5];
    }
    
    return nResult;
}


#pragma mark - Push Call View Controller

// 弹出通话页面
- (void)pushCallViewController
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 如果通话页面没有创建或主页面还没有创建则返回
    if (self.callViewController == nil || appDelegate.mainTabController == nil) {
        return;
    }
    NSLog(@"CALL: pushCallViewController");
    
    // 先使用一个UINavigationController将callViewController作为Root加载
    RKNavigationController *dialNavigationController = [[RKNavigationController alloc] initWithRootViewController:self.callViewController];
    
    // 保存弹出通话页面时存在的照相或相册等presentedViewController页面
    if (appDelegate.window.rootViewController.presentedViewController)
    {
        UIViewController *presentedViewController = appDelegate.window.rootViewController.presentedViewController;
        self.beforePresentedViewController = presentedViewController;
        
        // 通话页面弹出之前将之前已经弹出的页面先关闭，等通话结束后再次弹出此页面
        [presentedViewController dismissViewControllerAnimated:YES completion:^{
            // 将通话页面使用模块视图方式弹出(不使用原生的动画否则出现页面不能弹出的问题)
            [appDelegate.window.rootViewController presentViewController:dialNavigationController animated:YES completion:nil];
        }];
    }
    else {
        // 将通话页面使用模块视图方式弹出(不使用原生的动画否则出现页面不能弹出的问题)
        [appDelegate.window.rootViewController presentViewController:dialNavigationController animated:YES completion:nil];
    }
    
    //NSLog(@"UI: presentViewController: dialNavigationController");
}


#pragma mark - Save Local Message

// 插入消息记录中保存通话记录
- (void)saveCallRecordToChatLocalMessage:(NSString *)peerAccount
                            withIsCaller:(BOOL)isCaller
                         withIsVideoCall:(BOOL)isStartVideoCall
                        withIsMissedCall:(BOOL)isMissedCall
                            withCallTime:(long)callTime
{
    if (peerAccount == nil) {
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    LocalMessage *callLocalMessage = nil;
    if (isCaller) {
        // 主叫端-发送端的消息
        callLocalMessage = [LocalMessage buildSendMsg:peerAccount withMsgContent:self.strCallRecordMsgContent forSenderName:appDelegate.userProfilesInfo.userAccount];
    }
    else {
        // 被叫端-接送端的消息
        callLocalMessage = [LocalMessage buildReceivedMsg:peerAccount withMsgContent:self.strCallRecordMsgContent forSenderName:peerAccount];
    }
    
    // 保存扩展信息
    if (isStartVideoCall) {
        // 扩展信息: 视频通话
        callLocalMessage.extension = NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话");
    }
    else {
        // 扩展信息: 语音通话
        callLocalMessage.extension = NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话");
    }
    
    // 是否为未接记录
    if (isMissedCall) {
        callLocalMessage.messageStatus = MESSAGE_STATE_RECEIVE_RECEIVED;
    }
    else {
        callLocalMessage.messageStatus = MESSAGE_STATE_READED;
    }
    
    // 保存通话记录的和发生时间和接收时间
    callLocalMessage.sendTime = callTime;
    callLocalMessage.createTime = [ToolsFunction getCurrentSystemDateSecond];
    
    // 向终端插入音视频通话记录消息
    [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
    
    NSLog(@"CALL: saveCallRecordToChatLocalMessage: peerAccount = %@, isCaller = %d, isStartVideoCall = %d, strCallRecordMsgContent = %@, extension = %@", peerAccount, isCaller, isStartVideoCall, self.strCallRecordMsgContent, callLocalMessage.extension);
    
    self.strCallRecordMsgContent = nil;
}


#pragma mark - RKCloudAVDelegate - RKCloudAVNewCallCallBack

/**
 *  有新电话到达的通知
 *
 *  @param callerAccount 主叫方在云视互动中的账号
 *  @param isVideo       是否为视频通话 YES:视频通话 NO:语音通话
 */
- (void)onNewCall:(NSString *)callerAccount withIsVideo:(BOOL)isVideo
{
    NSLog(@"RKCloudAVDelegate: onNewCall: callerAccount = %@, isVideo = %d", callerAccount, isVideo);
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 判断是否在多人语音中
    if ([appDelegate.meetingManager isOwnInMeeting])
    {
        [RKCloudAV hangup];
        return;
    }
    
    // 初始化通话页面
    RKCloudUICallViewController *vwcCall = [[RKCloudUICallViewController alloc] initWithNibName:@"RKCloudUICallViewController" bundle:nil];
    vwcCall.peerAccount = callerAccount;
    vwcCall.isVideoCall = isVideo;
    vwcCall.isIncomingCall = YES;
    vwcCall.isAutoAnswer = (appDelegate.applicationGetPushMsgState & PUSHMSG_RECEIVED_NCR &&
                            appDelegate.applicationGetPushMsgState & PUSHMSG_ENTER_FOREGROUND);
    
    self.callViewController = vwcCall;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 弹出通话页面
        [self pushCallViewController];
    });
}

/**
 *  有未接来电的通知
 *
 *  @param callerAccount 主叫方在云视互动中的账号
 *  @param isVideo       是否为视频通话 YES:视频通话 NO:语音通话
 *  @param callTime      通话开始时间，单位：秒级时间戳
 */
- (void)onMissedCall:(NSString *)callerAccount
         withIsVideo:(BOOL)isVideo
        withCallTime:(long)callTime
{
    NSLog(@"RKCloudAVDelegate: onMissedCall: callerAccount = %@, isVideo = %d, callTime = %ld", callerAccount, isVideo, callTime);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // "未接来电"
        self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALL_MISSED", "未接来电");
        
        // 插入消息记录中保存通话记录
        [self saveCallRecordToChatLocalMessage:callerAccount withIsCaller:NO withIsVideoCall:isVideo withIsMissedCall:YES withCallTime:callTime];
    });
}


#pragma mark - RKCloudAVDelegate - RKCloudAVStateCallBack

/**
 *  通话状态发生变更的回调接口
 *
 *  @param state       通话状态对应的码值，请参考RKCloudAVCallState类文件中常量值定义
 *  @param stateReason 通话失败对应的错误码值，参见RKCloudAVCallReason类文件中常量值定义
 */
- (void)onStateCallBack:(RKCloudAVCallState)state withReason:(RKCloudAVErrorCode)stateReason
{
    if (self.callViewController) {
        [self.callViewController onStateCallBack:state withReason:stateReason];
    }
    
    BOOL isSaveMessage = YES;
    
    // 通话如果挂断则保存通话记录到消息会话中
    if (state == AV_CALL_STATE_HANGUP)
    {
        BOOL isMissCall = NO;
        // 获取当前通话的信息对象RKCloudAVCallInfo
        RKCloudAVCallInfo *avCallInfo = [RKCloudAV getAVCallInfo];
        // NSAssert(avCallInfo != nil, @"ERROR: avCallInfo == nil");
        if (avCallInfo == nil) {
            return;
        }
        
        switch (stateReason)
        {
            case AV_NO_REASON:
            {
                // 格式化通话时长显示格式
                long callDuration = [[NSDate date] timeIntervalSince1970] - avCallInfo.callAnswerTime;
                NSString *strFromatTime = [ToolsFunction stringFormatCallDuration:callDuration];
                
                // "通话时长 %d"
                self.strCallRecordMsgContent = [NSString stringWithFormat:NSLocalizedString(@"RKCLOUD_AV_MSG_CALL_DURATION", "通话时长 %@"), strFromatTime];
            }
                break;
                
            case AV_CALLEE_UNLINE: // 被叫不在线
                // "对方不在线"
                self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALLEE_OFFLINE", "对方不在线");
                break;
                
            case AV_CALLEE_REJECT: // 被叫拒接
            {
                if (self.callViewController.isIncomingCall) {
                    // "已拒接"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLEE_CALLEE_REJECT", "已拒接");
                }
                else {
                    // "对方已拒接"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALLEE_REJECT", "对方已拒接");
                }
            }
                break;
                
            case AV_CALLEE_BUSY: // 被叫正在通话中
                // "对方通话中"
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALLEE_CALLING", "对方通话中") background:nil showTime:1.5];
                self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALLEE_CALLING", "对方通话中");
                break;
                
            case AV_CALLEE_NO_ANSWER: // 被叫未接听，主要给主叫呼叫超时使用
            case AV_CALLEE_ANSWER_TIMEOUT: // 被叫未接听，主要给被叫应答超时使用
            {
                if (self.callViewController == nil || self.callViewController.isIncomingCall)
                {
                    // "未接来电"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALL_MISSED", "未接来电");
                    
                    isMissCall = YES;
                }
                else
                {
                    // "无人应答"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALLEE_NO_ANSWER", "无人应答");
                }
            }
                break;
                
            case AV_CALLER_CANCEL: // 主叫取消通话
            {
                if (self.callViewController.isIncomingCall) {
                    // "对方已取消"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLEE_CALL_CANCEL", "对方已取消");
                }
                else {
                    // "已取消"
                    self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALL_CANCEL", "已取消");
                }
            }
                break;
                
            case AV_CALL_OTHER_FAIL: // 其它原因导致呼叫失败
                // "呼叫失败"
                self.strCallRecordMsgContent = NSLocalizedString(@"RKCLOUD_AV_MSG_CALLER_CALL_FAILED", "呼叫失败");
                break;
            case AV_CALLEE_OTHER_PLATFORM_ANSWER:
                isSaveMessage = NO;
                break;
            default:
                break;
        }
        
        if (isSaveMessage)
        {
            // 插入消息记录中保存通话记录
            [self saveCallRecordToChatLocalMessage:avCallInfo.peerAccount withIsCaller:avCallInfo.isCaller withIsVideoCall:avCallInfo.isStartVideoCall withIsMissedCall:isMissCall withCallTime:[ToolsFunction getCurrentSystemDateSecond]];
        }
    }
}

@end
