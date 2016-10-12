//
//  MessageLocalRecordTableCell.m
//  RongKeMessenger
//
//  Created by Jacob on 15/3/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "MessageLocalRecordTableCell.h"
#import "RKCloudChatBaseMessage.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "CallManager.h"

// 消息cell中内容距离左边或右边的间距
#define CELL_CONTENT_LEFT_OR_RIGHT_SEPARATION  5


@implementation MessageLocalRecordTableCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    [self.textContentTextView setFont:MESSAGE_TEXT_FONT];
    [self.textContentTextView setBackgroundColor:[UIColor clearColor]];
    
    self.textContentTextView.userInteractionEnabled = NO;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj isEditing:(BOOL)isEditing
{
    [super initCellContent:messageObj isEditing:isEditing];
    
    self.textContentTextView.text = [ChatManager getLocalMesssageTextContent:messageObj];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // Jacky.Chen add 设置语音时间文字颜色
    if (isSenderMMS) {
        // 本地为白色
        self.textContentTextView.textColor = MESSAGE_TEXT_COLOR_SELF;
    }else
    {
        self.textContentTextView.textColor = MESSAGE_TEXT_COLOR_OTHER;
        
    }
    // 泡泡、图标、文本的尺寸
    CGRect textBubbleViewRect = CGRectZero;
    CGRect typeImageViewFrame = CGRectZero;
    CGRect textContentLabelFrame = CGRectZero;
    
    textContentLabelFrame.size = [ChatManager getTextCellSizeFromStringInTextView:self.textContentTextView.text withMaxWidth:MESSAGE_LOCAL_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
    NSInteger numberLine = textContentLabelFrame.size.height/MESSAGE_LINE_HEIGHT;
    
    int bubbleViewWidth = textContentLabelFrame.size.width + CELL_TEXT_LEFT_AND_RIGHT_IOS7_EARLIER ;
    
    // 通过本地消息对象的扩展信息判断不同的类型获取不同的图标
    UIImage *imageIcon = [self getCallTypeImage];
    if (imageIcon) {
        // 加载图标
        self.typeImageView.image = imageIcon;
        typeImageViewFrame = self.typeImageView.frame;
        
        bubbleViewWidth = bubbleViewWidth + typeImageViewFrame.size.width;
    }
    else {
        self.typeImageView.hidden = YES;
    }
    
    // 是否为本地发送消息
    if (isSenderMMS)
    {
        // 右侧泡泡的Rect x坐标
        float frameOriginX = UISCREEN_BOUNDS_SIZE.width - bubbleViewWidth - CELL_AVATAR_WIDTH - CELL_TEXT_LEFT_AND_RIGHT - CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE - 5;
        
        textBubbleViewRect = CGRectMake(frameOriginX, CELL_MESSAGE_BUBBLE_TOP_DISTANCE, bubbleViewWidth, CELL_MESSAGE_TOP_DISTANCE + MESSAGE_LINE_HEIGHT * numberLine + CELL_MESSAGE_BUTTOM_DISTANCE);
        
        // 如果存在图标则计算图标位置
        if ([self.typeImageView isHidden] == NO) {
            // 获取状态图标的OriginX
            typeImageViewFrame.origin.x = CGRectGetMinX(textBubbleViewRect) + CELL_CONTENT_LEFT_OR_RIGHT_SEPARATION;
            // 修正y坐标
            typeImageViewFrame.origin.y = CGRectGetMinY(textBubbleViewRect) + CELL_MESSAGE_TOP_DISTANCE;
        }
        
        // 获取详细描述的OriginX
        textContentLabelFrame.origin.x = frameOriginX + CGRectGetWidth(typeImageViewFrame) + CELL_CONTENT_LEFT_OR_RIGHT_SEPARATION;
        textContentLabelFrame.origin.y = CGRectGetMinY(textBubbleViewRect) + 2;
    }
    else
    {
        // 以下坐标由左至右开始计算，55为泡泡和左边的间距
        float frameOriginX = CELL_MESSAGE_BUBBLE_LEFT_DISTANCE;
        
        textBubbleViewRect = CGRectMake(frameOriginX, CELL_MESSAGE_BUBBLE_TOP_DISTANCE, bubbleViewWidth, CELL_MESSAGE_TOP_DISTANCE + MESSAGE_LINE_HEIGHT * numberLine + CELL_MESSAGE_BUTTOM_DISTANCE);
        
        // 如果存在图标则计算图标位置
        if ([self.typeImageView isHidden] == NO) {
            // 修正声浪view坐标
            typeImageViewFrame.origin.x = frameOriginX + CELL_CONTENT_LEFT_OR_RIGHT_SEPARATION + CELL_TEXT_LEFT_AND_RIGHT;
            // 修正y坐标
            typeImageViewFrame.origin.y = CGRectGetMinY(textBubbleViewRect) + CELL_MESSAGE_TOP_DISTANCE;
        }
        
        // 获取详细描述的OriginX
        textContentLabelFrame.origin.x = frameOriginX + CELL_CONTENT_LEFT_OR_RIGHT_SEPARATION + CGRectGetWidth(typeImageViewFrame) + CELL_TEXT_LEFT_AND_RIGHT;
        textContentLabelFrame.origin.y = CGRectGetMinY(textBubbleViewRect) + 2;
    }
    
    // 确保泡泡的高度大于最小高度
    if (textBubbleViewRect.size.height < TEXT_BUBBLE_MIN_HEIGHT)
    {
        textBubbleViewRect.size.height = TEXT_BUBBLE_MIN_HEIGHT;
    }
    
    // 确保泡泡的宽大于等于最小宽度
    if (textBubbleViewRect.size.width < CELL_TEXT_BUBBLE_MIN_WIDTH)
    {
        textBubbleViewRect.size.width = CELL_TEXT_BUBBLE_MIN_WIDTH;
    }
    
    // 设置绘制泡泡的Rect
    [self.messageBubbleView setBubbleRect:textBubbleViewRect];
    
    // 设置文本区域位置
    [self.textContentTextView setFrame:textContentLabelFrame];
    [self.typeImageView setFrame:typeImageViewFrame];
    
    // 设置字体
    [self.textContentTextView setFont:MESSAGE_TEXT_FONT];
    
    // 刷新内容区域
    [self.messageBubbleView setNeedsDisplay];
}

- (void)tapCallHistoryCellGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
        CGRectContainsPoint(self.messageBubbleView.bubbleRect, tapPoint))
    {
        // Gray.Wang:2015.08.27: 更新多人语音消息状态为已读
        [RKCloudChatMessageManager updateMsgStatusHasReaded:self.messageObject.messageID];
        
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话")])
        {
            // 语音通话
            [appDelegate.callManager dialAudioCall:self.messageObject.sessionID];
        }
        else if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话")])
        {
            // 视频通话
            [appDelegate.callManager dialVideoCall:self.messageObject.sessionID];
        }
        else if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音")])
        {
            // 多人语音
            [appDelegate.meetingManager joinMeetingRoomByMeetingId:self.messageObject.textContent andViewController:self.vwcMessageSession];
        }
    }
}

// 通过本地消息对象的扩展信息判断不同的类型获取不同的图标
- (UIImage *)getCallTypeImage
{
    UIImage *callTypeImage = nil;
    NSString *imgName = nil;
    // Jacky.Chen.2016.02.29根据消息类型加载资源图
    if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话")])
    {
        // 语音通话
        if ([self.messageObject.textContent isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_CALL_MISSED", "未接来电")]) {
            // 未接来电
            imgName = @"call_record_icon_audio_missed";

        }
        else
        {
            if (isSenderMMS) {
                // 右边 蓝色
                imgName = @"call_record_icon_audio_blue";
            }
            else
            {   // 左边 白色
                imgName = @"call_record_icon_audio_white";
            }

        }
            }
    else if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话")])
    {
        // 视频通话
        if ([self.messageObject.textContent isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_CALL_MISSED", "未接来电")]) {
            // 未接来电
            imgName = @"call_record_icon_video_missed";
            
        }
        else
        {
            if (isSenderMMS) {
                // 右边 蓝色
                imgName = @"call_record_icon_video_blue";
            }
            else
            {   // 左边 白色
                imgName = @"call_record_icon_video_white";
            }
        }

    }
    else if ([self.messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音")])
    {
        // 多人语音
        if (isSenderMMS) {
            // 右边 蓝色
            imgName = @"call_record_icon_audio_blue";
        }
        else
        {   // 左边 白色
            imgName = @"call_record_icon_audio_white";
        }

    }
    
    callTypeImage = [UIImage imageNamed:imgName];

    return callTypeImage;
}

// 开启手势识别功能
- (void)enableTapGesture
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(tapCallHistoryCellGesture:)];
    [self.messageBubbleView addGestureRecognizer:gestureRecognizer];
}

@end
