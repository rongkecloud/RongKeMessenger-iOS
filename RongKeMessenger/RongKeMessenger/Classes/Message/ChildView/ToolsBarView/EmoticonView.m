//
//  EmoticonView.m
//  RongKeMessenger
//
//  Created by Gray on 14-1-21.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "EmoticonView.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "ChatManager.h"
#import "UIBorderButton.h"

// 表情的宏定义
#define SCROLL_PAGE_COUNTS	      1 // 表情图标页面页数
#define EMOTICON_COUNTS	         24 // 表情图标总数量
#define EMOTICON_LINE		      3 // 表情图标页面行数
#define EMOTICON_X_SPACE          8 // 表情图标页面横向间隔
#define EMOTICON_Y_SPACE          8 // 表情图标页面纵向间隔
#define EMOTICON_GRID_WIDTH      32 // 每个表情图标格子的宽度
#define EMOTICON_GRID_HEIGHT     30 // 每个表情图标格子的高度
#define EMOTICON_OFFSET_X       2.5 // 距离X轴0点的偏移位置
#define EMOTICON_OFFSET_Y         6 // 距离Y轴0点的偏移位置

@interface EmoticonView ()

@property (nonatomic, retain) UIScrollView *emoticonScrollView; // 表情符号加载和显示的滚动页面
@property (nonatomic, retain) UIPageControl *emoticonPageControl; // 控制ScrollView滚动页面页数的控制器

@property (nonatomic, assign) NSInteger numOfEmotionForRow;      // 一行需要显示Emotion的数量
@property (nonatomic, assign) float offsetXMargin;   // Emotion显示距离屏幕的间距
@property (nonatomic, assign) float spaceBetweenTwoSticker;  // Emotion之间的距离
@property (nonatomic, assign) NSInteger numOfEmotionPage;  // Emotion之间的距离

@end

@implementation EmoticonView

@synthesize emoticonScrollView, emoticonPageControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // 根据不同的屏幕尺寸计算出边距、间距、一行显示的个数
        [self initVariable];
        
        // 初始化表情界面
        [self initEmoticonViewWithFrame:frame];
        
		// 加载表情的位置和图像
		[self loadEmoticonResource];
        
        // 加载底部的发送按钮
        [self initSegmentView];
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

- (void)dealloc {
    
    [self.emoticonScrollView removeFromSuperview];
    self.emoticonScrollView = nil;
    [self.emoticonPageControl removeFromSuperview];
	self.emoticonPageControl = nil;
}

- (void)initVariable
{
    // 动态计算表情或Emtion在不同屏幕上的横向的：个数、边距、间距
    EmoticonStickerViewLayout emoticonStickerViewLayout = [EmoticonView calculationEmotionAndStickerLayoutWithMargin:EMOTICON_OFFSET_X
                                                                                                    forImageWidth:EMOTICON_GRID_WIDTH
                                                                                                 withImageSpacing:EMOTICON_X_SPACE];
    
    self.numOfEmotionForRow = emoticonStickerViewLayout.nImageRowCount;
    self.offsetXMargin = emoticonStickerViewLayout.fMarginWidth;
    self.spaceBetweenTwoSticker = emoticonStickerViewLayout.fSpacingWidth;
    
    // 计算需要Emtion需要的页数
    if (EMOTICON_COUNTS % (EMOTICON_LINE*self.numOfEmotionForRow) > 0)
    {
        self.numOfEmotionPage = (NSInteger)(EMOTICON_COUNTS / (EMOTICON_LINE*self.numOfEmotionForRow)) + 1;
    }
    else
    {
        self.numOfEmotionPage = (NSInteger)(EMOTICON_COUNTS / (EMOTICON_LINE*self.numOfEmotionForRow));
    }
    
}

// 初始化表情页面
- (void)initEmoticonViewWithFrame:(CGRect)frame;
{
    int width = self.frame.size.width;
    int height = self.frame.size.height;
    
    // 增加整个表情窗口背景图片
    self.backgroundColor = [UIColor whiteColor];
	
    // 滚动窗口
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    scroll.contentSize = CGSizeMake(self.numOfEmotionPage * width, height);
    scroll.pagingEnabled = YES;
    scroll.delegate = self;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    self.emoticonScrollView = scroll;
	
	// 增加到本View上
    [self addSubview:self.emoticonScrollView];
    
	/*int emoticonImageXPosition = 0;
    // 加载表情符号背景图片
	for (int i = 1; i <= SCROLL_PAGE_COUNTS; i++) {
		NSString * emoticonImageName = [NSString stringWithFormat:@"emoticons_background_%02d", i];
		
		UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:emoticonImageName]];
		[imageView setFrame:CGRectMake(emoticonImageXPosition, 0, width, height)];
		[self.emoticonScrollView addSubview:imageView];
		[imageView release];
		
		emoticonImageXPosition += width;
	}*/
    
    if (self.numOfEmotionPage > 1) {
        // 表情符号页面控制窗口
         self.emoticonPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((UISCREEN_BOUNDS_SIZE.width - 60)/2, CGRectGetMaxY(self.emoticonScrollView.frame) - 60, 60, 16)];
        self.emoticonPageControl.pageIndicatorTintColor = COLOR_WITH_RGB(200, 200, 200);
        self.emoticonPageControl.currentPageIndicatorTintColor = COLOR_WITH_RGB(126, 126, 126);
        [self.emoticonPageControl setBackgroundColor:[UIColor clearColor]];
        self.emoticonPageControl.numberOfPages = self.numOfEmotionPage;
        self.emoticonPageControl.currentPage = 0;
        [self.emoticonPageControl addTarget:self
                        action:@selector(pageControlTurn:)
              forControlEvents:UIControlEventValueChanged];
        
        // 增加到EmoticonView上
        [self addSubview:self.emoticonPageControl];
    }
}


#pragma mark -
#pragma mark Load Resource

// 加载表情符号的位置和图像
- (void)loadEmoticonResource
{
    // 从资源plist中加载表情符号字典
	NSDictionary *emoticonDict = [AppDelegate appDelegate].chatManager.emotionESCToFileNameDict;
	NSArray *arrayKeys = [emoticonDict allKeys];
	
	// 将plist字典key和value转换一下，字典的key是表情符号的名称，值是表情符号的标示符
	NSMutableDictionary *dictEmoticonName = [[NSMutableDictionary alloc] initWithCapacity:[emoticonDict count]];
    NSMutableDictionary *dictEmoticonCharacter = [[NSMutableDictionary alloc] initWithCapacity:[emoticonDict count]];
    
	for (int i = 0; i < [emoticonDict count]; i++)
    {
		NSString *stringKey = [arrayKeys objectAtIndex:i];
		NSString *stringValue = [emoticonDict objectForKey:stringKey];
		
		if (stringKey && stringValue)
        {
			// 表情符号的图标文件名称对应的转义字符标识字典(mms_face_01 -> ~:*0~)
			[dictEmoticonName setObject:stringKey forKey:stringValue];
            
            // 表情符号的图标文件名称对应的转义字符标识字典([微笑] -> ~:*0~)
            [dictEmoticonCharacter setObject:stringKey forKey:NSLocalizedString(stringKey, nil)];
		}
	}
    
    // 设置表情符号的对应表
    [AppDelegate appDelegate].chatManager.emoticonFileNameToESCDict = dictEmoticonName;
    [AppDelegate appDelegate].chatManager.emoticonMultilingualStringToESCDict = dictEmoticonCharacter;
	
	// 定义图标的坐标和矩形
	NSInteger nWidth = EMOTICON_GRID_WIDTH; // 每个格子的宽度
	NSInteger nHeight = EMOTICON_GRID_HEIGHT; // 每个格子的高度
	NSInteger currentCounts = 0;
	
	// 初始化表情符号的矩形数组
	NSMutableArray *arrayButtonRect = [[NSMutableArray alloc] init];
	
	// 循环页数
	for (int page = 0; page < self.numOfEmotionPage; page++)
	{
		// 循环行数
		for (int line = 0; line < EMOTICON_LINE; line++)
		{
			float nX = 0;
			float nY = 0;
            
			// 循环列数
			for (int row = 0; row < self.numOfEmotionForRow; row++)
			{
				// 每个图标的X坐标
				nX = page * self.frame.size.width + row * nWidth + row * self.spaceBetweenTwoSticker + self.offsetXMargin;
				// 每个图标的Y坐标
				nY = line * nHeight + line * EMOTICON_Y_SPACE + EMOTICON_Y_SPACE + EMOTICON_OFFSET_Y;
                
				// 得到每个表情图标的的矩形区域
				CGRect rectEmoticon = CGRectMake(nX, nY, nWidth, nHeight);
				
				// 统计当前的图标数量
				currentCounts = page * EMOTICON_LINE * self.numOfEmotionForRow + line * self.numOfEmotionForRow + row;
				
				// 将每个图标的矩形坐标保存到数组中
				[arrayButtonRect addObject:[NSValue valueWithCGRect:rectEmoticon]];
				
				// 如果已经到达最大的图标数量则跳出循环
				if (currentCounts == EMOTICON_COUNTS-1) {
					break;
				}
			}
			
			// 如果已经到达最大的图标数量则跳出循环
			if (currentCounts == EMOTICON_COUNTS-1) {
				break;
			}
		}
		
		// 如果已经到达最大的图标数量则跳出循环
		if (currentCounts == EMOTICON_COUNTS-1) {
			break;
		}
	}
    // 每一个表情按钮
	UIButton *buttonEmoticon = nil;
	// 将使用按钮来将图标贴出来显示
	for (int i=0; i < [arrayButtonRect count]; i++)
	{
		buttonEmoticon = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, nWidth, nHeight)];
		
		// 设置表情按钮的触发位置，位置都是从已经保存的图标矩形数组中取出来
        [buttonEmoticon setFrame:[[arrayButtonRect objectAtIndex:i] CGRectValue]];
        
        // 使用整张表情图标做为背景图片，将单独加载图标到按钮功能屏蔽
        // 将资源图片从plist字典中取出来
        UIImage *imageEmoticon = [UIImage imageNamed:[NSString stringWithFormat:@"mms_face_%02d", i+1]];
        
        // 设置表情按钮的相应表情图片
        [buttonEmoticon setImage:imageEmoticon forState:UIControlStateNormal];
        
        // 设置表情按钮的点击高亮状态后的图片
        [buttonEmoticon setBackgroundImage:nil
                                  forState:UIControlStateNormal];
        [buttonEmoticon setBackgroundImage:[UIImage imageNamed:@"button_emoticon_high"]
                                  forState:UIControlStateHighlighted];
        buttonEmoticon.tag = i+1;
        
		// 增加表情按钮的响应事件
		[buttonEmoticon addTarget:self
						   action:@selector(touchSelectedEmoticonButton:)
				 forControlEvents:UIControlEventTouchUpInside];
		
		// 将按钮加载到scrollView上
		[self.emoticonScrollView addSubview:buttonEmoticon];
	}
}

// 动态计算表情或sticker在不同屏幕上的横向的：个数、边距、间距
+ (EmoticonStickerViewLayout)calculationEmotionAndStickerLayoutWithMargin:(CGFloat)fDefaultSingleMargin
                                                            forImageWidth:(CGFloat)fImageWidth
                                                         withImageSpacing:(CGFloat)fDefaultSpaceBetween
{
    EmoticonStickerViewLayout emoticonViewLayout = {0,0,0};
    
    // 表情整个窗口的宽度(减少一个图标的宽度，因为间距个数比图标个数少一个)
    int nImageViewContentWidth = UISCREEN_BOUNDS_SIZE.width - (fDefaultSingleMargin*2 + fImageWidth);
    
    // 表情在一行的个数：使用窗口的宽度 除以 单个表情宽度+默认的表情间距 + 减少的一个图标
    emoticonViewLayout.nImageRowCount = ((int)nImageViewContentWidth / (fImageWidth + fDefaultSpaceBetween)) + 1;
    
    // 剩余的空间的间距偏移量：(使用窗口的宽度 % 单个表情宽度+默认的表情间距)取余数 除以 (一行表情的个数+1)
    float fSpacingOffset = (float)(nImageViewContentWidth % (int)(fImageWidth + fDefaultSpaceBetween)) / (emoticonViewLayout.nImageRowCount + 1);
    
    // 将偏移量增加到表情窗口边距和表情之间的间距上
    emoticonViewLayout.fMarginWidth = fDefaultSingleMargin + fSpacingOffset;
    emoticonViewLayout.fSpacingWidth = fDefaultSpaceBetween + fSpacingOffset;
    
    return emoticonViewLayout;
}


#pragma mark -
#pragma mark Touch Selected Emoticon Button

// Gray.Wang:点击选择的表情符号的响应事件
- (void)touchSelectedEmoticonButton:(id)sender
{
	//NSLog(@"DEBUG: touchSelectedEmoticonButton : sender = %@", sender);
    
	UIButton *buttonEmoticon = (UIButton *)sender;
	NSInteger nButtonIndex = buttonEmoticon.tag;
	NSString *stringEmoticonESC = nil;
    
    NSDictionary *dictEmoticonFileNameToESC = [AppDelegate appDelegate].chatManager.emoticonFileNameToESCDict;
    // 查找表情符号名称对应的字典
    if (dictEmoticonFileNameToESC != nil && [dictEmoticonFileNameToESC count] > 0)
    {
        // 通过名称找到相应的表情字符标识
        stringEmoticonESC = [dictEmoticonFileNameToESC objectForKey:[NSString stringWithFormat:@"mms_face_%02ld", (long)nButtonIndex]];
        
        // 如果已经选择了表情符号，则通过代理告知代理者
        if (stringEmoticonESC &&
            [self.delegate respondsToSelector:@selector(didSelectedEmoticonKey:)])
        {
            [self.delegate didSelectedEmoticonKey:stringEmoticonESC];
        }
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate

// 获取滑动ScrollView的当前页面
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
	CGPoint offset = aScrollView.contentOffset;
    if (aScrollView == self.emoticonScrollView)
    {
        self.emoticonPageControl.currentPage = offset.x / UISCREEN_BOUNDS_SIZE.width;
    }
}


#pragma mark -
#pragma mark UIPageControl ActionEvent

// 页面改变时UIPageControl的控制响应
- (void)pageControlTurn:(UIPageControl *)aPageControl
{
	// 更新scrollView以匹配PageControl的变化
	NSInteger whichPage = aPageControl.currentPage;
	
    // pagecontrol的过场动画
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // 根据不同的pageControl来执行不同的操作
    if (aPageControl == self.emoticonPageControl)
	{
        // 表情控制器
        self.emoticonScrollView.contentOffset = CGPointMake(UISCREEN_BOUNDS_SIZE.width * whichPage, 0.0F);
    }
    
	[UIView commitAnimations];
}

// 初始化分割选择器（表情符号、贴图的选择按钮窗口）
- (void)initSegmentView
{
    UIBorderButton *sendButton = [[UIBorderButton alloc] initWithFrame:CGRectMake(UISCREEN_BOUNDS_SIZE.width - 10 - 50, CGRectGetHeight(self.frame) - 42, 50, 32)];
    [sendButton setBackgroundStateNormalColor:COLOR_BUTTON_BACKGROUND];
    [sendButton setBackgroundStateHighlightedColor:COLOR_OK_BUTTON_HIGHLIGHTED];
    [sendButton setTitle:NSLocalizedString(@"STR_SEND", "发送") forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    sendButton.titleLabel.font = FONT_TEXT_SIZE_14;
    [sendButton addTarget:self action:@selector(touchSendButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sendButton];
}

- (void)touchSendButtonMethod:(id)sender
{
    // 如果已经选择了表情符号，则通过代理告知代理者
    if ([self.delegate respondsToSelector:@selector(sendEmotionButtonDelegateMethod)])
    {
        [self.delegate sendEmotionButtonDelegateMethod];
    }
}

@end
