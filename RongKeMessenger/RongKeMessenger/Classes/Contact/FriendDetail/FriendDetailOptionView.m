//
//  FriendDetailOptionView.m
//  RongKeMessenger
//
//  Created by 陈朝阳 on 16/2/19.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "FriendDetailOptionView.h"
#import "Definition.h"

#define kButtonCount 3 // 定义子控件个数
#define kSeparatedLineCount 2 // 分割线条数
static BOOL isFriend = NO; // 是否为好友
@interface FriendDetailOptionView ()

@end
@implementation FriendDetailOptionView

#pragma mark - 
#pragma mark SYSTERM SELECTOR
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        if (isFriend) {
            // 好友
            [self setupFriendOptionMenu];
        }else
        {
            // 陌生人
            [self setupStrangerOptionMenu];
        }
        
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    // 设置frame
    if (isFriend) {
   
        // 设置button的frame
        // 计算button的宽度和高度
        CGFloat btnW = (self.frame.size.width - kSeparatedLineCount * SEPARATED_LINE_WIDTH)/kButtonCount;
        CGFloat btnH = 24;
        CGFloat btnY = (self.frame.size.height - btnH)/2;
        for (int i = 0; i < 3; i ++) {
            // 计算button的x
            CGFloat btnX = i * (btnW + SEPARATED_LINE_WIDTH);
            UIButton *button = self.subviews[i];
            button.frame = CGRectMake(btnX, btnY, btnW, btnH);
        }
        // 设置分割线的frame
        for (int i = 3; i < 5; i ++) {
            CGFloat lineX =  (i - 2)*btnW + (i - 3)*SEPARATED_LINE_WIDTH;
            UIView *line = self.subviews[i];
            line.frame = CGRectMake(lineX, 0, SEPARATED_LINE_WIDTH, 50);
        }

        
    }else
    {
        UIButton *button = self.subviews[0];
        button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        
    }
}

#pragma mark - CUSTOMER SELECTOR
#pragma mark PRIVATE SELECTOR

// 初始化好友选项卡
- (void)setupFriendOptionMenu
{
    // 依次添加三个按钮 先添加3个按钮后添加分割线方便后续调整frame
    [self addButtonWithTitle:@"消息" imageName:@"friendinfo_button_icon_message" color:COLOR_NAVBAR_ITEM_TITLE tag:FRIEND_FETAIL_OPTION_BUTTON_TAG + 0];
    [self addButtonWithTitle:@"视频" imageName:@"friendinfo_button_icon_call" color:COLOR_NAVBAR_ITEM_TITLE tag:FRIEND_FETAIL_OPTION_BUTTON_TAG + 1];
    [self addButtonWithTitle:@"删除" imageName:@"friendinfo_button_icon_delete" color:COLOR_WARNING_TEXT tag:FRIEND_FETAIL_OPTION_BUTTON_TAG + 2];
    
    // 添加两个分割线
    for (int i = 0; i < 2; i++) {
        [self addSeparatedLine];
    }
    
    // 设置背景色
    [self setBackgroundColor:[UIColor whiteColor]];
}

// 初始化陌生人选项卡
- (void)setupStrangerOptionMenu
{
    UIButton *btn = [self addButtonWithTitle:@"添加好友" imageName:@"add_new_friend_button_icon" color:[UIColor whiteColor] tag:FRIEND_FETAIL_OPTION_BUTTON_TAG + 3];
    
    // 设置title的边距
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
    // 设置背景色
    [self setBackgroundColor:COLOR_BUTTON_BACKGROUND];
}

// 添加一个按钮（字体15号）
- (UIButton *)addButtonWithTitle:(NSString *)title imageName:(NSString *)imgName color:(UIColor *)color tag:(NSUInteger) btnTag
{
    if (title == nil || imgName == nil || color == nil) {
        NSLog(@"ERROR:Add Button error title = %@, imgName = %@",title,imgName);
        return nil;
    }
    UIButton *btn = [[UIButton alloc] init];
    
    // 设置
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:color forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [btn.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btn setAdjustsImageWhenHighlighted:YES];
    [btn setTag:btnTag];
    
    // 调整内边距
    if (btnTag - FRIEND_FETAIL_OPTION_BUTTON_TAG == 3 ) {
         btn.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
    }else
    {
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);

    }
    
    // 添加点击事件
    [btn addTarget:self action:@selector(touchOptionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    // 添加
    [self addSubview:btn];
    
    return btn;
}

// 分割线（1px）
- (void)addSeparatedLine
{
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5, 50)];
    
    // 设置
    [line setBackgroundColor:COLOR_SEPARATED_VIEW_BACKGROUND];
    
    [self addSubview:line];
}

#pragma mark TOUCH BUTTON SELECTOR

// 按钮点击事件
- (void)touchOptionBtn:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(touchUpInsideWithButtonTag:)]) {
        [self.delegate touchUpInsideWithButtonTag:button.tag];
    }
}

#pragma mark PUBLIC SELECTOR

// 加载好友的底部选项卡
+(instancetype)creatFriendOptionMenu:(BOOL)isfriend frame:(CGRect)frame
{
    isFriend = isfriend;
    // 好友
    FriendDetailOptionView *optionMenu = [[FriendDetailOptionView alloc] initWithFrame:frame];
   
    return optionMenu;
}

@end
