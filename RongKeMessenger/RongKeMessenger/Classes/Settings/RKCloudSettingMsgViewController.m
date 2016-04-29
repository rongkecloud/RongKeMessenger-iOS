//
//  RKCloudSettingMsgViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudSettingMsgViewController.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "RKCloudSettingMsgNoticeViewController.h"

@interface RKCloudSettingMsgViewController ()
@property (weak, nonatomic) IBOutlet UITableView *settingMsgTableView;

@end

@implementation RKCloudSettingMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.settingMsgTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    
    self.title = NSLocalizedString(@"TITLE_SETTING_MESSAGE", "消息设置");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"cell"];
    }
    
    cell.userInteractionEnabled = YES;
    
    int floatX = UISCREEN_BOUNDS_SIZE.width - 76;
    
    switch (indexPath.row)
    {
        case 1:
        {
            // 设置是否在通知栏中显示新消息
            cell.textLabel.text = NSLocalizedString(@"TITLE_VOICE_PLAY_MODEL_EARPHONE", "听筒模式播放语音消息");
            if ([ToolsFunction iSiOS7Earlier])
            {
                floatX -= 25;
            }
            
            UISwitch *switch_enable = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 76, 27)];
            
            NSLog(@"DEBUG: getVoicePlayModel = %d", [RKCloudChatConfigManager getVoicePlayModel]);
            
            [switch_enable setOn:[RKCloudChatConfigManager getVoicePlayModel]];
            
            [switch_enable addTarget:self action:@selector(setVoicePlayModel:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:switch_enable];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
            break;
        case 0:
        {
            // 设置新消息是否声音提醒
            cell.textLabel.text = NSLocalizedString(@"TITLE_SETTING_MESSAGE", "消息设置");

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        default:
            break;
    }
    
    return cell;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
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
    //选中后的反显颜色即刻消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ([indexPath row])
    {
        case 0:
        {
            RKCloudSettingMsgNoticeViewController *vwcMsg = [[RKCloudSettingMsgNoticeViewController alloc] init];
            vwcMsg.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vwcMsg animated:YES];
            break;
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

#pragma mark - Custom Method

// 设置播放语音消息类型
- (void)setVoicePlayModel:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    [RKCloudChatConfigManager setVoicePlayModel:mSender.isOn];
}


@end
