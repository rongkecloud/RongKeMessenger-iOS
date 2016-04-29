//
//  FriendInfoHeaderView.m
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "FriendInfoHeaderView.h"
#import "Definition.h"
#import "CustomAvatarImageView.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "PersonalInfos.h"

#define  AVATAR_AND_ACCOUNT_LABEL_SPACING     10  // 头像与名称Label的间距
#define  MARGIN_RIGHT     15    // 名称Label距离右边距
#define  TITLE_LABEL_HEIGHT  26    // Label默认的高度

@interface FriendInfoHeaderView()

@property (nonatomic, strong) CustomAvatarImageView *avatarImageView;   // 头像ImageView
@property (nonatomic, strong) UILabel *accountLabel;   // 账号Label
@property (nonatomic, strong) UILabel *markNameLabel;  // 标签名称Label
@property (nonatomic, strong) UIButton *addRemarkNameButton;  // 添加备注名的操作按钮

@end

@implementation FriendInfoHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // 初始化各个控件
//        [self initAvatarAndNameLabel];
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/**
 *  初始化好友详情头像 名称 备注名
 *
 *  @param delegate    代理
 *  @param userAccount 用户名 用来判断需不需要显示 备注名
 */
- (void)initAvatarAndNameLabel:(id)delegate andUserAccount:(NSString *)userAccount
{
    if (userAccount != nil)
    {
        self.userAccount = userAccount;
    } else {
        return;
    }
    
    if (self.avatarImageView == nil) { //20, 20, 80, 80
        self.avatarImageView  = [[CustomAvatarImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60 )];
        [self.avatarImageView setUserAvatarImageByUserId:userAccount];
        self.avatarImageView.delegate = delegate;
        if ([ToolsFunction getFriendAvatarWithFriendAccount:userAccount andIsThumbnail:YES] != nil)
        {
            self.avatarImageView.userInteractionEnabled = YES;
        } else {
            self.avatarImageView.userInteractionEnabled = NO;
        }
        
        [self addSubview:self.avatarImageView];
    }
    
    if (self.accountLabel == nil) { //27
        // 显示账号的Label
        self.accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + AVATAR_AND_ACCOUNT_LABEL_SPACING, CGRectGetMinY(self.avatarImageView.frame) + 17, self.frame.size.width - CGRectGetMaxX(self.avatarImageView.frame) - AVATAR_AND_ACCOUNT_LABEL_SPACING - MARGIN_RIGHT, TITLE_LABEL_HEIGHT)];
        self.accountLabel.textColor = COLOR_MAIN_TEXT;
        self.accountLabel.font = FONT_TEXT_SIZE_16;
        self.accountLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.accountLabel];
    }
    
//    // 好友添加备注label
//    if (self.markNameLabel == nil && [[AppDelegate appDelegate].friendManager isOwnFriend:userAccount]) {
//        self.markNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.accountLabel.frame), CGRectGetMaxY(self.avatarImageView.frame) - 40, CGRectGetWidth(self.accountLabel.frame), TITLE_LABEL_HEIGHT)];
//        self.markNameLabel.textColor = COLOR_MAIN_TEXT;
//        self.markNameLabel.font = FONT_TEXT_SIZE_16;
//        self.markNameLabel.textAlignment = NSTextAlignmentLeft;
//        
//        [self addSubview:self.markNameLabel];
//    }
    
//    if (self.addRemarkNameButton == nil) {
//        self.addRemarkNameButton = [[UIButton alloc] initWithFrame:self.markNameLabel.frame];
//        [self.addRemarkNameButton addTarget:self action:@selector(touchRemarkNameButton:) forControlEvents:UIControlEventTouchUpInside];
//        
//        [self addSubview:self.addRemarkNameButton];
//    }
}

//- (void)touchRemarkNameButton:(id)sender
//{
//    UIAlertView *creatGroupsNameAlertView = [[UIAlertView alloc]
//                                             initWithTitle:@"修改备注名称"
//                                             message:nil
//                                             delegate:self
//                                             cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"")
//                                             otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
//    
//    creatGroupsNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
//    UITextField * titleField = [creatGroupsNameAlertView textFieldAtIndex:0];
//    //设置字体大小
//    [titleField setFont:[UIFont systemFontOfSize:16]];
//    //设置右边消除键出现模式
//    //    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
//    //设置文字垂直居中
//    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    //设置键盘背景色透明
//    //    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
//    titleField.keyboardType = UIKeyboardTypeDefault;
//    
//    if (self.friendTable.remarkName != nil)
//    {
//        titleField.text = self.friendTable.remarkName;
//    }
//    
//    titleField.placeholder = @"请输入备注名";
//    [titleField becomeFirstResponder];
//
//    [creatGroupsNameAlertView show];
//}

// 更新各个控件信息
- (void)updateAvatarAndLabelInfo
{
    // 账号名称
    self.accountLabel.text = self.friendinfoTable == nil ? self.friendTable.friendAccount : self.friendinfoTable.account;
    // 备注名称
//    self.markNameLabel.text = self.friendTable.remarkName;
    
//    if (self.friendTable.remarkName.length == 0) {
//        self.markNameLabel.text = @"添加备注名";
//    }
//    else
//    {
//         self.markNameLabel.text = self.friendTable.remarkName;
//    }
}

#pragma mark -
#pragma mark TextFieldDelegate Method

- (void)textDidChange:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    // 键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > USER_NAME_MAX_LENGTH) {
                textField.text = [toBeString substringToIndex:USER_NAME_MAX_LENGTH];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > USER_NAME_MAX_LENGTH) {
            textField.text = [toBeString substringToIndex:USER_NAME_MAX_LENGTH];
        }
    }
}

/*
#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    UITextField * titleField = [alertView textFieldAtIndex:0];
    NSString *applyStr = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    self.friendTable.remarkName = applyStr;
    self.markNameLabel.text = applyStr;
    // 向服务器提交新的分组信息
    [self submitContactGroupsNameToServer];
}



- (void)submitContactGroupsNameToServer
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        [ToolsFunction showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    //    [ToolsFunction showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSuccessChange = [[AppDelegate appDelegate].friendManager syncModifyFriendInfo:self.friendTable];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //            [ToolsFunction hideWaitingMaskView];
            if (isSuccessChange) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
                
                if (self.friendTable.friendAccount != nil || [self.friendTable.friendAccount length] != 0)
                {
                    [self.friendTable save];
                }
                
            }
        });
    });
}
*/


@end
