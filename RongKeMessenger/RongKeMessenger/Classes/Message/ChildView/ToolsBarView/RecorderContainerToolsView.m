//
//  RecorderContainerToolsView.m
//
//
//  Created by Gray on 14-1-20.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RecorderContainerToolsView.h"
#import "Definition.h"
#import "ToolsFunction.h"

// 录音按钮的高度
#define RECORD_BUTTON_HEIGHT     35

@interface RecorderContainerToolsView()
{
}


@end

@implementation RecorderContainerToolsView

- (id)initWithFrame:(CGRect)frame withDelegate:(id)delegateParam
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = delegateParam;
        
        self.backgroundColor = [UIColor clearColor];
        
        // Add recorder button
        [self initRecorderToolsButton:delegateParam];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark -
#pragma mark Custom Methods

- (void)initRecorderToolsButton:(id)delegateParam
{
    // 创建录音窗口
    self.recordVoiceButton = [[RecordVoiceButton alloc] initWithFrame:CGRectZero];
    self.recordVoiceButton.delegate = delegateParam;
    [self addSubview:self.recordVoiceButton];
    
    self.recordVoiceButton.frame = CGRectMake(0,
                                              (self.frame.size.height - RECORD_BUTTON_HEIGHT)/2,
                                              self.frame.size.width,
                                              RECORD_BUTTON_HEIGHT);
}

// 根据录音的不同状态更新操作按钮的布局
- (void)updateToolsButtonLayout:(RecorderCurrentType)RecorderType
{
    switch (RecorderType)
    {
        case RecorderInitType:
        {
            [self.recordVoiceButton setTitle:NSLocalizedString(@"STR_HOLD_RECORDING", "按住说话") forState:UIControlStateHighlighted];
        }
            break;
        case RecorderLockingType:
        {
            // Show cancel and send button
        }
            break;
        case RecorderMoveUpType:
        {
            [self.recordVoiceButton setTitle:NSLocalizedString(@"STR_LOOSEN_SEND_VOICE_MESSAGE", nil) forState:UIControlStateHighlighted];
        }
            break;
        case RecorderResetType:
        {
            [self.recordVoiceButton setHighlighted:NO];
            [self.recordVoiceButton setTitle:NSLocalizedString(@"STR_HOLD_RECORDING", nil) forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Touch Button Methods

// 点击锁定时取消与发送按钮的代理方法
- (void)touchLockingCancelButton
{
    if ([self.delegate respondsToSelector:@selector(touchLockingCancelButtonDelegateMethod)])
    {
        [self.delegate touchLockingCancelButtonDelegateMethod];
    }
}

- (void)touchLockingSendButton
{
    if ([self.delegate respondsToSelector:@selector(touchLockingSendButtonDelegateMethod)])
    {
        [self.delegate touchLockingSendButtonDelegateMethod];
    }
}

@end
