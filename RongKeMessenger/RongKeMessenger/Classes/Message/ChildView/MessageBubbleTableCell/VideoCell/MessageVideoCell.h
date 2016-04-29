//
//  MessageVideoCell.h
//  RongKeMessenger
//
//  Created by Jacob on 16/4/9.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBubbleTableCell.h"

// MMS消息表格单元标识符
#define CELL_TABLE_MESSAGE_VIDEO  @"MessageVideoCell"

@interface MessageVideoCell : MessageBubbleTableCell
{
    CGRect videoImageCGRect;
}

@property (nonatomic, weak) IBOutlet UIButton *tryAgainButton; // 发送重试按钮
@property (nonatomic, weak) IBOutlet UILabel *resendLabel;

@end
