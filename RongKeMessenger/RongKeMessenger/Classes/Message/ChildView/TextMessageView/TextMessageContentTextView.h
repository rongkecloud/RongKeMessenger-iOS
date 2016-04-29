//
//  TextMessageContentTextView.h
//  RongKeMessenger
//
//  Created by GrayWang on 14-3-11.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextMessageContentTextViewDelegate <NSObject>

- (void)longPressEvent:(UILongPressGestureRecognizer *)gestureRecognizer;
@end

@interface TextMessageContentTextView : UITextView

@property (nonatomic, strong) NSString *textContent; // 文本内容
@property (nonatomic, assign) id <TextMessageContentTextViewDelegate> textDelegate;

// 显示文本消息
- (void)displayTextMessage;

@end
