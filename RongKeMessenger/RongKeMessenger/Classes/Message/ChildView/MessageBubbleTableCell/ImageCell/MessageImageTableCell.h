//
//  MessageImageTableCell.h
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  图片消息的表格单元

#import <UIKit/UIKit.h>
#import "MessageBubbleTableCell.h"
#import "MessageBubbleView.h"

// MMS消息表格单元标识符
#define CELL_TABLE_MESSAGE_IMAGE      @"MessageImageTableCell"

@interface MessageImageTableCell : MessageBubbleTableCell {
    CGRect imageCGRect;
}
@property (nonatomic, weak) IBOutlet UIButton *tryAgainButton; // 发送重试按钮
@property (nonatomic, weak) IBOutlet UILabel *resendLabel;

@end
