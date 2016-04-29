//
//  FriendDetailViewController.h
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTable.h"
#import "CustomAvatarImageView.h"

@protocol FriendDetailViewControllerDelegate <NSObject>

// 成功删除好友的代理方法
- (void)deleteFriendDelegateMethod:(FriendTable *)friendTable;

@end

@interface FriendDetailViewController : UIViewController<CustomAvatarImageViewDelegate>

@property (nonatomic) id<FriendDetailViewControllerDelegate>delegate;
@property (nonatomic, assign) int personalDetailType; // 详情类型
@property (nonatomic, strong) NSString *userAccount;

@end
