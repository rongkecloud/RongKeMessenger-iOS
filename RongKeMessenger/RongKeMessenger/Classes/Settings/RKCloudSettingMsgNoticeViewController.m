//
//  RKCloudUISettingWithMsgViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudSettingMsgNoticeViewController.h"
#import "AppDelegate.h"
#import "ToolsFunction.h"
#import "RKCloudChatConfigManager.h"

#define UISWITCH_ENABLE_TAG     701
#define UISWITCH_NOTICE_TAG     702
#define UISWITCH_VIBRATE_TAG    703

@interface RKCloudSettingMsgNoticeViewController ()<UIActionSheetDelegate>

@property (strong, nonatomic) UISwitch *enableSwitch; // 通知栏提醒
@property (strong, nonatomic) UISwitch *soundSwitch; // 声音提醒
@property (strong, nonatomic) UISwitch *vibrateSwitch; // 振动提醒
@property (strong, nonatomic) UISwitch *showDetailSwitch; // 振动提醒
@property (assign, nonatomic) BOOL isEnable; // 是否通知栏提醒
@property (assign, nonatomic) BOOL isSystemNotifyRing; //是否系统铃声

@end

@implementation RKCloudSettingMsgNoticeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TITLE_SETTING_NEW_MESSAGE", "新消息提醒");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.isEnable = [ToolsFunction isApnsNotificationsEnabled];
    self.isSystemNotifyRing = ![RKCloudChatConfigManager getNotifyRingUri].lastPathComponent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 4;

    if ([RKCloudChatConfigManager getNoticeBySound]) {
        rowNum = 5;
    }
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"cell"];
    }
    
    cell.userInteractionEnabled = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int floatX = UISCREEN_BOUNDS_SIZE.width - 76;
    
    switch (indexPath.row)
    {
        case 0:
        {
            // 设置是否在通知栏中显示新消息
            cell.textLabel.text = NSLocalizedString(@"PROMPT_GET_NOTIFICATION_ENABLE", "通知栏提醒");
            
            if (self.isEnable)
            {
                cell.detailTextLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_ENABLE", @"已开启");
            }
            else
            {
                cell.detailTextLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_DISABLE", @"已关闭");
            }
            
//            if ([ToolsFunction iSiOS7Earlier])
//            {
//                floatX -= 25;
//            }
//            
//            self.enableSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 76, 27)];
//            self.enableSwitch.tag = UISWITCH_ENABLE_TAG;
//            [self.enableSwitch setOn:[RKCloudChatConfigManager getNotificationEnable]];
//            [self.enableSwitch addTarget:self action:@selector(setNotificationEnable:) forControlEvents:UIControlEventValueChanged];
//            
//            if (![cell viewWithTag:UISWITCH_ENABLE_TAG])
//            {
//                [cell addSubview:self.enableSwitch];
//            }
        }
            break;
        case 1:
        {
            // 设置通知显示消息详情
            cell.textLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_SHOW_DETAIL", "通知显示消息详情");
            
            self.showDetailSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 76, 27)];
            self.showDetailSwitch.tag = UISWITCH_NOTICE_TAG;
            [self.showDetailSwitch setOn:[RKCloudChatConfigManager getMsgRemindSum]];
            [self.showDetailSwitch addTarget:self action:@selector(setNotifyShowDetailSwitch:) forControlEvents:UIControlEventValueChanged];
            
            if (![cell viewWithTag:UISWITCH_NOTICE_TAG])
            {
                [cell addSubview:self.showDetailSwitch];
            }
        }
            break;
        case 2:
        {
            // 设置新消息是否声音提醒
            cell.textLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_BY_SOUND", "声音提醒");
            
            self.soundSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 76, 27)];
            self.soundSwitch.tag = UISWITCH_NOTICE_TAG;
            [self.soundSwitch setOn:[RKCloudChatConfigManager getNoticeBySound]];
            [self.soundSwitch addTarget:self action:@selector(setNoticeBySound:) forControlEvents:UIControlEventValueChanged];
            
            if (![cell viewWithTag:UISWITCH_NOTICE_TAG])
            {
                [cell addSubview:self.soundSwitch];
            }
        }
            break;
        case 3:
        {
            // 设置新消息是否振动提醒
            cell.textLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_BY_VIBRATE", "振动提醒");
            
            self.vibrateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 76, 27)];
            self.vibrateSwitch.tag = UISWITCH_VIBRATE_TAG;
            [self.vibrateSwitch setOn:[RKCloudChatConfigManager getNoticedByVibrate]];
            [self.vibrateSwitch addTarget:self action:@selector(setNoticedByVibrate:) forControlEvents:UIControlEventValueChanged];
            
            if (![cell viewWithTag:UISWITCH_VIBRATE_TAG])
            {
                [cell addSubview:self.vibrateSwitch];
            }
        }
            break;
        case 4:
        {
            // 设置新消息是否振动提醒
            cell.textLabel.text = NSLocalizedString(@"PROMPT_GET_NOTICE_NEW_MESSAGE_SOUND", "新消息提示音");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (self.isEnable == YES)
            {
                if (self.isSystemNotifyRing) {
                    cell.detailTextLabel.text = @"系统铃声";
                } else {
                    cell.detailTextLabel.text = @"自定义铃声";
                }
            }
        }
            break;
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
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 4: // 新消息提示音
        {
            UIActionSheet *changeNotifyRingActionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:nil
                                                  delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                  destructiveButtonTitle:nil
                                                  otherButtonTitles:@"系统铃声",@"自定义铃声", nil];
            [changeNotifyRingActionSheet showInView:self.view];
        }
            break;
            
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

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: // 系统铃声
        {
            [RKCloudChatConfigManager setNotifyRingUri:nil];
            self.isSystemNotifyRing = YES;
            [self.tableView reloadData];
        }
            break;
        
        case 1: // 自定义铃声
        {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"rkcloud_chat_sound_custom" ofType:@"caf"];
            [RKCloudChatConfigManager setNotifyRingUri:filePath];
            self.isSystemNotifyRing = NO;
            [self.tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom Method

// 设置是否在通知栏中显示新消息
- (void)setNotificationEnable:(id)sender
{
    self.isEnable = !self.isEnable;
    [RKCloudChatConfigManager setNotificationEnable:self.isEnable];
    [RKCloudChatConfigManager setNoticeBySound:self.isEnable];
    [RKCloudChatConfigManager setNoticedByVibrate:self.isEnable];
    [RKCloudChatConfigManager setMsgRemindSum:self.isEnable];
    
    [self.tableView reloadData];
}

// 设置新消息是否声音提醒
- (void)setNoticeBySound:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    [RKCloudChatConfigManager setNoticeBySound:mSender.isOn];
    
    [self.tableView  reloadData];
}

// 设置新消息是否振动提醒
- (void)setNoticedByVibrate:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    [RKCloudChatConfigManager setNoticedByVibrate:mSender.isOn];
}

// 设置新消息是否显示提示详情
- (void)setNotifyShowDetailSwitch:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    [RKCloudChatConfigManager setMsgRemindSum:mSender.isOn];
}

@end

