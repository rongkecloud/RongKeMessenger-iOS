//
//  RKChatImagesBrowseViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChat.h"

@interface RKChatImagesBrowseViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *imageMessageArray; // 仅仅显示图片消息
@property (nonatomic, strong) RKCloudChatBaseMessage *currentMessage; // 当前显示的图片消息
@property (nonatomic)         int currentIndex;

- (id)initWithCurrentMessage:(RKCloudChatBaseMessage *)messageObject andLoadedMessage:(NSArray *)loadedMessageArray;

- (void)updateImage:(RKCloudChatBaseMessage *)messageObject;

@end
