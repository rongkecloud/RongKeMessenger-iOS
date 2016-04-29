//
//  NewContactTableViewCell.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "NewFriendTableViewCell.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "UIBorderButton.h"
#import "AppDelegate.h"
#import "RKCloudChatMessageManager.h"
#import "CustomAvatarImageView.h"
#import "UserInfoManager.h"

@interface NewFriendTableViewCell()

@property (nonatomic, strong) UILabel *markLabel;
@property (nonatomic, strong) UIBorderButton *authorizeButton;

@end

@implementation NewFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // 添加自定义的imageView
    CustomAvatarImageView *customAvatarImageView = [[CustomAvatarImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 40.0, 40.0)];
    [customAvatarImageView setUserAvatarImageByUserId:self.friendsNotifyTable.friendAccount];
    [self addSubview:customAvatarImageView];
    // 添加 好友账号
    UILabel *labelText = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 5.0, UISCREEN_BOUNDS_SIZE.width - 120.0, 20.0)];
    labelText.text = self.friendsNotifyTable.friendAccount;
    labelText.font = FONT_TEXT_SIZE_16;
    [self addSubview:labelText];
    // 添加验证内容
    UILabel *labelDetailText = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 25.0, UISCREEN_BOUNDS_SIZE.width - 140.0, 20.0)];
    labelDetailText.text = self.friendsNotifyTable.content;
    labelDetailText.font = FONT_TEXT_SIZE_14;
    labelDetailText.textAlignment = NSTextAlignmentLeft;
    labelDetailText.textColor = COLOR_SUBHEAD_TEXT;
    [self addSubview:labelDetailText];
    
    switch ([self.friendsNotifyTable.status integerValue]) {
        case AddFriendCurrentStateNomal:
        {
            return;
        }
            break;
        case AddFriendCurrentStateSuccess:
        {
            if (self.markLabel == nil) {
                self.markLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 26)];
                self.markLabel.font = FONT_TEXT_SIZE_14;
                self.markLabel.textColor = COLOR_SUBHEAD_TEXT;
                self.accessoryView = self.markLabel;
            }
            self.markLabel.text = NSLocalizedString(@"PROMPT_HAVED_BECOME_FRIEND", @"互为好友");
        }
            break;
        case AddFriendCurrentStateWaitingValidation:
        {
            if (self.markLabel == nil) {
                self.markLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 26)];
                self.markLabel.font = FONT_TEXT_SIZE_14;
                self.markLabel.textColor = COLOR_SUBHEAD_TEXT;
                self.accessoryView = self.markLabel;
            }
            self.markLabel.text = NSLocalizedString(@"PROMPT_WAITING_VALIDATION_TITLE", @"等待对方验证");
        }
            break;
        case AddFriendCurrentStateWaitingAuthorize:
        {
            if (self.authorizeButton == nil) {
                self.authorizeButton = [[UIBorderButton alloc] initWithFrame:CGRectMake(0, 0, 68, 35)];
                [self.authorizeButton setTitle:NSLocalizedString(@"PROMPT_VALIDATION_TITLE", @"通过验证") forState:UIControlStateNormal];
                
                [self.authorizeButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
                [self.authorizeButton setTitleColor:COLOR_WITH_RGB(50, 50, 50) forState:UIControlStateNormal];
                [ToolsFunction setBorderColorAndBlueBackGroundColorFor:self.authorizeButton];
                
                [self.authorizeButton addTarget:self action:@selector(touchAuthorizeButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.authorizeButton setBackgroundColor:[UIColor redColor]];
                
                self.accessoryView = self.authorizeButton;
            }
        }
            break;
            
        default:
            break;
    }
}


- (void)touchAuthorizeButtonMethod:(id)sender
{
    // 通过验证提交服务器
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    // 向服务器提交申请信息
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 提交申请
        [[AppDelegate appDelegate].contactManager asyncaConfirmAddFriend:self.friendsNotifyTable];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView hideWaitingMaskView];
            
            switch ([self.friendsNotifyTable.status integerValue]) {
                case AddFriendCurrentStateSuccess: // 通过验证
                {
                    [[AppDelegate appDelegate].contactManager getContactInfoByUserAccount:self.friendsNotifyTable.friendAccount];
                    
                    // 更新联系人列表
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
                    
                    LocalMessage *callLocalMessage = nil;
                    
                    // 向对方发送验证通过的消息
                   callLocalMessage = [LocalMessage buildSendMsg:self.friendsNotifyTable.friendAccount withMsgContent:nil forSenderName:[AppDelegate appDelegate].userProfilesInfo.userAccount];
                    // 保存扩展信息
                    callLocalMessage.textContent = NSLocalizedString(@"RKCLOUD_SINGLE_CHAT_MSG_CALL", nil);
                    [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
                    
                    [self setNeedsDisplay];
                    
                    // 同时下载个人头像
                    if (![ToolsFunction isFileExistsAtPath:[ToolsFunction getFriendThumbnailAvatarPath:self.friendsNotifyTable.friendAccount]])
                    {
                        [[AppDelegate appDelegate].userInfoManager asyncDownloadThumbnailAvatarWithAccount:self.friendsNotifyTable.friendAccount];
                    }
                }
                    break;

                default:
                    break;
            }
        });
    });
}


@end
