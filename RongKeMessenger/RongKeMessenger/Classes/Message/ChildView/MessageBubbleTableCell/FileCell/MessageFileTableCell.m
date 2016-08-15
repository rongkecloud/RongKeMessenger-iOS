//
//  MessageFileTableCell.m
//  RongKeMessenger
//
//  Created by Gray.Wang on 11-8-18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "MessageFileTableCell.h"
#import "MessageBubbleTableCell.h"
#import "Definition.h"
#import "ToolsFunction.h"

@implementation MessageFileTableCell

@synthesize tryAgainButton;
@synthesize resendLabel;
@synthesize filesPath;		

#define FILE_TAG_NO			0
#define FILE_TAG_DOWNLOAD	1
#define FILE_TAG_OPEN		2


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


#pragma mark -
#pragma mark Initialization & Draw

- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj isEditing:(BOOL)isEditing
{
	// 父类初始化
	[super initCellContent:messageObj isEditing:isEditing];

	// 初始化时隐藏重发按钮
	self.tryAgainButton.hidden = YES;
    self.fileImageView.hidden = NO;
    self.resendLabel.hidden = YES;
    self.resendLabel.text = NSLocalizedString(@"STR_RESENT_MANUALLY", nil);
    
    [self.messageBubbleView setTag:FILE_TAG_NO];
    
    FileMessage *fileMessage = (FileMessage *)self.messageObject;
    
	// 得到文件大小
    NSString *strFileSize = [ToolsFunction stringFileSizeWithBytes:fileMessage.fileSize];
	self.messageBubbleView.fileSize = strFileSize;
    
	// 得到文件的名称
	self.messageBubbleView.fileName = fileMessage.fileName;
	// 得到文件的路径 如果filepath不为空，则通过拼接filepath得到，反之，用文件名拼接。
	self.filesPath = fileMessage.fileLocalPath;
    
    // 设置文件名字符串
    self.fileNameLabel.text = [NSString stringWithFormat:@"%@  %@", self.messageBubbleView.fileName, self.messageBubbleView.fileSize];
	// 获取消息状态
	[self updateMMSCellStatus:self.messageObject.messageStatus];
}

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
    // 设置文本颜色(2016.02.29:Jacky.Chen,add)
    if (isSenderMMS) {
        // 本地发送
        [self.fileNameLabel setTextColor:MESSAGE_TEXT_COLOR_SELF];
    }else
    {
        [self.fileNameLabel setTextColor:MESSAGE_TEXT_COLOR_OTHER];
    }
    //Jacky.Chen:2016.02.29 Add 在此计算文件名字符自适应高度
    CGSize fileNameLabeSize =[self.fileNameLabel.text boundingRectWithSize:
                           CGSizeMake(MESSAGE_FILE_CONTENT_WIDTH , CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.fileNameLabel.font,NSFontAttributeName, nil] context:nil].size;

	// 根据rect改变泡泡的高度
    // 设置泡泡坐标
	CGRect fileIconFrame = self.fileImageView.frame;
    int fileBubbleW  = fileNameLabeSize.width + CELL_MESSAGE_FILEICON_LEFT + CELL_MESSAGE_FILE_ICON_WIDTH + CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE + CELL_MESSAGE_FILETEXT_RIGHT;
    if (isSenderMMS)
	{
        // 以下坐标由右至左开始计算
        float fileCell_OriginX = UISCREEN_BOUNDS_SIZE.width - fileBubbleW - CELL_AVATAR_WIDTH - CELL_TEXT_LEFT_AND_RIGHT - CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE - 5;
        // (2016.02.29:Jacky.Chen,add)这里使用int型是为了解决文件名高度计算出现0.1个像素，导致目前泡泡绘图会出现横线
        int  fileCell_OriginH = fileNameLabeSize.height+ CELL_MESSAGE_FILETEXT_TOP*2;
        [self.messageBubbleView setBubbleRect:CGRectMake(fileCell_OriginX,CELL_MESSAGE_BUBBLE_TOP_DISTANCE, fileBubbleW, fileCell_OriginH)];
        
        // 设置文件名称label的frame(2016.02.29:Jacky.Chen,add)
        self.fileNameLabel.frame = CGRectMake(CGRectGetMinX(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT + CELL_MESSAGE_FILE_ICON_WIDTH + CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE, CGRectGetMinY(self.messageBubbleView.bubbleRect) + 10, fileNameLabeSize.width, fileNameLabeSize.height);
        
        // 设置文件Icon的坐标
        fileIconFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT;;
        fileIconFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_TOP;
        
        // 设置重新发送图标frame
        CGRect resendButtonFrame = self.tryAgainButton.frame;
        resendButtonFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_STATUS_AND_LEFT_OF_BUBBLE - CGRectGetWidth(resendButtonFrame);
        resendButtonFrame.origin.y = CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_STATUS_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(resendButtonFrame);
		[self.tryAgainButton setFrame:resendButtonFrame];
        
        //设置重新发送文本的frame
        CGRect resendLableFrame = self.resendLabel.frame;
        resendLableFrame.origin.x = CGRectGetMinX(resendButtonFrame) - CELL_DISTANCE_BETWEEN_TIME_AND_LEFT_OF_STATUS - CGRectGetWidth(resendLableFrame);
        resendLableFrame.origin.y = CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(resendLableFrame);
        [self.resendLabel setFrame:resendLableFrame];
    }
	else {
        //以下坐标由右至左开始计算
        [self.messageBubbleView setBubbleRect:CGRectMake(CELL_MESSAGE_BUBBLE_LEFT_DISTANCE, CELL_MESSAGE_BUBBLE_TOP_DISTANCE, fileBubbleW,  (int)(fileNameLabeSize.height + CELL_MESSAGE_FILETEXT_TOP*2))];
        
		fileIconFrame.origin.x = CGRectGetMinX(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT;
        fileIconFrame.origin.y = CGRectGetMinY(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_TOP;
        
        // 设置文件名称label的frame(2016.02.29:Jacky.Chen,add)
        self.fileNameLabel.frame = CGRectMake(CGRectGetMinX(self.messageBubbleView.bubbleRect) + CELL_MESSAGE_FILEICON_LEFT + CELL_MESSAGE_FILE_ICON_WIDTH + CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE, CGRectGetMinY(self.messageBubbleView.bubbleRect) + 10, fileNameLabeSize.width, fileNameLabeSize.height);
    }
    [self.fileNameLabel layoutIfNeeded];
    [self.fileImageView setFrame:fileIconFrame];
	[self.messageBubbleView setNeedsDisplay];
}

#pragma mark -
#pragma mark UI Update Method

// 改变cell的发送状态
- (void)updateMMSCellStatus:(int)messageStatus {
    
    // 根据消息状态调用想用的页面
    switch (messageStatus)
    {
        case MESSAGE_STATE_RECEIVE_RECEIVED:
        case MESSAGE_STATE_RECEIVE_DOWNFAILED:
            // 增加点击下载事件
            [self.messageBubbleView setTag:FILE_TAG_DOWNLOAD];
            break;
            
        case MESSAGE_STATE_RECEIVE_DOWNING:
            // 隐藏打开按钮
            self.fileImageView.hidden = YES;
            break;
            
        case MESSAGE_STATE_SEND_FAILED:
            // 如果为发送失败则显示重试按钮
            self.tryAgainButton.hidden = NO;
            
            // 根据DCR的需求去掉重发的提示，暂时对该控件隐藏的处理 14.8.7
            self.resendLabel.hidden = YES;
            break;
            
        case MESSAGE_STATE_SEND_SENDING:
            // 隐藏打开按钮
            self.fileImageView.hidden = YES;
            // 隐藏重试按钮
            self.tryAgainButton.hidden = YES;
            self.resendLabel.hidden = YES;
            break;
            
        case MESSAGE_STATE_RECEIVE_DOWNED:
        {
            // 更新消息状态为“已读”状态
			[RKCloudChatMessageManager updateMsgStatusHasReaded:self.messageObject.messageID];
        }
            break;
            
        default:
            // 使文件窗口可用
            [self.messageBubbleView setTag:FILE_TAG_OPEN];
            break;
    }
}


#pragma mark -
#pragma mark UITapGestureRecognizer

- (void)enableTapGesture
{
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] 
                                                 initWithTarget:self action:@selector(tapFileCellGesture:)];
    [self.messageBubbleView addGestureRecognizer:gestureRecognizer];
}

- (void)tapFileCellGesture:(UITapGestureRecognizer *)gestureRecognizer 
{
    // 获取手势点击的范围，然后根据时否在泡泡中来执行相应的事件
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded &&
        CGRectContainsPoint(self.messageBubbleView.bubbleRect, tapPoint))
	{
        switch ([self.messageBubbleView tag]) 
        {
            case FILE_TAG_DOWNLOAD: // 文件下载事件
            {
                [self downloadFileMessage];
                self.fileImageView.hidden = YES;
            }
                break;
                
            case FILE_TAG_OPEN: // 文件打开事件
            {
                if ([ToolsFunction isFileExistsAtPath: self.filesPath] == NO)
                {
                    [self downloadFileMessage];
                    self.fileImageView.hidden = YES;
                    return;
                }
                [self touchOpenFileButton];
            }
                break;
                
            default:
                break;
        }
    }
}


#pragma mark -
#pragma mark Touch Button Action

- (IBAction)touchToTap:(id)sender
{
	[self tapFileCellGesture:nil];
}

// 发送失败，点击重试
- (IBAction)touchTryAgainButton
{
	// 调用父类的重发函数
	[super touchResendButton:self];
}

// 下载
- (void)downloadFileMessage
{
    NSLog(@"UA: MessageFileTableCell -> downloadFileMessage - messageID = %@", self.messageObject.messageID);
		
	// 调用下载接口进行下载
	if ([RKCloudChatMessageManager downMediaFile:self.messageObject.messageID] == RK_SUCCESS)
	{
		[self setNeedsDisplay];
		[self.messageBubbleView setTag:FILE_TAG_NO];
	}
}

// 文件浏览
- (IBAction)touchOpenFileButton
{
    // 打开文件
    [self.vwcMessageSession openFilesWithFilePath:self.filesPath
                                     withShowName:self.messageBubbleView.fileName];
}

// 屏蔽按键功能
- (void)disableButtonAction:(BOOL)flag
{
    [super disableButtonAction:flag];
	self.tryAgainButton.enabled = !flag;
}

@end
