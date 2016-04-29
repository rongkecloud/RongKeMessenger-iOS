//
//  MessageTableCell.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//
//  消息记录分组的表格单元

#import <UIKit/UIKit.h>
#import "CustomAvatarImageView.h"
#import "EnumMacroDefinition.h"
#import "RKCloudChat.h"

#define SESSION_LIST_TABLE_CELL @"SessionListTableCell"

@interface SessionListTableCell : UITableViewCell {

}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel; // 收件人的名字
@property (nonatomic, retain) IBOutlet UILabel *missReadLabel; // 未读短信的个数
@property (nonatomic, retain) IBOutlet UILabel *dateLabel; // 最近一条短信的日期
@property (nonatomic, retain) IBOutlet UILabel *timeLabel; // 最近一条短信的时间
@property (nonatomic, retain) IBOutlet UILabel *descriptionLabel; // 文本短信
@property (nonatomic, retain) IBOutlet UIImageView *missReadImageView; // 未读短信的背景图片

@property (nonatomic, retain) IBOutlet CustomAvatarImageView *headImageView; // 联系人的头像

#pragma mark - Config Session List TableViewCell

// 配置会话列表Cell的相关会话的信息
- (void)configSessionListByChatSessionObject:(RKCloudChatBaseChat *)sessionObject
                                withListType:(SessionListShowType)sessionListType
                            withMarkColorStr:(NSString *)markColorStr;

@end
