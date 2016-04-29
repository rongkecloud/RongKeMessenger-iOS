//
//  SelectFriendsViewController.h
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Definition.h"
#import "RKCloudChat.h"

@protocol SelectFriendsViewControllerDelegate <NSObject>

- (void)selectFriendsSuccessDelegateMethod;

@end

@protocol ChatSelectFriendsViewControllerDelegate <NSObject>

- (void)selectChatFriendsWithAccout:(NSArray *)accoutArray;

@end

@interface SelectFriendsViewController : UIViewController

@property (nonatomic) id<SelectFriendsViewControllerDelegate>delegate; // 编辑分组好友的代理
@property (nonatomic) id<ChatSelectFriendsViewControllerDelegate>chatDelegate; // Chat添加联系人选择后的代理

@property (nonatomic, strong) NSString *groupId;    // 分组操作时需要的当前分组的ID
@property (nonatomic, assign) FriendsListType friendsListType;  // 使用还有列表的类型
@property (nonatomic, strong) NSArray *groupChatMembersArray;  // Chat添加好友时传入的已在会话中的好友

@property (nonatomic, strong) RKCloudChatBaseMessage *currentMessageObject;     // 多媒体短信(用于转发)

// 响应 底部选中成员方法
- (void)touchDeleteMemberButton:(id)sender;

@end
