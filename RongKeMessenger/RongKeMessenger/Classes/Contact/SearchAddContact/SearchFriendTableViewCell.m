//
//  SearchContactTableViewCell.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SearchFriendTableViewCell.h"
#import "UIBorderButton.h"
#import "Definition.h"
#import "RKTableViewCell.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "DatabaseManager+FriendTable.h"
#import "DatabaseManager+FriendsNotifyTable.h"
#import "FriendsNotifyTable.h"


@interface SearchFriendTableViewCell()<UITextFieldDelegate>

@property (nonatomic, strong) UIBorderButton *addContactButton;

@end

@implementation SearchFriendTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    FriendsNotifyTable *friendsNotifyTable = [[AppDelegate appDelegate].databaseManager getFriendsNotifyTableByFriendAccout:self.friendsNotifyTable.friendAccount];
    
    if ([[AppDelegate appDelegate].databaseManager isHaveContactTable:self.friendsNotifyTable.friendAccount])
    {
        self.accessoryView = nil;
        // 显示已加为好友
        self.detailTextLabel.text = NSLocalizedString(@"PROMPT_HAVED_BECOME_FRIEND", @"互为好友");
        
    }
    else if ([friendsNotifyTable.status intValue] == AddFriendCurrentStateWaitingValidation)
    {
        self.accessoryView = nil;       // 显示正在验证
        self.detailTextLabel.text = NSLocalizedString(@"PROMPT_WAITING_VALIDATION_TITLE", "等待验证");
    }
    else if ([self.friendsNotifyTable.friendAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
    {
        self.accessoryView = nil;       // 显示正在验证
        self.detailTextLabel.text = nil;
    }
    else
    {
        if (self.addContactButton) {
            [self.addContactButton removeFromSuperview];
            self.addContactButton = nil;
        }
        
        self.addContactButton = [[UIBorderButton alloc] initWithFrame:CGRectMake(0, 0, 60, 32)];
        [self.addContactButton setTitle:NSLocalizedString(@"STR_ADD", @"添加") forState:UIControlStateNormal];
        
        [self.addContactButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        [self.addContactButton setTitleColor:COLOR_WITH_RGB(255, 255, 255) forState:UIControlStateNormal];
        
        [ToolsFunction setBorderColorAndBlueBackGroundColorFor:self.addContactButton];
        [self.addContactButton setCornerRadius:4.0f];
        
        [self.addContactButton addTarget:self action:@selector(touchAddContactButtonMethod:) forControlEvents:UIControlEventTouchUpInside];
        
        self.addContactButton.isNeedBorder = NO;
        self.addContactButton.isNoNeedCorner = NO;
        self.accessoryView = self.addContactButton;
        self.detailTextLabel.text = nil;
    }
    
    self.textLabel.text = self.friendsNotifyTable.friendAccount;
}

// 点击添加好友的Button
- (void)touchAddContactButtonMethod:(id)sender
{
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
        BOOL isSuccess = [[AppDelegate appDelegate].contactManager syncAddFriend:self.friendsNotifyTable];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView hideWaitingMaskView];
            
            if (isSuccess == YES)
            {
                // 添加成功
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_HAVED_ADD", nil) background:nil showTime:2];
                
                [[AppDelegate appDelegate].contactManager getContactInfoByUserAccount:self.friendsNotifyTable.friendAccount];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
                
                // 新建一个聊天会话,如果会话存在，打开聊天页面
                [SingleChat buildSingleChat:self.friendsNotifyTable.friendAccount
                                  onSuccess:^{
                                      LocalMessage *callLocalMessage = nil;
                                      
                                      // 向对方发送验证通过的消息
                                      callLocalMessage = [LocalMessage buildReceivedMsg:self.friendsNotifyTable.friendAccount withMsgContent:NSLocalizedString(@"RKCLOUD_SINGLE_CHAT_MSG_CALL", nil) forSenderName:self.friendsNotifyTable.friendAccount];
                                      
                                      // 保存扩展信息
                                      [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
                                      
                                  }
                                   onFailed:^(int errorCode) {
                                   }];
                
                
            } else {
                
                // 弹出申请AlertView
                UIAlertView *addContactAlertView = [[UIAlertView alloc]
                                                    initWithTitle:NSLocalizedString(@"TITLE_ADD_CONTACT_TITLE", @"对方需要验证")
                                                    message:nil
                                                    delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"")
                                                    otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
                addContactAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                
                UITextField *addTitleTextField = [addContactAlertView textFieldAtIndex:0];
                addTitleTextField.delegate = self;
                NSString *disPlayName = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
                
                NSString *stringResultName = disPlayName;
                // 优化个人姓名显示 长度不超过20位 否则无法添加好友
                if (disPlayName != nil && [disPlayName length] > 20)
                {
                    stringResultName = [disPlayName substringToIndex:20];
                }
                
                addTitleTextField.text = [NSString stringWithFormat:@"%@ 请求添加您为好友。", stringResultName];
        
                [addContactAlertView show];                
            }
        });
    });
}

#pragma mark - UIAlertViewDelegate

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.alertViewStyle == UIAlertViewStylePlainTextInput)
    {
        UITextField *titleField = [alertView textFieldAtIndex:0];
        if ([titleField.text length] == 0)
        {
            return NO;
        }
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    UITextField *addFriendTextField = [alertView textFieldAtIndex:0];
    NSString *applyStr = [addFriendTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (applyStr.length == 0) {
        
        [UIAlertView showAutoHidePromptView:@"申请信息不能为空" background:nil showTime:1.5];
        return;
    }
    
    if ([applyStr length] > USER_NAME_MAX_LENGTH)
    {
        // 系统自带头像
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CONTENT_TOO_LONG", "申请信息过长") background:nil showTime:1.5];
        return;
    }
    
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
        self.friendsNotifyTable.content = applyStr;
        
        // 提交申请
        [[AppDelegate appDelegate].contactManager syncAddFriend:self.friendsNotifyTable];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView hideWaitingMaskView];
            
            self.friendsNotifyTable.status = [NSString stringWithFormat:@"%ld",(long)AddFriendCurrentStateWaitingValidation];
            // 保存到本地
            [[AppDelegate appDelegate].databaseManager saveFriendsNotifyTable:self.friendsNotifyTable];
            
            // 屏蔽添加按钮
            self.addContactButton.enabled = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
            
            [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_WAITING_VALIDATION", @"等待对方验证中") background:nil showTime:2.0];
        });
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text length] + [string length] > USER_NAME_MAX_LENGTH  && ![string isEqualToString:@""]) {
        
        return NO;
    }
    return YES;
}

@end
