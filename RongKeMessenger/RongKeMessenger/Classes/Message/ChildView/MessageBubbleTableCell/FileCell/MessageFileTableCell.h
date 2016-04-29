//
//  MessageFileTableCell.h
//  RongKeMessenger
//
//  Created by Gray.Wang on 11-8-18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "AppDelegate.h"
#import "MessageBubbleTableCell.h"
#import "MessageBubbleView.h"

// MMS消息表格单元标识符
#define CELL_TABLE_MESSAGE_FILE  @"MessageFileTableCell"

@interface MessageFileTableCell : MessageBubbleTableCell

@property (nonatomic, weak) IBOutlet UIButton *tryAgainButton;   // 发送重试按钮
@property (nonatomic, weak) IBOutlet UILabel *resendLabel;       // 发送重试文字提示
@property (nonatomic, weak) IBOutlet UIImageView *fileImageView; // 发送重试按钮

@property (nonatomic, copy) NSString *filesPath;                 // 文件path

@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;     // 文件名展示label(Jacky.Chen,Add.2016.02.29)

- (IBAction)touchToTap:(id)sender;
// 发送失败，点击重试
- (IBAction)touchTryAgainButton;

@end
