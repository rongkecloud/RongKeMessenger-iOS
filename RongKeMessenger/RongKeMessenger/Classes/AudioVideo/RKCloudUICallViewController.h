//
//  RKCloudUICallViewController.h
//  RKCloudDemo
//
//  Created by WangGray on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface RKCloudUICallViewController : UIViewController

@property (nonatomic, strong) NSString *peerAccount; // 对方帐号
@property (nonatomic, assign) BOOL isVideoCall; // 是否为视频通话
@property (nonatomic, assign) BOOL isIncomingCall; // 是否来电
@property (nonatomic, assign) BOOL isAutoAnswer; // 是否自动接听


- (void)onStateCallBack:(RKCloudAVCallState)state withReason:(RKCloudAVErrorCode)stateReason;

@end
