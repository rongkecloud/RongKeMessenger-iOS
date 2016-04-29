//
//  ToolsControlView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChatBaseChat.h"

@protocol ToolsControlViewDelegate <NSObject>

- (void)didTouchSelectedToolsControlButtonDelegateMethod:(NSInteger)nButtonIndex;

@end

@interface ToolsControlView : UIView

@property (nonatomic, assign) id <ToolsControlViewDelegate> delegate;


// 初始化表情符号窗口以及表情符号的位置
- (id)initWithFrame:(CGRect)frame withParent:(id)parentView withRKCloudChatBaseChat:(RKCloudChatBaseChat *)sessionChatObject;
- (void)showEmoticonView:(BOOL)isShow;

@end
