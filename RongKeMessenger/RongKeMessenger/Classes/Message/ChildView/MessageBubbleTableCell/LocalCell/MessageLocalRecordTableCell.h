//
//  MessageLocalRecordTableCell.h
//  RongKeMessenger
//
//  Created by Jacob on 15/3/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageBubbleTableCell.h"

#define CELL_TABLE_MESSAGE_LOCAL_RECORD      @"MessageLocalRecordTableCell"

@interface MessageLocalRecordTableCell : MessageBubbleTableCell

@property (nonatomic, weak) IBOutlet UITextView *textContentTextView;
@property (nonatomic, weak) IBOutlet UIImageView *typeImageView;

@end
