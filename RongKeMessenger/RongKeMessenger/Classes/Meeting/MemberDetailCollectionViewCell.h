//
//  MemberDetailCollectionViewCell.h
//  RKCloudMeetingTest
//
//  Created by 程荣刚 on 15/8/8.
//  Copyright (c) 2015年 rongkecloud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomAvatarImageView.h"

@interface MemberDetailCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet CustomAvatarImageView *memberAvatarImageView; // 会议成员头像图片

@property (weak, nonatomic) IBOutlet UIImageView *avatarMuteImageView; // 会议成员是否静音状态图片

@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel; // 会议成员名字

@end
