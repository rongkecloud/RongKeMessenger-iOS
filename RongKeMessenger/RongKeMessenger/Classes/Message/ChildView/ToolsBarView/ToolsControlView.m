//
//  ToolsControlView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "ToolsControlView.h"
#import "EmoticonView.h"
#import "Definition.h"
#import "ToolsFunction.h"

// 控制窗口的宏定义
#define SCROLL_PAGE_COUNTS	            1 // 按钮图标页面页数
#define CONTROL_BUTTON_COUNTS	        2 // 按钮图标总数量
#define CONTROL_BUTTON_LINE		        2 // 按钮图标页面行数
#define CONTROL_BUTTON_ROW	            4 // 按钮图标页面列数
#define CONTROL_BUTTON_X_SPACE          0 // 按钮图标页面横向间隔
#define CONTROL_BUTTON_Y_SPACE         12 // 按钮图标页面纵向间隔
//#define CONTROL_BUTTON_GRID_WIDTH      65 // 每个按钮图标格子的宽度
#define CONTROL_BUTTON_GRID_HEIGHT     65 // 每个按钮图标格子的高度
#define CONTROL_BUTTON_OFFSET_X         0 // 距离X轴0点的偏移位置
#define CONTROL_BUTTON_OFFSET_Y         0 // 距离Y轴0点的偏移位置

@interface ToolsControlView ()

@property (nonatomic, retain) EmoticonView * emoticonView; // 表情符号选择窗口
@property (nonatomic, strong) RKCloudChatBaseChat *chatSessionObject;

@end

@implementation ToolsControlView

- (id)initWithFrame:(CGRect)frame withParent:(id)parentView withRKCloudChatBaseChat:(RKCloudChatBaseChat *)sessionChatObject
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.chatSessionObject = sessionChatObject;
        self.backgroundColor = [UIColor clearColor];
        
        // 加载控制按钮资源
        [self loadControlButtonResource];
        
        // 增加表情符号窗口
        EmoticonView *emoticonView = [[EmoticonView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.emoticonView = emoticonView;
        self.emoticonView.delegate = parentView;
        self.emoticonView.hidden = YES;
        
        [self addSubview:self.emoticonView];
    }
    return self;
}



// 加载控制按钮资源
- (void)loadControlButtonResource
{
    NSInteger controlButtonCounts = 2;
    if (self.chatSessionObject.sessionType == SESSION_GROUP_TYPE) {
        controlButtonCounts = 4;
    }
    else
    {
        // 单聊5个操作按钮
        controlButtonCounts = 5;
    }
    
    // 定义图标的坐标和矩形
	NSInteger nX = 0;
	NSInteger nY = 0;
	NSInteger nWidth = self.frame.size.width / CONTROL_BUTTON_ROW; // 每个格子的宽度，Jacky.Chen:2016.02.23:格子均分屏幕
	NSInteger nHeight = CONTROL_BUTTON_GRID_HEIGHT; // 每个格子的高度
	CGRect rectEmoticon = CGRectZero;
	NSInteger currentCounts = 0;
	
	// 初始化表情符号的矩形数组
	NSMutableArray *arrayButtonRect = [[NSMutableArray alloc] init];
	
	// 循环页数
	for (int page = 0; page < SCROLL_PAGE_COUNTS; page++)
	{
		// 循环行数
		for (int line = 0; line < CONTROL_BUTTON_LINE; line++)
		{
            // 循环列数
			for (int row = 0; row < CONTROL_BUTTON_ROW; row++)
			{
				// 每个图标的X坐标
				nX = page * self.frame.size.width + row * nWidth + row * CONTROL_BUTTON_X_SPACE + CONTROL_BUTTON_OFFSET_X;
				// 每个图标的Y坐标
				nY = line * nHeight + line * CONTROL_BUTTON_Y_SPACE + CONTROL_BUTTON_Y_SPACE + CONTROL_BUTTON_OFFSET_Y;
                
				// 得到每个表情图标的的矩形区域
				rectEmoticon = CGRectMake(nX, nY, nWidth, nHeight);
				
				// 统计当前的图标数量
				currentCounts = page * CONTROL_BUTTON_LINE * CONTROL_BUTTON_ROW + line * CONTROL_BUTTON_ROW + row;
				
				// 将每个图标的矩形坐标保存到数组中
				[arrayButtonRect addObject:[NSValue valueWithCGRect:rectEmoticon]];
				
				// 如果已经到达最大的图标数量则跳出循环
				if (currentCounts == controlButtonCounts-1) {
					break;
				}
			}
			
			// 如果已经到达最大的图标数量则跳出循环
			if (currentCounts == controlButtonCounts-1) {
				break;
			}
		}
		
		// 如果已经到达最大的图标数量则跳出循环
		if (currentCounts == controlButtonCounts-1) {
			break;
		}
	}
    
    // 每一个表情按钮
	UIButton *buttonEmoticon = nil;
    UILabel *labelTitle = nil;
	// 将使用按钮来将图标贴出来显示
	for (int i=0; i < [arrayButtonRect count]; i++)
	{
        CGRect rectButton = [[arrayButtonRect objectAtIndex:i] CGRectValue];
        
        // 设置表情按钮的触发位置，位置都是从已经保存的图标矩形数组中取出来
		buttonEmoticon = [[UIButton alloc] initWithFrame:rectButton];
        labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(rectButton.origin.x, rectButton.origin.y + rectButton.size.height, rectButton.size.width, 21)];
        
        NSString *strImageButtonName = nil;
        NSString *strTitle = nil;
        
        switch (i) {
            case 0: // 图片
                strImageButtonName = @"image_button_photo_normal";
                strTitle = NSLocalizedString(@"STR_IMAGE_DESCRIBE", "图片");
                break;
                
            case 1: // 拍照
                strImageButtonName = @"image_button_picture_normal";
                strTitle = NSLocalizedString(@"STR_TAKE_PHOTO", "拍照");
                break;
                
            case 2: // 视频
                strImageButtonName = @"image_button_small_video_normal";
                strTitle = NSLocalizedString(@"STR_TAKE_VIDEO", "视频");
                break;
                
            case 3: // 多人语音/语音聊天
            {
                if (self.chatSessionObject.sessionType == SESSION_GROUP_TYPE)
                {
                    // 多人语音
                    strTitle = @"多人语音";
                    strImageButtonName = @"image_button_meeting_normal";
                }
                else
                {
                    // 语音聊天
                    strTitle = @"语音聊天";
                    strImageButtonName = @"image_button_voice_normal";
                }
            }
                break;
            case 4:
            {
                // 视频聊天
                strImageButtonName = @"image_button_video_normal";
                strTitle = @"视频聊天";
            }
                break;
                
            default:
                break;
        }

        // 设置表情按钮的相应表情图片
        [buttonEmoticon setImage:[UIImage imageNamed:strImageButtonName]
                        forState:UIControlStateNormal];
        
		buttonEmoticon.tag = i+1;
		// 增加表情按钮的响应事件
		[buttonEmoticon addTarget:self
						   action:@selector(touchSelectedToolsControlButton:)
				 forControlEvents:UIControlEventTouchUpInside];
        
        // 设置按钮下发的标题文字
        [labelTitle setText:strTitle];
        [labelTitle setTextColor:[UIColor blackColor]];
        [labelTitle setFont:[UIFont systemFontOfSize:13]];
        [labelTitle setTextAlignment:NSTextAlignmentCenter];
        [labelTitle setBackgroundColor:[UIColor clearColor]];
		
		// 将按钮加载到View上
		[self addSubview:buttonEmoticon];
        [self addSubview:labelTitle];
        
        // 若是小秘书则不显示语音与视频
        if (i == 1 && [ToolsFunction isRongKeServiceAccount:self.chatSessionObject.sessionID]) {
            break;
        }
	}
}

- (void)touchSelectedToolsControlButton:(id)sender
{
    UIButton * buttonControl = (UIButton *)sender;
	NSInteger nButtonIndex = buttonControl.tag;

    // 调用代理方法
    if ([self.delegate respondsToSelector:@selector(didTouchSelectedToolsControlButtonDelegateMethod:)]) {
        [self.delegate didTouchSelectedToolsControlButtonDelegateMethod:nButtonIndex];
    }
}

- (void)showEmoticonView:(BOOL)isShow
{
    self.emoticonView.hidden = !isShow;
}

@end
