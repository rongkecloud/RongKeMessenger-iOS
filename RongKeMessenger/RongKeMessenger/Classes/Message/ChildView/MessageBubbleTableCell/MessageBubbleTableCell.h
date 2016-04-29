//
//  MessageBubbleTableCell.h
//  RongKeMessenger
//
//  Created by Gray on 11-9-19.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChat.h"
#import "RKChatSessionViewController.h"
#import "Definition.h"
#import "MessageBubbleView.h"
#import "ChatMacroDefinition.h"

@class RKChatSessionViewController;
@class CustomAvatarImageView;

@interface MessageBubbleTableCell : UITableViewCell <UIActionSheetDelegate> {
	BOOL isSenderMMS;   // 是否为本地用户发送的消息
	BOOL isTapEnabled; // 是否启用手势识别
}

@property (nonatomic, strong) RKCloudChatBaseMessage *messageObject; // 多媒体短信
@property (nonatomic, strong) MessageBubbleView *messageBubbleView; // 消息泡泡窗口
@property (nonatomic, strong) CustomAvatarImageView *userHeaderImageView;     // 用户头像的imageView
@property (nonatomic, strong) UILabel *userNameLabel;               // 现实用户的名称
@property (nonatomic, assign) RKChatSessionViewController *vwcMessageSession;


// 初始化cell (子类扩展)
- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj isEditing:(BOOL)isEditing;
- (void)disableButtonAction:(BOOL)flag;

// 设置是否选中
//- (void)setChecked:(BOOL)check;
// 长按手势处理 (弹出UIMenu)
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer;

// 重发按钮事件
- (void)touchResendButton:(id)sender;

@end
