//
//  RKAudioToolsKit.h
//  云视互动即时通讯SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "RKCloudChat.h"

#define MAX_RECORDER_PEAK_POWER  13 // 最大的声浪表示值

@protocol AudioToolsKitRecorderDelegate <NSObject>
- (void)didRecorderSuccess;
- (void)didRecorderFail;
- (void)didStopRecorderSuccess;
- (void)didStopRecordAndPlaying;
- (void)didPlayFinish:(RKCloudChatBaseMessage *)messageObject;
@optional
@end

@protocol AudioToolsKitPlayerDelegate <NSObject>
- (void)didPlayerStart;
- (void)didPlayerStop;
- (void)didPlayerFail;
@optional
@end


/// 云视互动音频包
@interface RKCloudChatAudioToolsKit : NSObject <AVAudioSessionDelegate,
AVAudioRecorderDelegate, AVAudioPlayerDelegate>

/// 录音代理
@property (nonatomic, weak) id <AudioToolsKitRecorderDelegate> recorderDelegate;
/// 播放代理
@property (nonatomic, weak) id <AudioToolsKitPlayerDelegate> playerDelegate;

/// 录音所用到的AudioRecorder
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
/// 录音文件名称
@property (nonatomic, strong) NSString * recordVoiceFilePath;
/// 正在播放的
@property (nonatomic, strong) AVAudioPlayer * audioPlayer;
/// 录音文件的路径
@property (nonatomic, strong) NSString * playVoiceFilePath;
/// 录音文件的subtype类型
@property (nonatomic, strong) NSString * playVoiceType;
/// 正在播放的语音对象
@property (nonatomic, strong) AudioMessage *playMessageObject;


#pragma mark -
#pragma mark Init RKCloud Audio Kit Object Function

/// 初始化RKCloud Audio Kit Object.
- (id)initAudioToolsKit;

#pragma mark -
#pragma mark Record Voice Function

/**
 * @brief 判断当前设备是否支持音频输入.
 * @return 返回布尔值.
 */
- (BOOL)inputIsAvailable;
/**
 * @brief 初始化录音功能.
 */
- (void)prepareRecord;
/**
 * @brief 开始录音.
 * @return 返回布尔值.
 */
- (BOOL)startRecordVoice;
/**
 * @brief 停止录音.
 */
- (void)stopRecordVoice;

/**
 * @brief 删除当前录制的语音.
 * @return void.
 */
- (void)deleteRecordVoice;

/**
 * @brief 得到当前录音的声浪值.
 * @return 录音的声浪值.
 */
- (NSInteger)getAudioRecorderPeakPower;

/**
 * @brief 是否在录制语音.
 * @return 返回布尔值.
 */
- (BOOL)isRecordingVoice;


#pragma mark -
#pragma mark Play Audio Method

/// 开始播放MMS语音消息.
- (void)startPalyVoice:(RKCloudChatBaseMessage *)messageObject;
/// 停止播放MMS语音消息.
- (void)stopPalyVoice;
/// 判断当前是否正在播放语音.
- (BOOL)isPlayingVoice;
/// 得到当前播放的进度.
- (float)playingProgress;

/// 得到当前播放的时间
- (CGFloat)playingCurrentTime;
/// 得到播放剩余时间
- (NSInteger)playingRemainTime;

/// 删除当前转换并播放完成的语音.
- (void)deletePlayVoice;

/// 得到当前播放的声浪值
- (NSInteger)getAudioPlayerPeakPower;

@end
