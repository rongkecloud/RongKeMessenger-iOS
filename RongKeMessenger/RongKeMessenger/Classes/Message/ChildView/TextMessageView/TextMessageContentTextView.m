//
//  TextMessageContentTextView.m
//  RongKeMessenger
//
//  Created by GrayWang on 14-3-11.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "TextMessageContentTextView.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "ChatManager.h"

@implementation TextMessageContentTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

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
#pragma mark custom methods

// 针对显示文本信息，来设置UITextView的属性
- (void)setTextViewAttributed
{
    // 设置超链接的属性
    NSDictionary *linkDic = @{NSFontAttributeName: self.font, NSForegroundColorAttributeName:[UIColor blueColor],NSUnderlineStyleAttributeName: [NSNumber numberWithBool: YES]};
    self.linkTextAttributes = linkDic;
    
    self.font = MESSAGE_TEXT_FONT;
    self.dataDetectorTypes = UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber | UIDataDetectorTypeAddress;
    self.editable = NO;
    self.allowsEditingTextAttributes = NO;
    self.scrollEnabled = NO;
    // self.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
}

// 显示文本消息
- (void)displayTextMessage
{
    // 容错文本内容为nil的crash情况
    if (self.textContent == nil) {
        self.textContent = @"";
    }
    
    // 通过文本字串创建属性化字串
    NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString:self.textContent attributes:nil];
    
    // 替换表情图片
    [self replaceEmotionImage:textAttributedString];
    
    // 设置字体
    [textAttributedString addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, [[textAttributedString string] length])];
    // 为UITextView的属性化字串赋值
    self.attributedText = textAttributedString;
    
    // 针对显示文本信息，来设置UITextView的属性
    [self setTextViewAttributed];
    
}

// 对文本字串属性化操作--替换表情符号
- (void)replaceEmotionImage:(NSMutableAttributedString *)textAttributedString
{
    AppDelegate * appDelegate = [AppDelegate appDelegate];
    NSString * stringKey = nil;
	NSString * emotionName = nil;
	NSArray *arrayKeys = [appDelegate.chatManager.emotionESCToFileNameDict allKeys];
	NSRange emotionRange;
    
	// 发送时将文本中的表情描述转换为表情转义字符串
	for (int i = 0; i < [arrayKeys count]; i++)
    {
		// 表情转移字符
		stringKey = [arrayKeys objectAtIndex:i];
        emotionRange = [[textAttributedString string] rangeOfString: stringKey];
        
        // 查找是否存在表情符号
        if (emotionRange.length > 0)
        {
            // 表情符号对应的图标名称
            emotionName = [appDelegate.chatManager.emotionESCToFileNameDict objectForKey:stringKey];
            
            // 属性化表情符号
            NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] initWithData:nil ofType:nil];
            UIImage *imageEmoticon = [UIImage imageNamed:emotionName];
            imageAttachment.image = imageEmoticon;
            imageAttachment.bounds = CGRectMake(0, -5, MESSAGE_EMOTICON_WIDTH, MESSAGE_EMOTICON_HEIGHT);
            NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
            
            // 将文本字符串中的表情转义字符替换为表情字符串
            if (stringKey && emotionName)
            {
                // 通过循环替换字串中所有的表情符号
                while ([[textAttributedString string] rangeOfString:stringKey].length > 0)
                {
                    [textAttributedString replaceCharactersInRange:[[textAttributedString string] rangeOfString:stringKey]
                                              withAttributedString:imageAttributedString];
                }
            }
        }
	}
}

// 解决UITextView把longPress手势截取的问题
- (BOOL)canBecomeFirstResponder
{
    NSArray *gestureArray = [self gestureRecognizers];
    UIGestureRecognizer *gestureRecognizer = nil;
    for (int i = 0; i < [gestureArray count]; i++)
    {
        gestureRecognizer = [gestureArray objectAtIndex: i];
        if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] && gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            if ([self.textDelegate respondsToSelector:@selector(longPressEvent:)]) {
                [self.textDelegate longPressEvent:(UILongPressGestureRecognizer *)gestureRecognizer];
            }
            break;
        }
    }
    
    return NO;
}

@end
