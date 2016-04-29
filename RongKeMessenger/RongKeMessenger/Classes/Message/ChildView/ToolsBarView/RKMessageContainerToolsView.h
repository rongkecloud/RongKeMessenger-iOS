//
//  RKMessageContainerToolsView.h
//  RongKeMessenger
//
//  Created by Jacob on 15/8/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputContainerToolsView.h"
#import "RecorderContainerToolsView.h"


@protocol RKMessageContainerToolsViewDelegate <NSObject>

// 第三方输入框代理函数
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView;
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height;
- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height;
- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext;
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView;
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView;

// 点击表情按钮的代理函数
- (void)touchEmoticonButtonDelegateMethod;
// 点击录音／键盘按钮的代理方法
- (void)touchRecorderAndKeyboardButtonDelegate:(BOOL)isRecorderType;
// 点击事件
- (void)touchBegin;
- (void)touchMove:(CGPoint)point;
- (void)touchEnd:(CGPoint)point;
- (void)touchCancel;

// 点击锁定时取消与发送的代理方法
- (void)touchLockingCancelButtonDelegateMethod;
- (void)touchLockingSendButtonDelegateMethod;

// 点击更多功能选项按钮
- (void)touchMoreOptionButtonDelegate;

@end

@interface RKMessageContainerToolsView : UIView

@property (nonatomic, assign) id <RKMessageContainerToolsViewDelegate> delegate;
@property (nonatomic, retain) InputContainerToolsView *inputContainerToolsView;
@property (nonatomic, retain) RecorderContainerToolsView *recorderContainerToolsView;

// 表情按钮的状态的设置
- (void)setMessageToolsButtonInitFrame;
// 根据Recorder的状态更新UI布局
- (void)updateRecorderContainerToolsView:(RecorderCurrentType)RecorderType;

@end
