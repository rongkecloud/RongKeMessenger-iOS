//
//  RKAudioToolsKit.m
//  云视互动即时通讯SDK
//
//  Created by www.rongkecloud.com on 14/11/10.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudChatAudioToolsKit.h"
#import "RKCloudChat.h"
#import "VoiceConverter.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

@implementation RKCloudChatAudioToolsKit

#pragma mark -
#pragma mark Init RKCloud Audio Kit Object Function

// 初始化RKCloud Audio Kit Object
- (id)initAudioToolsKit {
    self = [super init];
    if (self)
    {
        self.audioRecorder = nil;
        self.recordVoiceFilePath = nil;
        self.playMessageObject = nil;
    }
    
    return self;
}

- (void)dealloc {
    
    self.audioRecorder = nil;
    self.recordVoiceFilePath = nil;
    
    self.audioPlayer = nil;
    self.playVoiceFilePath = nil;
    self.playVoiceType = nil;
    self.playMessageObject = nil;
    
    // 释放AVAudioSession实例相关设置
    [self releaseAVAudioSession];
    
    NSLog(@"DEBUG: *****AudioToolsKit dealloc*****");
}

// 初始化AVAudioSession相关设置
- (void)initAVAudioSession
{
    // Registers this class as the delegate of the audio session.
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    // Use this code instead to allow the app sound to continue to play when the screen is locked.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Registers AVAudioSessionRouteChangeNotification function
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioRouteChangeNotification:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:[AVAudioSession sharedInstance]];
    
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeDefault error:nil];
}

// 释放AVAudioSession实例相关设置
- (void)releaseAVAudioSession
{
    // 移除AudioSession监听通知事件
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:[AVAudioSession sharedInstance]];
}


#pragma mark -
#pragma mark Record Voice Function

// 判断当前设备是否支持音频输入
- (BOOL)inputIsAvailable {
    return [[AVAudioSession sharedInstance] isInputAvailable];
}

// 初始化录音功能
- (void)prepareRecord
{
    NSLog(@"AUDIO-TOOLSKIT: prepareRecord");
    // 停止正在播放的声音
    [self stopPalyVoice];
    
    // 容错处理停止录音线程
    [self stopRecordVoice];
    
    // 初始化AVAudioSession相关设置
    [self initAVAudioSession];
    
    // 进行蓝牙状态查询,然后决定输入设备
    [ToolsFunction enableSpeaker:NO];
}

// 开始录音
- (BOOL)startRecordVoice
{
    NSLog(@"AUDIO-TOOLSKIT: startRecordVoice");
    
    BOOL bSuccess = YES;
    NSError *error = nil;
    
    // 设置录音和压缩参数
    // record settings kAudioFormatMPEG4AAC kAudioFormatMPEG4AAC_LD kAudioFormatMPEG4AAC_ELD
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithCapacity:0];
    // 声音的编码格式
    [settings setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    // 声音的采样率8000次
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    // 声音的使用声道（单声道）
    [settings setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    // 声音的位深度
    [settings setValue:[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    // Encoder
    // 编码器的采样率
    [settings setValue:[NSNumber numberWithInt:12000] forKey:AVEncoderBitRateKey];
    // 编码器的位深度
    [settings setValue:[NSNumber numberWithInt:8] forKey:AVEncoderBitDepthHintKey];
    // 编码器的声道采样率
    [settings setValue:[NSNumber numberWithInt:8] forKey:AVEncoderBitRatePerChannelKey];
    // 编码器的编码质量
    [settings setValue:AVAudioQualityMin forKey:AVEncoderAudioQualityKey];
    
    // 声音文件取名
    NSString *voiceFileName = [self getMMSFileName:MESSAGE_TYPE_VOICE withApplicationFile:nil];
    // 录音文件路径
    self.recordVoiceFilePath = [RKCloudChatMessageManager getMMSFilePath:MESSAGE_TYPE_VOICE
                                                      withFileLocalName:voiceFileName
                                                       isThumbnailImage:NO];
    
    // Voice File Url
    NSURL *voiceFilePathUrl = [NSURL fileURLWithPath:self.recordVoiceFilePath];
    // Creat Recorder
    AVAudioRecorder *avAudioRecorder = [[AVAudioRecorder alloc] initWithURL:voiceFilePathUrl settings:settings error:&error];
    
    // 创建录制文件成功
    if (avAudioRecorder)
    {
        self.audioRecorder = avAudioRecorder;
        self.audioRecorder.delegate = self;
        self.audioRecorder.meteringEnabled = YES;
        
        // 开始录音
        if ([self.audioRecorder record])
        {
            [self.recorderDelegate didRecorderSuccess];
        }
        else {
            // 如果录音失败
            NSLog(@"ERROR: audioRecorder record fail!!!");
            
            [self.recorderDelegate didRecorderFail];
            // 删除空文件
            [[NSFileManager defaultManager] removeItemAtPath:self.recordVoiceFilePath
                                                       error:&error];
            
            // 清空录音文件名称
            self.recordVoiceFilePath = nil;
            bSuccess = NO;
        }
    }
    else {
        error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                    code:[error code]
                                userInfo:nil];
        bSuccess = NO;
    }
    
    
    return bSuccess;
}

// 停止录音
- (void)stopRecordVoice
{
    // 容错处理，如果在录音中则停止录音，并停止更新进度条定时器
    if (self.audioRecorder.recording)
    {
        NSLog(@"AUDIO-TOOLSKIT: stopRecordVoice");
        
        [self.audioRecorder stop];
        
        [self.recorderDelegate didStopRecorderSuccess];
    }
}

// 删除当前录制的语音
- (void)deleteRecordVoice
{
    if (self.recordVoiceFilePath) {
        
        // delete the recorded file.
        [self.audioRecorder deleteRecording];
        
        if ([ToolsFunction isFileExistsAtPath:self.recordVoiceFilePath]) {
            // 删除该文件
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:self.recordVoiceFilePath
                                                       error:&error];
        }
        
        self.recordVoiceFilePath = nil;
    }
}

// 得到当前录音的声浪值
- (NSInteger)getAudioRecorderPeakPower
{
    // 更新声浪
    [self.audioRecorder updateMeters];
    
    int voicePeakPower = ([self.audioRecorder peakPowerForChannel:0] + 30) / 3;
    
    // peak makesure 在0~9之间
    voicePeakPower = MAX(voicePeakPower, 0);
    voicePeakPower = MIN(voicePeakPower, 10);
    //NSLog(@"AUDIO-TOOLSKIT: getAudioRecorderPeakPower -> voicePeakPower = %d", voicePeakPower);
    
    return voicePeakPower;
}

// 是否在录制语音
- (BOOL)isRecordingVoice
{
    BOOL bRecording = NO;
    if (self.audioRecorder) {
        bRecording = [self.audioRecorder isRecording];
    }
    return bRecording;
}


#pragma mark -
#pragma mark AVAudioRecorder Delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"AUDIO-TOOLSKIT: raudioRecorderDidFinishRecording");
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"AUDIO-TOOLSKIT: audioRecorderEncodeErrorDidOccur error = %@", [error localizedDescription]);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    // 录音被中断
    NSLog(@"AUDIO-TOOLSKIT: audioRecorderBeginInterruption");
    
    // 停止录音并且不发送
    [self.recorderDelegate didStopRecordAndPlaying];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    // 录音中断结束
    NSLog(@"AUDIO-TOOLSKIT: audioRecorderEndInterruption");
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}


#pragma mark -
#pragma mark Play Audio Function

// 开始播放MMS语音消息
- (void)startPalyVoice:(RKCloudChatBaseMessage *)messageObject
{
    NSLog(@"AUDIO-TOOLSKIT: startPalyVoice");
    
    self.playMessageObject = (AudioMessage *)messageObject;
    
    // 准备播放语音消息
    if ([self preparePlayMMSAudio])
    {
        if (self.audioPlayer || [ToolsFunction isFileExistsAtPath:self.playVoiceFilePath] == NO)
        {
            NSLog(@"WARNING: playMMSAudio -- staticPlayer = %@ or file not exists!", self.audioPlayer);
        }
        
        NSString * cateGory = [[AVAudioSession sharedInstance] category];
        NSLog(@"DEBUG: playSoundToSpeaker - AVAudioSession cateGory = %@", cateGory);
        
        // 载入新的语音消息
        NSURL *urlFilePath = [[NSURL alloc] initFileURLWithPath:self.playVoiceFilePath];
        NSError *error = nil;
        
        // 创建播放器对象，进行播放
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:urlFilePath error:&error];
        if (self.audioPlayer == nil || error) {
            NSLog(@"ERROR: staticPlayer == nil, error = %@",  error);
        }
        
        // 设置播放器的软音量，从软件中增加语音播放的音量，从而避免开系统媒体音量50-70%而导致声音很小的问题。
        self.audioPlayer.volume = 1.5;
        self.audioPlayer.delegate = self;
        self.audioPlayer.meteringEnabled = YES;
        
        NSLog(@"AUDIO-TOOLSKIT: self.audioPlayer.volume = %f", self.audioPlayer.volume);
        
        // 2013.03.05:添加准备播放的方法，防止点击多个语音消息后切换到后台提示无法播放的问题。
        if ([self.audioPlayer prepareToPlay])
        {
            // 开始播放语音
            if ([self.audioPlayer play])
            {
                NSLog(@"AUDIO-TOOLSKIT: audioPlayer play");
                
                [self.playerDelegate didPlayerStart];
                return;
            }
            else {
                NSLog(@"ERROR: audioPlayer paly error!!!");
                [self.playerDelegate didPlayerFail];
            }
        }
        else {
            NSLog(@"WARNING: audioPlayer prepareToPlay error!!");
        }
    }
    else {
        NSLog(@"ERROR: preparePlayMMSAudio error!!");
        [self.playerDelegate didPlayerFail];
    }
    
    // 如果已经打开了光感器则关闭
    if ([[UIDevice currentDevice] isProximityMonitoringEnabled]) {
        // 播放失败后，关闭光感器
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
}

- (void)stopPalyVoice
{
    if (self.audioPlayer == nil) {
        //NSLog(@"WARNING: stopPalyVoice staticPlayer == nil return");
        return;
    }
    
    NSLog(@"AUDIO-TOOLSKIT: stopPalyVoice");
    
    // 停止接收距离感应器的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceProximityStateDidChangeNotification
                                                  object:nil];
    // 如果已经打开了光感器则关闭
    if ([[UIDevice currentDevice] isProximityMonitoringEnabled]) {
        // 关闭光感器
        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    }
    
    // 停止时判断是否在播放中
    if ([self.audioPlayer isPlaying]) {
        NSLog(@"DEBUG: self.audioPlayer isPlaying -- stop");
        // 停止播放
        [self.audioPlayer stop];
    }
    self.audioPlayer = nil;
    
    // 如果为"amr"或“wav”文件，则删除转换过的文件
    [self deletePlayVoice];
    
    // 停止后删除播放的对象和清空当前播放的类型和文件路径
    // self.playMessageObject = nil;
    self.playVoiceType = nil;
    self.playVoiceFilePath = nil;
}

- (BOOL)isPlayingVoice
{
    return [self.audioPlayer isPlaying];
}

- (float)playingProgress
{
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    
    return progress;
}

- (CGFloat)playingCurrentTime
{
    CGFloat currentTime = 0.0;
    if (self.audioPlayer)
    {
        currentTime = self.audioPlayer.currentTime;
    }
    return currentTime;
}

- (NSInteger)playingRemainTime
{
    NSInteger currentTime = 0;
    if (self.audioPlayer)
    {
        //  audioplayer 和 recorderplayer duration 相差 0.094
        double moreTime = (self.audioPlayer.duration - floor(self.audioPlayer.duration)) > 0.094 ? self.audioPlayer.duration : floor(self.audioPlayer.duration);
        
        NSInteger tatalTime = ceil(moreTime);
        NSInteger playingTime = ceil(self.audioPlayer.currentTime);
        currentTime = tatalTime - playingTime;
    }
    return currentTime;
}

- (BOOL)preparePlayMMSAudio
{
    BOOL bPreparePlay = YES;
    
    // 得到音频地址
    NSString *voiceSourcePath = self.playMessageObject.fileLocalPath;
    self.playVoiceFilePath = voiceSourcePath;
    
    // 得到声音文件类型
    NSArray *arrayFileNameSeparated = [self.playMessageObject.fileName componentsSeparatedByString:@"."];
    NSString *subType = [[NSString alloc] initWithString:[arrayFileNameSeparated objectAtIndex:([arrayFileNameSeparated count]-1)]];
    self.playVoiceType = subType;
    
    // 初始化AVAudioSession相关设置
    [self initAVAudioSession];
    
    // Gray.Wang:2015.11.19: 如果用户没有打开听筒模式，则开启距离感应器来自动切换扬声器和听筒
    if (![[UIDevice currentDevice] isProximityMonitoringEnabled] &&
        [RKCloudChatConfigManager getVoicePlayModel] == NO)
    {
        // 打开光感器
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
        // 注册光感器状态改变通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(proximityStateMonitoringChange:)
                                                     name:UIDeviceProximityStateDidChangeNotification
                                                   object:nil];
        
        // 如果是默认的输出方式，则根据距离感应器来选择扬声器或听筒
        if ([ToolsFunction getAudioRouteTypeOfOutputDevice] == IPHONE_OUTPUT_DEFAULT)
        {
            /*
             BOOL bProximity = [[UIDevice currentDevice] proximityState];
             // 根据光感状态来判断有哪个声音设备来播放声音
             [ToolsFunction enableSpeaker:!bProximity];
             */
            
            // 2013.01.31:因iPhone5的距离感应器存在问题，所以初始默认使用扬声器播放，
            // 待距离感应器起作用后则由距离感应器控制播放输出方式。
            [ToolsFunction enableSpeaker:YES];
        }
    }
    
    // 如果为Android的amr或者WinPhone的wav则需要修改新文件的后缀扩展名为“wav“格式。
    // 不为“.xxx”格式转换是为了容错酷派手机的声音文件不能播放的问题
    if (![self.playVoiceFilePath hasSuffix:@".xxx"] &&
        ([self.playVoiceType isEqualToString:@"amr"] || [self.playVoiceType isEqualToString:@"wav"]))
    {
        // 获得wav路径
        NSString *wavFilePath = [[NSString alloc] initWithFormat:@"%@.wav", self.playVoiceFilePath];
        self.playVoiceFilePath = wavFilePath;
    }
    
    // 转换Android的语音文件（因酷派的一款手机的声音文件不能播放，所以使用后缀名为：xxx的文件来区分）
    if ([self.playVoiceType isEqualToString:@"amr"] && ![self.playVoiceFilePath hasSuffix:@".xxx"])
    {
        // Convert amr to wav
        if (![VoiceConverter amrToWav:voiceSourcePath wavSavePath:self.playVoiceFilePath])
        {
            NSLog(@"ERROR: Convert AMR to WAV File Failed!!!");
            bPreparePlay = NO;
        }
    }
    
    return bPreparePlay;
}

// 删除当前转换并播放完成的语音
- (void)deletePlayVoice
{
    // 如果为"amr"或“wav”文件，则删除转换过的文件
    if (([self.playVoiceType isEqualToString:@"amr"] ||
         [self.playVoiceType isEqualToString:@"wav"]) && [ToolsFunction isFileExistsAtPath:self.playVoiceFilePath])
    {
        // 删除该文件
        [[NSFileManager defaultManager] removeItemAtPath:self.playVoiceFilePath error:nil];
    }
}

// 得到当前播放的声浪值
- (NSInteger)getAudioPlayerPeakPower
{
    // 更新声浪
    [self.audioPlayer updateMeters];
    
    float fPeakPower = [self.audioPlayer peakPowerForChannel:0];
    //NSLog(@"DEBUG: fPeakPower = %f", fPeakPower);
    
    int voicePeakPower = ((int)fPeakPower + MAX_RECORDER_PEAK_POWER * 3) / 3;
    
    // peak makesure 在0~MAX_RECORDER_PEAK_POWER之间
    voicePeakPower = MAX(voicePeakPower, 0);
    voicePeakPower = MIN(voicePeakPower, MAX_RECORDER_PEAK_POWER);
    //NSLog(@"AUDIO-TOOLSKIT: getAudioPlayerPeakPower -> voicePeakPower = %d", voicePeakPower);
    
    return voicePeakPower;
}



#pragma mark -
#pragma mark AVAudioPlayer Delegate

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    // 中断开始
    NSLog(@"AUDIO-TOOLSKIT: audioPlayerBeginInterruption");
    
    if (self.playerDelegate) {
        [self.playerDelegate didPlayerStop];
    }
    
    [self stopPalyVoice];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    // 中断结束
    NSLog(@"AUDIO-TOOLSKIT: audioPlayerEndInterruption");
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    // 语音自动播放完成
    NSLog(@"AUDIO-TOOLSKIT: audioPlayerDidFinishPlaying");
    
    // 停止全局播放，并释放静态变量内存
    [self.recorderDelegate didPlayFinish:self.playMessageObject];
    [self stopPalyVoice];
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}


#pragma mark -
#pragma mark Notification Center Methods

// 光感器状态改变方法
- (void)proximityStateMonitoringChange:(NSNotification *)notification
{
    // 判断当前输出的设备是默认的并在播放语音过程中
    if ([ToolsFunction getAudioRouteTypeOfOutputDevice] == IPHONE_OUTPUT_DEFAULT &&
        [self isPlayingVoice]) {
        
        BOOL bProximity = [[UIDevice currentDevice] proximityState];
        
        // 控制音频输出方式，根据光感状态来转换，如果为贴近耳朵，则从听筒出声，反之则通过喇叭出声
        [ToolsFunction enableSpeaker:!bProximity];
    }
}

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
    NSLog(@"DEBUG: audioRouteChangeNotification: notification.userInfo = %@,\n routeDescription = %@", dictInfo, routeDescription);
    
    /*NSArray * arrayInputs = [routeDescription inputs];
     for (int i = 0; i < [arrayInputs count]; i++)
     {
     AVAudioSessionPortDescription *inputsPortDescription = [arrayInputs objectAtIndex:i];
     NSLog(@"DEBUG: inputsPortDescription = %@", inputsPortDescription);
     }*/
    NSString *strOldOutputDeviceType = nil;
    NSArray * arrayOutputs = [routeDescription outputs];
    for (int i = 0; i < [arrayOutputs count]; i++)
    {
        AVAudioSessionPortDescription *outputsPortDescription = [arrayOutputs objectAtIndex:i];
        strOldOutputDeviceType = outputsPortDescription.portType;
        
        NSLog(@"DEBUG: outputsPortDescription portName = %@ , portType = %@", outputsPortDescription.portName,outputsPortDescription.portType);
    }
    
    NSString *strNewOutputDeviceType = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    if ([currentRoute.outputs count] > 0)
    {
        AVAudioSessionPortDescription *newRoute = [currentRoute.outputs objectAtIndex:0];
        strNewOutputDeviceType = newRoute.portType;
    }
    
    switch (audioRouteChangeReason)
    {
        case kAudioSessionRouteChangeReason_NewDeviceAvailable:
        case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
        case kAudioSessionRouteChangeReason_RouteConfigurationChange:
        {
            if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP])
            {
                // 具备蓝牙时更改为音频源
            }
            else if ([strNewOutputDeviceType isEqualToString:AVAudioSessionPortBuiltInSpeaker] &&
                     ([strOldOutputDeviceType isEqualToString:AVAudioSessionPortLineOut] ||
                      [strOldOutputDeviceType isEqualToString:AVAudioSessionPortBluetoothHFP]))
            {
                // 从耳机转到听筒 或 从备蓝牙转到听筒时
                
                // 如果是默认的输出方式，则根据距离感应器来选择扬声器或听筒
                if ([ToolsFunction getAudioRouteTypeOfOutputDevice] == IPHONE_OUTPUT_DEFAULT)
                {
                    BOOL bProximity = [[UIDevice currentDevice] proximityState];
                    // 根据光感状态来判断有哪个声音设备来播放声音
                    [ToolsFunction enableSpeaker:!bProximity];
                }
            }
        }
            break;
            
        default:
            break;
    }
}

// 根据多媒体类型给文件命名（在外部Release）
- (NSString *)getMMSFileName:(int)nMMSType withApplicationFile:(NSString *)name
{
    NSString *fileName = nil;
    NSString *extName = nil;
    
    // 定义时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYMMddhhmmssSSS";
    
    switch (nMMSType)
    {
        case MESSAGE_TYPE_IMAGE:
        {
            // 图片后缀名
            extName = @".png";
        }
            break;
            
        case MESSAGE_TYPE_VOICE:
            // 声音后缀名
            extName = @".3gp";
            break;
            
        case MESSAGE_TYPE_FILE:
            // 文件的原始后缀名
            extName = [NSString stringWithFormat:@".%@", [name pathExtension]];
            break;
            
        default:
            break;
    }
    
    fileName = [[NSString alloc] initWithFormat:@"%@_%@", [RKCloudBase getUserName],
                [[formatter stringFromDate:[NSDate date]] stringByAppendingString:extName]];
    
    return fileName;
}

@end
