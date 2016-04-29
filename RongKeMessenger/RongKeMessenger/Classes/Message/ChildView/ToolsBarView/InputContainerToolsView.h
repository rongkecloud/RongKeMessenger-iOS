//
//  InputContainerToolsView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "RecordVoiceButton.h"

@protocol InputContainerToolsViewDelegate <NSObject>

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

@end

@interface InputContainerToolsView : UIView <HPGrowingTextViewDelegate>

@property (nonatomic, retain) HPGrowingTextView *growingTextView;
@property (nonatomic, assign) id <InputContainerToolsViewDelegate> delegate;

// 设置表情符号切换按钮的图标：YES=表情符号图标，NO=键盘图标
- (void)setEmoticonImage;

@end
