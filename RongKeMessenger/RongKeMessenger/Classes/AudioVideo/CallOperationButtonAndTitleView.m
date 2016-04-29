//
//  CallOperationButtonAndTitleView.m
//  RongKeMessenger
//
//  Created by Jacob on 15/8/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "CallOperationButtonAndTitleView.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "RKCloudUICallViewController.h"

@interface CallOperationButtonAndTitleView()

@property (nonatomic, strong) UIButton *oprationButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic) CallOperationButtonType callOperationButtonType;

@end

@implementation CallOperationButtonAndTitleView

- (id)initWithFrame:(CGRect)frame withCallOperationButtonType:(CallOperationButtonType)callOperationButtonType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isButtonSelected = NO;
        self.callOperationButtonType = callOperationButtonType;
        [self layoutOprationButtonAndTittle:callOperationButtonType];
        self.backgroundColor = [UIColor clearColor];
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

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    NSString *buttonTitle = nil;
    NSString *buttonImageName = nil;
    
    switch (self.callOperationButtonType)
    {
        case CallOperationButtonTypeAnswer:  // 接听按钮
        {
//            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_ANSWER", @"接听");
            buttonImageName = @"call_button_answer_normal";
        }
            break;
            
        case CallOperationButtonTypeHangUp:  // 挂断按钮
        {
//            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_HANGUP", @"取消");
            buttonImageName = @"call_button_hangup_normal";
        }
            break;
            
        case CallOperationButtonTypeMute:  // 静音
        {
            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_MUTE", @"静音");
            if (self.isButtonSelected == YES) {
                buttonImageName = @"call_opration_button_mute_pressed"; // 静音图标
            }
            else {
                buttonImageName = @"call_opration_button_mute_nor"; // 非静音图标
            }
        }
            break;
            
        case CallOperationButtonTypeSwitchCamera:  // 切换摄像头
        {
            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_SWITCH_CAMERA", @"切换摄像头");
            if (self.isButtonSelected == YES) {
                buttonImageName = @"call_opration_button_switch_camera_press"; // 后置摄像头
            }
            else {
                buttonImageName = @"call_opration_button_switch_camera_nor"; // 前置摄像头
            }
        }
            break;
            
        case CallOperationButtonTypeAudioChat:  // 切到语音聊天
        {
            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_SWITCH_AUDIO_CHAT", @"切到语音聊天");
            buttonImageName = @"call_opration_button_switch_video_nor";
            [self.oprationButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
            [self.oprationButton setImage:[UIImage imageNamed:@"call_opration_button_switch_video_pre"] forState:UIControlStateHighlighted];
        }
            break;
            
        case CallOperationButtonTypeHandsFree:  // 免提
        {
            buttonTitle = NSLocalizedString(@"STR_CALL_BUTTON_HANDS_FREE", @"免提");
            if (self.isButtonSelected == YES) {
                buttonImageName = @"call_opration_button_hands_free_pressed"; // 免提
            }
            else {
                buttonImageName = @"call_opration_button_hands_free_normal"; // 非免提
            }
        }
            break;
        default:
            break;
    }
    
    [self.oprationButton setImage:nil forState:UIControlStateNormal];
    [self.oprationButton setImage:[UIImage imageNamed:buttonImageName] forState:UIControlStateNormal];
    self.titleLabel.text = buttonTitle;
}

- (void)layoutOprationButtonAndTittle:(CallOperationButtonType)callOperationButtonType
{
    self.oprationButton = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - OPRATION_BUTTON_WIDTH_AND_HEIGHT)/2, 0, OPRATION_BUTTON_WIDTH_AND_HEIGHT, OPRATION_BUTTON_WIDTH_AND_HEIGHT)];
    self.oprationButton.tag = CALL_OPRATION_BUTTON_TAG + callOperationButtonType;
    [self.oprationButton addTarget:self action:@selector(touchOprationButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.oprationButton];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 15, CGRectGetWidth(self.frame), 21)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = FONT_TEXT_SIZE_12;
    self.titleLabel.textColor = COLOR_WITH_RGB(255, 255, 255);
    [self addSubview:self.titleLabel];
}

- (void)touchOprationButtonMethod:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(touchCalloprationButtonDelegateMethod:)]) {
        NSInteger buttonTag = [(UIButton *)sender tag] - CALL_OPRATION_BUTTON_TAG;
        [self.delegate touchCalloprationButtonDelegateMethod:buttonTag];
    }
}

@end
