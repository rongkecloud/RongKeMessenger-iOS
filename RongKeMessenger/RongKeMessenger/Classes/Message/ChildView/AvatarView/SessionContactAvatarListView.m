//
//  ContainerContactImageView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "SessionContactAvatarListView.h"
#import "CustomAvatarImageView.h"
#import "RKChatSessionInfoViewController.h"
#import "AppDelegate.h"

@interface SessionContactAvatarListView ()

//@property (strong, nonatomic) UIScrollView *containerScrollView;

@end

@implementation SessionContactAvatarListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        // 设置背景色
        //self.backgroundColor = [UIColor whiteColor];
        
        self.isDelete = NO;
        
        /*
        self.containerScrollView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 5, self.frame.size.width, self.frame.size.height - 10)];
        [self.containerScrollView setBackgroundColor: [UIColor clearColor]];
        [self addSubview:self.containerScrollView];
        */
    }
    return self;
}

- (void)dealloc
{
    /*
    [self.containerScrollView removeFromSuperview];
    self.containerScrollView = nil;
     */
}


#pragma mark -
#pragma mark Custom methods

// 根据联系人的array添加联系人的头像
- (void)addContactAvatarByContactArray:(NSArray *)contactArray
                              isCreate:(BOOL)isCreate
                          isOpenInvite:(BOOL)isOpenInvite
{
    for (UIView *subView in self.subviews) {
        if (subView) {
            [subView removeFromSuperview];
        }
    }
    if (contactArray == nil || [contactArray count] == 0)
    {
        return;
    }
    
    // x方向距离
    float avatarDistanceX = (self.frame.size.width - CONTACT_AVATAR_HEIGHT * CONTACT_COUNTS_PER_ROW) / (CONTACT_COUNTS_PER_ROW * 2 * 1.0);
    
    // 默认的是有添加联系人的按钮
    NSUInteger needAddCounts = [contactArray count] + 1;
    
    // 如果是创建者，并且群组中只有一个人，那么只显示添加按钮
    if (isCreate && [contactArray count] == 1)
    {
        isCreate = NO;
    }
    
    // 如果是创建者的话，会有删除的按钮
    if (isCreate) {
        needAddCounts++;
    }
    
    float x = 0.0;
    float y = 0.0;
    int row = 0;
    int col = 0;
    CustomAvatarImageView *customImageView = nil;
    NSString *memberUserName = @"";
    
    UILabel *nameLabel = nil;
    UIButton *buttonAvatar = nil;
    for (int i = 0; i < needAddCounts; i++)
    {
        if (i % CONTACT_COUNTS_PER_ROW == 0)
        {
            col = 0;
        }
        // 计算x坐标
        x = (col * 2 + 1) * avatarDistanceX + col * CONTACT_AVATAR_HEIGHT;
        col++;
        
        // 计算y坐标
        row = i / CONTACT_COUNTS_PER_ROW;
        y = row * (CONTACT_AVATAR_HEIGHT + CONTACT_NAME_HEIGHT + CONTACT_START_ORIGIN_Y);
        
        if (isCreate && i >= needAddCounts - 2)
        {
            if ([ToolsFunction isRongKeServiceAccount:((RKChatSessionInfoViewController *)self.parent).rkChatSessionViewController.currentSessionObject.sessionID]) {
                return;
            }
            
            buttonAvatar = [[UIButton alloc] initWithFrame:CGRectMake(x, y, CONTACT_AVATAR_HEIGHT, CONTACT_AVATAR_HEIGHT)];
            if (i == needAddCounts - 2)
            {
                // 删除联系人
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_delete_nor"] forState:UIControlStateNormal];
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_delete_press"] forState:UIControlStateHighlighted];
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_delete_press"] forState:UIControlStateSelected];
                [buttonAvatar addTarget:self action:@selector(deleteContactFromSession:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                // 添加联系人
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_nor"] forState:UIControlStateNormal];
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_press"] forState:UIControlStateHighlighted];
                [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_press"] forState:UIControlStateSelected];
                [buttonAvatar addTarget:self.parent action:@selector(addContactToSession:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [self addSubview:buttonAvatar];
        }
        else if (isCreate == NO && i == needAddCounts - 1)
        {
            if ([ToolsFunction isRongKeServiceAccount:((RKChatSessionInfoViewController *)self.parent).rkChatSessionViewController.currentSessionObject.sessionID]) {
                return;
            }
            
            // 如果群聊但是没有邀请权限，不允许出现邀请成员按钮
            if(!isOpenInvite){
                continue;
            }
            
            buttonAvatar = [[UIButton alloc] initWithFrame: CGRectMake(x, y, CONTACT_AVATAR_HEIGHT, CONTACT_AVATAR_HEIGHT)];
            // 添加联系人
            [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_nor"] forState:UIControlStateNormal];
            [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_press"] forState:UIControlStateHighlighted];
            [buttonAvatar setBackgroundImage:[UIImage imageNamed:@"message_session_btn_add_press"] forState:UIControlStateSelected];
            [buttonAvatar addTarget:self.parent action:@selector(addContactToSession:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:buttonAvatar];
        }
        else
        {
            memberUserName = [contactArray objectAtIndex: i];
            
            // 显示头像的view
            customImageView = [[CustomAvatarImageView alloc] initWithFrame: CGRectMake(x, y, CONTACT_AVATAR_HEIGHT, CONTACT_AVATAR_HEIGHT)];
            // [customImageView setBackgroundColor: [UIColor redColor]];
            [self addSubview:customImageView];
            
            customImageView.userAccount = memberUserName;
            customImageView.delegate = self.parent;
            [customImageView setUserAvatarImageByUserId:memberUserName];
            
            // 显示名字
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(customImageView.frame.origin.x - avatarDistanceX + 2, customImageView.frame.origin.y + CONTACT_AVATAR_HEIGHT, CONTACT_AVATAR_HEIGHT + avatarDistanceX * 2 - 4, CONTACT_NAME_HEIGHT)];
            nameLabel.font = [UIFont systemFontOfSize:12];
            
            //
            if ([memberUserName isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
            {
                nameLabel.text = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
            } else {
                nameLabel.text = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:memberUserName];
            }
            
            nameLabel.textColor = [UIColor blackColor];
            [nameLabel setBackgroundColor: [UIColor clearColor]];
            [nameLabel setTextAlignment:NSTextAlignmentCenter];
            [self addSubview: nameLabel];
        }
    }
}

// 删除所有的用户头像
- (void)removeAllContactAvator
{
    NSArray *subViewArray = [self subviews];
    for (int i = 0; i < [subViewArray count]; i++)
    {
        id objectView = [subViewArray objectAtIndex: i];
        [objectView removeFromSuperview];
    }
    
    self.isDelete = NO;
}

#pragma mark -
#pragma mark touch button action methods

- (void)deleteContactFromSession:(id)sender
{
    
    self.isDelete = !self.isDelete;
    NSArray *subViewArray = [self subviews];
    CustomAvatarImageView *customImageView = nil;
    for (int i = 0; i < [subViewArray count]; i++)
    {
        id objectView = [subViewArray objectAtIndex: i];
        if ([objectView isKindOfClass: [CustomAvatarImageView class]])
        {
            customImageView = (CustomAvatarImageView *)objectView;
            // 如果联系人为当前登录者，跳过
            if ([[AppDelegate appDelegate].userProfilesInfo.userAccount isEqualToString:customImageView.userAccount]) {
                continue;
            }
            customImageView.deleteButton.hidden = !self.isDelete;
        }
    }
}

@end
