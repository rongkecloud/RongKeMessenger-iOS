//
//  RKCloudSettingViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudSettingViewController.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "Definition.h"
#import "UIBorderButton.h"
#import "PersonalInfos.h"

#import "FeedBackViewController.h"
#import "RKCloudSettingMsgViewController.h"
#import "ChangePasswordViewController.h"
#import "AboutSoftWareViewController.h"
#import "PersonalDetailViewController.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"

@interface RKCloudSettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *settingTableView; // 设置界面列表
@property (assign, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) UIImageView *imageViewCell;
@property (strong, nonatomic) UILabel *labelCell;
@property (strong, nonatomic) UILabel *labelAccountCell;

@end

@implementation RKCloudSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TITLE_SETTING", "设置");
        
        // Custom initialization
        UITabBarItem* item = [[UITabBarItem alloc]
                              initWithTitle:NSLocalizedString(@"TITLE_SETTING", "设置")
                              image:[UIImage imageNamed:@"tabbar_icon_settings_normal"]
                              tag:0];
        self.tabBarItem = item;
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatarSuccess:) name:NOTIFICATION_UPLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatarFail:) name:NOTIFICATION_UPLOAD_AVATAR_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAvatarSuccessNotification:) name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    // 完善个人信息成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePersonalInfoSuccess:) name:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
    
    self.settingTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.appDelegate = [AppDelegate appDelegate];
    
    // 避免下载图片失败
    [self.appDelegate.userInfoManager asyncUpdateMyInfo];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPLOAD_AVATAR_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (section) {
        case 0:
        case 1:
        case 4:
            rows = 1;
            break;
        case 2:
        case 3:
            rows = 2;
            break;
        default:
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch ([indexPath section])
    {
        case 0:{
            
            static NSString *cellIndeAccount = @"cellAccount";
            
            UITableViewCell *cellAccount = [tableView dequeueReusableCellWithIdentifier:cellIndeAccount];
            
            if (cellAccount == nil)
            {
                cellAccount = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndeAccount];
            }            
            
            if (self.imageViewCell == nil)
            {
                self.imageViewCell = [[UIImageView alloc] initWithFrame:CGRectMake(15.0, 5.0, 70.0, 70.0)];
                self.imageViewCell.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
                self.imageViewCell.layer.masksToBounds = YES;
                [cellAccount addSubview:self.imageViewCell];
            }
            
            NSString *stringUserAvatarThumbnailImagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, self.appDelegate.userProfilesInfo.userAccount]];
            
            // 显示小图
            if (![ToolsFunction isFileExistsAtPath:stringUserAvatarThumbnailImagePath])
            {
                self.imageViewCell.image = [UIImage imageNamed:@"default_icon_user_avatar"];
            }else{
                self.imageViewCell.image = [UIImage imageWithContentsOfFile:stringUserAvatarThumbnailImagePath];
            }
            
            if (self.labelCell == nil)
            {
                self.labelCell = [[UILabel alloc] initWithFrame:CGRectMake(95.0, 15.0, 200.0, 20.0)];
                self.labelCell.font = FONT_TEXT_SIZE_16;
                [cellAccount addSubview:self.labelCell];
            }
            
            if (self.labelAccountCell == nil)
            {
                self.labelAccountCell = [[UILabel alloc] initWithFrame:CGRectMake(95.0, 45.0, 200.0, 20.0)];
                self.labelAccountCell.font = FONT_TEXT_SIZE_14;
                [cellAccount addSubview:self.labelAccountCell];
            }
            
            self.labelAccountCell.text = [NSString stringWithFormat:@"账号：%@", [AppDelegate appDelegate].userProfilesInfo.userAccount];
            self.labelAccountCell.textColor = [UIColor colorWithRed:154.0/255.0 green:154.0/255.0 blue:154.0/255.0 alpha:1];
            
            if (self.appDelegate.userProfilesInfo.userName == nil || [self.appDelegate.userProfilesInfo.userName length] == 0)
            {
                self.labelCell.text = NSLocalizedString(@"TITLE_NO_SETTING_NAME", "<姓名未设置>");
            } else {
                self.labelCell.text = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
            }

            cellAccount.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            cell = cellAccount;
        }
            break;
        case 1:{
            
            static NSString *cellIndeChangePwd = @"cellChangePwd";
            
            UITableViewCell *cellChangePwd = [tableView dequeueReusableCellWithIdentifier:cellIndeChangePwd];
            
            if (cellChangePwd == nil)
            {
                cellChangePwd = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndeChangePwd];
            }
            
            cellChangePwd.textLabel.text = NSLocalizedString(@"TITLE_CHANGE_SECRET", "修改密码");
            cellChangePwd.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            // 添加图片
            cellChangePwd.imageView.image = [UIImage imageNamed:@"setting_cell_change_pwd"];
            
            cell = cellChangePwd;
        }
            break;
        case 2:{
            
            static NSString *cellIndeMessage = @"cellMessage";
            
            UITableViewCell *cellMessage = [tableView dequeueReusableCellWithIdentifier:cellIndeMessage];
            
            if (cellMessage == nil)
            {
                cellMessage = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndeMessage];
            }
            
            if ([indexPath row] == 0)
            {
                cellMessage.textLabel.text = NSLocalizedString(@"TITLE_SETTING_MESSAGE", "消息设置");
                cellMessage.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                // 添加图片
                cellMessage.imageView.image = [UIImage imageNamed:@"setting_cell_messageSetting"];
            }else if ([indexPath row] == 1)
            {
                cellMessage.textLabel.text = NSLocalizedString(@"TITLE_CLEAN_CHAT_RECORD", "清空消息记录");
                // 添加图片
                cellMessage.imageView.image = [UIImage imageNamed:@"setting_cell_delete_message"];
            }
            
            cell = cellMessage;
        }
            break;
        case 3:{
            
            static NSString *cellIndeAdvice = @"cellAdvice";
            
            UITableViewCell *cellAdvice = [tableView dequeueReusableCellWithIdentifier:cellIndeAdvice];
            
            if (cellAdvice == nil)
            {
                cellAdvice = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIndeAdvice];
            }
            
            cellAdvice.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if ([indexPath row] == 0)
            {
                cellAdvice.textLabel.text = NSLocalizedString(@"TITLE_FEEDBACK_ADVICE", "意见反馈");
                // 添加图片
                cellAdvice.imageView.image = [UIImage imageNamed:@"setting_cell_feedback"];
                
            }else if ([indexPath row] == 1)
            {
                cellAdvice.textLabel.text = NSLocalizedString(@"TITLE_ABOUT_RONGKE", "关于融科通");
                cellAdvice.detailTextLabel.text = [NSString stringWithFormat:@"V%@", APP_SHORT_VERSION];
                // 添加图片
                cellAdvice.imageView.image = [UIImage imageNamed:@"setting_cell_about"];
            }
            
            cell = cellAdvice;
        }
            break;
        case 4:
        {
            static NSString *cellIndeMessage = @"cellUnlogin";
            
            UITableViewCell *cellUnlogin = [tableView dequeueReusableCellWithIdentifier:cellIndeMessage];
            
            if (cellUnlogin == nil)
            {
                cellUnlogin = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndeMessage];
            }
            cellUnlogin.textLabel.text = NSLocalizedString(@"STR_EXIT", "退出登录");
            // 设置字体颜色
            cellUnlogin.textLabel.textColor = [UIColor colorWithRed:247/255.0f green:76/255.0f blue:49/255.0f alpha:1.0];
            // 添加图片
            cellUnlogin.imageView.image = [UIImage imageNamed:@"setting_cell_unlogin"];

            cell = cellUnlogin;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark -
#pragma mark UITableViewDelegate

// 设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0)
    {
        return 80.0;
    }
    
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //选中后的反显颜色即刻消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath section])
    {
        case 0:
        {
            PersonalDetailViewController *vwcDetail = [[PersonalDetailViewController alloc] init];
            vwcDetail.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vwcDetail animated:YES];
        }
            break;
            
        case 1:
        {
            ChangePasswordViewController *vwcChangePwd = [[ChangePasswordViewController alloc] init];
            vwcChangePwd.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vwcChangePwd animated:YES];
        }
            break;
            
        case 2:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    RKCloudSettingMsgViewController *vwcMsg = [[RKCloudSettingMsgViewController alloc] init];
                    vwcMsg.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vwcMsg animated:YES];
                }
                    break;
                    
                case 1:
                {
                    [self cleanAllData];
                }
                    break;
                default:
                    break;
            }
            break;
        }
            
        case 3:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    FeedBackViewController *vwcFeedBack = [[FeedBackViewController alloc] init];
                    vwcFeedBack.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vwcFeedBack animated:YES];
                }
                     break;
                    
                case 1:
                {
                    AboutSoftWareViewController *vwcAboutRK = [[AboutSoftWareViewController alloc] init];
                     vwcAboutRK.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vwcAboutRK animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            
            break;
        }
       case 4:
        {
            // 退出
            [self showLogoutPromptAlert];
        }
            
        default:
            break;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;

}
#pragma mark -
#pragma mark UIAlertViewDelegate methods
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case SETTING_CLEAN_RECORD_ALERTVIEW_TAG: //清除聊天记录
        {
            if (buttonIndex == 1) {
                // 清空聊天记录
                [RKCloudChatMessageManager clearChatsAndMsgs:YES];
            }
        }
            break;
            
        case SETTING_LOGOUT_ALERTVIEW_TAG: // 退出
        {
            // 点击的“确定”按钮
            if (buttonIndex == 1)
            {
                // 进行多人语音业务的清空
                [AppDelegate appDelegate].meetingManager = nil;
                // 退出当前帐号
                [[AppDelegate appDelegate].userProfilesInfo logoutRKCloudAccount];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Custom Method
// 退出登录提示框
- (void)showLogoutPromptAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR_EXIT", "退出")
                                                    message:NSLocalizedString(@"PROMPT_LOGOUT_MESSAGE", "退出登录后不会删除任何历史数据，下次登录依然可以使用本账号")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                          otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
    alert.tag = SETTING_LOGOUT_ALERTVIEW_TAG;
    [alert show];
}

// 清除聊天记录提示框
- (void)cleanAllData
{
    //清除聊天记录
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_CLEAN_CHAT_RECORD", "清空消息记录")
                                                    message:NSLocalizedString(@"PROMPT_CLEAN_ALL_MESSAGE_RECORD", "将清空所有个人和群的聊天记录")
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                          otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
    alert.tag = SETTING_CLEAN_RECORD_ALERTVIEW_TAG;
    [alert show];
    
}

#pragma mark - Notification Method

// 上传图片成功通知方法
- (void)uploadAvatarSuccess:(NSNotification *)notificatio
{
    [self.settingTableView reloadData];
}

// 上传图片失败通知方法
- (void)uploadAvatarFail:(NSNotification *)notificatio
{
    
}

// 下载图片成功通知方法
- (void)downloadAvatarSuccessNotification:(NSNotification *)notificatio
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PersonalInfos *personalInfos = notificatio.object;
        
        if (![personalInfos.userAccount isEqualToString:self.appDelegate.userProfilesInfo.userAccount])
        {
            return; // 如果下载的图片账号不符 不作处理
        }
        
        switch ([personalInfos.avatarType intValue])
        {
            case UploadAndDownloadRequestTypeDownloadThumbNailAvatar:
            {
                FriendInfoTable *friendInfoTable = [[AppDelegate appDelegate].databaseManager getFriendInfoTableByAccout:personalInfos.userAccount];
                if (friendInfoTable) {
                    friendInfoTable.friendThumbnailAvatarVersion = friendInfoTable.friendServerAvatarVersion;
                    [self.appDelegate.databaseManager saveFriendInfoTable:friendInfoTable];
                }
                
                [self.settingTableView reloadData];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)completePersonalInfoSuccess:(NSNotification *)notification
{
    [self.settingTableView reloadData];
}

@end
