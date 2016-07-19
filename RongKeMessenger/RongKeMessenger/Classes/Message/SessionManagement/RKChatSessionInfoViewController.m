//
//  RKChatSessionInfoViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKChatSessionInfoViewController.h"
#import "SetBackgroundImageTableViewController.h"
#import "AppDelegate.h"
#import "RKCloudChat.h"
#import "Definition.h"
#import "RKCloudUIContactViewController.h"
#import "ToolsFunction.h"
#import "SessionContactAvatarListView.h"
#import "SelectFriendsViewController.h"
#import "PersonalDetailViewController.h"
#import "DatabaseManager+FriendTable.h"
#import "FriendDetailViewController.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"
#import "SelectGroupMemberViewController.h"
#import "FriendTable.h"

#define SESSIONINFO_SWITCH_GROUPCHAT_TOP_TAG                601
#define SESSIONINFO_SWITCH_GROUPCHAT_MESSAGE_PROMPT_TAG     602
#define SESSIONINFO_SWITCH_SINGLECHAT_TOP_TAG               603
#define SESSIONINFO_SWITCH_SINGLECHAT_MESSAGE_PROMPT_TAG    604
#define SESSIONINFO_SWITCH_INVITE_PROMPT_TAG    605

@interface RKChatSessionInfoViewController () <UITableViewDelegate, UITableViewDataSource,  UIAlertViewDelegate, RKCloudChatDelegate,ChatSelectFriendsViewControllerDelegate, SelectGroupMemberDelegate>
{
    CGFloat sessionContactListViewHeight;
}

@property (nonatomic, weak) MeetingRoomViewController *meetingRoomViewController; // 多人会议视图

@property (retain, nonatomic) IBOutlet UITableView *sessionInfoTableView;

@property (strong, nonatomic) SessionContactAvatarListView *sessionContactListView; // 会话管理联系人列表窗口（横向的）

@property (nonatomic, strong) NSArray *createFriendObjectArray;  // 新创建的朋友对象数组

@property (copy, nonatomic) NSString *deleteContactId; // 要删除的用户Id

@end

@implementation RKChatSessionInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 添加修改好友备注名通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdateUserInfoNotification:) name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
    
    // 设置当前会话页面键盘不监听（页面布局设置）
    self.rkChatSessionViewController.isAppearFirstly = YES;
    
    // 初始化会话信息
    [self initCurrentSessionInfo];
    
    // 定制返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_BACK", @"返回")  style:UIBarButtonItemStylePlain  target:self  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 设置当前会话页面键盘启动监听（页面布局设置）
    self.rkChatSessionViewController.isAppearFirstly = NO;
}

- (void)viewDidUnload {
    [self.sessionContactListView removeFromSuperview];
    self.sessionContactListView = nil;
    
    [self setSessionInfoTableView:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    // 移除修改好友备注名通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
}


#pragma mark -
#pragma mark Chat Session Function Method

// 初始化会话信息
- (void)initCurrentSessionInfo
{
    // 获取会话所有成员（不包括登陆者）
    NSArray *sessionMemberArray = [RKCloudChatMessageManager queryGroupUsers:self.rkChatSessionViewController.currentSessionObject.sessionID];
    self.currentAllGroupContactArray = [NSMutableArray arrayWithArray:sessionMemberArray];

    NSString *titleString = NSLocalizedString(@"TITLE_GROUP_CHAT_MESSAGE", "聊天信息");
    if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE) {
        titleString = [NSString stringWithFormat:@"聊天信息(%lu人)", (unsigned long)[self.currentAllGroupContactArray count] + 1];
    }
    self.title = titleString;
    
    // 当前所有群联系人数组,登录者需排到第一位
    [self.currentAllGroupContactArray insertObject:[RKCloudBase getUserName] atIndex:0];
    
    // 计算headerView的高度
    // 默认的是有添加联系人的按钮
    BOOL isCreate = (self.rkChatSessionViewController.currentSessionObject.sessionType == 1 && [((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]]);
    
    NSUInteger contactAvatarCounts = 0;
    
    // 群聊
    if (self.rkChatSessionViewController.currentSessionObject.sessionType == 1)
    {
        if (isCreate == YES) // 创建者
        {
            contactAvatarCounts = [self.currentAllGroupContactArray count] + 2;
        }
        else {
            // 非创建者
            if (((GroupChat *)self.rkChatSessionViewController.currentSessionObject).isEnableInvite == YES) // 有 邀请权限
            {
                contactAvatarCounts = [self.currentAllGroupContactArray count] + 1;
                
            }
            else {
                // 无 邀请权限
                contactAvatarCounts = [self.currentAllGroupContactArray count];
            }   
        }
    }
    else
    {
        // 单聊 判断是否是小秘书会话
        if ([ToolsFunction isRongKeServiceAccount:self.rkChatSessionViewController.currentSessionObject.sessionID]) {
            contactAvatarCounts = [self.currentAllGroupContactArray count];
        }
        else
        {
            contactAvatarCounts = [self.currentAllGroupContactArray count] + 2;
        }
    }

    NSUInteger row = contactAvatarCounts / CONTACT_COUNTS_PER_ROW;
    if ((contactAvatarCounts % CONTACT_COUNTS_PER_ROW) > 0)
    {
        row++;
    }
    
    sessionContactListViewHeight = row * (CONTACT_AVATAR_HEIGHT + CONTACT_NAME_HEIGHT + CONTACT_START_ORIGIN_Y) + CONTACT_START_ORIGIN_Y;
}

#pragma mark -
#pragma mark Touch Button Action methods

// 群组会话时点击”清空并退出“按钮
 -(void)touchExitButton
{
    NSString *titleStr = nil;
    // 判断群聊和是否为群建立者
    if ([((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]]) {
        titleStr = NSLocalizedString(@"PROMPT_SURE_TO_DISMISS_GROUP", "您确认解散当前群吗？");
    }
    else {
        titleStr = NSLocalizedString(@"PROMPT_SURE_TO_QUIT_GROUP", "您确认退出当前群吗？");
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:titleStr
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
    alertView.tag = ALERT_EXIT_SESSION_TAG;
    [alertView show];
}

// 点击”清空聊天记录“按钮
-(void)touchCleanChatDataButton
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"您确认清空该会话中的所有消息记录吗？"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
    alertView.tag = ALERT_CLEAR_MESSAGES_TAG;
    [alertView show];
}


// 向该群组中添加好友
- (void)addContactToSession:(id)sender
{
    SelectFriendsViewController *contactViewController = [[SelectFriendsViewController alloc] init];
    contactViewController.friendsListType = FriendsListTypeChatAddFriend;
    contactViewController.groupChatMembersArray = self.currentAllGroupContactArray;
    contactViewController.chatDelegate = self;
    
    // 设置动画
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    [self.navigationController pushViewController:contactViewController animated: NO];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Jacky.Chen:02.24 ADD
    if(self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        return 5;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
            
        case 1:
        {
            numberOfRows = 3;
            // 如果是群聊，当前登录者非群主，允许公开邀请权限不让显示
            if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE && [((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]])
            {
                numberOfRows = 6;
            }
            else if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_SINGLE_TYPE)
            {
                numberOfRows = 2;
            }
        }
            break;
            
        case 2:
            numberOfRows = 1;
            break;
            
        case 3:
        case 4:
            numberOfRows = 1;
            break;
            
        default:
            break;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Jacky.Chen:02.24 ADD
    NSString *identifier = nil;
    // 如果是群聊且为退群cell则不进行重用
    if ((indexPath.section == 4) && (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE))
    {
        identifier = @"groupExitCell";
    }
    else
    {
        identifier = @"cell";
        
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: identifier];
    }
    
    // 当为群聊时
    // 设置字体
    [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
    
    UIView *subView = [cell viewWithTag:100];
    if (subView)
    {
        [subView removeFromSuperview];
    }
    
    cell.userInteractionEnabled = YES;
    
    int floatXSwitch = UISCREEN_BOUNDS_SIZE.width - 76;
    if ([ToolsFunction iSiOS7Earlier])
    {
        floatXSwitch -= 25;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            if (self.sessionContactListView == nil)
            {
                // 会话成员增加删除view
                self.sessionContactListView = [[SessionContactAvatarListView alloc] initWithFrame:CGRectMake(8, 10, UISCREEN_BOUNDS_SIZE.width-16, sessionContactListViewHeight)];
                self.sessionContactListView.parent = self;
            }
            else
            {
                self.sessionContactListView.frame = CGRectMake(8, 10, UISCREEN_BOUNDS_SIZE.width-16, sessionContactListViewHeight);
            }
            
            // 判断是否开放邀请用户权限
            BOOL isOpenInvite = YES;
            if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE) {
                isOpenInvite = ((GroupChat *)self.rkChatSessionViewController.currentSessionObject).isEnableInvite;
            }
            
            BOOL isCreate = (self.rkChatSessionViewController.currentSessionObject.sessionType == 1 && [((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]]);
            
            // 添加联系人到页面
            [self.sessionContactListView addContactAvatarByContactArray:self.currentAllGroupContactArray
                                                                  isCreate:isCreate
                                                              isOpenInvite:isOpenInvite];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell addSubview:self.sessionContactListView];
        }
            break;
            
        case 1:
        {
            if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
            {
                // Jacky.Chen:2012.02.26.设置尾部有开关按钮的cell不可选中
                if (indexPath.row > 2)
                {
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                switch (indexPath.row)
                {
                    case 0:  // 群名称
                    {
                        cell.textLabel.text = NSLocalizedString(@"TITLE_GROUP_NAME", "群名称");
                        cell.detailTextLabel.text = self.rkChatSessionViewController.currentSessionObject.sessionShowName;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                    case 1:  // 群描述
                    {
                        cell.textLabel.text = NSLocalizedString(@"TITLE_GROUP_DESCRIPTION", "群描述");
                        cell.detailTextLabel.text = ((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupDescription;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                    case 2:  // 群转让
                    {
                        cell.textLabel.text = NSLocalizedString(@"TITLE_GROUP_TRANSFER", "群转让");
                        cell.detailTextLabel.text = @"";
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                        break;
                        
                    case 3:
                    {
                        // 是否置顶聊天
                        cell.textLabel.text = NSLocalizedString(@"TITLE_CHAT_ON_TOP", "置顶聊天");
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        
                        UISwitch *switch_top = [[UISwitch alloc] initWithFrame:CGRectMake(floatXSwitch, 8.5, 76, 27)];
                        switch_top.tag = SESSIONINFO_SWITCH_GROUPCHAT_TOP_TAG;
                        [switch_top setOn:self.rkChatSessionViewController.currentSessionObject.isTop];
                        [switch_top addTarget:self action:@selector(setTop:) forControlEvents:UIControlEventValueChanged];
                        
                        UIView *subView = [cell viewWithTag:SESSIONINFO_SWITCH_GROUPCHAT_TOP_TAG];
                        if (!subView) {
                            [cell addSubview:switch_top];
                        }
                        
                    }
                        break;
                    case 4:
                    {
                        // 是否消息提醒
                        cell.textLabel.text = NSLocalizedString(@"TITLE_MESSAGE_REMIND", "消息提醒");
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        UISwitch *switchRemind = [[UISwitch alloc] initWithFrame:CGRectMake(floatXSwitch, 8.5, 76, 27)];
                        switchRemind.tag = SESSIONINFO_SWITCH_GROUPCHAT_MESSAGE_PROMPT_TAG;
                        [switchRemind setOn:self.rkChatSessionViewController.currentSessionObject.isRemindStatus];
                        [switchRemind addTarget:self action:@selector(setRemind:) forControlEvents:UIControlEventValueChanged];
                        UIView *subView = [cell viewWithTag:SESSIONINFO_SWITCH_GROUPCHAT_MESSAGE_PROMPT_TAG];
                        if (!subView) {
                            [cell addSubview:switchRemind];
                        }
                    }
                        break;
                    case 5:
                    {
                        // 判断当前群聊建立者是否是登录者
                        if ([((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]])
                        {
                            
                            cell.textLabel.text = NSLocalizedString(@"TITLE_INVITE_JURISDICTION", "邀请权限");
                            cell.selectionStyle = UITableViewCellSelectionStyleNone;
                            
                            UISwitch *switchState = [[UISwitch alloc] initWithFrame:CGRectMake(floatXSwitch, 8.5, 76, 27)];
                            switchState.tag = SESSIONINFO_SWITCH_INVITE_PROMPT_TAG;
                            [switchState setOn:((GroupChat *)self.rkChatSessionViewController.currentSessionObject).isEnableInvite];
                            [switchState addTarget:self action:@selector(setInvate:) forControlEvents:UIControlEventValueChanged];
                            UIView *subView = [cell viewWithTag:SESSIONINFO_SWITCH_INVITE_PROMPT_TAG];
                            if (!subView) {
                                [cell addSubview:switchState];
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            else
            {
                // Jacky.Chen:2012.02.26.设置尾部有开关按钮的cell不可选中
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                switch (indexPath.row)
                {
                    case 0:
                    {
                        // 是否置顶聊天
                        cell.textLabel.text = NSLocalizedString(@"TITLE_CHAT_ON_TOP", "置顶聊天");
                        UISwitch *switch_top = [[UISwitch alloc] initWithFrame:CGRectMake(floatXSwitch, 8.5, 76, 27)];
                        switch_top.tag = SESSIONINFO_SWITCH_SINGLECHAT_TOP_TAG;
                        [switch_top setOn:self.rkChatSessionViewController.currentSessionObject.isTop];
                        [switch_top addTarget:self action:@selector(setTop:) forControlEvents:UIControlEventValueChanged];
                        UIView *subView = [cell viewWithTag:SESSIONINFO_SWITCH_SINGLECHAT_TOP_TAG];
                        if (!subView) {
                            [cell addSubview:switch_top];
                        }
                    }
                        break;
                    case 1:
                    {
                        // 是否消息提醒
                        cell.textLabel.text = NSLocalizedString(@"TITLE_MESSAGE_REMIND", "消息提醒");

                        UISwitch *switch_remind = [[UISwitch alloc] initWithFrame:CGRectMake(floatXSwitch, 8.5, 76, 27)];
                        switch_remind.tag = SESSIONINFO_SWITCH_SINGLECHAT_MESSAGE_PROMPT_TAG;
                        [switch_remind setOn:self.rkChatSessionViewController.currentSessionObject.isRemindStatus];
                        [switch_remind addTarget:self action:@selector(setRemind:) forControlEvents:UIControlEventValueChanged];
                        UIView *subView = [cell viewWithTag:SESSIONINFO_SWITCH_SINGLECHAT_MESSAGE_PROMPT_TAG];
                        if (!subView) {
                            [cell addSubview:switch_remind];
                        }
                        
                    }
                        
                        break;
                    default:
                        break;
                }
            }
        }
            break;
            
        case 2:
        {
            // 设置聊天背景
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = NSLocalizedString(@"TITLE_SETTING_CHAT_BACKGROUND", "设置聊天背景");
        }
            break;
            
        case 3:
        {
            // 清空消息记录
            cell.textLabel.text = NSLocalizedString(@"TITLE_CLEAN_MESSAGE_RECORD", "清空消息记录");
        }
            break;
            
        case 4:
        {
            // Jacky.Chen:02.24 ADD
            UILabel *titleLabel = nil;
            if ([cell viewWithTag:1000]== nil) {
                
                // 添加标题label
                titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEIGHT_MORE_LIST_CELL)];
                
                // 设置
                titleLabel.backgroundColor = [UIColor clearColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.tag = 1000;
                titleLabel.font = [UIFont systemFontOfSize:16];
                titleLabel.textColor = COLOR_WARNING_TEXT;
                [cell addSubview:titleLabel];

            }
            
            // 判断群聊和是否为群建立者
            if ([((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]]) {
                titleLabel.text = @"解散群";
                
            }
            else {
                titleLabel.text = @"退出群";

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
    CGFloat heightForRow = HEIGHT_MORE_LIST_CELL;
    if (indexPath.section == 0) {
        heightForRow = sessionContactListViewHeight;
    }
    
	return heightForRow;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
//    if (section == 3 && self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE) {
//        return 70;
//    }
    return 10;
}

// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

// custom view for footer. will be adjusted to default or specified footer height
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // 最后一个section才有此按钮
//    if(section == 3 &&
//       self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
//    {
//        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 60)];
//        UIButton *redExitButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 15, UISCREEN_BOUNDS_SIZE.width - 20*2, 44)];
//        [redExitButton setBackgroundColor:[UIColor redColor]];
//        redExitButton.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
//        
//        // 判断群聊和是否为群建立者
//        if ([((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupCreater isEqualToString:[RKCloudBase getUserName]]) {
//            [redExitButton setTitle:@"解散群" forState:UIControlStateNormal];
//        }
//        else {
//            [redExitButton setTitle:@"退出群" forState:UIControlStateNormal];
//        }
//        [redExitButton addTarget:self action:@selector(touchExitButton) forControlEvents:UIControlEventTouchUpInside];
//        
//        [footerView addSubview:redExitButton];
//        return footerView;
//    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];   //选中后的反显颜色即刻消失
    
    switch (indexPath.section)
    {
        case 0:
            break;
            
        case 1:
        {
            if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE && indexPath.row <= 2)
            {
                switch (indexPath.row)
                {
                    case 0:  // 群名称
                        [self updateChatSessionName];
                        break;
                    case 1:  // 群描述
                        [self modifyGroupDescription];
                        break;
                    case 2:  // 群转让
                        [self transferGroupOwner];
                        break;
                    default:
                        break;
                }
            }
        }
            break;
            
        case 2:
        {
            SetBackgroundImageTableViewController *rkChatSessionSetBackgroundImage = [[SetBackgroundImageTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            // Push进入消息详情页面之前将TabBar隐藏，并且设置选择消息Tab索引
            rkChatSessionSetBackgroundImage.hidesBottomBarWhenPushed = YES;
            rkChatSessionSetBackgroundImage.rkChatSessionViewController = self.rkChatSessionViewController;
            [self.navigationController pushViewController:rkChatSessionSetBackgroundImage animated:YES];
        }
            break;
            
        case 3:
        {
            // 点击”清空聊天记录“按钮
            [self touchCleanChatDataButton];
            break;
        }
        case 4:
        {
            // Jacky.Chen:02.24 ADD
            // 点击退群或者解散群
            [self touchExitButton];
            
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark action methods

// 邀请加入一个已经存在的消息会话
- (void)joinExistChatSession:(NSArray *)arrayFriendObject
{
    if ([arrayFriendObject count] <= 0) {
        return;
    }
    
    // 如果是从查看群联系人页面进入的话，则说明是邀请好友加入该群聊
    // 判断当前会话是单聊还是群聊
    if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_SINGLE_TYPE)
    {
        // 是单聊则重新需要创建一个新多人会话
        NSMutableArray * arrayAllFriendObject = [[NSMutableArray alloc] initWithArray:arrayFriendObject];
        if (self.rkChatSessionViewController.currentSessionObject.sessionID) {
            [arrayAllFriendObject addObject:self.rkChatSessionViewController.currentSessionObject.sessionID];
        }
        
        self.createFriendObjectArray = arrayAllFriendObject;
        
        // 显示一个创建新的群聊会话的弹出提示框
        [UIAlertView showCreateNewGroupChatAlert:self];
    }
    else if (self.rkChatSessionViewController.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        [UIAlertView showWaitingMaskView:nil];
        
        // 调用接口（发送邀请消息）
        [RKCloudChatMessageManager inviteUsers:arrayFriendObject
                                    forGroupID:self.rkChatSessionViewController.currentSessionObject.sessionID
                                     onSuccess:^ {
                                         [UIAlertView hideWaitingMaskView];
                                         [UIAlertView showAutoHidePromptView:@"邀请成员加入群聊成功" background:nil showTime:1.5];
                                         
                                         // 跟新当前的数据
                                         [self initCurrentSessionInfo];
                                         
                                     } onFailed:^(int errorCode, NSArray *arrayFailUserName) {
                                         [UIAlertView hideWaitingMaskView];
                                         
                                         NSString *errString = @"操作失败";
                                         switch (errorCode) {
                                             case RK_INVALID_USER: // 5，非法用户，即非云视互动用户或是该用户从未登录使用过
                                             {
                                                 NSString *failName = [arrayFailUserName componentsJoinedByString:@","];
                                                 
                                                 errString = [NSString stringWithFormat:@"非法用户：%@，即非云视互动用户或是该用户从未登录使用过", failName];
                                             }
                                                 break;
                                                 
                                             case CHAT_GROUP_NOT_EXIST: // 2021，群号码不存在
                                                 errString = @"群号码不存在";
                                                 break;
                                                 
                                             case CHAT_GROUP_USER_NUMBER_EXCEED_LIMIT: // 2024，群用户人数已达上限
                                                 errString = @"群用户人数已达上限";
                                                 break;
                                                 
                                             case CHAT_GROUP_UNAUTH_INVITE: // 2026，没有邀请权限
                                                 errString = @"无邀请权限";
                                                 break;
                                                 
                                             case CHAT_GROUP_USER_HAS_EXIST: // 2029，邀请好用已经存在，不允许重复邀请
                                             {
                                                 NSString *failName = [arrayFailUserName componentsJoinedByString:@","];
                                                 errString = [NSString stringWithFormat:@"成员：%@ 已存在，邀请失败", failName];
                                             }
                                                 break;
                                                 
                                             default:
                                                 break;
                                         }
                                         
                                         // 弹出提示信息
                                         [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode] background:nil showTime:1.5];
                                         
                                     }];
    }
}

// 踢出某对象出群聊 协议方法
- (void)deleteContactFromSession:(NSString *)deleteUserId
{
    if (deleteUserId == nil) {
        return;
    }
    else {
        self.deleteContactId = deleteUserId;
    }
    
    // 提示用户 是否确定删除好友
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                          message:[NSString stringWithFormat:@"确定将%@从群聊踢出吗？", [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:self.deleteContactId]]
                                                         delegate:self
                                                cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", nil)
                                                otherButtonTitles:NSLocalizedString(@"STR_OK", "确定"), nil];
    
    deleteAlert.tag = ALERTVIEW_SESSIONINFO_DELETE_CONTACT_TAG;
    [deleteAlert show];
    
}

// 踢出某对象出群聊请求
- (void)touchDeleteContactFromSessionButton:(NSString *)deleteUserId
{
    if (deleteUserId == nil) {
        return;
    }
    
    [UIAlertView showWaitingMaskView:nil];
    
    // 调用接口（踢出某成员出群聊操作）
    [RKCloudChatMessageManager kickUser:deleteUserId
                             forGroupID:self.rkChatSessionViewController.currentSessionObject.sessionID
                              onSuccess:^{
                                  [UIAlertView hideWaitingMaskView];
                                  
                                  // 弹出提示信息
                                  [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"您已将%@从群中移除", [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:deleteUserId]]
                                                             background:nil
                                                               showTime:1.5];                                                                    
                                  
                              }
                               onFailed:^(int errorCode) {
                                   [UIAlertView hideWaitingMaskView];
                                   
                                   NSString *errString = @"操作失败";
                                   switch (errorCode) {
                                       case CHAT_GROUP_NOT_EXIST: // 群号码不存在
                                           // CHAT_GROUP_NOT_EXIST=2021，群号码不存在错误码
                                           errString = @"群号码不存在";
                                           break;
                                           
                                       case CHAT_GROUP_USER_NOT_EXIST: // 非群用户
                                           // CHAT_GROUP_USER_NOT_EXIST=2022，非群用户
                                           errString = @"群号码不存在";
                                           break;
                                           
                                       case CHAT_GROUP_UNAUTH_KICKUSER: // 没有踢人权限
                                           // CHAT_GROUP_UNAUTH_KICKUSER=2027，无踢人操作权限
                                           errString = @"无踢人操作";
                                           break;
                                           
                                       default:
                                           break;
                                   }
                                   
                                   // 弹出提示信息
                                   [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                                              background:nil
                                                                showTime:1.5];
                                   
                               }];
}

// 设置邀请好友权限
- (void)setInvate:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    
    [UIAlertView showWaitingMaskView:nil];
    
    // 调用接口（设置群聊中邀请成员的权限操作）
    [RKCloudChatMessageManager modifyGroupInviteAuth:mSender.isOn
                                          forGroupID:self.rkChatSessionViewController.currentSessionObject.sessionID
                          onSuccess:^ {
                              [UIAlertView hideWaitingMaskView];
                              
                              [UIAlertView showSimpleAlert:@"您设置的群邀请权限已更新成功"
                                                   withTitle:nil
                                                  withButton:NSLocalizedString(@"STR_OK",nil)
                                                    toTarget:nil];
                          } onFailed:^(int errorCode) {
                              [UIAlertView hideWaitingMaskView];
                              
                              NSString *errString = @"操作失败";
                              switch (errorCode) {
                                  case CHAT_GROUP_UNMASTER: // 非群创建者，禁止该操作
                                      // CHAT_GROUP_UNMASTER=2028，非群主
                                      errString = @"非群主";
                                      break;
                                      
                                  default:
                                      break;
                              }
                              
                              // 弹出提示信息
                              [UIAlertView showSimpleAlert:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                                   withTitle:nil
                                                  withButton:NSLocalizedString(@"STR_OK",nil)
                                                    toTarget:nil];
                              
                          }];
    
}

// 设置是否消息提醒
- (void)setRemind:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    // 修改会话数据
    self.rkChatSessionViewController.currentSessionObject.isRemindStatus = mSender.isOn;
    
    // 设置消息提醒状态
    [RKCloudChatMessageManager maskGroupMsgRemind:self.rkChatSessionViewController.currentSessionObject.sessionID isMask:!(mSender.isOn) onSuccess:^{

    } onFailed:^(int errorCode) {
        
    }];
    // [RKCloudChatMessageManager setRemindStatusInChat:self.rkChatSessionViewController.currentSessionObject.sessionID withRemindStatu:self.rkChatSessionViewController.currentSessionObject.isRemindStatus];
}

// 设置是否置顶聊天
- (void)setTop:(id)sender
{
    UISwitch *mSender = (UISwitch *)sender;
    
    // 设置当前会话置顶
    [RKCloudChatMessageManager setChatIsTop:mSender.isOn
                               forSessionID:self.rkChatSessionViewController.currentSessionObject.sessionID];
}


#pragma mark -
#pragma mark 修改群信息相关函数

// 修改会话对象名称
- (void)updateChatSessionName
{
    // 输入新的群组名称
    UIAlertView *setChatTitleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_PLEASE_INPUT_NEW_NAME", "请输入新名称")
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                      otherButtonTitles:NSLocalizedString(@"STR_OK", "确定"), nil];
    
    
    setChatTitleAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    setChatTitleAlert.tag = ALERT_MODIFY_GROUP_NAME;
    
    UITextField * titleField = [setChatTitleAlert textFieldAtIndex:0];
    //设置字体大小
    [titleField setFont:[UIFont systemFontOfSize:16]];
    //设置右边消除键出现模式
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    //设置文字垂直居中
    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //设置键盘背景色透明
    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
    titleField.keyboardType = UIKeyboardTypeDefault;
    titleField.text = self.rkChatSessionViewController.currentSessionObject.sessionShowName;
    titleField.placeholder = NSLocalizedString(@"TITLE_PLEASE_INPUT_NEW_NAME", "请输入新名称");
    [titleField becomeFirstResponder];
    
    [setChatTitleAlert show];

}


// 修改会话对象名称
- (void)modifyGroupDescription
{
    // 输入新的群组名称
    UIAlertView *setChatTitleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_PLEASE_INPUT_GROUP_DESCRIPTION", "请输入群描述")
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                      otherButtonTitles:NSLocalizedString(@"STR_OK", "确定"), nil];
    
    
    setChatTitleAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    setChatTitleAlert.tag = ALERT_MODIFY_GROUP_DESCRIPTION;
    
    UITextField * titleField = [setChatTitleAlert textFieldAtIndex:0];
    //设置字体大小
    [titleField setFont:[UIFont systemFontOfSize:16]];
    //设置右边消除键出现模式
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    //设置文字垂直居中
    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //设置键盘背景色透明
    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
    titleField.keyboardType = UIKeyboardTypeDefault;
    titleField.text = ((GroupChat *)self.rkChatSessionViewController.currentSessionObject).groupDescription;
    titleField.placeholder = NSLocalizedString(@"TITLE_PLEASE_INPUT_GROUP_DESCRIPTION", "请输入群描述");
    [titleField becomeFirstResponder];
    
    [setChatTitleAlert show];
    
}

// 转让群主
- (void)transferGroupOwner
{
    SelectGroupMemberViewController *viewController = [[SelectGroupMemberViewController alloc] initWithNibName:@"SelectGroupMemberViewController" bundle:nil];
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer: appDelegate.window.layer];
    viewController.groupId = self.rkChatSessionViewController.currentSessionObject.sessionID;
    viewController.delegate = self;
    
    [self.navigationController pushViewController:viewController animated: NO];
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

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

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ALERT_CLEAR_MESSAGES_TAG:
        {
            // 清空消息记录
            if (buttonIndex == 1)
            {
                // 清空表中的消息记录
                [RKCloudChatMessageManager deleteAllMsgsInChat:self.rkChatSessionViewController.currentSessionObject.sessionID withFile:YES];
                
                // 发送清空消息的通知
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CLEAR_MESSAGES_OF_SESSION object: nil];
            }
        }
            break;
            
        case ALERT_EXIT_SESSION_TAG:
        {
            // 清空并退出
            if (buttonIndex == 1)
            {
                [UIAlertView showWaitingMaskView:nil];
                
                // 调用接口（离开群聊操作,只有出现操作失败的时候才会有返回值，成功后直接跳转到RKChatSessionListViewController）
                [RKCloudChatMessageManager quitGroup:self.rkChatSessionViewController.currentSessionObject.sessionID
                                           onSuccess:^{
                                               [UIAlertView hideWaitingMaskView];
                                               /*
                                               // 弹出提示信息
                                               [UIAlertView showSimpleAlert:@"操作成功"
                                                                    withTitle:nil
                                                                   withButton:NSLocalizedString(@"STR_OK",nil)
                                                                     toTarget:nil];
                                               */
                                               
                                               // 如果在当前退出群的多人语音中 hangup多人语音
                                               if ([[AppDelegate appDelegate].meetingManager isOwnInMeeting] &&
                                                   [self.rkChatSessionViewController.currentSessionObject.sessionID isEqualToString:[AppDelegate appDelegate].meetingManager.sessionId])
                                               {
                                                   [[AppDelegate appDelegate].meetingManager asyncHandUpMeeting];
                                               }
                                               
                                               [self.navigationController popToRootViewControllerAnimated:YES];
                                           }
                                            onFailed:^(int errorCode) {
                                                [UIAlertView hideWaitingMaskView];
                                                
                                                NSString *errString = @"操作失败";
                                                // 弹出提示信息
                                                [UIAlertView showSimpleAlert:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                                                     withTitle:nil
                                                                    withButton:NSLocalizedString(@"STR_OK",nil)
                                                                      toTarget:nil];
                                                
                                            }];
                
            }
        }
            break;
            
        case ALERT_CREATE_NEW_GROUP_TAG:
        {
            // 确定按钮则创建聊天会话
            if (buttonIndex == 1 && self.createFriendObjectArray && [self.createFriendObjectArray count] > 1)
            {
                UITextField *titleField = [alertView textFieldAtIndex:0];
                titleField.placeholder = NSLocalizedString(@"STR_TEMP_GROUP_NAME", "临时群");
                
                // 返回群组的名字
                NSString *groupName = titleField.placeholder;
                
                // 若用户在文本框内输入文字并且点击确定则使用用户创建的名字，否则为空
                if ([titleField.text length] > 0) {
                    // 点击“确定”按钮
                    groupName = titleField.text;
                }
                
                // 去除文本框
                [titleField resignFirstResponder];
                titleField.delegate = nil;
                
                [UIAlertView showWaitingMaskView:NSLocalizedString(@"PROMPT_CREATE_MULTI_CHAT", "正在创建群...")];
                
                // 调用接口（创建群聊会话操作,只有出现操作失败的时候才会有返回值，成功后直接跳转到RKChatSessionViewController）
                [RKCloudChatMessageManager applyGroup:self.createFriendObjectArray
                                        withGroupName:groupName
                                            onSuccess:^(NSString *groupID) {
                                                
                                                [UIAlertView hideWaitingMaskView];
                                                
                                                // 视图返回到根视图
                                                [self.navigationController popToRootViewControllerAnimated:NO];
                                            }
                                             onFailed:^(int errorCode, NSArray *arrayFailUserName) {
                                                 [UIAlertView hideWaitingMaskView];
                                                 
                                                 NSString *errString = @"操作失败";
                                                 switch (errorCode) {
                                                     case RK_INVALID_USER: // 5, 非法用户，即非云视互动用户或是该用户从未登录使用过
                                                     {
                                                         NSString *failName = [arrayFailUserName componentsJoinedByString:@","];
                                                         
                                                         errString = [NSString stringWithFormat:@"非法用户：%@，即非云视互动用户或是该用户从未登录使用过", failName];
                                                     }
                                                         break;
                                                         
                                                     case CHAT_GROUP_COUNT_EXCEED_LIMIT: // 2023, 群个数已达上限
                                                         errString = [NSString stringWithFormat:@"群个数已达上限，目前限制群个数最大为：%d个", [RKCloudChatMessageManager getMaxNumOfCreateGroups]];
                                                         break;
                                                         
                                                     case CHAT_GROUP_USER_NUMBER_EXCEED_LIMIT: // 2024, 群用户人数已达上限
                                                         errString = [NSString stringWithFormat:@"群用户人数已达上限，目前限制群用户人数最大为：%d人", [RKCloudChatMessageManager getMaxNumOfGroupUsers]];
                                                         break;
                                                         
                                                     default:
                                                         break;
                                                 }
                                                 
                                                 // 弹出提示信息
                                                 [UIAlertView showSimpleAlert:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                                                      withTitle:nil
                                                                     withButton:NSLocalizedString(@"STR_OK",nil)
                                                                       toTarget:nil];
                                                 
                                             }];
                
                
                self.createFriendObjectArray = nil;
            }
        }
            break;
            
        case ALERTVIEW_SESSIONINFO_DELETE_CONTACT_TAG:
        {
            // 确认将用户从群聊删除
            if (buttonIndex == 1)
            {
                [self touchDeleteContactFromSessionButton:self.deleteContactId];
            } else {
                self.deleteContactId = nil;
            }
            
        }
            break;
        case ALERT_MODIFY_GROUP_DESCRIPTION:  // 修改群描述
        {
            if (buttonIndex == 0) {
                return;
            }
            
            // 隐藏键盘
            id titleField = [alertView textFieldAtIndex:0];
            NSString *inputContent = nil;
            // 获取输入的名称
            if (titleField && [titleField isKindOfClass:[UITextField class]])
            {
                [titleField resignFirstResponder];
                inputContent = ((UITextField *)titleField).text;
            }
            
            NSString *stringTrim = [inputContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            // 判断是否为空
            if (stringTrim == nil || [stringTrim length] <= 0){
                [UIAlertView showAutoHidePromptView:@"群描述不能为空" background:nil showTime:1.5];
                return;
            }
            
            [RKCloudChatMessageManager modifyGroupDescription:stringTrim
                                                   forGroupID: self.rkChatSessionViewController.currentSessionObject.sessionID
                                                    onSuccess:^{
                                                        
                                                        GroupChat *groupChat = (GroupChat *)self.rkChatSessionViewController.currentSessionObject;
                                                        
                                                        groupChat.groupDescription = stringTrim;
                                                        
                                                        [self.sessionInfoTableView reloadData];
                                                        
                                                    } onFailed:^(int errorCode) {
                                                        
                                                    }];
            
        }
            break;
        case ALERT_MODIFY_GROUP_NAME:
        {
            // 确认修改
            if (buttonIndex == 1)
            {
                // 隐藏键盘
                id titleField = [alertView textFieldAtIndex:0];
                NSString *inputContent = nil;
                // 获取输入的名称
                if (titleField && [titleField isKindOfClass:[UITextField class]])
                {
                    [titleField resignFirstResponder];
                    inputContent = ((UITextField *)titleField).text;
                }
                
                NSString *stringTrim = [inputContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                // 判断是否为空
                if (stringTrim == nil || [stringTrim length] <= 0){
                    [UIAlertView showAutoHidePromptView:@"群名称不能为空" background:nil showTime:1.5];
                    return;
                }
                
                // 修改群聊的名字
                [RKCloudChatMessageManager modifyGroupName:stringTrim forGroupID:self.rkChatSessionViewController.currentSessionObject.sessionID onSuccess:^{
                    // 修改当前对话的群组名称
                    UITableViewCell *cell = [self.sessionInfoTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
                    cell.detailTextLabel.text = stringTrim;
                    
                    self.rkChatSessionViewController.currentSessionObject.sessionShowName = stringTrim;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHAT_SESSION_CHANGE_GROUP_NAME object:nil];
                } onFailed:^(int errorCode) {
                    
                }];
                
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatGroup
// 云视互动即时通信对于群的回调接口

/*!
 * @brief 代理方法: 单个群信息有变化
 *
 * @param groupId NSString 群ID
 * @param changedType 修改群信息的类型，具体看ChangedType定义
 *
 * @return
 */
- (void)didGroupInfoChanged:(NSString *)groupId changedType:(ChangedType)changedType
{
    // 初始化会话信息
    [self initCurrentSessionInfo];
    // 删除所有的头像
    [self.sessionContactListView removeAllContactAvator];
    
    if (self.sessionInfoTableView) {
        [self.sessionInfoTableView reloadData];
    }
}


/**
 * @brief 代理方法: 移除群
 *
 * @param groupId NSString 群ID
 * @param removeType int 移除类型 1：主动退出 2：被踢除 3：群解散
 *
 * @return
 */
- (void)didGroupRemoved:(NSString *)groupId withRemoveType:(LeaveType)removeType
{
    // 初始化会话信息
    [self initCurrentSessionInfo];
    // 删除所有的头像
    [self.sessionContactListView removeAllContactAvator];
    
    if (self.sessionInfoTableView) {
        [self.sessionInfoTableView reloadData];
    }
}

/**
 * @brief 代理方法: 群成员有变化
 *
 * @param groupId NSString 群ID
 *
 * @return
 */
- (void)didGroupUsersChanged:(NSString *)groupId
{
    // 初始化会话信息
    [self initCurrentSessionInfo];
    
    // 删除所有的头像
    [self.sessionContactListView removeAllContactAvator];
    
    if (self.sessionInfoTableView) {
        [self.sessionInfoTableView reloadData];
    }
}


#pragma mark -
#pragma mark CustomAvatarImageViewDelegate

// 点击用户image头像，应该显示用户详细信息，此处只弹出用户名称信息
- (void)touchAvatarMethod:(NSString *)paramUserId
{
    FriendDetailViewController *vwcFriendDetail = [[FriendDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    // 判断点击头像的类型  个人
    if ([paramUserId isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
    {
        PersonalDetailViewController *vwcPersonalDetail = [[PersonalDetailViewController alloc] initWithNibName:@"PersonalDetailViewController" bundle:nil];
        
        [self.navigationController pushViewController:vwcPersonalDetail animated:YES];
    }
    else if ([[AppDelegate appDelegate].contactManager isOwnFriend:paramUserId]) // 好友
    {
        vwcFriendDetail.personalDetailType = PersonalDetailTypeFriend;
        vwcFriendDetail.userAccount = paramUserId;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
    else // 陌生人
    {
        vwcFriendDetail.personalDetailType = PersonalDetailTypeStranger;
        vwcFriendDetail.userAccount = paramUserId;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
}

#pragma mark -
#pragma mark ChatSelectFriendsViewControllerDelegate

- (void)selectChatFriendsWithAccout:(NSArray *)accoutArray
{
    // 邀请加入一个已经存在的消息会话
    [self joinExistChatSession:accoutArray];
}

#pragma mark - Modify Friend Remark

- (void)receivedUpdateUserInfoNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 刷新tableview
        if (self.sessionInfoTableView)
        {
            [self.sessionInfoTableView reloadData];
        }
    });
}

#pragma mark -
#pragma mark SelectGroupMemberDelegate methods

- (void)selectedGroupMember:(NSMutableArray *)selectedMemberArray
{
    if (selectedMemberArray == nil || [selectedMemberArray count] == 0) {
        return;
    }
    FriendTable *friendTable = [selectedMemberArray firstObject];
    
    [UIAlertView showWaitingMaskView: NSLocalizedString(@"PROMPT_FIXING", nil)];
    
    [RKCloudChatMessageManager transferGroup:self.rkChatSessionViewController.currentSessionObject.sessionID toAccount:friendTable.friendAccount onSuccess:^{
        [UIAlertView hideWaitingMaskView];
    } onFailed:^(int errorCode) {
        [UIAlertView hideWaitingMaskView];
        NSString *errorMessage = @"系统错误";
        switch (errorCode)
        {
            case CHAT_GROUP_UNMASTER:
                errorMessage = @"非群主，不能转让群";
                break;
                
            default:
                break;
        }
        
        [UIAlertView showAutoHidePromptView: errorMessage];
    }];
}

@end
