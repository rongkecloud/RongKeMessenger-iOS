//
//  RKChatSessionListViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RKCloudBase.h"
#import "RKCloudChat.h"

@class RKChatSessionViewController;

@interface RKChatSessionListViewController : UIViewController <UINavigationControllerDelegate,UITextFieldDelegate, UISearchBarDelegate,UISearchDisplayDelegate, RKCloudChatDelegate>
@property (nonatomic, strong) RKChatSessionViewController *messageSessionViewController; // 打开的消息列表

@property (nonatomic, strong) NSMutableDictionary *progressDic; // 保存上传、下载进度值

// 加载所有的会话列表
- (void)loadAllChatSessionList;

// 创建一个新的消息会话
- (void)createNewChatView:(RKCloudChatBaseChat *)chatSession;

@end
