//
//  InputContainerToolsView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "InputContainerToolsView.h"
#import "HPGrowingTextView.h"
#import "UIBorderButton.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

// emoticonButton与出入TextView之间的距离
#define EMOTICON_BUTTON_FOR_TEXTVIEW_SPACE  4
#define MESSAGE_INPUT_TEXTVIEW_HEIGHT 35 //输入框大小


@interface InputContainerToolsView ()
{
    UIImageView *containerImageView; // 输入框背景Imageview
}

@property (nonatomic, retain) UIButton *emoticonButton;
@property (nonatomic, retain) UIButton *recorderButton;

@end

@implementation InputContainerToolsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 添加发送与表情按钮
        [self addEmoticonButton:frame];
        
        // 设置容器view的背景色
        [self initCurrentViewBackgroundColor];
        
        // 初始化第三方文本输入TextView
        [self initGrowingTextView:frame];
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
#pragma mark Interface Methods

// 设置表情符号切换按钮的图标：YES=表情符号图标，NO=键盘图标
- (void)setEmoticonImage
{
    UIImage *emoticonButtonNomalImage = nil;// 表情按钮常态资源图片
    UIImage *emoticonButtonHightedImage = nil;// 表情按钮按下时的资源图片
    
//    UIImage *keyboardButtonNormalImage = nil; // 键盘按钮常态时的资源图片
//    UIImage *keyboardButtonHightedImage = nil;// 键盘按钮按下时的资源图片
    
    // 获取表情按钮按下时的资源图片
    emoticonButtonNomalImage = [UIImage imageNamed:@"message_session_btn_emoticon_normal"];
    emoticonButtonHightedImage = [UIImage imageNamed:@"message_session_btn_emoticon_pressed"];
    
//    keyboardButtonNormalImage = [UIImage imageNamed:@"message_session_btn_keyboard_normal"];
//    keyboardButtonHightedImage = [UIImage imageNamed:@"message_session_btn_keyboard_pressed"];
    
    [self.emoticonButton setImage:emoticonButtonNomalImage
                         forState:UIControlStateNormal];
    [self.emoticonButton setImage:emoticonButtonHightedImage
                         forState:UIControlStateHighlighted];
}


#pragma mark -
#pragma mark Custom Methods

// 初始化当前view的背景色
- (void)initCurrentViewBackgroundColor
{
   self.backgroundColor = [UIColor whiteColor];
}

- (void)initGrowingTextView:(CGRect)frame
{
    // 进行初始化设置
    self.growingTextView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(0,
                                                                      (frame.size.height - MESSAGE_INPUT_TEXTVIEW_HEIGHT)/2,
                                                                      CGRectGetMinX(self.emoticonButton.frame) - EMOTICON_BUTTON_FOR_TEXTVIEW_SPACE,MESSAGE_INPUT_TEXTVIEW_HEIGHT)];
    
    // 文字显示的偏移
    //self.growingTextView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    // 设定最大行数 6
    self.growingTextView.maxNumberOfLines = 6;
    // 设定键盘确定键
    self.growingTextView.returnKeyType = UIReturnKeySend;
    // 取消背景色
    self.growingTextView.backgroundColor = [UIColor whiteColor];
    // 设定字体颜色
    self.growingTextView.textColor = [UIColor blackColor];
    // 设定字体大小
    self.growingTextView.font = [UIFont systemFontOfSize:15];
    self.growingTextView.placeholder = @"";
    
    self.growingTextView.isScrollable = NO;
//    // 设定最小行数为 1
    self.growingTextView.minNumberOfLines = 1;
//    // 设定代理
    self.growingTextView.delegate = self;
//    // 打开动画
    self.growingTextView.animateHeightChange = YES;
    // 滑动杠缩减范围
    self.growingTextView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    self.growingTextView.placeholderColor = [UIColor colorWithRed:181.0/255.0 green:181.0/255.0 blue:181.0/255.0 alpha:1];
    // self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.growingTextView];
    
    self.growingTextView.layer.borderWidth = 0.5;
    self.growingTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.growingTextView.layer.masksToBounds = YES;
    self.growingTextView.layer.cornerRadius = 3.0;
}

// 添加表情键和发送键
- (void)addEmoticonButton:(CGRect)frame
{
    UIImage *emoticonButtonNomalImage = nil;
    UIImage *emoticonButtonHightedImage = nil;
    
    // 添加表情按钮
    emoticonButtonNomalImage = [UIImage imageNamed:@"image_button_emotion_normal"];
    emoticonButtonHightedImage = [UIImage imageNamed:@"image_button_emotion_highlighted"];
    self.emoticonButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 30 - EMOTICON_BUTTON_FOR_TEXTVIEW_SPACE, (self.frame.size.height - 30)/2, 30, 30)];
    [self.emoticonButton setImage:emoticonButtonNomalImage
                         forState:UIControlStateNormal];
    [self.emoticonButton setImage:emoticonButtonHightedImage
                         forState:UIControlStateHighlighted];
    [self.emoticonButton addTarget:self
                            action:@selector(touchEmoticonButton)
                  forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:self.emoticonButton];
}

// 点击表情按钮
- (void)touchEmoticonButton
{
    if ([self.delegate respondsToSelector:@selector(touchEmoticonButtonDelegateMethod)])
    {
        [self.delegate touchEmoticonButtonDelegateMethod];
    }
}

#pragma mark -
#pragma mark UIGrowingTextView  Delegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewShouldBeginEditing:)])
    {
        [self.delegate growingTextViewShouldBeginEditing:growingTextView];
    }
    
    return YES;
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewShouldEndEditing:)])
    {
        [self.delegate growingTextViewShouldEndEditing:growingTextView];
    }
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    // 获取高度差
    float diff = (growingTextView.frame.size.height - height);
    
    // 根据当前的输入框高度，调整发送表情按钮的坐标，保证其在最下端
    self.emoticonButton.frame = CGRectMake(self.emoticonButton.frame.origin.x,
                                           self.emoticonButton.frame.origin.y-diff,
                                           self.emoticonButton.frame.size.width,
                                           self.emoticonButton.frame.size.height);
    
    if ([self.delegate respondsToSelector:@selector(growingTextView:willChangeHeight:)])
    {
        [self.delegate growingTextView:growingTextView willChangeHeight:height];
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    // 粘贴长文本，让文字与textview 上部分对其，处理异常显示
//    growingTextView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(growingTextViewShouldReturn:)])
    {
        [self.delegate growingTextViewShouldReturn:growingTextView];
    }
    return YES;
}

- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext
{
    // 删除字符
    if ([atext isEqualToString:@""]){
        if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
        {
            return [self.delegate growingTextView:growingTextView shouldChangeTextInRange:range replacementText:atext];
        }
        return YES;
    }
    
    // 如果输入框中没有字符并且要替换的字符也为空则返回NO
    if (self.growingTextView.text == nil || atext == nil) {
        return NO;
    }
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 粘贴字串的时候，标志是否超出
    BOOL isBeyond = NO;
    // 处理粘贴字串
    if ([atext length] > 1)
    {
        atext = [ToolsFunction translateEmotionString:atext withDictionary:appDelegate.chatManager.emotionESCToFileNameDict];
        NSString *strGrowingText = [ToolsFunction translateEmotionString:growingTextView.text withDictionary:appDelegate.chatManager.emotionESCToFileNameDict];
        
        // 如果是复制过来的字串，则计算复制的字串长度是否超出规定的长度
        NSUInteger textLastLenght = [RKCloudChatMessageManager getTextMaxLength] - [strGrowingText length];
        if (textLastLenght > 0 && [atext length] >= textLastLenght)
        {
            atext = [atext substringToIndex: textLastLenght];
            isBeyond = YES;
        }
        atext = [ToolsFunction translateEmotionString:atext withDictionary:appDelegate.chatManager.emotionESCToFileNameDict];
    }
    
    // 判断字符串的长度
    NSString *appendString = nil;
    
    // 如果粘贴的字串加上已有的字串超出最大的文本限度，则把超出的文本去掉，只留没有超出的文本
    if (isBeyond)
    {
        if (range.location < [growingTextView.text length])
        {
            // 光标在中间的情况
            appendString = [[NSString alloc] initWithFormat:@"%@%@%@", [growingTextView.text substringToIndex: range.location], atext, [growingTextView.text substringFromIndex: range.location]];
        }
        else
        {
            // 光标在最后的情况
            appendString = [[NSString alloc] initWithFormat:@"%@%@", [growingTextView.text substringToIndex: range.location], atext];
        }
        
        // 粘贴操作
        growingTextView.text = appendString;
        growingTextView.selectedRange = NSMakeRange(range.location + [atext length], 0);
        
        return NO;
    }
    else
    {
        appendString = [[NSString alloc] initWithFormat:@"%@%@", growingTextView.text, atext];
    }
    
    // 如果输入的字数大于最大，则不让用户输入
    NSString *strCompareString = [ToolsFunction translateEmotionString:appendString withDictionary:appDelegate.chatManager.emotionESCToFileNameDict];
    if ([strCompareString length] > [RKCloudChatMessageManager getTextMaxLength])
    {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(growingTextView:shouldChangeTextInRange:replacementText:)])
    {
        return [self.delegate growingTextView:growingTextView shouldChangeTextInRange:range replacementText:atext];
    }
    
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    // 判断字符串 是否超出限制
    NSString *toBeString = growingTextView.text;
    // 键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [growingTextView.internalTextView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [growingTextView.internalTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > [RKCloudChatMessageManager getTextMaxLength]) {
                self.growingTextView.text = [toBeString substringToIndex:[RKCloudChatMessageManager getTextMaxLength]];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else if (toBeString.length > [RKCloudChatMessageManager getTextMaxLength]) {
        self.growingTextView.text = [toBeString substringToIndex:[RKCloudChatMessageManager getTextMaxLength]];
    }
    
    if ([self.delegate respondsToSelector:@selector(growingTextViewDidChange:)])
    {
        [self.delegate growingTextViewDidChange:growingTextView];
    }
}

@end
