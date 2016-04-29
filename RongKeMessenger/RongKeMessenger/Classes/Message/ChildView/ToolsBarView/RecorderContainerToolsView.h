//
//  RecorderContainerToolsView.h
//
//
//  Created by Gray on 14-1-20.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RecordVoiceButton.h"

typedef NS_ENUM(NSInteger, RecorderCurrentType)
{
    RecorderInitType = 0,       // Recorder处于初始化得状态
    RecorderMoveUpType = 1,     // Recorder时手指上移状态
    RecorderLockingType = 2,    // Recorder处于松开手指继续录音的锁定状态
    RecorderResetType = 3,      // Recorder时遇到来电强行取消
};

@protocol RecorderContainerToolsViewDelegate <NSObject>

// 点击锁定时取消与发送按钮的代理方法
- (void)touchLockingCancelButtonDelegateMethod;
- (void)touchLockingSendButtonDelegateMethod;

@end

@interface RecorderContainerToolsView : UIView
@property (nonatomic, strong) RecordVoiceButton * recordVoiceButton; // 录制语音的view
@property (nonatomic, assign) id <RecorderContainerToolsViewDelegate> delegate;


// 初始化控件
- (id)initWithFrame:(CGRect)frame withDelegate:(id)delegateParam;
// 根据录音的不同状态更新操作按钮的布局
- (void)updateToolsButtonLayout:(RecorderCurrentType)RecorderType;

@end
