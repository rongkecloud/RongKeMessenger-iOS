//
//  MessageTextTableCell.h
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  文字消息的表格单元（Gray.Wang:20110819实现文本消息记录图文混排绘制，并增加长按手势拷贝动作）

#import <UIKit/UIKit.h>
#import "TextMessageContentView.h"
#import "MessageBubbleTableCell.h"
#import "MessageBubbleView.h"
#import "TextMessageContentTextView.h"

// MMS消息表格单元标识符
#define CELL_TABLE_MESSAGE_TEXT	      @"MessageTextTableCell"

@interface MessageTextTableCell : MessageBubbleTableCell <UIActionSheetDelegate, TextMessageContentTextViewDelegate>

@property (nonatomic, weak) IBOutlet UIButton *tryAgainButton; //重新发送BUtton;
@property (nonatomic, weak) IBOutlet UILabel *resendLabel;
@property (nonatomic, weak) IBOutlet TextMessageContentView *textMessageContentView; // 文本消息内容加载显示的View
@property (retain, nonatomic) IBOutlet TextMessageContentTextView *textMessageContentTextView; // 文本消息内容加载显示的View，针对ios7的属性化

//@property (nonatomic, retain) IBOutlet UIWebView *textWebView; // 显示文本和表情的WebView
//@property (nonatomic, retain) NSString * textMessageString;

@property (nonatomic, retain) NSMutableArray *urlsArray;

// 重新发送
- (IBAction)touchTryAgainButton;

@end
