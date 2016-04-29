//
//  RKMessageContainerToolsView.m
//  RongKeMessenger
//
//  Created by Jacob on 15/8/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKMessageContainerToolsView.h"
#import "Definition.h"

// 录音与更多按钮的边距
#define BUTTON_BETWEEN_BORDER_SPACE   4
#define OPERATION_BOTTON_WIDTH 30
#define OPERATION_BOTTON_HEIGHT 30

@interface RKMessageContainerToolsView() <InputContainerToolsViewDelegate>
{
    UIView *bottomView;
    BOOL isTouchRecordButton; // 录音
    BOOL isAdjustButtonFrame; // 调整button位置
    CGFloat changedHeight; // 输入文本 frame 高度变化
}

@property (nonatomic, strong) UIButton *recorderAndKeyboardButton;
@property (nonatomic, strong) UIButton *moreOperationButton;

@end

@implementation RKMessageContainerToolsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        isTouchRecordButton = NO;
        isAdjustButtonFrame = NO;
        changedHeight = 0.0;
        
        // Add Message Operation Button
        [self addMessageOprationButton];
        
        // Init InputContainerToolsView
        [self initInputContainerToolsView];
        
        // Add top and bottom line view
        [self initViewBackgroundColorAndAddLine];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

// 键盘与录音按钮的初始化
- (void)addRecorderAndKeyboardButton
{
    UIButton *recorderBt = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_BETWEEN_BORDER_SPACE, (self.frame.size.height - OPERATION_BOTTON_HEIGHT)/2, OPERATION_BOTTON_WIDTH, OPERATION_BOTTON_HEIGHT)];
    self.recorderAndKeyboardButton = recorderBt;
    
    [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_normal"] forState:UIControlStateNormal];
    [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_highlighted"] forState:UIControlStateHighlighted];
    [self.recorderAndKeyboardButton addTarget:self action:@selector(touchRecorderAndKeyboardButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.recorderAndKeyboardButton];
}

// 添加更多操作按钮
- (void)addShowMoreOperationViewButton
{
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - OPERATION_BOTTON_WIDTH - BUTTON_BETWEEN_BORDER_SPACE, (self.frame.size.height - OPERATION_BOTTON_HEIGHT)/2, OPERATION_BOTTON_WIDTH, OPERATION_BOTTON_HEIGHT)];
    self.moreOperationButton = moreButton;
    
    [self.moreOperationButton setBackgroundImage:[UIImage imageNamed:@"image_select_attach_bnt_normal"] forState:UIControlStateNormal];
    [self.moreOperationButton setBackgroundImage:[UIImage imageNamed:@"image_select_attach_bnt_highlighted"] forState:UIControlStateHighlighted];
    [self.moreOperationButton addTarget:self action:@selector(touchMoreOptionButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.moreOperationButton];
}

- (void)addMessageOprationButton
{
    // Add Recorder And Keyboard Button
    [self addRecorderAndKeyboardButton];
    
    // Add Show Operation View Button
    [self addShowMoreOperationViewButton];
}

- (void)initInputContainerToolsView
{
    CGRect inputToolsViewRect = CGRectMake(CGRectGetMaxX(self.recorderAndKeyboardButton.frame)+BUTTON_BETWEEN_BORDER_SPACE,
                                           0,
                                           CGRectGetMinX(self.moreOperationButton.frame) - CGRectGetMaxX(self.recorderAndKeyboardButton.frame)-BUTTON_BETWEEN_BORDER_SPACE,
                                           self.bounds.size.height);
    self.inputContainerToolsView = [[InputContainerToolsView alloc] initWithFrame:inputToolsViewRect];
    
    self.inputContainerToolsView.delegate = self;
    
    [self addSubview:self.inputContainerToolsView];
}

- (void)setMessageToolsButtonInitFrame
{
    CGRect recorderAndKeyboardButtonFrame = self.recorderAndKeyboardButton.frame;
    recorderAndKeyboardButtonFrame.origin.y= (self.frame.size.height - recorderAndKeyboardButtonFrame.size.height)/2;
    self.recorderAndKeyboardButton.frame = recorderAndKeyboardButtonFrame;
    
    CGRect moreOperationButtonFrame = self.moreOperationButton.frame;
    moreOperationButtonFrame.origin.y= (self.frame.size.height - moreOperationButtonFrame.size.height)/2;
    self.moreOperationButton.frame = moreOperationButtonFrame;
}


- (void)initViewBackgroundColorAndAddLine
{
    self.backgroundColor = [UIColor whiteColor];
    
    CGSize mainViewSize = self.bounds.size;
    CGFloat borderWidth = 0.5;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainViewSize.width, borderWidth)];
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - borderWidth, mainViewSize.width, borderWidth)];
    
    topView.opaque = YES;
    bottomView.opaque = YES;
    
    topView.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0f];
    bottomView.backgroundColor = [UIColor colorWithRed:212.0/255.0 green:212.0/255.0 blue:212.0/255.0 alpha:1.0f];
    
    [self addSubview:topView];
    [self addSubview:bottomView];
}

- (void)updateRecorderContainerToolsView:(RecorderCurrentType)RecorderType
{
    switch (RecorderType) {
        case RecorderInitType:
        case RecorderResetType:
        {
            self.recorderAndKeyboardButton.enabled = YES;
            self.moreOperationButton.enabled = YES;
        }
            break;
        case RecorderMoveUpType:
        case RecorderLockingType:
        {
            self.recorderAndKeyboardButton.enabled = NO;
            self.moreOperationButton.enabled = NO;
        }
            break;
            
        default:
            break;
    }
    if (self.recorderContainerToolsView)
    {
        [self.recorderContainerToolsView updateToolsButtonLayout:RecorderType];
    }
}

// 重置录制语音按钮
- (void)resetRecorderButton
{
    self.recorderAndKeyboardButton.selected = NO;
    [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_normal"] forState:UIControlStateNormal];
    [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_highlighted"] forState:UIControlStateHighlighted];
    
    self.inputContainerToolsView.hidden = NO;
    self.recorderContainerToolsView.hidden = YES;
    [self.recorderContainerToolsView layoutSubviews];
}


#pragma mark -
#pragma mark Touch Button Methods

- (void)touchMoreOptionButton
{
    isTouchRecordButton = NO;
    
    if (isAdjustButtonFrame == YES)
    {
        // 根据当前的输入框高度，调整发送按钮和表情按钮的坐标，保证其在最下端
        self.recorderAndKeyboardButton.frame = CGRectMake(self.recorderAndKeyboardButton.frame.origin.x,
                                                          self.recorderAndKeyboardButton.frame.origin.y + changedHeight,
                                                          self.recorderAndKeyboardButton.frame.size.width,
                                                          self.recorderAndKeyboardButton.frame.size.height);
        
        self.moreOperationButton.frame = CGRectMake(self.moreOperationButton.frame.origin.x,
                                                    self.moreOperationButton.frame.origin.y + changedHeight,
                                                    self.moreOperationButton.frame.size.width,
                                                    self.moreOperationButton.frame.size.height);
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y - changedHeight,
                                self.frame.size.width,
                                self.frame.size.height + changedHeight);
        
        isAdjustButtonFrame = NO;
    }
    
    self.moreOperationButton.selected = !self.moreOperationButton.selected;
    
    [self.moreOperationButton setBackgroundImage:[UIImage imageNamed:@"image_select_attach_bnt_normal"] forState:UIControlStateNormal];
    [self.moreOperationButton setBackgroundImage:[UIImage imageNamed:@"image_select_attach_bnt_highlighted"] forState:UIControlStateHighlighted];
    
    // 触发代理
    if ([self.delegate respondsToSelector:@selector(touchMoreOptionButtonDelegate)]) {
        [self.delegate touchMoreOptionButtonDelegate];
    }
    
    // 重置录制语音按钮
    [self resetRecorderButton];
}

- (void)touchRecorderAndKeyboardButton
{
    self.recorderAndKeyboardButton.selected = !self.recorderAndKeyboardButton.selected;
    if (self.recorderAndKeyboardButton.selected) // RecorderContainerView Type
    {
        isTouchRecordButton = YES;
        isAdjustButtonFrame = YES;
        
        [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_keyboard_normal"] forState:UIControlStateNormal];
        [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_keyboard_highlighted"] forState:UIControlStateHighlighted];
        self.inputContainerToolsView.hidden = YES;
        
        // Init RecorderContainerToolsView
        [self initRecorderContainerToolsView];
        self.recorderContainerToolsView.hidden = NO;
        
        // 录音时 位置不变
        self.recorderAndKeyboardButton.frame = CGRectMake(self.recorderAndKeyboardButton.frame.origin.x,
                                                          10.0,
                                                          self.recorderAndKeyboardButton.frame.size.width,
                                                          self.recorderAndKeyboardButton.frame.size.height);
        
        self.moreOperationButton.frame = CGRectMake(self.moreOperationButton.frame.origin.x,
                                                    10.0,
                                                    self.moreOperationButton.frame.size.width,
                                                    self.moreOperationButton.frame.size.height);
        
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y + changedHeight,
                                self.frame.size.width,
                                self.frame.size.height - changedHeight);
    }
    else // InputContainerToolsView Type
    {
        isTouchRecordButton = NO;
        
        [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_normal"] forState:UIControlStateNormal];
        [self.recorderAndKeyboardButton setBackgroundImage:[UIImage imageNamed:@"image_button_switch_recorder_voice_highlighted"] forState:UIControlStateHighlighted];
        
        self.inputContainerToolsView.hidden = NO;
        self.recorderContainerToolsView.hidden = YES;
        
        if (isAdjustButtonFrame == YES)
        {
            // 根据当前的输入框高度，调整发送按钮和表情按钮的坐标，保证其在最下端
            self.recorderAndKeyboardButton.frame = CGRectMake(self.recorderAndKeyboardButton.frame.origin.x,
                                                              self.recorderAndKeyboardButton.frame.origin.y + changedHeight,
                                                              self.recorderAndKeyboardButton.frame.size.width,
                                                              self.recorderAndKeyboardButton.frame.size.height);
            
            self.moreOperationButton.frame = CGRectMake(self.moreOperationButton.frame.origin.x,
                                                        self.moreOperationButton.frame.origin.y + changedHeight,
                                                        self.moreOperationButton.frame.size.width,
                                                        self.moreOperationButton.frame.size.height);
            
            self.frame = CGRectMake(self.frame.origin.x,
                                    self.frame.origin.y - changedHeight,
                                    self.frame.size.width,
                                    self.frame.size.height + changedHeight);
            
            isAdjustButtonFrame = NO;
        }
    }
    
    [self.recorderContainerToolsView layoutSubviews];
    
    if ([self.delegate respondsToSelector:@selector(touchRecorderAndKeyboardButtonDelegate:)])
    {
        [self.delegate touchRecorderAndKeyboardButtonDelegate:self.recorderAndKeyboardButton.selected];
    }
}

- (void)initRecorderContainerToolsView
{
    if (self.recorderContainerToolsView == nil)
    {
        CGRect RecorderContainerToolsViewFrame = CGRectMake(CGRectGetMaxX(self.recorderAndKeyboardButton.frame)+BUTTON_BETWEEN_BORDER_SPACE, 0, CGRectGetMinX(self.moreOperationButton.frame) - CGRectGetMaxX(self.recorderAndKeyboardButton.frame)-2*BUTTON_BETWEEN_BORDER_SPACE, 49.0);
        self.recorderContainerToolsView = [[RecorderContainerToolsView alloc] initWithFrame:RecorderContainerToolsViewFrame  withDelegate:self];
        [self addSubview:self.recorderContainerToolsView];
        
        // Set recorderAndKeyboardButton and moreOperationButton front to recorderContainerToolsView
        [self bringSubviewToFront:self.recorderAndKeyboardButton];
        [self bringSubviewToFront:self.moreOperationButton];
    }
}

#pragma mark -
#pragma mark InputContainerToolsViewDelegate Method

// 第三方输入框代理函数
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)])
    {
        [self.delegate growingTextViewShouldBeginEditing:growingTextView];
    }
    
    return YES;
}
- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)])
    {
        [self.delegate growingTextViewShouldEndEditing:growingTextView];
    }
    return YES;
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    // 获取高度差
    float diff = (growingTextView.frame.size.height - height);
    changedHeight -= diff;
    CGRect tempFrame = self.inputContainerToolsView.frame;
    tempFrame.size.height -= diff;
    
    self.inputContainerToolsView.frame = tempFrame;
    
    CGRect bottomViewFrame = bottomView.frame;
    bottomViewFrame.origin.y -= diff;
    bottomView.frame = bottomViewFrame;

    // 根据当前的输入框高度，调整发送按钮和表情按钮的坐标，保证其在最下端
    self.recorderAndKeyboardButton.frame = CGRectMake(self.recorderAndKeyboardButton.frame.origin.x,
                                                      self.recorderAndKeyboardButton.frame.origin.y-diff,
                                                      self.recorderAndKeyboardButton.frame.size.width,
                                                      self.recorderAndKeyboardButton.frame.size.height);
    
    self.moreOperationButton.frame = CGRectMake(self.moreOperationButton.frame.origin.x,
                                                self.moreOperationButton.frame.origin.y-diff,
                                                self.moreOperationButton.frame.size.width,
                                                self.moreOperationButton.frame.size.height);
    
    if ([self.delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)])
    {
        [self.delegate growingTextView:growingTextView willChangeHeight:height];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext
{
    if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
    {
        return [self.delegate growingTextView:growingTextView shouldChangeTextInRange:range replacementText:atext];
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidChange:)])
    {
        [self.delegate growingTextViewDidChange:growingTextView];
    }
}

- (void)touchEmoticonButtonDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(touchEmoticonButtonDelegateMethod)])
    {
        [self.delegate touchEmoticonButtonDelegateMethod];
    }
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(touchEmoticonButtonDelegateMethod)])
    {
        [self.delegate growingTextViewShouldReturn:growingTextView];
    }
    return YES;
}


#pragma mark -
#pragma mark RecorderContainerToolsViewDelegate Method

- (void)touchBegin
{
    self.recorderAndKeyboardButton.enabled = NO;
    self.moreOperationButton.enabled = NO;
    if ([self.delegate respondsToSelector:@selector(touchBegin)])
    {
        [self.delegate touchBegin];
    }
}
- (void)touchMove:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(touchMove:)])
    {
        [self.delegate touchMove:point];
    }
}
- (void)touchEnd:(CGPoint)point
{
    self.recorderAndKeyboardButton.enabled = YES;
    self.moreOperationButton.enabled = YES;
    
    if ([self.delegate respondsToSelector:@selector(touchEnd:)])
    {
        [self.delegate touchEnd:point];
    }
}
- (void)touchCancel
{
    if ([self.delegate respondsToSelector:@selector(touchCancel)])
    {
        [self.delegate touchCancel];
    }
}

- (void)touchLockingCancelButtonDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(touchLockingCancelButtonDelegateMethod)])
    {
        [self.delegate touchLockingCancelButtonDelegateMethod];
    }
    self.recorderAndKeyboardButton.enabled = YES;
    self.moreOperationButton.enabled = YES;
}

- (void)touchLockingSendButtonDelegateMethod
{
    if ([self.delegate respondsToSelector:@selector(touchLockingSendButtonDelegateMethod)])
    {
        [self.delegate touchLockingSendButtonDelegateMethod];
    }
    self.recorderAndKeyboardButton.enabled = YES;
    self.moreOperationButton.enabled = YES;
}


@end
