//
//  ContainerContactImageView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CONTACT_AVATAR_HEIGHT 50
#define CONTACT_NAME_HEIGHT 20
#define CONTACT_COUNTS_PER_ROW 4
#define CONTACT_START_ORIGIN_Y 6

@interface SessionContactAvatarListView : UIView

@property (nonatomic) BOOL isDelete;
@property (nonatomic, assign) id parent;

// 根据联系人的array添加联系人的头像
- (void)addContactAvatarByContactArray:(NSArray *)contactArray
                              isCreate:(BOOL)isCreate
                          isOpenInvite:(BOOL)isOpenInvite;

// 删除所有的用户头像
- (void)removeAllContactAvator;

@end
