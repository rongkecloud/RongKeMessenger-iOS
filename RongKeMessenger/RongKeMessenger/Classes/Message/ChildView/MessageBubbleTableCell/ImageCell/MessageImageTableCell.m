//
//  MessageImageTableCell.m
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
#import "RKChatSessionViewController.h"
#import "MessageImageTableCell.h"
#import "ToolsFunction.h"
#import "Definition.h"
#import "RKCloudChat.h"
#import "ChatMacroDefinition.h"


@implementation MessageImageTableCell

@synthesize tryAgainButton;
@synthesize resendLabel;


- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj isEditing:(BOOL)isEditing
{
	// 父类初始化
	[super initCellContent:messageObj isEditing:isEditing];
    
	// 初始化时隐藏重发按钮
	self.tryAgainButton.hidden = YES;
    self.resendLabel.hidden = YES;
    self.resendLabel.backgroundColor = [UIColor clearColor];
    self.resendLabel.text = NSLocalizedString(@"STR_RESENT_MANUALLY", nil);
	
    ImageMessage *imageMessage = (ImageMessage *)self.messageObject;
    
    // FIXME:
    // 对图片进行处理并加载图片
    UIImage *thumbnailImage = [UIImage imageWithContentsOfFile:imageMessage.thumbnailPath];
    if (thumbnailImage)
    {
        // 设置消息图片
        [self.messageBubbleView setImageContent:thumbnailImage];
    } else {
        // 下载缩略图（Jacky.Chen:2016.02.18:修正收到新消息缩略图下载失败后不再展示缩略图的问题）
        [RKCloudChatMessageManager downThumbImage:imageMessage.messageID];
        // 设置消息默认图片
        [self.messageBubbleView setImageContent:[UIImage imageNamed:@"default_image_bg"]];
    }
}

// 显示内容
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	
    // 设置图片大小
    CGSize size = [ToolsFunction sizeScaleFixedThumbnailImageSize:self.messageBubbleView.imageContent.size];
	
    // 设置图片坐标
    if (isSenderMMS) 
	{
        // 右侧消息
        imageCGRect = CGRectMake(UISCREEN_BOUNDS_SIZE.width - size.width - CELL_MESSAGE_BUBBLE_RIGHT_DISTANCE + CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE,
                                 CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
                                 size.width,
                                 size.height);
        
        if (self.messageObject.messageStatus == MESSAGE_STATE_SEND_FAILED)
        {
            [self.tryAgainButton setHidden:NO];
            
            // 根据DCR的需求去掉重发的提示，暂时对该控件隐藏的处理 14.8.7
            [self.resendLabel setHidden:YES];
            
            // 重发图标按钮的显示
            float unReadImageOriginX = imageCGRect.origin.x - self.tryAgainButton.frame.size.width - CELL_DISTANCE_BETWEEN_STATUS_AND_LEFT_OF_BUBBLE;
            float unReadImageOriginY = CGRectGetMaxY(imageCGRect) - self.tryAgainButton.frame.size.height - CELL_DISTANCE_BETWEEN_STATUS_AND_BOTTOM_OF_BUBBLE;
            [self.tryAgainButton setFrame:CGRectMake(unReadImageOriginX,
                                                     unReadImageOriginY,
                                                     self.tryAgainButton.frame.size.width,
                                                     self.tryAgainButton.frame.size.height)];
            
            // 重发title的显示
            float resendLabelOriginX = self.tryAgainButton.frame.origin.x - CELL_DISTANCE_BETWEEN_TIME_AND_LEFT_OF_STATUS - self.resendLabel.frame.size.width;
            float resendLabelOriginY = CGRectGetMaxY(imageCGRect) - self.resendLabel.frame.size.height - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE;
            [self.resendLabel setFrame:CGRectMake(resendLabelOriginX,
                                                  resendLabelOriginY,
                                                  self.resendLabel.frame.size.width,
                                                  self.resendLabel.frame.size.height)];
        }
        else {
            [self.tryAgainButton setHidden:YES];
            [self.resendLabel setHidden:YES];
        }
    }
    else {
        // 左侧泡泡的Rect计算
        imageCGRect = CGRectMake(CELL_MESSAGE_BUBBLE_LEFT_DISTANCE,
                                 CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
                                 size.width,
                                 size.height);
    }
    
    [self.messageBubbleView setBubbleRect:imageCGRect];
	// 刷新显示内容
	[self.messageBubbleView setNeedsDisplay];
}


#pragma mark -
#pragma mark UITapGestureRecognizer

// 开启手势识别功能
- (void)enableTapGesture
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(tapImageCellGesture:)];
    [self.messageBubbleView addGestureRecognizer:gestureRecognizer];
}

- (void)tapImageCellGesture:(UITapGestureRecognizer *)gestureRecognizer 
{    
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
		CGRectContainsPoint(imageCGRect, tapPoint)) 
	{
         // 获取当前消息状态
        switch (self.messageObject.messageStatus)
        {
            case MESSAGE_STATE_SEND_SENDING:
            case MESSAGE_STATE_SEND_FAILED:
            case MESSAGE_STATE_SEND_SENDED:
            case MESSAGE_STATE_RECEIVE_DOWNED:
            case MESSAGE_STATE_SEND_ARRIVED:
            case MESSAGE_STATE_READED:
            {
                BOOL isThumbnail = NO;
                if ([ToolsFunction isFileExistsAtPath: ((ImageMessage *)self.messageObject).fileLocalPath] == NO)
                {
                    isThumbnail = YES;
                    [RKCloudChatMessageManager downMediaFile:self.messageObject.messageID];
                }
                [self.vwcMessageSession pushImagePreviewViewController:self.messageObject
                                                isThumbnail: isThumbnail];
                break;
            }
                
            case MESSAGE_STATE_RECEIVE_RECEIVED:
            case MESSAGE_STATE_RECEIVE_DOWNFAILED:
                // 如果没下载就下载
            {
               [RKCloudChatMessageManager downMediaFile:self.messageObject.messageID];
            }
            case MESSAGE_STATE_RECEIVE_DOWNING:
                [self.vwcMessageSession pushImagePreviewViewController:self.messageObject
                                                           isThumbnail:YES];
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Touch Button Action

// 发送失败，点击重试
- (IBAction)touchTryAgainButton {
	// 调用父类的重发函数
	[super touchResendButton:self];
}

- (void)disableButtonAction:(BOOL)flag
{
    [super disableButtonAction:flag];
    
    self.tryAgainButton.enabled = !flag;    
}

@end
