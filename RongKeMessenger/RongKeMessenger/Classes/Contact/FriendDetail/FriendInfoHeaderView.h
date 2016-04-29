//
//  FriendInfoHeaderView.h
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendInfoTable.h"
#import "FriendTable.h"

@interface FriendInfoHeaderView : UIView

@property (nonatomic, strong) FriendTable *friendTable;
@property (nonatomic, strong) FriendInfoTable *friendinfoTable;
@property (nonatomic, strong) NSString *userAccount;

/**
 *  初始化好友详情头像 名称 备注名
 *
 *  @param delegate    代理
 *  @param userAccount 用户名 用来判断需不需要显示 备注名
 */
- (void)initAvatarAndNameLabel:(id)delegate andUserAccount:(NSString *)userAccount;
// 更新好友头像与名称信息
- (void)updateAvatarAndLabelInfo;

@end
