//
//  RecordVoiceView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RecordVoiceButton.h"
#import "Definition.h"

@interface RecordVoiceButton ()
{
}

@end

@implementation RecordVoiceButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.isAutoFinishRecord = NO;
        
        self.isNeedBorder = YES;
        self.isNoNeedCorner = NO;
        self.cornerRadius = 3.0;
        
        // 设置按钮背景颜色（默认255 255 255 按下226 226 226）
        [self setBackgroundStateNormalColor:[UIColor whiteColor]];
        [self setBackgroundStateHighlightedColor:COLOR_WITH_RGB(226, 226, 226)];
        [self setBorderStateDisabledColor:[UIColor grayColor]];
        
        // 设置按钮边框线条颜色
        [self setBorderStateNormalColor:[UIColor lightGrayColor]];
        [self setBorderStateHighlightedColor:[UIColor lightGrayColor]];
        
        // 设置按钮标题文字
        [self setTitle:NSLocalizedString(@"STR_HOLD_RECORDING", "按住说话")
              forState:UIControlStateNormal];
        [self setTitle:NSLocalizedString(@"STR_HAND_FREE_RECORDING", "松开结束")
              forState:UIControlStateHighlighted];
        [self setTitle:NSLocalizedString(@"STR_NO_AUDIO_INPUT", nil)
              forState:UIControlStateDisabled];
        
        // 设置按钮标题文字颜色
        [self setTitleColor:[UIColor colorWithRed:65/255.0 green:68/255.0 blue:76/255.0 alpha:1.0]
                   forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:93/255.0 green:96/255.0 blue:106/255.0 alpha:1.0]
                   forState:UIControlStateDisabled];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
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
#pragma mark UITouch methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    
    self.isAutoFinishRecord = NO;
    
    if ([self.delegate respondsToSelector:@selector(touchBegin)])
    {
        [self.delegate touchBegin];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    
    if (self.isAutoFinishRecord == NO && [self.delegate respondsToSelector:@selector(touchMove:)])
    {
        CGPoint point = [[touches anyObject] locationInView: self];
        [self.delegate touchMove: point];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    
    // 如果是录制了60，自动发送消息，则返回
    if (self.isAutoFinishRecord)
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(touchEnd:)])
    {
        CGPoint point = [[touches anyObject] locationInView: self];
        [self.delegate touchEnd: point];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    
    // 如果是录制了60，自动发送消息，则返回
    if (self.isAutoFinishRecord)
    {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(touchCancel)])
    {
        [self.delegate touchCancel];
    }
}

@end
