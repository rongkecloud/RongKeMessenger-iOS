//
//  MeetingRoomViewController.h
//  RKCloudMeetingTest
//
//  Created by 程荣刚 on 15/8/7.
//  Copyright (c) 2015年 rongkecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudMeeting.h"

@interface MeetingRoomViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (assign, nonatomic) BOOL isCreator; // 是否为创建者

/**
 *  会议信息有同步，包括会议本身的信息和会议参与者信息
 */
- (void)updateUserMeetingInfo:(NSDictionary *)meetingUserAccountToUserObjectDict;

/**
 *  退出会议
 */
- (void)quitMeetingWithReason:(NSInteger)reason;

#pragma mark - Call Time Method

// 启动检测通话时间定时器定时器
- (void)startDetectTalkingTime;

// 停止检测通话时间定时器定时器
- (void)stopDetectTalkingTime;

@end
