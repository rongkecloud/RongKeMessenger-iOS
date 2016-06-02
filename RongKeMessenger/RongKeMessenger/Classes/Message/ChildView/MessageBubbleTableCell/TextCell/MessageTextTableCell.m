//
//  MessageTextTableCell.m
//  RongKeMessenger
//
//  Created by GrayWang on 11-7-29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "MessageTextTableCell.h"
#import "ToolsFunction.h"

@interface MessageTextTableCell()


@end
@implementation MessageTextTableCell

@synthesize tryAgainButton;
@synthesize textMessageContentView;
@synthesize textMessageContentTextView;
//@synthesize textWebView;
//@synthesize textMessageString;
@synthesize urlsArray;
@synthesize resendLabel;

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
#pragma mark Draw Rect

- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
    
#if 1
	// 得到文本消息的size
	CGSize textCellSize = CGSizeZero;
    // 标识ios6和ios7下的文本框View
    UIView *textView = nil;
    
    // 兼容ios6 和 ios7 下文本消息框与泡泡间的上下间距之和
    float useCellTextTopAndBottom = 0.0;
    // 兼容ios6 和 ios7 下文本消息框与泡泡间的左右间距之和
    float useCellTextLeftAndRight = 0.0;
    // 文本消息框距屏幕右端的距离
    float textMessageRight = 0.0;
    
    // 文本消息泡泡距屏幕左边的X坐标值
    int textRectSizeX = 0;
    
    // ios7和ios6下分别使用不同的控件显示文本消息
    if ([ToolsFunction iSiOS7Earlier] == NO)
    {
        textCellSize = [ChatManager getTextCellSizeFromStringInTextView: self.textMessageContentTextView.textContent withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
        
        // 设置文本颜色(2016.02.26:Jacky.Chen,add)
        if (isSenderMMS) {
            // 本地发送
             [self.textMessageContentTextView setTextColor:MESSAGE_TEXT_COLOR_SELF];
        }else
        {
            [self.textMessageContentTextView setTextColor:MESSAGE_TEXT_COLOR_OTHER];
        }
        textView = self.textMessageContentTextView;
        
        useCellTextLeftAndRight = CELL_TEXT_LEFT_AND_RIGHT;
        textMessageRight = CELL_TEXT_BUBBLE_RIGHT_DISTANCE;
    }
    else
    {
        textCellSize = [ChatManager getTextCellSizeFromStringInView:self.textMessageContentView.textContent
                                                     withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
        // 设置文本颜色
        if (isSenderMMS) {
            // 本地发送
            [self.textMessageContentView setTextColor:MESSAGE_TEXT_COLOR_SELF];
        }else
        {
            [self.textMessageContentView setTextColor:MESSAGE_TEXT_COLOR_OTHER];
        }

        textView = self.textMessageContentView;
        
        // 在ios6下，如果大于一行，则文本和泡泡之间需要一段间距
        if (textCellSize.height >= TEXT_BUBBLE_MIN_HEIGHT)
        {
            useCellTextTopAndBottom = CELL_TEXT_MIDDLE_SPACE_IOS7_EARLIER;
        }
        
        useCellTextLeftAndRight = CELL_TEXT_LEFT_AND_RIGHT_IOS7_EARLIER;
        textMessageRight = CELL_TEXT_BUBBLE_RIGHT_DISTANCE_IOS7_EARLIER;
    }
    
    CGRect textBubbleViewRect = CGRectZero;
    
    // 本地发送的消息
    if (isSenderMMS)
    {
        // 获取发送消息泡泡的rect值
        textRectSizeX = UISCREEN_BOUNDS_SIZE.width - textCellSize.width - textMessageRight + useCellTextLeftAndRight;
        textBubbleViewRect = CGRectMake(textRectSizeX,
                                        CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
                                        textCellSize.width + CELL_BUBBLE_ARROW_WIDTH,
                                        textCellSize.height + useCellTextTopAndBottom);
        
        
        // 获取发送文本消息框距泡泡左边的间距
        float textMessageContentX = textRectSizeX + useCellTextLeftAndRight;
        // 获取发送文本消息框距泡泡的上间距
        float textMessageContentY = CELL_MESSAGE_BUBBLE_TOP_DISTANCE + useCellTextTopAndBottom/2;
        if (textCellSize.height < TEXT_BUBBLE_MIN_HEIGHT)
        {
            textMessageContentY = textMessageContentY + (TEXT_BUBBLE_MIN_HEIGHT - textCellSize.height)/2;
        }
        
        [textView setFrame:CGRectMake(textMessageContentX,
                                      textMessageContentY,
                                      textCellSize.width,
                                      textCellSize.height)];
    }
	else
    {
		// 获取泡泡的rect
        textRectSizeX = CELL_MESSAGE_BUBBLE_LEFT_DISTANCE;
        textBubbleViewRect = CGRectMake(textRectSizeX,
                              CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
                              textCellSize.width + CELL_BUBBLE_ARROW_WIDTH,
                              textCellSize.height + useCellTextTopAndBottom);
		
        // 文本消息框的X坐标
        float textMessageContentX = textRectSizeX + CELL_BUBBLE_ARROW_WIDTH + useCellTextTopAndBottom/2;
        
        // 文本消息框的Y坐标
        float textMessageContentY = CELL_MESSAGE_BUBBLE_TOP_DISTANCE + useCellTextTopAndBottom/2;
        // 调整泡泡最小高度为41后，调整文本框的Y坐标,使得表情消息整体居中
        if (textBubbleViewRect.size.height < TEXT_BUBBLE_MIN_HEIGHT)
        {
            textMessageContentY = textMessageContentY + (TEXT_BUBBLE_MIN_HEIGHT - textCellSize.height)/2;
        }
        
		[textView setFrame:CGRectMake(textMessageContentX,
                                      textMessageContentY,
                                      textCellSize.width,
                                      textCellSize.height)];
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
    
    // 设置泡泡的矩形区域
    [self.messageBubbleView setBubbleRect:textBubbleViewRect];
    
    // 修正重发按钮的坐标
    [self.tryAgainButton setFrame:CGRectMake(textBubbleViewRect.origin.x - self.tryAgainButton.frame.size.width - CELL_DISTANCE_BETWEEN_STATUS_AND_LEFT_OF_BUBBLE,
                                             CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(self.resendLabel.frame),
                                             self.tryAgainButton.frame.size.width,
                                             self.tryAgainButton.frame.size.height)];
    
    // 设置重发提示的Label坐标
    [self.resendLabel setFrame:CGRectMake(self.tryAgainButton.frame.origin.x - CELL_DISTANCE_BETWEEN_TIME_AND_LEFT_OF_STATUS -self.resendLabel.frame.size.width,
                                          CGRectGetMaxY(self.messageBubbleView.bubbleRect) - CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE - CGRectGetHeight(self.resendLabel.frame),
                                          self.resendLabel.frame.size.width,
                                          self.resendLabel.frame.size.height)];
	
	// 刷新内容区域
    [textView setNeedsDisplay];
	[self.messageBubbleView setNeedsDisplay];
#else
    /*
     // 得到文本消息的size
     CGSize textCellSize = [ChatManager getTextCellSizeFromStringInView:textMessageString withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH];
     
     //修正表情显示不全的问题
     // textCellSize.width += 3;
     
     int x = 0;
     
     // 本地发送的消息
     if (isLocalMMS) {
     // 以下坐标由右至左开始计算，38为泡泡的右边到屏幕右侧的距离，30为泡泡空白的总值
     x = UISCREEN_BOUNDS_SIZE.width - textCellSize.width - 38;
     textRect = CGRectMake(x,
     CELL_MESSAGE_BUTTOM_DISTANCE,
     textCellSize.width + 30,
     textCellSize.height + 5 * 2);
     
     // 编辑状态下的button位置修正
     [self.textWebView setFrame:CGRectMake(x + 11,
     CELL_MESSAGE_BUTTOM_DISTANCE + 5,
     textCellSize.width,
     textCellSize.height)];
     }
     else {
     //以下坐标由右至左开始计算，55为泡泡和左边的间距
     x = 55;
     textRect = CGRectMake(x,
     CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
     textCellSize.width + 30,
     textCellSize.height + 5 * 2);
     
     [self.textWebView setFrame:CGRectMake(x + 21,
     CELL_MESSAGE_BUBBLE_TOP_DISTANCE,
     textCellSize.width,
     textCellSize.height)];
     }
     
     // 确保泡泡的高度大于最小高度33
     if (textRect.size.height< TEXT_BUBBLE_MIN_HEIGHT)
     {
     textRect.size.height = TEXT_BUBBLE_MIN_HEIGHT;
     }
     
     // 确保泡泡的宽大于等于40
     if (textRect.size.width < 40) {
     textRect.size.width = 40;
     }
     
     // 设置泡泡的矩形区域
     [self.messageBubbleView setBubbleRect:textRect];
     
     // 修正重发按钮的坐标
     [self.tryAgainButton setFrame:CGRectMake(textRect.origin.x - self.tryAgainButton.frame.size.width - 10,
     (self.messageBubbleView.bubbleRect.size.height - tryAgainButton.frame.size.height)/2 + CELL_MESSAGE_TOP_DISTANCE,
     self.tryAgainButton.frame.size.width,
     self.tryAgainButton.frame.size.height)];
     
     //设置重发提示的Label坐标
     [self.resendLabel setFrame:CGRectMake(self.tryAgainButton.frame.origin.x - 5 -self.resendLabel.frame.size.width, self.tryAgainButton.frame.origin.y + 2, self.resendLabel.frame.size.width, self.resendLabel.frame.size.height)];
     
     // 刷新内容区域
     [self.messageBubbleView setNeedsDisplay];
     */
#endif
}


#pragma mark -
#pragma mark Initialization

- (void)initCellContent:(RKCloudChatBaseMessage *)messageObject isEditing:(BOOL)isEditing
{
#if 1
    
    // 针对ios7使用UITextView的属性化来显示文本消息
    if ([ToolsFunction iSiOS7Earlier] == NO)
    {
        // 隐藏在ios7之前使用绘制文本消息的view
        self.textMessageContentView.hidden = YES;
        self.textMessageContentTextView.textDelegate = self;
        self.textMessageContentTextView.textContent = messageObject.textContent;
        
        // 为UITextView的attributedText赋值
        [self.textMessageContentTextView displayTextMessage];
    }
    else
    {
        // 隐藏在ios7上显示文本的UITextView
        self.textMessageContentTextView.hidden = YES;
        
        // 初始化文本消息绘制窗口方法
        [self.textMessageContentView resetSelectHyperlinkArray];
        
        // Gray.Wang:2012.12.10:如果文本字符串中有URL链接，则替换标题符号为多语言字符串
        self.textMessageContentView.textContent = messageObject.textContent;
    }
    
#else
    /*
    // 文本消息的内容
    NSMutableString *stringMsgText = messageObject.textContent;
	// 从资源plist中加载表情符号字典
	NSDictionary *emoticonDict = [ToolsFunction loadPropertyList:EMOTICON_PLIST_NAME];
	NSString * stringKey = nil;
	NSString * stringReplacement = nil;
	NSRange range = NSMakeRange(0, [stringMsgText length]);
	NSArray *arrayKeys = [emoticonDict allKeys];
	
	// 发送时将文本中的表情描述转换为表情转义字符串
	for (int i = 0; i < [arrayKeys count]; i++) {
		range = NSMakeRange(0, [stringMsgText length]);
		// 表情转移字符
		stringKey = [arrayKeys objectAtIndex:i];
		// 表情符号对应的图标名称
		stringReplacement = [NSString stringWithFormat:@"<img src='%@.png' width=18 height=18>",
							 [emoticonDict objectForKey:stringKey]];
		// 将文本字符串中的表情转义字符替换为图标标签
		if (stringKey && stringReplacement) {
			[stringMsgText replaceOccurrencesOfString:stringKey
										   withString:stringReplacement
											  options:NSCaseInsensitiveSearch
												range:range];
		}
	}
	
	//NSLog(@"stringMsgText 2 = %@", stringMsgText);
	// 使用WebView加载和显示文本和图标
	[self.textWebView loadHTMLString:stringMsgText baseURL:[[NSBundle mainBundle] resourceURL]];
    
    textMessageString = stringMsgText;
	[stringMsgText release];
     */
#endif
    
	// 父类初始化
	[super initCellContent:messageObject isEditing:isEditing];

	// 初始化时隐藏重发按钮
	self.tryAgainButton.hidden = YES;
    self.resendLabel.text = NSLocalizedString(@"STR_RESENT_MANUALLY", nil);
    self.resendLabel.backgroundColor = [UIColor clearColor];
    self.resendLabel.hidden = YES;
	
	switch (messageObject.messageStatus)
	{
		case MESSAGE_STATE_RECEIVE_RECEIVED: // 已接收
		{
            // 当接收到的时候更新消息状态为“已读”状态
            [RKCloudChatMessageManager updateMsgStatusHasReaded:messageObject.messageID];
		}
			break;
			
		case MESSAGE_STATE_SEND_FAILED: // 发送失败
		{
			self.tryAgainButton.hidden = NO;
            
            // 根据DCR的需求去掉重发的提示，暂时对该控件隐藏的处理
            self.resendLabel.hidden = YES;
		}
			break;
		
		default:
			break;
	}
}

#pragma mark -
#pragma mark Touch Button Action

// 重新发送
- (IBAction)touchTryAgainButton {
	// 调用父类的重发函数
	[super touchResendButton:self];
}

// 禁止触发事件
- (void)disableButtonAction:(BOOL)flag {
    
    [super disableButtonAction:flag];
	self.tryAgainButton.enabled = !flag;
}


#pragma mark -
#pragma mark UITapGestureRecognizer

// 启用手势识别（目前没有使用）
- (void)enableTapGesture
{
    // 为了解决ios7下，不能及时把弹出的UIMenuController删除掉
    if ([ToolsFunction iSiOS7Earlier] == NO)
    {
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(tapGesture:)];
        [self addGestureRecognizer:gestureRecognizer];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resignFirstResponder];
    [self.messageBubbleView resignFirstResponder];
}


#pragma mark -
#pragma mark Long Press Gesture Recognizer

//长按手势处理 (弹出UIMenu)
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    if (CGRectContainsPoint(self.messageBubbleView.bubbleRect, tapPoint))
    {
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
        {
            
            [super longPress:gestureRecognizer];
            
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            //在当前的menu菜单项中加入copy项目
            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:[menuController menuItems]];
            // 拷贝手势仅添加一次
            if ([tempArray count] < 4) {
                UIMenuItem *copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_COPY", nil) action:@selector(copyMessage:)];
                [tempArray insertObject:copyMenuItem atIndex:0];
                
                //设置menu选项
                [menuController setMenuItems:tempArray];
            }
            
            //显示menuController
            [menuController setMenuVisible:YES animated:YES];
        }
    }
}

// UIMenu删除键响应函数
- (void)deleteMessage:(UIMenuController*)menuController
{
    [self.vwcMessageSession deleteMMSWithMessageObject:self.messageObject];
}

// UIMenu转发键响应函数
- (void)forwardMessage:(UIMenuController*)menuController
{
    [self.vwcMessageSession forwardMMSWithMessageObject:self.messageObject];
}

// UIMenu撤回键响应函数
- (void)revokeMessage:(UIMenuController*)menuController
{
    [self.vwcMessageSession revokeMMSWithMessageObject:self.messageObject];
}

// 复制动作处理
- (void)copyMessage:(id)sender {
    // called when copy clicked in menu
	
	// Get the General pasteboard and the current tile.
	UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
	NSString *textMessageString = nil;
    
    // 根据不同的系统，获取当前显示的文本
    if ([ToolsFunction iSiOS7Earlier] == NO) {
        textMessageString = self.textMessageContentTextView.textContent;
    }
    else
    {
        textMessageString = self.textMessageContentView.textContent;
    }
    
	if (textMessageString)
    {
		NSString *stringMsgText = [NSString stringWithString:textMessageString];
		
        NSString * stringKey = nil;
		NSArray *arrayKeys = [[AppDelegate appDelegate].chatManager.emotionESCToFileNameDict allKeys];
		
		// 拷贝时将文本中的表情转义字符串转换为表情描述
		for (int i = 0; i < [arrayKeys count]; i++) {
			// 遍历每个表情转移字符串
			stringKey = [arrayKeys objectAtIndex:i];
			
			// 查找文本内容是否存在图标的转义字符串
			NSRange range = [stringMsgText rangeOfString:stringKey];
			if (range.length > 0) {
				
				// 将文本字符串中的表情转义字符串转换为表情描述([大笑])
				stringMsgText = [stringMsgText stringByReplacingOccurrencesOfString:stringKey
																		 withString:NSLocalizedString(stringKey, nil)];
				
				// 将表情描述字符做为Key，表情转义字符串做为Value添加到字典中，供发送文本字符串时再替换为转义字符串使用
				[[AppDelegate appDelegate].chatManager.emoticonMultilingualStringToESCDict setObject:stringKey
                                                                                                                        forKey:NSLocalizedString(stringKey, nil)];
				
			}
		}
        
		// 得到文本字符串的内容保存到系统剪切板里，为粘贴使用
		[gpBoard setString:stringMsgText];
	}
}

- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender {
    if (selector == @selector(deleteMessage:) 
        || selector == @selector(forwardMessage:) 
        || selector == @selector(copyMessage:)
        || selector == @selector(revokeMessage:)){
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark TextMessageContentTextViewDelegate methods

// 处理UITextView上的longPress事件
- (void)longPressEvent:(UILongPressGestureRecognizer *)gestureRecognizer
{
    [self longPress:gestureRecognizer];
}


/****************** 以下代码没有使用，为测试代码，目的为获取字符串中的Url链接，尝试打开。********************/
/*
#pragma mark -
#pragma mark Test Method

- (BOOL)hasURLString:(NSString *)textContent
{
    if (textContent == nil) {
        return NO;
    }
	//判断字符串中是否有标准的URL连接地址
	//NSLog(@"MMS: has URL string?");
	NSString * textString = [[NSString alloc] initWithString:textContent];
	NSError *error;
	BOOL hasURL = NO;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[a-zA-z]+://[^\\s]*" options:0 error:&error];
	if (regex != nil) {
		NSArray *arry = [regex matchesInString:textString  options:0 range:NSMakeRange(0, [textString length])];
		
		if ([arry count] > 0) 
		{
            if (self.urlsArray == nil) {
                NSMutableArray *urlTableArray = [[NSMutableArray alloc] init];
                self.urlsArray = urlTableArray;
                [urlTableArray release];
            }
			for (int i = 0; i < [arry count]; i++) 
			{
				NSTextCheckingResult *firstMatch = [arry objectAtIndex:i];
				if (firstMatch) {
					NSString *resultURL = [textString substringWithRange:[firstMatch rangeAtIndex:0]];
					//[temp addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[[UIColor blueColor] CGColor] range:[firstMatch rangeAtIndex:0]];
					//输出结果
					if (resultURL != nil) {
						[self.urlsArray addObject:resultURL];
					}
				}
			}
			hasURL = YES;
		}
		else {
			NSLog(@"MMS: No URLString");
		} 
	}
	[textString release];
	return hasURL;
}

- (void)showActionSheetwithURLs
{
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"打开链接"
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", nil)
											   destructiveButtonTitle:nil//NSLocalizedString(@"TITLE_ACTIONSHEET_CLEARALL", nil)
													otherButtonTitles:@"打开",
								  nil];
	[actionSheet setActionSheetStyle: UIActionSheetStyleBlackTranslucent];
	[actionSheet showInView: [[(MessageSessionViewController *)self.parent view] superview]];
	[actionSheet release];
}


#pragma mark -
#pragma mark UIActionSheet Delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        //        NSURL*url=[NSURL URLWithString:@"prefs:root=General&path=Network/VPN"];
        //        [[UIApplication sharedApplication] openURL:url];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Safari"]];
        
        //        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.urlsArray objectAtIndex:buttonIndex]]];
        
        //        NSURL *url = [NSURL URLWithString:[self.urlsArray objectAtIndex:buttonIndex]];
        //        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        //        UIWebView *webview = [[UIWebView alloc] init];
        //        [webview loadRequest:requestObj];
        //        [webview release];
    }
}
*/
/****************** 以上代码没有使用，为测试代码，目的为获取字符串中的Url链接，尝试打开。********************/

@end
