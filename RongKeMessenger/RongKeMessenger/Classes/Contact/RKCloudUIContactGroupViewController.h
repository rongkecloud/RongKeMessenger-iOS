//
//  RKCloudUIContactGroupViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChat.h"

@interface RKCloudUIContactGroupViewController : UITableViewController <UINavigationControllerDelegate,UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
}

//- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated;

@property (nonatomic, strong) UISearchBar *searchBarItem;
//@property (nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;

@property (nonatomic, strong) NSArray *allGroupChatArray;                               // 所有群聊对象
@property (nonatomic, strong) NSArray *filteredGourps;                       // 过滤的群聊对象

@property (nonatomic, strong) NSString *forwardSessionID; // 转发给某个成员对象的名称
@property (nonatomic) int contactMode;                       // 通讯录模式
@property (nonatomic, strong) RKCloudChatBaseMessage *currentMessageObject;     // 多媒体短信(用于转发)


@end