//
//  MessageBubbleTableCell.m
//  RongKeMessenger
//
//  Created by Gray on 11-9-19.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "MessageBubbleTableCell.h"
#import "Definition.h"
#import "CustomAvatarImageView.h"
#import "ToolsFunction.h"
#import "ChatManager.h"
#import "AppDelegate.h"

@interface MessageBubbleTableCell () <CustomAvatarImageViewDelegate>

@end

@implementation MessageBubbleTableCell

@synthesize messageObject;
@synthesize messageBubbleView;
@synthesize userHeaderImageView;
@synthesize userNameLabel;

// 初始化cell (子类扩展)
- (void)initCellContent:(RKCloudChatBaseMessage *)messageObj isEditing:(BOOL)isEditing
{
    // 设置背景色为绿色
    if ([ToolsFunction iSiOS7Earlier])
    {
        // ios6.1 or earlier（如果设置为clearColor则会引起泡泡不能重用和UI错乱，这个是为什么？需要继续追踪）
        [self setBackgroundColor:[UIColor greenColor]];
    }
    else
    {
        // ios7 or later
        [self setBackgroundColor:[UIColor clearColor]];
    }
    
    // 清除选定模式
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
    // 初始化当前的数据对象
	self.messageObject = messageObj;
    
	// 创建MessageBubbleView，并添加手势
    [self createMessageBubbleView];
    
    // 初始化MessageBubbleView
    [self initMessageBubbleView];
    
//    self.backgroundColor = [self randomColor];
}

- (UIColor *) randomColor
{
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

#pragma mark -
#pragma mark 初始化相关函数

// 创建messageBubbleView，添加手势仅作一次
- (void)createMessageBubbleView {
    
    // 添加绘制视图（泡泡的View）
    if (self.messageBubbleView == nil) {
        
        MessageBubbleView *bubbleView = [[MessageBubbleView alloc] initWithFrame:self.frame];
        self.messageBubbleView = bubbleView;
		
		// 插入到TableCell中
        [self.contentView insertSubview:self.messageBubbleView atIndex:0];
                
        // 定义出长按手势
        UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] 
                                                           initWithTarget:self action:@selector(longPress:)];
        // Jacky.Chen:2016.02.04:设置长按手势的最短响应时间,解决长安文字消息出现两条蓝线选择
        gestureRecognizer.minimumPressDuration = 0.3f;
        [self addGestureRecognizer:gestureRecognizer];
        
        // 添加单击手势（父类虚函数，子类实现）
        [self enableTapGesture];
    }
	else {
        [self.messageBubbleView resetState];
    }
}

// 初始化MessageBubbleView
- (void)initMessageBubbleView
{
    // 判断是否需要绘制头像姓名（不是群组消息且不是用户本人）
    isSenderMMS = (self.messageObject.msgDirection == MESSAGE_SEND &&
                  self.messageObject.messageType != MESSAGE_TYPE_GROUP_JOIN &&
                  self.messageObject.messageType != MESSAGE_TYPE_GROUP_LEAVE);
    
    // 设置用户姓名和头像
    [self setUserNameAndAvatar];
    
    // 获取cell当前高度
    float cellHeight = [ChatManager heightForMessage:self.messageObject];
    
    [self.messageBubbleView setFrame:CGRectMake(self.frame.origin.x,
                                                self.messageBubbleView.frame.origin.y,
                                                UISCREEN_BOUNDS_SIZE.width,
                                                cellHeight)];
    
    // 设置消息类型
	self.messageBubbleView.mmsObject = self.messageObject;
    // 设置是否需要显示用户名和头像
    self.messageBubbleView.isRightBubble = isSenderMMS;
    
    // 判断是否是群聊
    if (self.vwcMessageSession.currentSessionObject &&
        self.vwcMessageSession.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        self.messageBubbleView.isMultiplayerSession = YES;
    }
}


#pragma mark -
#pragma mark Custom Function

// 设置用户姓名和头像
- (void)setUserNameAndAvatar
{
    // 头像的位置
    CGRect avatarRect = CGRectMake(CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CELL_AVATAR_WIDTH, CELL_AVATAR_WIDTH);
    if (isSenderMMS == YES) {
        avatarRect = CGRectMake(UISCREEN_BOUNDS_SIZE.width - CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE - CELL_AVATAR_WIDTH , CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CELL_AVATAR_WIDTH, CELL_AVATAR_WIDTH);
    }
    
    // 添加显示头像的ImageView
    if (self.userHeaderImageView == nil)
    {
        CustomAvatarImageView *headerImageView = [[CustomAvatarImageView alloc] initWithFrame:avatarRect];
        
        self.userHeaderImageView = headerImageView;
        
        [self.userHeaderImageView setBackgroundColor:[UIColor clearColor]];
        self.userHeaderImageView.delegate = self;
        // 给头像添加弧度
        self.userHeaderImageView.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
        self.userHeaderImageView.layer.masksToBounds = YES;
        
        // 添加头像控件
        [self addSubview:self.userHeaderImageView];
    }
    else {
        [self.userHeaderImageView setFrame:avatarRect];
    }
    
    // 姓名的位置，默认接收方-左侧
    NSTextAlignment textAlignment = NSTextAlignmentLeft;
    CGRect nameRect = CGRectMake(CGRectGetMaxX(self.userHeaderImageView.frame) + CELL_DISTANCE_BETWEEN_AVATAR_AND_NAME, CGRectGetMinY(self.userHeaderImageView.frame), UISCREEN_BOUNDS_SIZE.width - CGRectGetMaxX(self.userHeaderImageView.frame) -  CELL_DISTANCE_BETWEEN_AVATAR_AND_NAME - CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CELL_MESSAGE_USER_NAME_HEIGHT);
    // 发送方-右侧
    if (isSenderMMS == YES) {
        textAlignment = NSTextAlignmentRight;
        
        nameRect = CGRectMake(CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CGRectGetMinY(self.userHeaderImageView.frame), CGRectGetMinX(self.userHeaderImageView.frame) - CELL_DISTANCE_BETWEEN_AVATAR_AND_NAME - CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE, CELL_MESSAGE_USER_NAME_HEIGHT);
    }
    
    // 添加显示姓名的Label
    if (self.userNameLabel == nil)
    {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameRect];
        // Jacky.Chen:02.26
        self.userNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.userNameLabel = nameLabel;
        
        [self.userNameLabel setTextColor: [UIColor colorWithRed:115/255.0 green:115/255.0 blue:115/255.0 alpha:1.0]];
        [self.userNameLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.userNameLabel setTextAlignment:textAlignment];
        [self.userNameLabel setBackgroundColor:[UIColor clearColor]];
        
        // 添加用户名字控件
        [self addSubview:self.userNameLabel];
    }
    else {
        [self.userNameLabel setFrame:nameRect];
        [self.userNameLabel setTextAlignment:textAlignment];
         self.userNameLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    }
    
    // 根据优先级显示自己名称
    if ([self.messageObject.senderName isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
    {
        self.userNameLabel.text = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
    } else {
        // 显示姓名
        self.userNameLabel.text = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:self.messageObject.senderName];
    }
    
    // 设置用户的头像
    [self.userHeaderImageView setUserAvatarImageByUserId:self.messageObject.senderName];
}

// 开启手势识别功能
- (void)enableTapGesture
{
    //具体实现在子类
}

- (void)disableButtonAction:(BOOL)flag {
    self.messageBubbleView.userInteractionEnabled = !flag;
}


#pragma mark -
#pragma mark 手势处理函数

//长按手势处理 (弹出UIMenu)
- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
	
    
    // FIXME:
    CGPoint tapPoint = [gestureRecognizer locationInView:self.messageBubbleView];
    if (CGRectContainsPoint(self.messageBubbleView.bubbleRect, tapPoint)) {
        
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
            //获取UIMenu点击位置
            CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
            UIMenuController *menuController = [UIMenuController sharedMenuController];
            // Jacky.Chen:2016.02.04:为防止重复显示导致的重影问题，遂显示前先进行判断。
            if (menuController.menuVisible) {
                [menuController setMenuVisible:NO animated:NO];
            }
            // 使自己变为第一响应
            [self becomeFirstResponder];
            
            //创建MenuItem
            UIMenuItem *deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_DELETE", nil) action:@selector(deleteMessage:)];
            UIMenuItem *foewardMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_FORWARD", nil) action:@selector(forwardMessage:)];
            
            // 本地消息 语音消息不支持转发 图片和文件未下载不支持转发
            if (self.messageObject.messageType == MESSAGE_TYPE_LOCAL ||
                self.messageObject.messageType == MESSAGE_TYPE_VOICE ||
                (self.messageObject.messageType == MESSAGE_TYPE_IMAGE && self.messageObject.messageStatus == MESSAGE_STATE_RECEIVE_RECEIVED) ||
                (self.messageObject.messageType == MESSAGE_TYPE_FILE && self.messageObject.messageStatus == MESSAGE_STATE_RECEIVE_RECEIVED))
            {
                // 只具有删除
                [menuController setMenuItems:[NSArray arrayWithObjects:deleteMenuItem,nil]];
            } else {
                // 删除 和 转发
                [menuController setMenuItems:[NSArray arrayWithObjects:deleteMenuItem,foewardMenuItem,nil]];
            }

            //设置menu位置
            [menuController setTargetRect:CGRectMake(location.x, location.y, 0.0f, 0.0f) inView:[gestureRecognizer view]];
            //判定UIMenu出现的位置,若位置过于靠上,则让箭头朝下
            // Jacky.Chen:2016.02.04:修改原来获取locationInWindow方法，换为使用坐标系转换方法（测试原有方法在此不能获取tap手势的坐标）
            // CGPoint locationInWindow = [gestureRecognizer locationInView:[[UIApplication sharedApplication] keyWindow]];
            CGPoint locationInWindow = [self.messageBubbleView convertPoint:tapPoint toView:[[UIApplication sharedApplication] keyWindow]];
            if ( locationInWindow.y < 114.0 ) {
                [menuController setArrowDirection:UIMenuControllerArrowUp];
            }
            else {
                [menuController setArrowDirection:UIMenuControllerArrowDefault];
            }
            
            //如果不是文本消息,则显示该UIMenu，否则在文本cell中显示
            if (self.messageObject.messageType != MESSAGE_TYPE_TEXT) {
                //使UIMenu显示
                [menuController setMenuVisible:YES animated:YES];	
            }
        }
    }
}

// UIMenu删除键响应函数
- (void)deleteMessage:(UIMenuController*)menuController {
	
    [self.vwcMessageSession deleteMMSWithMessageObject:self.messageObject];
}

// 转发键响应函数
- (void)forwardMessage:(UIMenuController*)menuController {
	
	[self.vwcMessageSession forwardMMSWithMessageObject:self.messageObject];
}

// UIMenu代理
- (BOOL)canPerformAction:(SEL)selector withSender:(id)sender {

	if (selector == @selector(deleteMessage:)||selector == @selector(forwardMessage:)) {
		return YES;
	}
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark -
#pragma mark ButtonAction

// 重发button的事件
- (void)touchResendButton:(id)sender
{
    if (self.vwcMessageSession && [self.vwcMessageSession respondsToSelector:@selector(touchResendButton:)])
    {
        [self.vwcMessageSession touchResendButton:self.messageObject];
    }
}

#pragma mark -
#pragma mark CustomAvatarImageViewDelegate methods

// 点击用户image头像，应该显示用户详细信息，此处只弹出用户名称信息
- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount
{
    [self.vwcMessageSession touchAvatarActionForUserAccount:avatarUserAccount];
}

@end
