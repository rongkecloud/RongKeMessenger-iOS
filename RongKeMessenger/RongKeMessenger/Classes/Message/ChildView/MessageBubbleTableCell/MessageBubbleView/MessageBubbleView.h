//
//  MessageBubbleView.h
//  RongKeMessenger
//
//  Created by Gray on 11-12-14.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//  Gray.Wang:2013.05.08: review and neaten code, delete abolish code.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "ProgressView.h"
#import "RKCloudChat.h"

// 发送消息成功时“已发”文字和泡泡左边之间的间距
#define CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE  6
// 发送消息成功时“已发”文字和泡泡底部之间的间距
#define CELL_DISTANCE_BETWEEN_SEND_AND_BOTTOM_OF_BUBBLE  3
// 接收到的消息未读标志和泡泡之间的间距
#define CELL_DISTANCE_BETWEEN_READ_FLAG_AND_RIGHT_OF_RECEIVE_BUBBLE  8
// 接收到的消息的时间和泡泡之间的间距
#define CELL_DISTANCE_BETWEEN_TIME_AND_RIGHT_OF_READ_FLAG  4
// 接收到的消息未读标志和泡泡底部之间的间距
#define CELL_DISTANCE_BETWEEN_READ_FLAG_AND_BOTTOM_OF_RECEIVE_BUBBLE  5
// 接收到的消息的时间和泡泡之间的间距
#define CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_RECEIVE_BUBBLE  3
// 进度值与旋转图片之间的距离
#define CELL_DISTANCE_BETWEEN_PROGRESS_AND_ACTIVITY  12


@interface MessageBubbleView : UIView {
}

@property (nonatomic) BOOL isRightBubble; // 是右侧的泡泡
@property (nonatomic) BOOL isMultiplayerSession; // 是多人会话
@property (nonatomic) CGRect bubbleRect; // 泡泡的尺寸

@property (nonatomic, strong) NSString *fileName; // 文件的名称
@property (nonatomic, strong) NSString *fileSize; // 文件的大小
@property (nonatomic, strong) NSString *stringDuration; // 语音消息的时长

@property (nonatomic, strong) UIImage *imageContent; // 泡泡的图片内容
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) RKCloudChatBaseMessage *mmsObject; // 多媒体短信
@property (nonatomic, strong) ProgressView *progressView; // 上传下载的进度提示窗口

// 重置messageView各种参数
- (void)resetState;

@end
