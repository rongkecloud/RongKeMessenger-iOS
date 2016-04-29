//
//  MessageBubbleView.m
//  RongKeMessenger
//
//  Created by Gray on 11-12-14.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//  Gray.Wang:2013.05.08: review and neaten code, delete abolish code.
//

#import "MessageBubbleView.h"
#import "ToolsFunction.h"
#import "UIImage+Utils.h"
#import "AppDelegate.h"
#import "RKChatSessionListViewController.h"
#import "MessageBubbleTableCell.h"
#import "MessageFileTableCell.h"

// 消息状态字体颜色
#define MESSAGE_ARRIVED_COLOR  [UIColor colorWithRed:63/255.0 green:135/255.0 blue:28/255.0 alpha:1.0];
#define USERHEAD_BUTTON_TAG 258
#define USER_HEAD_HEIGHT 40
#define BUBBLE_RECT_OFFSET_Y_FOR_IMAGE  4

#define BUBBLE_IMAGE_RIGHT_INSETS  UIEdgeInsetsMake(20, 7, 7, 15) // 右边泡泡图片的EdgeInsets
#define BUBBLE_IMAGE_LEFT_INSETS   UIEdgeInsetsMake(20, 15, 7, 7) // 左边泡泡图片的EdgeInsets

#define BUBBLE_ACTIVITY_UNDICATORVIEW_WIDTH_AND_HEIGHT  22


@implementation MessageBubbleView

@synthesize progressView;
@synthesize stringDuration, fileName, fileSize;
@synthesize imageContent;
@synthesize bubbleRect;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        self.isRightBubble = NO;
        self.isMultiplayerSession = NO;
	}
    
    return self;
}

- (void)resetState {
    
    self.mmsObject = nil;
    
    // 重置MessageBubbleView各种参数
    self.bubbleRect = CGRectZero;
    
    self.isRightBubble = NO;
    self.isMultiplayerSession = NO;
    
    self.fileName = nil;
    self.fileSize = nil;
    self.stringDuration = nil;
    
    if (imageContent)
    {
        self.imageContent = nil;
    }
}

- (void)dealloc 
{
    [self resetState];
    
    if (self.progressView) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView = nil;
}


#pragma mark -
#pragma mark Drawing Methods

- (void)drawRect:(CGRect)rect
{
    [super drawRect: rect];
    
	// 绘制消息泡泡
    [self drawMessageBubble:rect];
	
	// 根据不同cell类型来绘制不同的内容
	[self drawMessageContent:rect];
	
	// 绘制消息状态
	[self drawMessageStatus:rect];
}

// 绘制消息泡泡
- (void)drawMessageBubble:(CGRect)rect
{
    // 图片消息不需要画泡泡
    if (self.mmsObject.messageType == MESSAGE_TYPE_IMAGE) {
        return;
    }
    
    UIImage *bubbleImage = nil;
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    // 发送的消息在右侧
    if (self.isRightBubble)
    {
        insets = BUBBLE_IMAGE_RIGHT_INSETS;
        bubbleImage = [UIImage imageNamed:@"bubble_bg_right"];

    }
    else {
        // 收到的消息在左侧
        insets = BUBBLE_IMAGE_LEFT_INSETS;
        bubbleImage = [UIImage imageNamed:@"bubble_bg_left"];
    }
    
    // 绘制泡泡
    UIImage *resizeImage = [bubbleImage resizableImageWithCapInsets:insets];
    [resizeImage drawInRect:self.bubbleRect];
}

// 根据不同cell类型来绘制不同的内容
- (void)drawMessageContent:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 保存绘制前状态
	CGContextSaveGState(context);

	CGContextSetBlendMode(context, kCGBlendModeNormal);
	//CGContextSelectFont(context, "Helvetica", 17, kCGEncodingMacRoman);
    // Gray.Wang:2015.12.03:去除上面方法在iOS7.0以上平台的警告提示，使用下面代码替换。
    // Gray.Wang:2016.01.27:修正CGFontCreateWithFontName代码的memory leak
    CGFontRef refFont = CGFontCreateWithFontName((__bridge CFStringRef)[MESSAGE_TEXT_FONT fontName]);
    CGContextSetFont(context, refFont);
    CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1.0, -1.0));
    
	switch (self.mmsObject.messageType)
	{
		case MESSAGE_TYPE_IMAGE: // 图片消息泡泡
        case MESSAGE_TYPE_VIDEO: // 视频消息泡泡
		{
            // Draw the image in the upper left corner (0,0)
            CGContextTranslateCTM(context, 0.0, self.bubbleRect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
            
            // 计算图片
            CGSize drawSize = [ToolsFunction sizeScaleFixedThumbnailImageSize:self.imageContent.size];
            
            // 第一步绘制图片
            // Gray.Wang:2014.07.29: 进行图片掩码处理，制作出掩码图片的样式图片
            const UIEdgeInsets insets = self.isRightBubble == YES ? BUBBLE_IMAGE_RIGHT_INSETS : BUBBLE_IMAGE_LEFT_INSETS;
            NSString *bubbleName = self.isRightBubble == YES ? @"bubble_bg_right" : @"bubble_bg_left";
            const UIImage *resizableMaskImage = [[UIImage imageNamed:bubbleName] resizableImageWithCapInsets:insets];
            
            // 进行图片缩放
            const UIImage *maskImageDrawnToSize = [resizableMaskImage renderAtSize:drawSize];
            // 进行图片掩码
            UIImage *maskedImage = [self.imageContent maskWithImage:maskImageDrawnToSize];
            
            // 绘制图片
            CGContextDrawImage(context, CGRectMake(self.bubbleRect.origin.x, -self.bubbleRect.origin.y, self.bubbleRect.size.width, self.bubbleRect.size.height), maskedImage.CGImage);
            
            // 第二步绘制图片的遮罩，制作边框的效果
            NSString *maskName = self.isRightBubble == YES ? @"bubble_image_mask_right" : @"bubble_image_mask_left";
            UIImage *resizableBubbleMaskImage = [[UIImage imageNamed:maskName] resizableImageWithCapInsets:insets];
            const UIImage *bubbleMaskImage = [resizableBubbleMaskImage renderAtSize:drawSize];
            
            // 遮罩图片的绘制
            CGContextDrawImage(context, CGRectMake(self.bubbleRect.origin.x, -self.bubbleRect.origin.y, self.bubbleRect.size.width, self.bubbleRect.size.height), bubbleMaskImage.CGImage);
            
            if (self.mmsObject.messageType == MESSAGE_TYPE_VIDEO) {
                
                UIImage *videoMarkImage = [UIImage imageNamed:@"image_video_logo"];
                // 视频Logo图的绘制
                CGContextDrawImage(context, CGRectMake((self.bubbleRect.origin.x + (self.bubbleRect.size.width - videoMarkImage.size.width/2)/2),-(self.bubbleRect.origin.y/2 - videoMarkImage.size.height/4), videoMarkImage.size.width/2, videoMarkImage.size.height/2), videoMarkImage.CGImage);
            }
            
            CGContextTranslateCTM(context, 0.0, self.bubbleRect.size.height);
			CGContextScaleCTM(context, 1.0, -1.0);
		}
			break;
			
		case MESSAGE_TYPE_VOICE: // 语音消息泡泡
			break;
			
		case MESSAGE_TYPE_FILE: // 文件消息泡泡
		{
            // 发送消息
//            if ([self.fileName length] > 0)
//            {
//                CGRect fileNameRect = {0};
//                
//                // 计算文件名字的size
//                NSString *fileNameStr = [NSString stringWithFormat:@"%@  %@", fileName, fileSize];
//                UIFont *fileNameFont = [UIFont systemFontOfSize:16];
//                
//                CGSize fileNameSize = CGSizeZero;
//                //Jacky.Chen.Add 更改计算文件名宽度的最大限制为MAXFLOAT，为计算文本真实宽度，进行后续判断进行换行，解决文件名绘制区域超出泡泡的问题
//                if ([ToolsFunction iSiOS7Earlier])
//                {
//                    fileNameSize = [fileNameStr sizeWithFont:fileNameFont constrainedToSize:CGSizeMake(MAXFLOAT, self.bubbleRect.size.height) lineBreakMode:NSLineBreakByTruncatingHead];
//                }
//                else {
//                    
//                    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:fileNameFont, NSFontAttributeName, nil];
//
//                    fileNameSize = [fileNameStr boundingRectWithSize:CGSizeMake(MAXFLOAT, self.bubbleRect.size.height)  options:NSStringDrawingUsesFontLeading attributes:dict context:nil].size;
//                }
//                
//                // 计算文件名字的行数
//                NSInteger fileNameLines = 1;
//                if (fileNameSize.width > MESSAGE_FILE_CONTENT_WIDTH)
//                {
//                    
//                    fileNameLines = 2;
//                }
//                
//                // 居中显示文件名字
//                fileNameRect.origin.y = self.bubbleRect.origin.y + ((CGRectGetHeight(self.bubbleRect)) - fileNameSize.height * fileNameLines) * 0.5;
//                fileNameRect.size.height = fileNameSize.height * fileNameLines;
//                
//                if (self.isRightBubble)
//                {
//                    // 右侧矩形位置
//                    fileNameRect = CGRectMake(CGRectGetMinX(self.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT + CELL_MESSAGE_FILE_ICON_WIDTH + CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE, fileNameRect.origin.y, MESSAGE_FILE_CONTENT_WIDTH, fileNameRect.size.height);
//                    
//                    // 绘制文件名称的颜色值
//                    CGContextSetFillColorWithColor(context, MESSAGE_TEXT_COLOR_SELF.CGColor);
//                }
//                else
//                {
//                    // 左侧矩形位置
//                    fileNameRect = CGRectMake(CGRectGetMinX(self.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT + CELL_MESSAGE_FILE_ICON_WIDTH + CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE, fileNameRect.origin.y, MESSAGE_FILE_CONTENT_WIDTH, fileNameRect.size.height);
//                    
//                    // 绘制文件名称的颜色值
//                    CGContextSetFillColorWithColor(context, MESSAGE_TEXT_COLOR_OTHER.CGColor);
//                }
//
//                CGContextSetRGBStrokeColor(context, 51 / 255.0, 51 / 255.0, 51 / 255.0, 1.0);
//                CGContextSetTextDrawingMode(context, kCGTextFill);
//                
//                [fileNameStr drawInRect:fileNameRect
//                                withFont:MESSAGE_TEXT_FONT
//                           lineBreakMode:NSLineBreakByCharWrapping];
//
//            }
		}
			break;
			
		default:
			break;
	}
    
    // Gray.Wang:2016.01.27:修正CGFontCreateWithFontName代码的memory leak
    if (refFont) {
        CFRelease(refFont);
    }
    
    // 刷新状态
	CGContextRestoreGState(context);
}

// 绘制消息状态
- (void)drawMessageStatus:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 保存绘制前状态
	CGContextSaveGState(context);
    
    // 获取消息类型和状态
    NSInteger mmsType = self.mmsObject.messageType;
    NSInteger mmsStatus = self.mmsObject.messageStatus;
    
	// 文字消息、下载中、发送中不显示状态
	if (mmsType != MESSAGE_TYPE_TEXT &&
		(mmsStatus == MESSAGE_STATE_RECEIVE_DOWNING || mmsStatus == MESSAGE_STATE_SEND_SENDING))
	{
		// 做颜色混合
		CGContextSetBlendMode(context, kCGBlendModeSourceAtop);
		// 画覆盖色
		CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.6); 
		// 在矩形区域内绘制
		CGContextFillRect(context, self.bubbleRect);
        
		// 下载/发送中文字和进度条
		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        
		// 进度窗口坐标
		CGRect progressViewRect = CGRectMake(0, 0, BUBBLE_ACTIVITY_UNDICATORVIEW_WIDTH_AND_HEIGHT, BUBBLE_ACTIVITY_UNDICATORVIEW_WIDTH_AND_HEIGHT);
        
        float bubbleArrowOriginX = self.isRightBubble == YES ? CGRectGetMinX(self.bubbleRect) - CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE - BUBBLE_ACTIVITY_UNDICATORVIEW_WIDTH_AND_HEIGHT: CGRectGetMaxX(self.bubbleRect) + CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE;
        
        progressViewRect.origin.x = bubbleArrowOriginX;//(self.bubbleRect.size.width - bubbleArrow) / 2.0;
        progressViewRect.origin.y = CGRectGetMaxY(self.bubbleRect) - BUBBLE_ACTIVITY_UNDICATORVIEW_WIDTH_AND_HEIGHT - CELL_DISTANCE_BETWEEN_SEND_AND_BOTTOM_OF_BUBBLE;// self.bubbleRect.origin.y + self.bubbleRect.size.height / 2.0;
        
		// 加载上传/下载进度窗口
		[self loadingProgressView:progressViewRect];
        
        if (![self.activityIndicatorView isAnimating])
        {
            [self.activityIndicatorView startAnimating];
        }
	}
	else
    {
        if (self.progressView)
        {
            [self.progressView removeFromSuperview];
            self.progressView = nil;
        }
        
        if (self.activityIndicatorView && [self.activityIndicatorView isAnimating]) {
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView removeFromSuperview];
        }
        
        RKChatSessionListViewController *vwcChatSessionList = [AppDelegate appDelegate].rkChatSessionListViewController;
        // 移除存储进度字典次messageID对应的数据
        if (vwcChatSessionList && [vwcChatSessionList.progressDic objectForKey:self.mmsObject.messageID])
        {
            [vwcChatSessionList.progressDic removeObjectForKey:self.mmsObject.messageID];
        }
    }
    
#ifdef RECEIVE_DATE_DRAW
    // 消息收到的时间字符串
	NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
	[timeFormatter setDateFormat:@"yy-MM-dd HH:mm"];
	NSString *receiveTimeString = [[NSString alloc] initWithFormat:@"%@", [timeFormatter stringFromDate:self.mmsObject.createDate]];
	[timeFormatter release];
#endif
	
    // 发送消息在右侧
    if (self.isRightBubble)
	{
        /*
        NSString *stateString = nil;
        
        // 群聊不显示状态
        if (!self.isMultiplayerSession)
        {
            UIColor *textColor = MESSAGE_ARRIVED_COLOR;
            [textColor set];
            
            // 显示消息状态
            switch (mmsStatus)
            {
                case MESSAGE_STATE_SEND_SENDING: // 9:发送中（用户点击发送或重发）
                    stateString = NSLocalizedString(@"STR_DRAFTS",nil);
                    break;
                    
                case MESSAGE_STATE_SEND_SENDED: // 2:已发送（文本或文件发送成功）
                    stateString = NSLocalizedString(@"STR_SENT",nil);
                    break;
                    
                case MESSAGE_STATE_SEND_ARRIVED: // 7:已送达（对方已接收消息成功）
                    stateString = NSLocalizedString(@"STR_ARRIVED",nil);
                    break;
                    
                case MESSAGE_STATE_READED: // 8:已读（用户已查看）
                    stateString = NSLocalizedString(@"STR_READ",nil);
                    break;
                    
                default:
                    break;
            }
            
            // 绘制发送的状态
            CGSize stateSize = [ToolsFunction getSizeFromString:stateString withFont:[UIFont systemFontOfSize:14]];
            float stateStringOriginX = self.bubbleRect.origin.x - CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE - stateSize.width;
            float stateStringOriginY = CGRectGetMaxY(self.bubbleRect) - CELL_DISTANCE_BETWEEN_SEND_AND_BOTTOM_OF_BUBBLE - stateSize.height;
            [stateString drawAtPoint:CGPointMake(stateStringOriginX, stateStringOriginY) withFont:[UIFont systemFontOfSize:14]];
        }
         */
        
        [[UIColor grayColor] set];
        
        // 绘制发送时间
        if (!(mmsStatus == MESSAGE_STATE_SEND_FAILED))
        {

#ifdef RECEIVE_DATE_DRAW
			// 接收时间绘制
			[receiveTimeString drawAtPoint:CGPointMake(self.bubbleRect.origin.x - [ToolsFunction getSizeFromString:receiveTimeString withFont:[UIFont systemFontOfSize:10]].width, self.bubbleRect.origin.y) withFont:[UIFont systemFontOfSize:10]];
#endif
		}
    }
	else {
        // 接收到的消息在左侧
        UIImage *unReadImage = nil;
        
        // 绘制未读标记
        if (mmsType != MESSAGE_TYPE_TEXT &&
            (mmsStatus == MESSAGE_STATE_RECEIVE_RECEIVED || mmsStatus == MESSAGE_STATE_RECEIVE_DOWNFAILED))
		{
            unReadImage = [UIImage imageNamed:@"unread_warning_icon"];
            float unReadImageOriginX = CGRectGetMaxX(self.bubbleRect) + CELL_DISTANCE_BETWEEN_READ_FLAG_AND_RIGHT_OF_RECEIVE_BUBBLE;
            float unReadImageOriginY = CGRectGetMaxY(self.bubbleRect) - unReadImage.size.height/2 - CELL_DISTANCE_BETWEEN_READ_FLAG_AND_BOTTOM_OF_RECEIVE_BUBBLE;
            [unReadImage drawInRect:CGRectMake(unReadImageOriginX,
                                               unReadImageOriginY,
                                               unReadImage.size.width,
                                               unReadImage.size.height)];
        }
        
        [[UIColor grayColor] set];
        
        // 格式化时间字符串
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        NSString *sendTimeString = [[NSString alloc] initWithFormat:@"%@", [timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.mmsObject.sendTime]]];
        
        // 绘制消息的发送时间
        CGSize dateSize = [ToolsFunction getSizeFromString:sendTimeString withFont:[UIFont systemFontOfSize:12]];
        float stringSendDateOriginX = CGRectGetMaxX(self.bubbleRect) + CELL_DISTANCE_BETWEEN_READ_FLAG_AND_RIGHT_OF_RECEIVE_BUBBLE + unReadImage.size.width/2 + CELL_DISTANCE_BETWEEN_TIME_AND_RIGHT_OF_READ_FLAG;
        float stringSendDateOriginY = CGRectGetMaxY(self.bubbleRect) - dateSize.height - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_RECEIVE_BUBBLE;
        
        [sendTimeString drawAtPoint:CGPointMake(stringSendDateOriginX, stringSendDateOriginY) withFont:[UIFont systemFontOfSize:12]];
        
#ifdef RECEIVE_DATE_DRAW
		// 接收时间绘制
		[receiveTimeString drawAtPoint:CGPointMake(CGRectGetMaxX(self.bubbleRect), self.bubbleRect.origin.y) withFont:[UIFont systemFontOfSize:10]];
#endif
	}
    
    // 绘制时间
    [[UIColor blackColor] set];
    
    if (self.mmsObject.messageType == MESSAGE_TYPE_VIDEO) {
        VideoMessage *videoMessage = (VideoMessage *)self.mmsObject;
        // 绘制时长
        NSString *videoDuration = [NSString stringWithFormat:@"%.2f",(float)((float)videoMessage.mediaDuration/100.00)];
        CGSize videoDurationStrsize = [ToolsFunction getSizeFromString:videoDuration withFont:[UIFont systemFontOfSize:10]];
        
        [videoDuration drawAtPoint:CGPointMake(CGRectGetMaxX(self.bubbleRect) - videoDurationStrsize.width - 10, self.bubbleRect.origin.y + self.bubbleRect.size.height - videoDurationStrsize.height - 6) withFont:[UIFont systemFontOfSize:10]];
    }
    
    // 刷新状态
	CGContextRestoreGState(context);
}

/*
- (UIImage *)imageBubble:(UIImage *)bubbleImage withMaskColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, bubbleImage.size.width, bubbleImage.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, bubbleImage.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, bubbleImage.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}
 */


#pragma mark -
#pragma mark ProgressView Methods

// 加载上传/下载进度窗口
- (void)loadingProgressView:(CGRect)activityViewRect
{
    // 如果为下载中或者上传中，则显示进度
    if (self.progressView == nil)
	{
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:activityViewRect];
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        self.activityIndicatorView = activityIndicator;
        [self addSubview:self.activityIndicatorView];
        
        // 添加进度条View
        float ProgressViewWidth = [ToolsFunction getSizeFromString:@"100%" withFont:[UIFont systemFontOfSize:PROGRESS_LABEL_TEXT_FOUNT]].width;
        ProgressView *proView = [[ProgressView alloc] initWithFrame:CGRectMake(0, 0, ProgressViewWidth, activityViewRect.size.height) withCallType:FROM_MESSAGE_SESSION_LIST_BUBBLE];
        self.progressView = proView;
        
        [self addSubview:self.progressView];
        
        self.progressView.progressLabel.text = @"0%";
        self.progressView.backgroundColor = [UIColor clearColor];
    }
    
    self.activityIndicatorView.frame = activityViewRect;

    float progressViewFrameOriginX = 0;
    // 设置进度左右泡泡进度显示的对齐方式
    if (self.isRightBubble) {
        self.progressView.progressLabel.textAlignment = NSTextAlignmentRight;
        progressViewFrameOriginX = activityViewRect.origin.x - self.progressView.frame.size.width - CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE/2;
    }
    else
    {
        self.progressView.progressLabel.textAlignment = NSTextAlignmentLeft;
        progressViewFrameOriginX = CGRectGetMaxX(activityViewRect) + CELL_DISTANCE_BETWEEN_SEND_AND_LEFT_OF_BUBBLE/2;
    }
    
    CGRect progressViewFrame = CGRectMake(progressViewFrameOriginX, activityViewRect.origin.y, self.progressView.frame.size.width, self.progressView.frame.size.height);
    self.progressView.frame = progressViewFrame;
    
    self.progressView.messageID = self.mmsObject.messageID;
    
    RKChatSessionListViewController *vwcChatSessionList = [AppDelegate appDelegate].rkChatSessionListViewController;
    
    // 先读取存储的进度值若没有则说明是新消息进度为0
    if (vwcChatSessionList && [vwcChatSessionList.progressDic objectForKey:self.mmsObject.messageID]) {
         self.progressView.progressLabel.text = [NSString stringWithFormat:@"%@%%", [vwcChatSessionList.progressDic objectForKey:self.mmsObject.messageID]];
    }
    else {
        self.progressView.progressLabel.text = @"0%";
    }
}

@end
