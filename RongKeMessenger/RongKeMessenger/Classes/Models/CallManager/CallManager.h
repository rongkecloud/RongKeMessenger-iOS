//
//  CallManager.h
//  RongKeMessenger
//
//  Created by WangGray on 15/8/12.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RKCloudUICallViewController;

@interface CallManager : NSObject

@property (nonatomic, strong) RKCloudUICallViewController *callViewController; // Call View Controller(IP Phone use)
@property (nonatomic, strong) UIViewController *beforePresentedViewController; // 通话页面弹出之前存在的照相或相册等presentedViewController页面


#pragma mark - Call Dial Interface

// 呼叫语音电话
- (int)dialAudioCall:(NSString *)calleeAccount;

// 呼叫视频电话
- (int)dialVideoCall:(NSString *)calleeAccount;

@end
