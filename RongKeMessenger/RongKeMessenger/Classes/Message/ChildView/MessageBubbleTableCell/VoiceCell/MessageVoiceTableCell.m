//
//  MessageVoiceTableCell.m
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "MessageVoiceTableCell.h"
#import "Definition.h"
#import "MessageBubbleTableCell.h"
#import "ToolsFunction.h"

// 语音消息聊天宽度
#define VOICE_BUBBLE_WIDTH                  134 // 语音泡泡的宽度
#define VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING  30  // 控件距离泡泡的边界距离
#define LEFT_BUBBLE_VIEW_X_LOCATION         CELL_MESSAGE_BUBBLE_LEFT_DISTANCE //左边泡泡的x起始坐标

@interface MessageVoiceTableCell ()

@property (nonatomic, weak) IBOutlet UIButton *tryAgainButton;
@property (nonatomic, weak) IBOutlet UIImageView *voiceWaveImageView;
@property (nonatomic, weak) IBOutlet UILabel *resendLabel;
@property (nonatomic, weak) IBOutlet UILabel *voiceRemainTimeLabel;

@property (nonatomic, strong) NSTimer *timerForUpdate;
@property (nonatomic, assign) NSInteger currentTime;//Jacky.Chen.2016.03.05.add.记录播放语音消息的当前剩余时间

@end

@implementation MessageVoiceTableCell

@synthesize tryAgainButton;
@synthesize resendLabel;
@synthesize timerForUpdate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)dealloc
{
	[self releaseOutlets];
	
    // 停止定时器
    if (self.timerForUpdate)
	{
		[self.timerForUpdate invalidate];
		self.timerForUpdate = nil;
	}
}

// Gray.Wang: 将UI的属性分开释放
- (void)releaseOutlets
{
	self.tryAgainButton = nil;
    self.resendLabel = nil;
    self.voiceWaveImageView = nil;
    self.voiceRemainTimeLabel = nil;
}


#pragma mark -
#pragma mark Initialization & Draw

- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj
              isEditing:(BOOL)isEditing
{
	// 父类初始化
	[super initCellContent:messageObj isEditing:isEditing];
    
	// 初始化时隐藏重发按钮
	self.tryAgainButton.hidden = YES;
    self.resendLabel.hidden = YES;
    self.resendLabel.text = NSLocalizedString(@"STR_RESENT_MANUALLY", nil);
    
    NSArray *senderWavePlayImageArray = @[[UIImage imageNamed:@"message_session_icon_voice_wave_right_01"], [UIImage imageNamed:@"message_session_icon_voice_wave_right_02"], [UIImage imageNamed:@"message_session_icon_voice_wave_right_03"]];
    
    NSArray *receiverWavePlayImageArray = @[[UIImage imageNamed:@"message_session_icon_voice_wave_left_01"], [UIImage imageNamed:@"message_session_icon_voice_wave_left_02"], [UIImage imageNamed:@"message_session_icon_voice_wave_left_03"]];
    
    // 语音波浪图片数组
    NSArray *voiceWaveImageArray = isSenderMMS ? senderWavePlayImageArray : receiverWavePlayImageArray;
    
    // 初始化声浪图片
    NSString *voiceWaveImageName = isSenderMMS ? @"message_session_icon_voice_wave_right_03" : @"message_session_icon_voice_wave_left_03";
    
    self.voiceWaveImageView.image = [UIImage imageNamed:voiceWaveImageName];
    self.voiceWaveImageView.animationImages = voiceWaveImageArray;
    self.voiceWaveImageView.animationDuration = 1;
    
    self.audioMessage = (AudioMessage *)self.messageObject;
    
    //Jacky.Chen.2016.03.05.add.记修改语音消息显示的倒计时时间，若为正在播放的语音消息则显示记录的剩余时间，若为不播放的消息则显示整个语音消息的总时间
	// 获取和显示声音文件的时长（若超过60秒则只显示60）
    NSString * voiceDuration = nil;
    // 如果当前正在播放，
    if ([self.vwcMessageSession.audioToolsKit isPlayingVoice] &&
        [self.vwcMessageSession.audioToolsKit.playMessageObject.messageID isEqualToString:self.audioMessage.messageID])
    {
        // 如果当前正在播放
        voiceDuration = [[NSString alloc] initWithFormat:@"%2ld\"", (long)self.currentTime];
    }
    else
    {
        // 如果当前不在播放
        voiceDuration = [[NSString alloc] initWithFormat:@"%2d\"", self.audioMessage.mediaDuration];
    }
    self.voiceRemainTimeLabel.text = voiceDuration;
    
	// 获取消息状态
	[self updateMMSCellStatus:self.messageObject.messageStatus];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
    // 设置语音时间文字颜色
    if (isSenderMMS) {
        // 本地为白色
        self.voiceRemainTimeLabel.textColor = MESSAGE_TEXT_COLOR_SELF;
    }else
    {
        self.voiceRemainTimeLabel.textColor = MESSAGE_TEXT_COLOR_OTHER;
        
    }

    // 设置泡泡坐标
    // 语音波浪Frame
    CGRect voiceWaveImageViewFrame = self.voiceWaveImageView.frame;
    // 语音剩余时间labelFrame
    CGRect voiceRemainLabelFrame = self.voiceRemainTimeLabel.frame;
    
    int bubbleWidth = VOICE_BUBBLE_WIDTH;
    if (isSenderMMS) 
	{
        //以下坐标由右至左开始计算，CELL_BUBBLE_ARROW_WIDTH为泡泡和右边的间距，bubbleWidth为语音泡泡的宽度
        // 右侧泡泡的Rect x坐标
        float frame_origin_x = UISCREEN_BOUNDS_SIZE.width - bubbleWidth - CELL_MESSAGE_BUBBLE_RIGHT_DISTANCE;
        // 设置绘制泡泡的Rect
        [self.messageBubbleView setBubbleRect:CGRectMake(frame_origin_x, CELL_MESSAGE_BUBBLE_TOP_DISTANCE, bubbleWidth + CELL_BUBBLE_ARROW_WIDTH, VOICE_BUBBLE_HEIGHT)];
        // VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING为语音波浪距离泡泡边距
        // 修正语音剩余时间label坐标
        voiceRemainLabelFrame.origin.x = CGRectGetMaxX(self.messageBubbleView.bubbleRect) - CELL_BUBBLE_ARROW_WIDTH - VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING - CGRectGetWidth(voiceRemainLabelFrame);
        // 修正y坐标
        voiceRemainLabelFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + (CGRectGetHeight(self.messageBubbleView.bubbleRect) - CGRectGetHeight(voiceRemainLabelFrame))/2.0;
        
        // 修正声浪view的坐标
        voiceWaveImageViewFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) + VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING;
        // 修正y坐标
        voiceWaveImageViewFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + (CGRectGetHeight(self.messageBubbleView.bubbleRect) - CGRectGetHeight(voiceWaveImageViewFrame))/2.0;
        
        // 重置重试button的frame
		CGRect resendButtonFrame = self.tryAgainButton.frame;
        // 修正重发button坐标
        resendButtonFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_STATUS_AND_LEFT_OF_BUBBLE - CGRectGetWidth(resendButtonFrame);
        // 修正y坐标
		resendButtonFrame.origin.y = CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_STATUS_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(resendButtonFrame);
		[self.tryAgainButton setFrame:resendButtonFrame];
        
        // 重置重发lebel的frame
        CGRect resendLabelFrame = self.resendLabel.frame;
        // 修正重发label的坐标
        resendLabelFrame.origin.x = CGRectGetMinX(resendButtonFrame) - CELL_DISTANCE_BETWEEN_TIME_AND_LEFT_OF_STATUS - CGRectGetWidth(resendLabelFrame);
        // 修正y坐标
        resendLabelFrame.origin.y = CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(resendLabelFrame);
        
        [self.resendLabel setFrame:resendLabelFrame];
    } 
	else
    {
        // 以下坐标由左至右开始计算，55为泡泡和左边的间距
        float frame_origin_x = LEFT_BUBBLE_VIEW_X_LOCATION;
        [self.messageBubbleView setBubbleRect:CGRectMake(frame_origin_x, CELL_MESSAGE_BUBBLE_TOP_DISTANCE, VOICE_BUBBLE_WIDTH + CELL_BUBBLE_ARROW_WIDTH, VOICE_BUBBLE_HEIGHT)];
        
        // 修正声浪view坐标
        voiceWaveImageViewFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) + CELL_BUBBLE_ARROW_WIDTH + VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING;
        // 修正y坐标
        voiceWaveImageViewFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + (CGRectGetHeight(self.messageBubbleView.bubbleRect) - CGRectGetHeight(voiceWaveImageViewFrame))/2.0;
        
        // 修正语音剩余时间label坐标
        voiceRemainLabelFrame.origin.x = CGRectGetMaxX(self.messageBubbleView.bubbleRect) - VOICE_BUBBLE_LEFT_OR_RIGHT_PADDING - CGRectGetWidth(voiceRemainLabelFrame);
        // 修正y坐标
        voiceRemainLabelFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + (CGRectGetHeight(self.messageBubbleView.bubbleRect) - CGRectGetHeight(voiceRemainLabelFrame))/2.0;
    }
    self.voiceRemainTimeLabel.frame = voiceRemainLabelFrame;
    
    self.voiceWaveImageView.frame = voiceWaveImageViewFrame;

	// 刷新内容区域
	[self.messageBubbleView setNeedsDisplay];
}


#pragma mark -
#pragma mark UI Cell Method

// 改变cell的发送状态
- (void)updateMMSCellStatus:(int)messageStatus {
    
    //NSLog(@"MMS: updateMMSCellStatus: status = %@, self.mmsObject.messageID = %@", status, self.mmsObject.messageID);
    
	// 根据消息状态调用想用的页面
    switch (messageStatus)
    {
        case MESSAGE_STATE_SEND_FAILED: // 发送失败
        {
            // 如果为发送失败显示重发图表于文字
            self.tryAgainButton.hidden = NO;
            
            // 根据DCR的需求去掉重发的提示，暂时对该控件隐藏的处理 14.8.7
            self.resendLabel.hidden = YES;
        }
            break;
            
        case MESSAGE_STATE_RECEIVE_RECEIVED: // 已接收
        case MESSAGE_STATE_RECEIVE_DOWNFAILED: // 下载失败
            break;
            
        case MESSAGE_STATE_RECEIVE_DOWNING: // 下载中
        case MESSAGE_STATE_SEND_SENDING: // 发送中
            break;
        
        case MESSAGE_STATE_RECEIVE_DOWNED: // 已下载
        {
            if ([self.vwcMessageSession.audioToolsKit isRecordingVoice] == NO)
            {
                // 更新消息状态为“已读”状态
                [RKCloudChatMessageManager updateMsgStatusHasReaded:self.messageObject.messageID];
                
                // 开始播放
                [self.vwcMessageSession touchPlayButton:self];
            }
            
            // 更新语音Cell的播放界面
            [self updatePlayVoiceCellView];
        }
            break;
            
        default:
            // 更新语音Cell的播放界面
            [self updatePlayVoiceCellView];
            break;
    }
}

// 更新语音Cell的播放界面
- (void)updatePlayVoiceCellView
{
	// 正在播放中，显示播放状态
	if ([self.vwcMessageSession.audioToolsKit isPlayingVoice] &&
        [self.audioMessage.messageID isEqualToString:self.vwcMessageSession.audioToolsKit.playMessageObject.messageID])
	{
        // 启动语音播放播放声音时的动画效果更新定时器
        [self startUpdateProgressForPlay];
	}
    else
    {
		// 停止定时器
        [self stopUpdateProgressForPlay];
    }
}


#pragma mark -
#pragma mark Update Progress Timer Method

// 更新播放声音时的动画效果
- (void)updateProgressForPlayVoice
{
    if (self.vwcMessageSession == nil ||
        self.timerForUpdate == nil ||
        [self.timerForUpdate isValid] == NO) {
        return;
    }
    
    //NSLog(@"DEBUG: updateProgressForPlayVoice...");
    
    // 播放完成或者不是当前的播放对象则停止进度更新
	if (self.vwcMessageSession.audioToolsKit.audioPlayer == nil ||
        !([self.audioMessage.messageID isEqualToString:self.vwcMessageSession.audioToolsKit.playMessageObject.messageID]))
	{
        // 停止更新播放声音时的动画效果
        [self stopUpdateProgressForPlay];
	}
    else {
        NSInteger remainTime = [self.vwcMessageSession.audioToolsKit playingRemainTime];
        NSString *voiceDuration = [[NSString alloc] initWithFormat:@"%ld\"", (long)remainTime];
        self.voiceRemainTimeLabel.text = voiceDuration;
        //Jacky.Chen.2016.03.05.add.记录播放语音消息的当前剩余时间
        self.currentTime = remainTime;
        // 刷新泡泡
        [self.messageBubbleView setNeedsDisplay];
    }
}

// 启动更新播放声音时的动画效果
- (void)startUpdateProgressForPlay
{
    //NSLog(@"DEBUG: startUpdateProgressForPlay");
    
    if (self.timerForUpdate == nil && ![self.timerForUpdate isValid]) {
        self.timerForUpdate = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                               target:self
                                                             selector:@selector(updateProgressForPlayVoice)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
    if (![self.voiceWaveImageView isAnimating])
    {
        self.voiceWaveImageView.animationRepeatCount = 90;
        [self.voiceWaveImageView startAnimating];
    }
}

// 停止更新播放声音时的动画效果
- (void)stopUpdateProgressForPlay
{
    if (self.timerForUpdate == nil) {
        return;
    }
    
    NSLog(@"DEBUG: stopUpdateProgressForPlay");
    
    // 停止播放声音时的动画效果更新定时器
    if (self.timerForUpdate)
    {
        [self.timerForUpdate invalidate];
        self.timerForUpdate = nil;
    }
    
    if ([self.voiceWaveImageView isAnimating])
    {
        [self.voiceWaveImageView stopAnimating];
    }
	
    // 删除当前转换并播放完成的语音
	[self.vwcMessageSession.audioToolsKit deletePlayVoice];
    
    [self.messageBubbleView setNeedsDisplay];
    
    NSString * voiceDuration = [[NSString alloc] initWithFormat:@"%2d\"", self.audioMessage.mediaDuration];
    self.voiceRemainTimeLabel.text = voiceDuration;
}


#pragma mark -
#pragma mark UITapGestureRecognizer

- (void)enableTapGesture
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                 initWithTarget:self action:@selector(tapVoiceCellGesture:)];
    [self.messageBubbleView addGestureRecognizer:gestureRecognizer];
}

- (void)tapVoiceCellGesture:(UITapGestureRecognizer *)gestureRecognizer 
{
	//NSLog(@"DEBUG: tapAction -> self.mmsObject.messageID = %@, gestureRecognizer = %@", self.mmsObject.messageID, gestureRecognizer);
    
    // 获取手势点击的范围，然后根据时否在泡泡中来执行相应的事件
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded && 
		CGRectContainsPoint(self.messageBubbleView.bubbleRect, tapPoint)) 
    {
        switch (self.messageObject.messageStatus)
        {
            case MESSAGE_STATE_RECEIVE_RECEIVED: // 已接收
            case MESSAGE_STATE_RECEIVE_DOWNFAILED: // 下载失败
                [self downloadVoiceMessage];
                break;
                
            case MESSAGE_STATE_RECEIVE_DOWNED: // 已下载
            {
                // 取消上次播放操作，如果点击太快则取消上次的操作，以免UI卡顿。
                [NSObject cancelPreviousPerformRequestsWithTarget:self.vwcMessageSession
                                                         selector:@selector(touchPlayButton:)
                                                           object:self];
                
                [self.vwcMessageSession performSelector:@selector(touchPlayButton:) withObject:self afterDelay:0.2];
            }
                break;
            
            case MESSAGE_STATE_SEND_FAILED: // 发送失败
            case MESSAGE_STATE_SEND_SENDED: // 已发送
            case MESSAGE_STATE_SEND_ARRIVED: // 已送达
            case MESSAGE_STATE_READED: // 已读
            {
                if ([ToolsFunction isFileExistsAtPath: self.audioMessage.fileLocalPath] == NO)
                {
                    [self downloadVoiceMessage];
                    return;
                }
                // 如果当前正在播放，并且是当前点击的Cell对象
                if ([self.vwcMessageSession.audioToolsKit isPlayingVoice] &&
                    [self.vwcMessageSession.audioToolsKit.playMessageObject.messageID isEqualToString:self.audioMessage.messageID])
                {
                    // 让当前正在播放的Cell停止播放
                    [self touchStopButton];
                }
                else
                {
                    // 否则没有播放，或者不是当前的播放的对象则播放点击的语音
                    // 取消上次播放操作，如果点击太快则取消上次的操作，以免UI卡顿。
                    [NSObject cancelPreviousPerformRequestsWithTarget:self.vwcMessageSession selector:@selector(touchPlayButton:) object:self];
                    [self.vwcMessageSession performSelector:@selector(touchPlayButton:) withObject:self afterDelay:0.2];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)downloadVoiceMessage
{
    NSLog(@"UA: MessageVoiceTableCell -> downloadVoiceMessage - messageID = %@", self.messageObject.messageID);
    
	// 调用下载接口进行下载
	[RKCloudChatMessageManager downMediaFile:self.messageObject.messageID];
}

// 发送失败,点击重试
- (void)touchTryAgainButton 
{
	// 调用父类的重发函数
	[super touchResendButton:self];
}

// 手动点击停止按钮
- (void)touchStopButton
{
	NSLog(@"UA: MessageVoiceTableCell -> touchStopButton - messageID = %@", self.messageObject.messageID);
    
    if ([self.voiceWaveImageView isAnimating])
    {
        [self.voiceWaveImageView stopAnimating];
    }
    
    NSString * voiceDuration = [[NSString alloc] initWithFormat:@"%2ld\"", (long)self.audioMessage.mediaDuration];
    self.voiceRemainTimeLabel.text = voiceDuration;
    
    [self.messageBubbleView setNeedsDisplay];
    
    // 停止更新定时器
    if (self.timerForUpdate) {
        [self.timerForUpdate invalidate];
        self.timerForUpdate = nil;
    }

	// 停止当前语音播放
	[self.vwcMessageSession.audioToolsKit stopPalyVoice];
}

- (void)disableButtonAction:(BOOL)flag 
{
    [super disableButtonAction:flag];
	self.tryAgainButton.enabled = !flag;
	
	if (flag) {
		[self.vwcMessageSession.audioToolsKit stopPalyVoice];
	}
}


#pragma mark -
#pragma mark audioToolsKit Player Delegate

- (void)didPlayerStart
{
    NSLog(@"AUDIO-KIT: didPlayerStart");
    // 启动刷新播放声音时的动画效果的定时器
    [self startUpdateProgressForPlay];
}

- (void)didPlayerStop
{
    NSLog(@"AUDIO-KIT: didPlayerStop");
    // 停止更新播放声音时的动画效果
    [self stopUpdateProgressForPlay];
}

- (void)didPlayerFail
{
    NSLog(@"AUDIO-KIT: didPlayerFail");
    // 停止更新播放声音时的动画效果
    [self stopUpdateProgressForPlay];
    
    // 播放失败，文件错误提示
    [UIAlertView showSimpleAlert:nil
                         withTitle:NSLocalizedString(@"STR_PLAY_FAILURE", nil) //播放失败
                        withButton:NSLocalizedString(@"STR_CLOSE", nil)
                          toTarget:nil];
}

@end
