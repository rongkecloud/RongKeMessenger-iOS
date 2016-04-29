//
//  ProgressView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

// 标识从哪个功能模块开启的图片预览功能
typedef NS_ENUM(NSInteger, CallProgressType)
{
    FROM_OTHER                              = 0, // other call
    FROM_MESSAGE_SESSION_LIST_BUBBLE        = 1, // 从消息会话列表泡泡调用下载进度
    FROM_MESSAGE_SESSION_LIST_IMAGE_PREVIEW = 2, // 从消息会话列表预览图片时调用下载进度
    FROM_MOMENT_LIST_OR_MOMENT_DETAIL_PREVIEW = 3 // 从 动态列表或者动态详情预览图片时调用的下载进度
};

#define PROGRESS_LABEL_TEXT_FOUNT     14


@interface ProgressView : UIView
{
    UIImageView *imageView;  // 添加动画的ImageView
}

@property (nonatomic, retain) NSString *messageID; // 当前消息对应的messageId
@property (nonatomic, retain) UILabel *progressLabel; // 显示进度百分比的Label
@property (nonatomic,assign) CallProgressType callProgressViewType; // 调用下载进度类型

// 刷新progress动画
- (void)runSpinAnimationWithDuration;

- (id)initWithFrame:(CGRect)frame withCallType:(CallProgressType)callType;

@end
