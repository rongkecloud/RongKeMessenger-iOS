//
//  RKChatSessionInfoViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChat.h"
#import "RKChatSessionViewController.h"

@interface RKChatSessionInfoViewController : UIViewController <UINavigationControllerDelegate>

@property (nonatomic, strong) RKChatSessionViewController *rkChatSessionViewController;  // 会话页面
@property (nonatomic, strong) NSMutableArray              *currentAllGroupContactArray;  // 当前所有群联系人数组，每个元素存放的是FriendTable对象

#pragma mark -
#pragma mark Chat Session Function Method

// 邀请加入一个已经存在的消息会话
- (void)joinExistChatSession:(NSArray *)arrayFriendObject;
// 向该群组中添加好友
- (void)addContactToSession:(id)sender;


#pragma mark RKCloudChatDelegate - RKCloudChatGroup

- (void)didGroupInfoChanged:(NSString *)groupId changedType:(ChangedType)changedType;
- (void)didGroupRemoved:(NSString *)groupId withRemoveType:(LeaveType)removeType;
- (void)didGroupUsersChanged:(NSString *)groupId;

@end
