//
//  MessageVoiceTableCell.h
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  语音消息的表格单元

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Definition.h"
#import "AppDelegate.h"
#import "MessageBubbleTableCell.h"
#import "MessageBubbleView.h"

// MMS消息表格单元标识符
#define CELL_TABLE_MESSAGE_VOICE      @"MessageVoiceTableCell"

@interface MessageVoiceTableCell : MessageBubbleTableCell <AudioToolsKitPlayerDelegate>

@property (nonatomic, assign) AudioMessage *audioMessage; // 语音消息对象

@end
