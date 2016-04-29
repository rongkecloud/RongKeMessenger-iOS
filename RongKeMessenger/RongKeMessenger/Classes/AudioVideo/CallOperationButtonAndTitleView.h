//
//  CallOperationButtonAndTitleView.h
//  RongKeMessenger
//
//  Created by Jacob on 15/8/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define OPRATION_BUTTON_WIDTH_AND_HEIGHT    85

typedef NS_ENUM(NSInteger, CallOperationButtonType)
{
    CallOperationButtonTypeAnswer = 0,   // 接听
    CallOperationButtonTypeHangUp = 1,   // 挂断
    CallOperationButtonTypeMute = 2,   // 静音
    CallOperationButtonTypeSwitchCamera = 3, // 切换摄像头
    CallOperationButtonTypeAudioChat = 4,   // 切到语音聊天
    CallOperationButtonTypeHandsFree = 5,   // 免提
};

@protocol CallOperationButtonAndTitleViewDelegate <NSObject>

- (void)touchCalloprationButtonDelegateMethod:(CallOperationButtonType)callOperationButtonType;
@end

@interface CallOperationButtonAndTitleView : UIView

@property (nonatomic, weak) id <CallOperationButtonAndTitleViewDelegate> delegate;
@property (nonatomic, assign) BOOL isButtonSelected;

- (id)initWithFrame:(CGRect)frame withCallOperationButtonType:(CallOperationButtonType)callOperationButtonType;

@end
