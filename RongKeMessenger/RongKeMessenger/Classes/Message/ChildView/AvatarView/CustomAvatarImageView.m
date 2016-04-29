//
//  CustomImageView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "CustomAvatarImageView.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "PersonalInfos.h"
#import "AppDelegate.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"

@interface CustomAvatarImageView ()
{
    UIImageView *userRoleImageView;
}
@end

@implementation CustomAvatarImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 下载图片成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAvatarSuccessNotification:) name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
        
        // Initialization code
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMethod:)];
        [self addGestureRecognizer: tapGesture];
        
        UIButton *buttonDelete = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        [buttonDelete setImage:[UIImage imageNamed:@"message_session_btn_delete_n"] forState:UIControlStateNormal];
        [buttonDelete setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 18, 18)];
        [buttonDelete addTarget:self action:@selector(touchDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [buttonDelete setHidden:YES];
        self.deleteButton = buttonDelete;
        
        [self addSubview:self.deleteButton];
        
        //设置头像圆角
        self.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if (self) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMethod:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
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
#pragma mark Custom methods

// 重置cell中的控件
- (void)resetCellConrol
{
    userRoleImageView.image = nil;
    userRoleImageView = nil;
}

// 设置用户的头像
- (void)setUserAvatarImageByUserId:(NSString *)userId
{
    if (userId == nil) {
        return;
    }
    
    self.userAccount = userId;
    self.userInteractionEnabled = YES;
    // 设置头像圆角
    self.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
    self.layer.masksToBounds = YES;
    
    UIImage *avatarImage = [ToolsFunction getFriendAvatarWithFriendAccount:userId andIsThumbnail:YES];
    
    // Jacky.Chen.03.01,修改设置小秘书图片的逻辑
    // 判断是否是小秘书
    if ([ToolsFunction isRongKeServiceAccount:userId]) {
        
        self.image = [UIImage imageNamed:@"rong_ke_service_icon"];

    }
    else
    {
        // 用户图像
        if (avatarImage)
        {
            self.image = avatarImage;
        }
        else
        {
            self.image = [UIImage imageNamed:@"default_icon_user_avatar"];
        }

    }
    
    // 获取对方最新
    [[AppDelegate appDelegate].contactManager getContactInfoByUserAccount:userId];
}

// 点击删除按钮的button
- (void)touchDeleteButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deleteContactFromSession:)])
    {
        [self.delegate deleteContactFromSession: self.userAccount];
    }
}

#pragma mark -
#pragma mark TapGesture

- (void)tapMethod:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(touchAvatarActionForUserAccount:)]) {
                [self.delegate touchAvatarActionForUserAccount:self.userAccount];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark Update Avatar

// 下载图片成功通知方法
- (void)downloadAvatarSuccessNotification:(NSNotification *)notification
{
    if (notification == nil || notification.object == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setUserAvatarImageByUserId:self.userAccount];
    });
}


@end
