//
//  RecordVoiceView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBorderButton.h"

@protocol RecordVoiceButtonDelegate <NSObject>
- (void)touchBegin;
- (void)touchMove:(CGPoint)point;
- (void)touchEnd:(CGPoint)point;
- (void)touchCancel;
@end


@interface RecordVoiceButton : UIBorderButton

@property (nonatomic, assign) id <RecordVoiceButtonDelegate> delegate;
@property (nonatomic) BOOL isAutoFinishRecord;


@end
