//
//  CustomImageView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomAvatarImageViewDelegate <NSObject>

- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount;

@optional

- (void)deleteContactFromSession:(NSString *)deleteUserId;
@end

@interface CustomAvatarImageView : UIImageView
@property (nonatomic, strong) NSString *userAccount;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, weak) id <CustomAvatarImageViewDelegate> delegate;


#pragma mark -
#pragma mark Custom methods

// 重置cell中的控件
- (void)resetCellConrol;

// 设置用户的头像根据用户的角色
- (void)setUserAvatarImageByUserId:(NSString *)userId;


@end
