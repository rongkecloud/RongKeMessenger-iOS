//
//  RKCloudUICallViewController.m
//  RKCloudDemo
//
//  Created by WangGray on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "RKCloudUICallViewController.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "UIBorderButton.h"
#import "CallOperationButtonAndTitleView.h"
#import "EmoticonView.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "CustomAvatarImageView.h"

#define OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT  85
#define OPERATION_BUTTON_SPACING_BOTTOM    10
#define LOCAL_VIEW_SPACE 8.0

@interface RKCloudUICallViewController () <CallOperationButtonAndTitleViewDelegate>
{
    NSInteger outputDeviceRoute; // 记录当前的输出设备类型
    
    BOOL isSpeakerEnable; // 是否打开扬声器
    BOOL isBluetoothConnected; // 是否蓝牙已经连接
    BOOL isHangupPop; // 已经挂断并弹出页面
}

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImgView;// 语音通话和视频通话未接通时的背景图片

@property (weak, nonatomic) IBOutlet UIView *remoteVideoView;
@property (weak, nonatomic) IBOutlet UIView *localVideoView;
@property (strong, nonatomic) CustomAvatarImageView *headerImageView;
@property (strong, nonatomic) UILabel *accountLabel;
@property (strong, nonatomic) UILabel *callStateLabel;
@property (strong, nonatomic) NSTimer *talkingTimeTimer;
@property (nonatomic, assign) long callSecond; // 记录通话时长秒数

@property (strong, nonatomic) CallOperationButtonAndTitleView *answerButtonView;  // 接听
@property (strong, nonatomic) CallOperationButtonAndTitleView *hangupButtonView;  // 挂断
@property (strong, nonatomic) CallOperationButtonAndTitleView *muteButtonView;  // 静音
@property (strong, nonatomic) CallOperationButtonAndTitleView *handsFreeButtonView; // 免提
@property (strong, nonatomic) CallOperationButtonAndTitleView *switchCameraButtonView;  // 切换摄像头
@property (strong, nonatomic) CallOperationButtonAndTitleView *switchAudioButtonView;   // 转换成语音通话

@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer; // 播放音频对象

@property (nonatomic, assign) BOOL isLocalViewSmall;
@property (nonatomic, assign) BOOL isAbleToSwitchLocalAndRemote;
@property (nonatomic, assign) BOOL isAllControlHidden;

@end

@implementation RKCloudUICallViewController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 初始化变量
    [self initVariable];
    
    // 初始化对方头像与名称
    [self initFriendHeaderAndAccount];
    
    // 初始化相应的按钮
    [self initOprationButtonView];
    
    // 判断是否需要自动接听
    if (self.isAutoAnswer == YES) {
        NSLog(@"CALL: isAutoAnswer == YES");
        [self touchAnswerButton];
    }    // 添加手势
    UITapGestureRecognizer * tapLocalViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchLocalVideoView)];
    [self.localVideoView addGestureRecognizer:tapLocalViewGesture];
    
    UIPanGestureRecognizer * panLocalViewGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragLocalView:)];
    [self.localVideoView addGestureRecognizer:panLocalViewGesture];
    
    UITapGestureRecognizer * tapRemoteViewGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchRemoteVideoView)];
    [self.remoteVideoView addGestureRecognizer:tapRemoteViewGesture];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 判断如果是视频通话则增加设置视频窗口的逻辑。
    if (self.isVideoCall)
    {
        // 设置默认前置摄像头
        [RKCloudAV setCamera:CAMERA_FRONT];
        // 设置视频的方向为竖屏显示
        [RKCloudAV setOrientation:YES];
        
        int videoOrientation = 1;
        switch (videoOrientation)
        {
            case 0:  // 横屏
            {
                self.remoteVideoView.transform = CGAffineTransformMakeRotation(-M_PI_2);
                self.localVideoView.transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
                break;
                
            case 1:  // 竖屏
            {
                //displayRemote.transform = CGAffineTransformMakeRotation(M_PI_2);
                //displayRemote.transform = CGAffineTransformMakeRotation(M_PI_2);
            }
                break;
                
            default:
                break;
        }
        
        NSLog(@"DEBUG: self.remoteVideoView.frame = %@, self.localVideoView.frame = %@", NSStringFromCGRect(self.remoteVideoView.frame), NSStringFromCGRect(self.localVideoView.frame));
        [RKCloudAV setVideoDisplay:self.remoteVideoView withLocalVideo:self.localVideoView];
    }
}

- (void)dealloc {

    // 停止播放铃声
    [self.avAudioPlayer stop];
    self.avAudioPlayer = nil;
    
    // 释放AVAudioSession实例
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Methods

// 初始化变量
- (void)initVariable
{
    self.navigationController.navigationBarHidden = YES;
    // 启用距离感应器
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    // Jacky.Chen:2016.02.25 弹出通话页面默认显示背景图，视频通话接通后隐藏
    self.backgroundImgView.hidden = NO;
    
    isSpeakerEnable = NO;
    isBluetoothConnected = NO;
    isHangupPop = NO;
    self.isLocalViewSmall = YES;
    self.isAbleToSwitchLocalAndRemote = YES;
    self.isAllControlHidden = NO;

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // Use this code instead to allow the app sound to continue to play when the screen is locked.
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // 添加设备切换的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeNotification:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    // 默认蔽本地视频View
    self.localVideoView.hidden = YES;
    self.view.backgroundColor = [UIColor blackColor];
}

// 初始化对方头像与名称
- (void)initFriendHeaderAndAccount
{
    // 初始化头像ImageView
    CGFloat headerImageViewX = (UISCREEN_BOUNDS_SIZE.width - 111)/2;
    self.headerImageView = [[CustomAvatarImageView alloc] initWithFrame:CGRectMake(headerImageViewX, 103, 111, 111)];
    [self.headerImageView setUserAvatarImageByUserId:self.peerAccount];
    [self.view addSubview:self.headerImageView];
    
    self.accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.headerImageView.frame), CGRectGetMaxY(self.headerImageView.frame) + 23, self.headerImageView.frame.size.width, 21)];
    self.accountLabel.font = FONT_TEXT_SIZE_20;
    self.accountLabel.textColor = [UIColor whiteColor];
    self.accountLabel.textAlignment = NSTextAlignmentCenter;
    self.accountLabel.text = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:self.peerAccount];
    [self.view addSubview:self.accountLabel];
    
    self.callStateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.headerImageView.frame), CGRectGetMaxY(self.accountLabel.frame) + 23, self.headerImageView.frame.size.width, 21)];
    self.callStateLabel.textAlignment = NSTextAlignmentCenter;
    self.callStateLabel.font = FONT_TEXT_SIZE_13;
    self.callStateLabel.textColor = [UIColor whiteColor];
    self.callStateLabel.text = @"通话正在建立中...";
    [self.view addSubview:self.callStateLabel];
}

// 初始化相应的按钮
- (void)initOprationButtonView
{
    float buttonOriginY = UISCREEN_BOUNDS_SIZE.height -  OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT - OPERATION_BUTTON_SPACING_BOTTOM;
    
    // 来电
    if (self.isIncomingCall == YES)
    {
        // 动态计算按钮布局：个数、边距、间距
        EmoticonStickerViewLayout callOptionButtonViewLayout =
        [EmoticonView calculationEmotionAndStickerLayoutWithMargin:40
                                                     forImageWidth:60
                                                  withImageSpacing:80];
        
        float buttonOriginX = callOptionButtonViewLayout.fMarginWidth;
        // 初始化挂断按钮
        if (self.handsFreeButtonView == nil) {
            self.hangupButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(buttonOriginX, buttonOriginY, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeHangUp];
            self.hangupButtonView.delegate = self;
            [self.view addSubview:self.hangupButtonView];
        }
        
        // 初始化接听按钮
        if (self.answerButtonView == nil) {
            self.answerButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(UISCREEN_BOUNDS_SIZE.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT - CGRectGetMinX(self.hangupButtonView.frame) , buttonOriginY, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeAnswer];
            self.answerButtonView.delegate = self;
            [self.view addSubview:self.answerButtonView];
        }
    }
    else
    {
        // 去电，初始化挂断按钮
        if (self.hangupButtonView == nil)
        {
            self.hangupButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake((UISCREEN_BOUNDS_SIZE.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2, UISCREEN_BOUNDS_SIZE.height -  OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT - OPERATION_BUTTON_SPACING_BOTTOM, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeHangUp];
            self.hangupButtonView.delegate = self;
            self.hangupButtonView.backgroundColor = [UIColor clearColor];
            [self.view addSubview:self.hangupButtonView];
        }
    }
}

- (void)addOprationButtonOfCallSuccessConnect
{
    float marginX = 40;
    float spacing = 80;
    if (self.isVideoCall) {
        marginX = 30;
        spacing = 40;
    }
    
//    // 动态计算表情或Emtion在不同屏幕上的横向的：个数、边距、间距
//    EmoticonStickerViewLayout callOptionButtonViewLayout =
//    [EmoticonView calculationEmotionAndStickerLayoutWithMargin:marginX
//                                                 forImageWidth:60
//                                              withImageSpacing:spacing];
    
    // Jacky.Chen:2016.02.25上面三个按钮 间距
    // 间距
    CGFloat margin = (UISCREEN_BOUNDS_SIZE.width - 3 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/4;
    // 下面两个按钮 间距
    CGFloat marginD = (UISCREEN_BOUNDS_SIZE.width - 2 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/3;
    // 初始化静音按钮
    if (self.muteButtonView == nil) {
        self.muteButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(margin, UISCREEN_BOUNDS_SIZE.height - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT*2 - OPERATION_BUTTON_SPACING_BOTTOM - 5, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeMute];
        self.muteButtonView.delegate = self;
        [self.view addSubview:self.muteButtonView];
    }
    
    // 初始免提音按钮
    if (self.handsFreeButtonView == nil)
    {
        // Jacky.Chen:2016.02.25，若第一次为语音通话则初始化免提按钮位置到静音按钮对称位置（默认，若为视频通话则在下边的条件里边更改X）
        self.handsFreeButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(UISCREEN_BOUNDS_SIZE.width - margin - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT, CGRectGetMinY(self.muteButtonView.frame), OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeHandsFree];

        // Gray.Wang:2015.09.09:修正如果是扬声器在选中按钮
        if (outputDeviceRoute == IPHONE_OUTPUT_SPEAKER) {
            self.handsFreeButtonView.isButtonSelected = YES;
        }
        
        self.handsFreeButtonView.delegate = self;
        [self.view addSubview:self.handsFreeButtonView];
    }
    
    if (self.isVideoCall)
    {
        // Jacky.Chen:2016.02.25：视频通话更改免提按钮位置
        CGRect handsFreeButtonFrame = self.handsFreeButtonView.frame;
        handsFreeButtonFrame.origin.x = CGRectGetMaxX(self.muteButtonView.frame) + margin;
        self.handsFreeButtonView.frame = handsFreeButtonFrame;

        // 计算title的宽度
        NSString *switchCamera = NSLocalizedString(@"STR_CALL_BUTTON_SWITCH_CAMERA", @"");
        CGSize switchCameraSize = [ToolsFunction getSizeFromString:switchCamera withFont:FONT_TEXT_SIZE_16];
        // 文字超出时需要挑这个ButtonView的坐标
        float buttonWith = OPRATION_BUTTON_WIDTH_AND_HEIGHT;
        float spacingWidthVlue = 0;
        if (switchCameraSize.width > OPRATION_BUTTON_WIDTH_AND_HEIGHT)
        {
            spacingWidthVlue = (switchCameraSize.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2;
            buttonWith = switchCameraSize.width;
        }
        
        // 初始化摄像头切换按钮
        if (self.switchCameraButtonView == nil)
        {
            self.switchCameraButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.handsFreeButtonView.frame) + margin, CGRectGetMinY(self.handsFreeButtonView.frame), buttonWith, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeSwitchCamera];
            self.switchCameraButtonView.delegate = self;
            [self.view addSubview:self.switchCameraButtonView];
        }
        
//        EmoticonStickerViewLayout hangupButtonViewLayOut =
//        [EmoticonView calculationEmotionAndStickerLayoutWithMargin:50
//                                                     forImageWidth:60
//                                                  withImageSpacing:100];
        
        // 计算title的宽度
        NSString *switchAudioButton = NSLocalizedString(@"STR_CALL_BUTTON_SWITCH_AUDIO_CHAT", @"");
        CGSize switchAudioButtonSize = [ToolsFunction getSizeFromString:switchAudioButton withFont:FONT_TEXT_SIZE_16];
        // 文字超出时需要挑这个ButtonView的坐标
        float switchAudioButtonWith = OPRATION_BUTTON_WIDTH_AND_HEIGHT;
        float switchAudioButtonSpacingWidthVlue = 0;
        if (switchAudioButtonSize.width > OPRATION_BUTTON_WIDTH_AND_HEIGHT)
        {
            switchAudioButtonSpacingWidthVlue = (switchAudioButtonSize.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2;
            switchAudioButtonWith = switchAudioButtonSize.width;
        }
        // 初始化语音切换按钮
        if (self.switchAudioButtonView == nil)
        {
            self.switchAudioButtonView = [[CallOperationButtonAndTitleView alloc] initWithFrame:CGRectMake(marginD, CGRectGetMinY(self.hangupButtonView.frame), switchAudioButtonWith, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT) withCallOperationButtonType:CallOperationButtonTypeAudioChat];
            self.switchAudioButtonView.delegate = self;
            [self.view addSubview:self.switchAudioButtonView];
        }
    }
}

#pragma mark - Call Time Method

// 启动检测通话时间定时器定时器
- (void)startDetectTalkingTime
{
    // 停止检测通话时间定时器
    [self stopDetectTalkingTime];
    
    NSLog(@"CALL: startDetectTalkingTime");
    
    self.talkingTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                              target:self
                                                           selector:@selector(detectTalkingTime)
                                                           userInfo:nil 
                                                            repeats:YES];
}

// 停止检测通话时间定时器定时器
- (void)stopDetectTalkingTime
{
    // 停止检测通话时间定时器
    if(self.talkingTimeTimer!=nil)  {
        NSLog(@"CALL: stopDetectTalkingTime");
        
        [self.talkingTimeTimer invalidate];
        self.talkingTimeTimer = nil;
        //NSLog(@"DEBUG: +++++self.talkingTimeTimer invalidate+++++");
    }
}

// 检测通话后通话时间定
- (void)detectTalkingTime
{
    // 格式化通话时长显示格式
    long callDuration = [[NSDate date] timeIntervalSince1970] - self.callSecond;
    NSString *strFromatTime = [ToolsFunction stringFormatCallDuration:callDuration];
    // 更新通话时间
    self.callStateLabel.text = strFromatTime;
    [self.view bringSubviewToFront: self.callStateLabel];
}

#pragma mark - CallOperationButtonAndTitleViewDelegate Method

- (void)touchCalloprationButtonDelegateMethod:(CallOperationButtonType)callOperationButtonType
{
    switch (callOperationButtonType)
    {
        case CallOperationButtonTypeAnswer: // 接听
        {
            // 接听
            [self touchAnswerButton];
        }
            break;
            
        case CallOperationButtonTypeHangUp: // 挂断
        {
            // 挂断
            [self touchHangupButton];
        }
            break;
            
        case CallOperationButtonTypeMute: // 静音
        {
            self.muteButtonView.isButtonSelected = !self.muteButtonView.isButtonSelected;
            if (self.muteButtonView.isButtonSelected == YES) {
                // 静音
                [RKCloudAV mute:YES];
            }
            else if (self.muteButtonView.isButtonSelected == NO)
            {
                // 取消静音
                [RKCloudAV mute:NO];
            }
            
            [self.muteButtonView setNeedsDisplay];
        }
            break;
            
        case CallOperationButtonTypeSwitchCamera: // 切换摄像头
        {
            self.switchCameraButtonView.isButtonSelected = !self.switchCameraButtonView.isButtonSelected;
            if (self.switchCameraButtonView.isButtonSelected == YES) {
                // 后置摄像头
                [RKCloudAV setCamera:CAMERA_REAR];
            }
            else if (self.switchCameraButtonView.isButtonSelected == NO)
            {
                // 前置摄像头
                [RKCloudAV setCamera:CAMERA_FRONT];
            }
            
            [self.switchCameraButtonView setNeedsDisplay];
        }
            break;
            
        case CallOperationButtonTypeAudioChat: // 切到语音聊天
        {
            // 停止视频
            [self touchStopVideoButton];
            [self moveSwitchAudioTypeOprationButtonFrame];
            
            // 显示本人头像与名称
            self.accountLabel.hidden = NO;
            self.headerImageView.hidden = NO;
            
            [self.localVideoView removeFromSuperview];
            [self.remoteVideoView removeFromSuperview];
        }
            break;
            
        case CallOperationButtonTypeHandsFree: // 免提
        {
            self.handsFreeButtonView.isButtonSelected = !self.handsFreeButtonView.isButtonSelected;
            if (self.handsFreeButtonView.isButtonSelected == YES) {
                // 扬声器
                [ToolsFunction setAudioRouteTypeOfOutputDevice:IPHONE_OUTPUT_SPEAKER];
                outputDeviceRoute = IPHONE_OUTPUT_SPEAKER;
            }
            else if (self.handsFreeButtonView.isButtonSelected == NO)
            {
                // 话筒或者耳机
                [ToolsFunction setAudioRouteTypeOfOutputDevice:IPHONE_OUTPUT_HEADPHONES];
                outputDeviceRoute = IPHONE_OUTPUT_HEADPHONES;
            }
            
            [self.handsFreeButtonView setNeedsDisplay];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Touch Button Action

- (void)touchAnswerButton
{
    
    self.callSecond = [ToolsFunction getCurrentSystemDateSecond];
    
    [self startDetectTalkingTime];
    
    CGRect hangupButtonViewFrame = CGRectZero;
    // 移除接听按钮
    if (self.isVideoCall)
    {
        // 视频 移动挂断按钮到中间位置
        hangupButtonViewFrame = self.hangupButtonView.frame;//        self.answerButtonView.frame;
        hangupButtonViewFrame.origin.x = UISCREEN_BOUNDS_SIZE.width - (UISCREEN_BOUNDS_SIZE.width - 2 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/3 - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
        
        // Jacky.Chen:2016.02.25 视频通话接听后，隐藏背景图
        self.backgroundImgView.hidden = YES;
        // Jacky.Chen:2016.02.25
        // 通话时间标签位置调整
        CGRect timeLabelFrame = self.callStateLabel.frame;
        timeLabelFrame.origin.y = CGRectGetMinY(self.handsFreeButtonView.frame) - 40;
        self.callStateLabel.frame = timeLabelFrame;
        // 隐藏头像图片与名称
        self.headerImageView.hidden = YES;
        self.accountLabel.hidden = YES;
        self.localVideoView.hidden = NO;
    }
    else
    {
        // 语音 移动挂断按钮到中间位置
        hangupButtonViewFrame = CGRectMake((UISCREEN_BOUNDS_SIZE.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2, UISCREEN_BOUNDS_SIZE.height -  OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT - OPERATION_BUTTON_SPACING_BOTTOM, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT);
        // 更改免提按钮的位置到切换摄像头位置
        CGRect handsFreeButtonFrame = self.handsFreeButtonView.frame;
        handsFreeButtonFrame.origin.x = UISCREEN_BOUNDS_SIZE.width - (UISCREEN_BOUNDS_SIZE.width - 3 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/4 - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
        self.handsFreeButtonView.frame = handsFreeButtonFrame;
        // 更改时间标签的位置
        CGRect timeLabelFrame = self.callStateLabel.frame;
        timeLabelFrame.origin.y =  CGRectGetMaxY(self.accountLabel.frame) + 23;
        self.callStateLabel.frame = timeLabelFrame;
    }
    
    // 语音 移动挂断按钮到中间位置
    [UIView animateWithDuration:0.2 animations:^{
        self.hangupButtonView.frame = hangupButtonViewFrame;
        [self.answerButtonView removeFromSuperview];
    } completion:^(BOOL finished) {
        if (finished) {
            // 初始化静音、免提按钮
            [self addOprationButtonOfCallSuccessConnect];
        }
    }];
    
    
    // 接听来电
    [RKCloudAV answer];
}

// 调整切换到语音模式下各个按钮的坐标
- (void)moveSwitchAudioTypeOprationButtonFrame
{
    // Jacky.Chen add 切换到语音后展示背景图
    self.backgroundImgView.hidden = NO;
    
    [self.switchAudioButtonView removeFromSuperview];
    [self.switchCameraButtonView removeFromSuperview];
    
    // 语音 移动挂断按钮到中间位置
    [UIView animateWithDuration:0.2 animations:^{
        // 动态计算表情或Emtion在不同屏幕上的横向的：个数、边距、间距
//        EmoticonStickerViewLayout callOptionButtonViewLayout =
//        [EmoticonView calculationEmotionAndStickerLayoutWithMargin:40
//                                                     forImageWidth:OPRATION_BUTTON_WIDTH_AND_HEIGHT
//                                                  withImageSpacing:100];
        // Jacky.Chen:2016.02.25
        // 修改计算按钮位置的方式，使用对称的方式调整
        
        self.hangupButtonView.frame = CGRectMake((UISCREEN_BOUNDS_SIZE.width - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2, UISCREEN_BOUNDS_SIZE.height -  OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT - OPERATION_BUTTON_SPACING_BOTTOM, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT);
        self.muteButtonView.frame = CGRectMake((UISCREEN_BOUNDS_SIZE.width - 3 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/4, UISCREEN_BOUNDS_SIZE.height - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT*2 - OPERATION_BUTTON_SPACING_BOTTOM - 5, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT);
        // 更改免提按钮的位置到切换摄像头位置
        CGRect handsFreeButtonFrame = self.handsFreeButtonView.frame;
        handsFreeButtonFrame.origin.x = UISCREEN_BOUNDS_SIZE.width - CGRectGetMinX(self.muteButtonView.frame) - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
        self.handsFreeButtonView.frame = handsFreeButtonFrame;
        // 更改时间标签的位置
        CGRect timeLabelFrame = self.callStateLabel.frame;
        timeLabelFrame.origin.y =  CGRectGetMaxY(self.accountLabel.frame) + 23;
        self.callStateLabel.frame = timeLabelFrame;

        
    } completion:^(BOOL finished) {
    }];
}

- (void)touchHangupButton{
    
    self.callSecond = 0;
    
    [self stopDetectTalkingTime];
    
    // 挂断电话
    [RKCloudAV hangup];
    
    // Gray.Wang:2015.11.07:为了防止挂断的状态通过状态代理接口不能及时返回，所以在此做一个延迟弹出通话页面的逻辑:
    // 如果2秒后也没有没有结束则自动弹出通话页面
    [self performSelector:@selector(popCallViewController) withObject:nil afterDelay:2];
}

- (void)touchStartVideoButton{
    
    // 为视频通话打开相关设备
    [self openRelatedDeviceForVideoCall];
    
    // 启动视频
    [RKCloudAV startVideo];
}

- (void)touchStopVideoButton{
    
    // 停止视频
    [RKCloudAV stopVideo];
}

- (void)touchAudioMuteSegmentedControl:(id)sender {
    UISegmentedControl *muteSegmentedControl = (UISegmentedControl *)sender;
    
    switch (muteSegmentedControl.selectedSegmentIndex) {
        case 0:
            [RKCloudAV mute:NO];
            break;
            
        case 1:
            [RKCloudAV mute:YES];
            break;
            
        default:
            break;
    }
}

- (void)touchAudioOutputDeviceSegmentedControl:(id)sender {
    UISegmentedControl *outputDeviceSegmentedControl = (UISegmentedControl *)sender;
    
    switch (outputDeviceSegmentedControl.selectedSegmentIndex) {
        case 0: // 听筒
        {
            [ToolsFunction setAudioRouteTypeOfOutputDevice:IPHONE_OUTPUT_HEADPHONES];
            outputDeviceRoute = IPHONE_OUTPUT_HEADPHONES;
        }
            break;
            
        case 1: // 扬声器
        {
            [ToolsFunction setAudioRouteTypeOfOutputDevice:IPHONE_OUTPUT_SPEAKER];
            outputDeviceRoute = IPHONE_OUTPUT_SPEAKER;
        }
            break;
            
        case 2: // 当前连接的蓝牙耳机
        {
            [ToolsFunction setAudioRouteTypeOfOutputDevice:IPHONE_OUTPUT_BLUETOOTH_HFP];
            outputDeviceRoute = IPHONE_OUTPUT_BLUETOOTH_HFP;
        }
            break;
            
        default:
            break;
    }
}

- (void)touchCameraDeviceSegmentedControl:(id)sender {
    UISegmentedControl *cameraDeviceSegmentedControl = (UISegmentedControl *)sender;
    
    switch (cameraDeviceSegmentedControl.selectedSegmentIndex) {
        case 0: // 前置摄像头
            [RKCloudAV setCamera:CAMERA_FRONT];
            break;
            
        case 1: // 后置摄像头
            [RKCloudAV setCamera:CAMERA_REAR];
            break;
            
        default:
            break;
    }
}

- (void)touchLocalVideoView
{
    if (self.isAbleToSwitchLocalAndRemote)
    {
        self.isAbleToSwitchLocalAndRemote = NO;
        [self performSelector:@selector(enableSwitchLocalAndRemote) withObject:nil afterDelay:0.5];
        
        if (self.isLocalViewSmall)
        {
            [RKCloudAV setVideoDisplay:self.localVideoView withLocalVideo:self.remoteVideoView];
        }
        else
        {
            [RKCloudAV setVideoDisplay:self.remoteVideoView withLocalVideo:self.localVideoView];
        }
        self.isLocalViewSmall = !self.isLocalViewSmall;
    }
}

- (void)enableSwitchLocalAndRemote {
    self.isAbleToSwitchLocalAndRemote = YES;
}

- (void)dragLocalView:(UIPanGestureRecognizer *)panLocalViewGesture
{
    CGPoint point = [panLocalViewGesture translationInView:self.view];
    CGFloat x = point.x + self.localVideoView.center.x;
    CGFloat y = point.y + self.localVideoView.center.y;
    
    if (x < LOCAL_VIEW_SPACE + self.localVideoView.frame.size.width/2)
    {
        x = LOCAL_VIEW_SPACE + self.localVideoView.frame.size.width/2;
    }
    else if (x > (UISCREEN_BOUNDS_SIZE.width - (LOCAL_VIEW_SPACE + self.localVideoView.frame.size.width/2)))
    {
        x = UISCREEN_BOUNDS_SIZE.width - (LOCAL_VIEW_SPACE + self.localVideoView.frame.size.width/2);
    }
    
    if (y < self.localVideoView.frame.size.height/2 + [UIApplication sharedApplication].statusBarFrame.size.height)
    {
        y = self.localVideoView.frame.size.height/2 + [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    else if (y > (UISCREEN_BOUNDS_SIZE.height - (LOCAL_VIEW_SPACE + self.localVideoView.frame.size.height/2)))
    {
        y = UISCREEN_BOUNDS_SIZE.height - (LOCAL_VIEW_SPACE + self.localVideoView.frame.size.height/2);
    }
    
    self.localVideoView.center = CGPointMake(x, y);
    [panLocalViewGesture setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (void)touchRemoteVideoView {
    [self setAllControlHidden:self.isAllControlHidden];
}

-(void)setAllControlHidden:(BOOL)isAllControlHidden
{
    self.isAllControlHidden = !self.isAllControlHidden;
    for (UIView * obj in self.view.subviews)
    {
        if (obj != self.localVideoView && obj != self.remoteVideoView && obj != self.backgroundImgView && obj != self.headerImageView && obj != self.accountLabel)
        {
            [obj setHidden:self.isAllControlHidden];
        }
    }
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
    switch (state)
    {
        case AV_CALL_STATE_ANSWER: // 通话已接通
        {
            self.callSecond = [ToolsFunction getCurrentSystemDateSecond];
            // 开始计时
            [self startDetectTalkingTime];
            
            // 停止播放铃声
            [self.avAudioPlayer stop];
            self.avAudioPlayer = nil;
            
            // 如果是视频通话则设置视频窗口
            if (self.isVideoCall)
            {
                // 为视频通话打开相关设备
                [self openRelatedDeviceForVideoCall];
                
                // Jacky.Chen:02.25 ADD 通话接通后视频通话的背景图隐藏
                self.backgroundImgView.hidden = YES;
                
                // 隐藏个人头像与名称
                self.headerImageView.hidden = YES;
                self.accountLabel.hidden = YES;
                self.localVideoView.hidden = NO;
                
//                EmoticonStickerViewLayout hangupButtonViewLayOut =
//                [EmoticonView calculationEmotionAndStickerLayoutWithMargin:40
//                                                             forImageWidth:60
//                                                          withImageSpacing:80];
                
                // 语音 移动挂断按钮到中间位置
                [UIView animateWithDuration:0 animations:^{
                    CGRect hangupFrame = self.hangupButtonView.frame;
                    hangupFrame.origin.x =  UISCREEN_BOUNDS_SIZE.width - (UISCREEN_BOUNDS_SIZE.width - 2 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/3 - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
                    self.hangupButtonView.frame = hangupFrame;
                } completion:^(BOOL finished) {
                    if (finished)
                    {
                        // 初始化静音、免提按钮
                        [self addOprationButtonOfCallSuccessConnect];
                        
                        // 通话时间标签位置调整
                        CGRect timeLabelFrame = self.callStateLabel.frame;
                        timeLabelFrame.origin.y = CGRectGetMinY(self.handsFreeButtonView.frame) - 40;
                        self.callStateLabel.frame = timeLabelFrame;
                    }
                }];
            }
            else
            {
                // 初始化静音、免提按钮
                [self addOprationButtonOfCallSuccessConnect];
                
                // Jacky.Chen:2016.02.25
                // 更改免提按钮的位置
                CGRect handsFreeButtonFrame = self.handsFreeButtonView.frame;
                handsFreeButtonFrame.origin.x = UISCREEN_BOUNDS_SIZE.width - (UISCREEN_BOUNDS_SIZE.width - 3 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/4 - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
                self.handsFreeButtonView.frame = handsFreeButtonFrame;
                // 更改时间标签的位置
                CGRect timeLabelFrame = self.callStateLabel.frame;
                timeLabelFrame.origin.y =  CGRectGetMaxY(self.accountLabel.frame) + 23;
                self.callStateLabel.frame = timeLabelFrame;
            }
        }
            break;
            
        case AV_CALL_STATE_HANGUP: // 通话挂断
        {
            // 弹出通话页面
            [self popCallViewController];
            
            if (stateReason == AV_CALLEE_OTHER_PLATFORM_ANSWER)
            {
                [UIAlertView showAutoHidePromptView: @"通话已在其它终端接听"];
            }
        }
            break;
            
        case AV_CALL_STATE_VIDEO_INIT: // 通话建立后的动作(即通话状态为CALL_ANSWER时)：视频初始化成功
        {
            EmoticonStickerViewLayout hangupButtonViewLayOut =
            [EmoticonView calculationEmotionAndStickerLayoutWithMargin:40
                                                         forImageWidth:60
                                                      withImageSpacing:80];
            
            // 语音 移动挂断按钮到中间位置
            // Jacky.Chen:02.25:视频通话不调整 self.hangupButtonView.frame
            if (self.isVideoCall == NO)
            {
                [UIView animateWithDuration:0 animations:^{
                    CGRect hangupFrame = self.hangupButtonView.frame;
                    hangupFrame.origin.x = hangupButtonViewLayOut.fMarginWidth + hangupButtonViewLayOut.fSpacingWidth + OPRATION_BUTTON_WIDTH_AND_HEIGHT;
                    self.hangupButtonView.frame = hangupFrame;
                    
                    // Jacky.Chen:2016.02.25
                    // 更改免提按钮的位置
                    CGRect handsFreeButtonFrame = self.handsFreeButtonView.frame;
                    handsFreeButtonFrame.origin.x = UISCREEN_BOUNDS_SIZE.width - (UISCREEN_BOUNDS_SIZE.width - 3 * OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT )/4 - OPRATION_BUTTON_BACKGROUND_VIEW_HEIGHT;
                    self.handsFreeButtonView.frame = handsFreeButtonFrame;
                    // 更改时间标签的位置
                    CGRect timeLabelFrame = self.callStateLabel.frame;
                    timeLabelFrame.origin.y =  CGRectGetMaxY(self.accountLabel.frame) + 23;
                    self.callStateLabel.frame = timeLabelFrame;
                    
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
            break;
        
        case AV_CALL_STATE_VIDEO_START: // 通话建立后的动作(即通话状态为CALL_ANSWER时)：切换为视频通话
            break;
            
        case AV_CALL_STATE_VIDEO_STOP: // 通话建立后的动作(即通话状态为CALL_ANSWER时)：切换为语音通话
        {
            // 停止视频
            [self touchStopVideoButton];
            [self moveSwitchAudioTypeOprationButtonFrame];
            
            // 显示本人头像与名称
            self.accountLabel.hidden = NO;
            self.headerImageView.hidden = NO;
            
            [self.localVideoView removeFromSuperview];
            [self.remoteVideoView removeFromSuperview];
            
            RKCloudAVCallInfo *avCallInfo = [RKCloudAV getAVCallInfo];
            if (avCallInfo && avCallInfo.isCurrVideoOpen == YES)
            {
                // 为视频通话关闭相关设备
                [self closeRelatedDeviceForVideoCall];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UI View Control

// 弹出通话页面
- (void)popCallViewController
{
    if (isHangupPop == YES) {
        return;
    }
    
    NSLog(@"CALL: popCallViewController");
    
    [self stopDetectTalkingTime];
    
    isHangupPop = YES;
    // 取消本类所有的延迟操作
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    // 已经切换到前台时清理获取Push状态
    appDelegate.applicationGetPushMsgState = 0;
    
    // 播放管段声音
    NSString *hangupSoundFilePath = [[NSBundle mainBundle] pathForResource:@"hangup" ofType:@"caf"];
    self.avAudioPlayer = [ToolsFunction playSound:hangupSoundFilePath withNumberOfLoops:1 outputToSpeaker:outputDeviceRoute];
    
    RKCloudAVCallInfo *avCallInfo = [RKCloudAV getAVCallInfo];
    if (avCallInfo && avCallInfo.isCurrVideoOpen == YES)
    {
        // 为视频通话关闭相关设备
        [self closeRelatedDeviceForVideoCall];
    }
    
    // 当本端发起视频邀请且进入视频页面，这时对端在没有进入视频页面时，挂断电话，本端收到远端挂断后，需要先挂断视频页面，然后再挂断音频界面，为了解决音频页面退出不成功的问题
    // 在同一个runloop中，不能同时执行dismissModalViewControllerAnimated函数
    
    // 将模块视图方式弹出的通话页面消除(不使用原生的动画否则出现页面不能弹出的问题)
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        //NSLog(@"CALL: popCallViewController - dismissViewControllerAnimated");
        
        // 如果通话页面弹出之前存在的照相或相册等presentedViewController页面，则在通话结束后将其再次弹出
        if (appDelegate.callManager.beforePresentedViewController)
        {
            [appDelegate.window.rootViewController presentViewController:appDelegate.callManager.beforePresentedViewController animated:YES completion:^{
                appDelegate.callManager.beforePresentedViewController = nil;
            }];
        }
        
        // 停止播放铃声
        [self.avAudioPlayer stop];
        self.avAudioPlayer = nil;
        
        // 如果是当前的callViewController则清空
        if (appDelegate.callManager.callViewController == self) {
            appDelegate.callManager.callViewController = nil;
        }
    }];
    
    // 退出语音界面时，关闭距离感应器
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
}


#pragma mark -
#pragma mark Audio Source Function

// 检测调整扬声器/音频源按钮状态
- (BOOL)checkAdjustmentAudioSourceStatus
{
    //RKCloudDebugLog(@"MEETING-CALL: checkAdjustmentAudioSourceStatus");
    BOOL bBluetooth = NO;
    
    // 判断是否有蓝牙耳机，如果有则改变为：音频源，并更改图标
    if ([ToolsFunction getAudioRouteTypeOfOutputDevice] == IPHONE_OUTPUT_BLUETOOTH_HFP)
    {
        // 具备蓝牙时更改为音频源
        [self switchAudioSourceToBluetooth:YES];
        bBluetooth = YES;
    }
    else
    {
        // 不具备蓝牙时使用扬声器切换
        [self switchAudioSourceToBluetooth:NO];
        bBluetooth = NO;
    }
    
    return bBluetooth;
}

// 更改扬声器/音频源切换按钮
- (void)switchAudioSourceToBluetooth:(BOOL)bAudioSource
{
    //RKCloudDebugLog(@"MEETING-CALL: switchAudioSourceToBluetooth: bAudioSource = %d", bAudioSource);
    
    if (bAudioSource)
    {
        isBluetoothConnected = YES;
        outputDeviceRoute = IPHONE_OUTPUT_BLUETOOTH_HFP;
        
        // 获取当前蓝牙设备名称
        [ToolsFunction getCurrentBluetoothDeviceName];
    }
    else
    {
        isBluetoothConnected = NO;
    }
}

// 为视频通话打开相关设备
- (void)openRelatedDeviceForVideoCall
{
    // 打开视频默认关闭距离感应器
    [UIDevice currentDevice].proximityMonitoringEnabled = NO;
    
    // 打开视频时，判断如果没有蓝牙或有线耳机连接则打开扬声器
    if ([ToolsFunction getAudioRouteTypeOfOutputDevice] == IPHONE_OUTPUT_DEFAULT)
    {
        // 则打开视频时默认将扬声器打开
        [ToolsFunction enableSpeaker:YES];
        outputDeviceRoute = IPHONE_OUTPUT_SPEAKER;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handsFreeButtonView.isButtonSelected = YES;
            [self.handsFreeButtonView setNeedsDisplay];
        });
    }
    
    // 将系统自动锁屏关闭，视频通话中屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

// 为视频通话关闭相关设备
- (void)closeRelatedDeviceForVideoCall
{
    // 关闭视频后，在通话中开启距离感应器
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    // 停止视频时，如果扬声器在音频没有打开则关闭扬声器
    if (!isSpeakerEnable)
    {
        // 则关闭视频默认打开的扬声器
        [ToolsFunction enableSpeaker:NO];
        outputDeviceRoute = IPHONE_OUTPUT_DEFAULT;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.handsFreeButtonView.isButtonSelected = NO;
            [self.handsFreeButtonView setNeedsDisplay];
        });
    }
    
    // 将系统自动锁屏打开，视频通话结束后屏幕允许自动锁屏
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}


#pragma mark -
#pragma mark AVAudioSession RouteChange Notification

// 音频源改变的通知
- (void)audioRouteChangeNotification:(NSNotification *)notification
{
    if (notification == nil || [notification userInfo] == nil)
    {
        return;
    }
    
    NSDictionary * dictInfo = [notification userInfo];
    
    // 音频源改变的原因
    AVAudioSessionRouteChangeReason audioRouteChangeReason = [[dictInfo objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    // 音频源改变前的原因
    AVAudioSessionRouteDescription *routeDescription = [dictInfo objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    //RKCloudDebugLog(@"DEBUG: audioRouteChangeNotification: notification.userInfo = %@,\n routeDescription = %@", dictInfo, routeDescription);
    
    /*NSArray * arrayInputs = [routeDescription inputs];
     for (int i = 0; i < [arrayInputs count]; i++)
     {
     AVAudioSessionPortDescription *inputsPortDescription = [arrayInputs objectAtIndex:i];
     RKCloudDebugLog(@"DEBUG: inputsPortDescription = %@", inputsPortDescription);
     }*/
    NSString *strOldOutputDeviceType = nil;
    NSArray * arrayOutputs = [routeDescription outputs];
    for (int i = 0; i < [arrayOutputs count]; i++)
    {
        AVAudioSessionPortDescription *outputsPortDescription = [arrayOutputs objectAtIndex:i];
        strOldOutputDeviceType = outputsPortDescription.portType;
        
        // RKCloudDebugLog(@"DEBUG: outputsPortDescription portName = %@ , portType = %@", outputsPortDescription.portName,outputsPortDescription.portType);
    }
    
    NSString *strNewOutputDeviceType = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    if ([currentRoute.outputs count] > 0)
    {
        AVAudioSessionPortDescription *newRoute = [currentRoute.outputs objectAtIndex:0];
        strNewOutputDeviceType = newRoute.portType;
    }
    
    
    BOOL bOpenSpeaker = NO;
    switch (audioRouteChangeReason)
    {
        case kAudioSessionRouteChangeReason_NewDeviceAvailable:
        case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
        case kAudioSessionRouteChangeReason_RouteConfigurationChange:
        {
            if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP])
            {
                // 具备蓝牙时更改为音频源
                [self switchAudioSourceToBluetooth:YES];
            }
            else if ([strOldOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP])
            {
                // 不具备蓝牙时使用扬声器切换
                [self switchAudioSourceToBluetooth:NO];
                
                // 如果新的设备不是有线耳机则可以在视频时打开扬声器，否则需要从有线耳机输出声音
                if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortHeadphones] == NO)
                {
                    // 视频时扬声器可以打开
                    bOpenSpeaker = YES;
                }
            }
            else if ([strOldOutputDeviceType isEqualToString:AVAudioSessionPortLineOut])
            {
                // 有线耳机拨出
                // 检测调整扬声器/音频源按钮
                BOOL bBluetooth = [self checkAdjustmentAudioSourceStatus];
                
                // 如果蓝牙耳机没有连接则可以打开视频时的扬声器，否则需要从蓝牙耳机输出声音
                if (bBluetooth == NO) {
                    // 视频时扬声器可以打开
                    bOpenSpeaker = YES;
                }
            }
        }
            break;
            
        case kAudioSessionRouteChangeReason_Override:
        {
            // 在ios7中蓝牙的连接会响应此状态，与之前的系统不同，所以在此只做针对处理。
            if (![ToolsFunction iSiOS7Earlier])
            {
                if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP])
                {
                    // 具备蓝牙时更改为音频源
                    [self switchAudioSourceToBluetooth:YES];
                }
                else if ([strOldOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP])
                {
                    // 不具备蓝牙时使用扬声器切换
                    [self switchAudioSourceToBluetooth:NO];
                    
                    // 如果新的设备不是有线耳机则可以在视频时打开扬声器，否则需要从有线耳机输出声音
                    if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortHeadphones] == NO)
                    {
                        // 视频时扬声器可以打开
                        bOpenSpeaker = YES;
                    }
                }
            }
        }
            break;
            
            
        default:
            break;
    }
    
    RKCloudAVCallInfo *avCallInfo = [RKCloudAV getAVCallInfo];
    // 是否在视频通话中
    if (avCallInfo && avCallInfo.isCurrVideoOpen == YES && bOpenSpeaker)
    {
        // 为视频通话打开相关设备
        [self openRelatedDeviceForVideoCall];
    }
}

@end
