//
//  ContactViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "AppDelegate.h"
#import "RKCloudUIContactViewController.h"
#import "RKCloudUIContactGroupViewController.h"
#import "RKCloudUIContactTableCell.h"
#import "RKChatSessionInfoViewController.h"
#import "RKChatSessionListViewController.h"
#import "ToolsFunction.h"
#import "ContactObject.h"
#import "ContactListItem.h"
#import "ContactHorizontalList.h"
#import "DatabaseManager+FriendGroupsTable.h"
#import "Definition.h"
#import "RKTableViewCell.h"
#import "RKNavigationController.h"
#import "SearchAddContactViewController.h"
#import "NewFriendViewController.h"
#import "DatabaseManager+FriendTable.h"
#import "FriendDetailViewController.h"
#import "SelectFriendsViewController.h"
#import "PersonalInfos.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"
#import "RKCustomerServiceSDK.h"

@interface RKCloudUIContactViewController()<SelectFriendsViewControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *contactTableView;
@property (nonatomic, strong) NSMutableArray *friendGroupsArray;  // 保存分组信息的数组
@property (nonatomic, strong) NSMutableDictionary *friendListDic;  // 保存分组信息的数组
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, assign) NSInteger editSectionIndex;  // 当前编辑的SectionHeaderView对应的Section Index

@end

@implementation RKCloudUIContactViewController

#define REFRESH_TIMEOUT  240
#define ALL_CONTACT		0

#define SECTION_DEFULT_NUMBER		1  // 除去联系人Section固定的Sectiong个数

#pragma mark - Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.allContactsArray = nil;
        self.allSelectedArray = [[NSMutableArray alloc] init];
        isSearchContact = NO;
        self.editSectionIndex = -1;
        self.appDelegate = [AppDelegate appDelegate];
        
        self.title = NSLocalizedString(@"STR_CONTACT_LIST", @"");
        
        // Custom initialization
        UITabBarItem* item = [[UITabBarItem alloc]
                              initWithTitle:@"通讯录"
                              image:[UIImage imageNamed:@"tabbar_icon_contact_normal"]
                              tag:0];
        self.tabBarItem = item;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGroupsInfoNoticeMethod:) name:NOTIFICATION_UPDATE_GROUPS_INFO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendListNoticeMethod:) name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
        // 添加修改好友备注名 修改群聊名称 通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];

        // 初始化分组相关的数据
        [self initFriendGroupsInfoArray];
        
        // 初始联系人相关的数据
        [self initFriendInfoListDic];
        
    }
    return self;
}


- (void)viewDidLoad {

    [super viewDidLoad];

    // 定制页面UI的布局
    [self customViewFace];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
   
    // 设置状态栏默认风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // 注册TextField通知，解决非本页面的UITextField输入文字时响应通知的问题
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 移除TextField的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_GROUPS_INFO object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
    // 移除修改好友备注名 修改群聊名称 通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Custom Methods

// 初始化相关的数据
- (void)initFriendGroupsInfoArray
{
    // 获取分组信息数组
    self.friendGroupsArray = [NSMutableArray arrayWithArray:[self.appDelegate.databaseManager getAllFriendGroupsTable]];
    
    // 使所有分组都不显示好友cell 用于首次点击section 下载图片
    if ([self.friendGroupsArray count] > 0)
    {
        for (FriendGroupsTable *friendGroupTable in self.friendGroupsArray)
        {
            friendGroupTable.isShowFriendsList = NO;
            [self.appDelegate.databaseManager saveFriendGroupsTable:friendGroupTable];
        }
    }
    
    NSLog(@"CONTACTS: Load ContactGroups Frome DB friendGroupsArray = %@",self.friendGroupsArray);
}

- (void)initFriendInfoListDic
{
    if (self.friendGroupsArray && self.friendGroupsArray.count > 0)
    {
        if (self.friendListDic == nil) {
            self.friendListDic = [NSMutableDictionary dictionary];
        }
        for (int i = 0; i<self.friendGroupsArray.count; i++)
        {
            FriendGroupsTable *contactGroupTable = [self.friendGroupsArray objectAtIndex:i];
            
            // 获取GroupId对应的ContactTable
            NSArray *friendsArray = [self.appDelegate.databaseManager getFriendTableByGrooupId:contactGroupTable.contactGroupsId];
            
            NSMutableArray *arrayContacts = [NSMutableArray array];
            
            // 过滤用户名为nil的空数据
            for (FriendTable *friendTable in friendsArray)
            {
                if (friendTable.friendAccount != nil && ![friendTable.friendAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
                {
                    [arrayContacts addObject:friendTable];
                }
            }
            
            // 以GroupId作为KEY  对应联系人数组作为Object 获取数据
            [self.friendListDic setValue:arrayContacts forKey:contactGroupTable.contactGroupsId];
        }
    }
}

// 页面中控件的添加与设置
- (void)customViewFace
{
    // 添加contactTableView
    CGRect tableviewFrame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-70);
    self.contactTableView = [[UITableView alloc]initWithFrame:tableviewFrame style:UITableViewStylePlain];
    self.contactTableView.delegate = self;
    self.contactTableView.dataSource = self;
    self.contactTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.contactTableView];

    // 初始化 Right Bar Button
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"add_friend_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchAddFriendButton)];
    self.navigationItem.rightBarButtonItem = rightBarButton;
    
    // Jacky.Chen:2016.02.26ADD,增加顶部间距Headerview，高度15
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 15.0)];
    headerView.backgroundColor = [UIColor clearColor];
    
    [self.contactTableView setTableHeaderView:headerView];
}

// 点击添加好友按钮
- (void)touchAddFriendButton
{
    // 添加新朋友
    SearchAddContactViewController *addContactController = [[SearchAddContactViewController alloc] initWithNibName:nil bundle:nil];
    
    addContactController.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:addContactController animated:YES];
}

- (UIView *)addContactGroupInfoView:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, HEIGHT_MORE_LIST_CELL)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.tag = CONTACT_SECTION_GROUPS_TAG + section;
    
    if (section == 0) {
        
    }
    // 第一个分组需要增加顶端线条
    if (section == SECTION_DEFULT_NUMBER) {
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(headerView.frame), 0.5)];
        topLine.backgroundColor = COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND;
        [headerView addSubview:topLine];
    }
    
    // 每一个分组添加一条底线
    UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame) - 0.5, CGRectGetWidth(headerView.frame), 0.5)];
    bottomLine.backgroundColor = COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND;
    [headerView addSubview:bottomLine];
    
    // 添加headview的点击事件
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSectionHeaderView:)];
    [headerView addGestureRecognizer:tapGestureRecognizer];
    
    // 添加长按手势，长按编辑分组
    UILongPressGestureRecognizer *longGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longtapSectionHeaderView:)];
    [headerView addGestureRecognizer:longGestureRecognizer];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, (CGRectGetHeight(headerView.frame) - 15)/2, 15, 15)];
    [headerView addSubview:iconImageView];
    
    // 显示title的label
    UILabel *headTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame) + 5, 0, UISCREEN_BOUNDS_SIZE.width - 15 - CGRectGetMaxX(iconImageView.frame), HEIGHT_MORE_LIST_CELL)];
    headTitleLabel.textAlignment = NSTextAlignmentLeft;
    headTitleLabel.font = [UIFont systemFontOfSize:16];
    [headerView addSubview:headTitleLabel];
    
    // 获取FriendGroupsTable对象
    FriendGroupsTable *friendGroupsTable = [self.friendGroupsArray objectAtIndex:(section - SECTION_DEFULT_NUMBER)];
    headTitleLabel.text = friendGroupsTable.contactGroupsName;
    
    iconImageView.image = friendGroupsTable.isShowFriendsList == YES ? [UIImage imageNamed:@"groups_show_icon"] : [UIImage imageNamed:@"groups_show_icon_left"];
    
    return headerView;
}

#pragma mark -
#pragma mark NSNotice Methods

// 更新联系人分组
- (void)updateGroupsInfoNoticeMethod:(NSNotification *)notice
{
    // 重新获取分组信息
    [self initFriendGroupsInfoArray];
    
    // 初始联系人相关的数据
    [self initFriendInfoListDic];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.contactTableView reloadData];
    });
    
}

// 更新联系人分组
- (void)updateFriendListNoticeMethod:(NSNotification *)notice
{
    // 重新获取好友列表信息
    [self initFriendInfoListDic];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.contactTableView reloadData];
    });
}

- (void)receivedNotification:(NSNotification *)notification
{
    [self.contactTableView reloadData];
}

#pragma mark -
#pragma mark UIMenuItem Action Methods

- (BOOL)canBecomeFirstResponder
{
    [super canBecomeFirstResponder];
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(touchCreatContactGroupsEditMenu:) || action == @selector(touchSelectContactEditMenu:) || action == @selector(touchDeleteContactEditMenu:) || action == @selector(touchChangeContactGroupsNameEditMenu:)) {
        return YES;
    }
    
    return NO;
}

// 创建分组
- (void)touchCreatContactGroupsEditMenu:(id)sender
{
    UIAlertView *creatGroupsNameAlertView = [[UIAlertView alloc]
                                             initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_CREAT", @"")
                                             message:nil
                                             delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"")
                                             otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
    
    creatGroupsNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *titleField = [creatGroupsNameAlertView textFieldAtIndex:0];
    //设置字体大小
    [titleField setFont:[UIFont systemFontOfSize:16]];
    //设置右边消除键出现模式
//    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    //设置文字垂直居中
    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //设置键盘背景色透明
//    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
    titleField.keyboardType = UIKeyboardTypeDefault;
    titleField.placeholder = NSLocalizedString(@"STR_ADD_COTANT_GROUP_MASSAGE", @"");
    [titleField becomeFirstResponder];
    
    creatGroupsNameAlertView.tag = ALERT_CONTACT_GROUPS_NAME_NEW;
    
    [creatGroupsNameAlertView show];
}

// 选择好友
- (void)touchSelectContactEditMenu:(id)sender
{
    // 弹出选择好友页面
    SelectFriendsViewController *selectFriendsCtr = [[SelectFriendsViewController alloc] init];
    selectFriendsCtr.friendsListType = FriendsListTypeFriendGroupsOpration;
    FriendGroupsTable *friendGroupTable = [self.friendGroupsArray objectAtIndex:self.editSectionIndex];
    selectFriendsCtr.groupId = friendGroupTable.contactGroupsId;
    selectFriendsCtr.delegate = self;
    selectFriendsCtr.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    [self.navigationController pushViewController:selectFriendsCtr animated: NO];
}

// 修改分组
- (void)touchChangeContactGroupsNameEditMenu:(id)sender
{
    UIAlertView *changeGroupsNameAlertView = [[UIAlertView alloc]
                                     initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_CHANGE", @"")
                                     message:nil
                                     delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                     otherButtonTitles:NSLocalizedString(@"STR_OK", @"取消"), nil];
    
    changeGroupsNameAlertView.tag = ALERT_CONTACT_GROUPS_NAME_CHANGE;
    changeGroupsNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *groupsNameText = [changeGroupsNameAlertView textFieldAtIndex:0];
    groupsNameText.delegate = self;
    // 修改分组名称的TextField设置text
    FriendGroupsTable *FriendGroupsTable = [self.friendGroupsArray objectAtIndex:self.editSectionIndex];
    groupsNameText.text = FriendGroupsTable.contactGroupsName;
    
    [changeGroupsNameAlertView show];
}

// 删除分组
- (void)touchDeleteContactEditMenu:(id)sender
{
    UIAlertView *deleteGroupsNameAlertView = [[UIAlertView alloc]
                                              initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_DELETE_TITLE", @"")
                                              message:nil
                                              delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"STR_OK", @"取消"), nil];
    deleteGroupsNameAlertView.tag = ALERT_CONTACT_GROUPS_NAME_DELETE;
    [deleteGroupsNameAlertView show];
}

#pragma mark -
#pragma mark Submit Data To Server

// 向服务器提交新分组信息的数据
- (void)submitContactGroupsNameToServer:(NSString *)contactGroupsName
               withOptionGroupsNameType:(ContactGroupsOprationType)contactGroupsOprationType
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    FriendGroupsTable *friendGroupsTable = nil;
    
    switch (contactGroupsOprationType) {
        case ContactGroupsOprationTypeAdd:  // 创建新分组
        {
            friendGroupsTable = [[FriendGroupsTable alloc] init];
            friendGroupsTable.contactGroupsName = contactGroupsName;
        }
            break;
        case ContactGroupsOprationTypeChange:  // 修改分组名称
        {
            friendGroupsTable = [self.friendGroupsArray objectAtIndex:self.editSectionIndex];
            friendGroupsTable.contactGroupsName = contactGroupsName;
        }
            break;
        case ContactGroupsOprationTypeDelete:  // 删除分组名称
        {
            friendGroupsTable = [self.friendGroupsArray objectAtIndex:self.editSectionIndex];
        }
            break;
        default:
            break;
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 提交服务器
        BOOL isSuccessCreat = [self.appDelegate.contactManager asyncContactGroupsOpration:friendGroupsTable withOprationType:contactGroupsOprationType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIAlertView hideWaitingMaskView];
            
            if (isSuccessCreat)
            {
                // 重新获取数据库中的分组数组
                [self initFriendGroupsInfoArray];
                
                // 重新获取分组对应的好友列表
                [self initFriendInfoListDic];
                
                [self.contactTableView reloadData];
            }
        });
    });
}

#pragma mark -
#pragma mark Contact Groups Name Methods

- (void)tapSectionHeaderView:(UITapGestureRecognizer*)tapGestureRecognizer
{
    // 获取点击的headerView
    UIView *headerView = (UIView *)tapGestureRecognizer.view;
    
    if (headerView == nil) {
        return;
    }
    
    // 获取当前点击headerView对应的Section
    self.editSectionIndex = headerView.tag - CONTACT_SECTION_GROUPS_TAG - SECTION_DEFULT_NUMBER;
    
    FriendGroupsTable *friendGroupsTable = [self.friendGroupsArray objectAtIndex:self.editSectionIndex];
    friendGroupsTable.isShowFriendsList = !friendGroupsTable.isShowFriendsList;
    
    // 判断组是否统一下载过头像
    NSArray *friendsArray = [self.friendListDic objectForKey:friendGroupsTable.contactGroupsId];
    if (friendsArray.count > 0)
    {
        for (int i = 0; i<friendsArray.count; i++) {
            FriendTable *friendTable = [friendsArray objectAtIndex:i];
            
            FriendInfoTable *friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:friendTable.friendAccount];
            // 若头像不存在则再下载
            if ([friendInfoTable.friendServerAvatarVersion intValue] > 0 && (![ToolsFunction isFileExistsAtPath:[ToolsFunction getFriendThumbnailAvatarPath:friendTable.friendAccount]] || [friendInfoTable.friendThumbnailAvatarVersion intValue] < [friendInfoTable.friendServerAvatarVersion intValue]))
            {
                [self.appDelegate.userInfoManager asyncDownloadThumbnailAvatarWithAccount:friendTable.friendAccount];
            }
        }
    }
    
    [self.appDelegate.databaseManager saveFriendGroupsTable:friendGroupsTable];
    
    // 查找图标对应的UIiamgeView并旋转
    for (UIView *subView in headerView.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [self revolveHeagerIconImageView:(UIImageView *)subView withClockwise:friendGroupsTable.isShowFriendsList == YES ? YES : NO];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contactTableView reloadData];
    });
}

- (void)longtapSectionHeaderView:(UITapGestureRecognizer*)tapGestureRecognizer
{
    NSLog(@"first longtapSectionHeaderView self become first responder = %d",[self isFirstResponder]);
    [self becomeFirstResponder];
    NSLog(@"second longtapSectionHeaderView self become first responder = %d",[self isFirstResponder]);
    
    // 获取点击的headerView
    UIView *headerView = (UIView *)tapGestureRecognizer.view;
    
    // 获取当前点击headerView对应的Section
    self.editSectionIndex = headerView.tag - CONTACT_SECTION_GROUPS_TAG - SECTION_DEFULT_NUMBER;
    
    // 获取点击的headerView
    NSInteger section = headerView.tag - CONTACT_SECTION_GROUPS_TAG;
    if ([tapGestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [headerView becomeFirstResponder];
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        NSMutableArray *menuItemArray = [NSMutableArray array];
        UIMenuItem *creatGroupItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_CREAT", @"创建分组") action:@selector(touchCreatContactGroupsEditMenu:)];
        [menuItemArray addObject:creatGroupItem];
        
        UIMenuItem *selectGroupContactItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_SELECT", @"选择好友") action:@selector(touchSelectContactEditMenu:)];
        [menuItemArray  addObject:selectGroupContactItem];
        
        // 我的好友分组无一下选项
        if (section != SECTION_DEFULT_NUMBER) {
            UIMenuItem *chageGroupItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_CHANGE", @"修改分组") action:@selector(touchChangeContactGroupsNameEditMenu:)];
            [menuItemArray addObject:chageGroupItem];
            
            UIMenuItem *deleteGroupItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"STR_COTANT_GROUP_DELETE", @"删除分组") action:@selector(touchDeleteContactEditMenu:)];
            [menuItemArray addObject:deleteGroupItem];
        }

        [menuController setMenuItems:menuItemArray];
        [menuController setTargetRect:[self.contactTableView rectForHeaderInSection:section] inView:self.contactTableView];
        [menuController setMenuVisible:YES animated:YES];
        NSLog(@"last longtapSectionHeaderView self become first responder = %d",[self isFirstResponder]);
        NSLog(@"DEBUG:RKCloudUIContactViewController-longtapSectionHeaderView: Group Option Menu Show");
    }
}

// 动画旋转指示图标
- (void)revolveHeagerIconImageView:(UIImageView *)iconImageView withClockwise:(BOOL)isClockwise
{
    if (isClockwise) {
        iconImageView.image = [UIImage imageNamed:@"groups_show_icon_left"];
    }
    else
    {
        iconImageView.image = [UIImage imageNamed:@"groups_show_icon"];
    }
}

#pragma mark -
#pragma mark Config Cell Title And Logo Methods

// 设置好友cell
- (void)configContactCell:(RKCloudUIContactTableCell *)contactCell withIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section - SECTION_DEFULT_NUMBER >= [self.friendGroupsArray count])
    {
        NSLog(@"WARNING:RKCloudUIContactViewController-configContactCell: indexPath.section:%d, SECTION_DEFULT_NUMBER:%d, self.friendGroupsArray.count:%d", (int)indexPath.section, SECTION_DEFULT_NUMBER, (int)[self.friendGroupsArray count]);

        return;
    }
    FriendGroupsTable *friendGroupsTable = [self.friendGroupsArray objectAtIndex:(indexPath.section - SECTION_DEFULT_NUMBER)];
    
    if ([[self.friendListDic allKeys] containsObject:friendGroupsTable.contactGroupsId]) {
        NSArray *friendsArray = [self.friendListDic objectForKey:friendGroupsTable.contactGroupsId];
        
        if ([friendsArray count] == 0)
        {
            return;
        }
        
        // 获取对应的ContactTable
        FriendTable *contactTable = [friendsArray objectAtIndex:indexPath.row];
        
        contactCell.cellPositionType = Cell_Position_Type_Middle;
        
        if (indexPath.row == [friendsArray count] - 1)
        {
            contactCell.cellPositionType = Cell_Position_Type_Bottom;
        }
        
        [contactCell setCellAvatarImageWithFriendAccount:contactTable.friendAccount];
        
        NSString *labelText = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:contactTable.friendAccount];
        
        [contactCell setLabelText:labelText];
    }
    
    [contactCell setNeedsDisplay];
}

// 设置添加新朋友与群聊Cell
- (void)configNewContactAndGroupsChatCell:(RKCloudUIContactTableCell *)contactCell withIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [contactCell setCellImage:[UIImage imageNamed:@"add_new_friends_icon"]];
            [contactCell setLabelText:NSLocalizedString(@"STR_ADD_NEW_CONTACT", @"添加新朋友")];
            contactCell.cellPositionType = Cell_Position_Type_Top;
            
            if (self.appDelegate.userProfilesInfo.isHaveNewfriendNotice) {
                [contactCell setNewFriendNoticeImageViewHidden:NO];
            }
        }
            break;
        case 1:
        {
            [contactCell setCellImage:[UIImage imageNamed:@"groups_chat_logo"]];
            [contactCell setLabelText:NSLocalizedString(@"STR_GROUP_CHAT", @"群聊")];
            contactCell.cellPositionType = Cell_Position_Type_Middle;
        }
            break;
        case 2:
        {
            // 云视互动小秘书
            [contactCell setCellAvatarImageWithFriendAccount:RONG_KE_SERVICE];
            [contactCell setLabelText:NSLocalizedString(@"TITLE_RONG_KE_SERVICE", @"云视互动小秘书")];
            contactCell.cellPositionType = Cell_Position_Type_Bottom;
        }
            break;
        default:
            break;
    }
}

- (void)configCellTitleAndLogo:(RKCloudUIContactTableCell *)contactCell withIndexPath:(NSIndexPath *)indexPath
{
    [contactCell setCheckedImageHide:YES];
    [contactCell setNewFriendNoticeImageViewHidden:YES];
    [contactCell setCellImage:nil];
    [contactCell setLabelText:nil];
    
    switch (indexPath.section) {
        case 0:
        {
            // 新的朋友与群聊
            [self configNewContactAndGroupsChatCell:contactCell withIndexPath:indexPath];
        }
            break;
        default:
        {
            // 好友分组
            [self configContactCell:contactCell withIndexPath:indexPath];
        }
            break;
    }
    
    [contactCell setNeedsDisplay];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
#ifndef NONUSE_TRY_CATCH
    @try {
#endif
        // 显示搜索的结果
        if (isSearchContact || self.sectionArray == nil)
        {
            return 0;
        }
        
        // 索引下联系人的个数
        NSInteger contactCount = 0;
        if (index - 1 < [self.sectionArray count])
        {
            contactCount = [[self.sectionArray objectAtIndex: index - 1] count];
        }
        // 如果联系人的个数为0的话，则返回的索引值为-1，不去定位联系人的位置
        if (contactCount == 0)
        {
            return -1;
        }
        
        return index - 1;
        
#ifndef NONUSE_TRY_CATCH
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: ***** sectionForSectionIndexTitle exception = %@ *****", exception);
    }
    @finally {
        
    }
#endif
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    // 减去搜索栏的位置的索引
    NSInteger index = section - 1;
    
    if (isSearchContact || section < 1 || index >= [self.allSectionTitlesArray count])
    {
        // 1、添加搜索title
        // 2、设备分组title
        // 3、当前是搜索功能，则不显示title
        return nil;
    }
    
    if (index < [self.sectionArray count])
    {
        // 索引下联系人的个数为0，则不显示title的分组
        NSInteger contactCount = [[self.sectionArray objectAtIndex: index] count];
        if (contactCount == 0)
        {
            return nil;
        }
    }
    
    // 为了解决在ios7上，阿拉伯语排序的问题
    if (section >= 2 &&
        [ToolsFunction iSiOS7Earlier] == NO &&
        [[ToolsFunction getLocaliOSLanguage] isEqualToString: @"ar"])
    {
        
        // 阿拉伯语下，减去搜索栏的位置的索引，并且再减去一个多余的值。
        index = section - 2;
    }
    
    // 得到每个分组的标题返回
    NSString *titleString = nil;
    if (index < [self.allSectionTitlesArray count])
    {
        titleString = [self.allSectionTitlesArray objectAtIndex:index];
    }
    return titleString;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// 显示搜索的结果
	if (isSearchContact)
	{
		return 1;
	}
    
	// 多增加一个section，为了设置联系人的个数
    // 增加一个section，为了设备分组
	return ([self.friendGroupsArray count] + SECTION_DEFULT_NUMBER);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// 显示搜索的结果
	if (isSearchContact)
	{
		return [self.searchContactArray count];
	}
    
    NSInteger cellNum = 0;
    switch (section) {
        case 0:
            cellNum = 3;
            break;
        default:
        {
            cellNum = 0;
           FriendGroupsTable *friendGroupsTable = [self.friendGroupsArray objectAtIndex:(section - SECTION_DEFULT_NUMBER)];
            if ([[self.friendListDic allKeys] containsObject:friendGroupsTable.contactGroupsId]) {
                
                if (friendGroupsTable.isShowFriendsList) {
                    NSArray *friendsArray = [self.friendListDic objectForKey:friendGroupsTable.contactGroupsId];
                    cellNum = friendsArray.count;
                }
                else
                {
                    cellNum = 0;
                }
            }
        }
            break;
    }

    return cellNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifierStr = nil;
    if (indexPath.section > 1) {
        identifierStr = @"ContactCell";
    }
    else
    {
        identifierStr = @"ContactOptionCell";
    }
    
    RKCloudUIContactTableCell *contactCell = [RKCloudUIContactTableCell creatCellWithTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell" fromType:Cell_From_Type_Other];
    
    // 设置cell的显示
    [self configCellTitleAndLogo:contactCell withIndexPath:indexPath];

	return contactCell;
}


#pragma mark - UITableViewDelegate

    // 去掉“好友分组”
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//	// 显示搜索的结果
//	if (isSearchContact || self.friendGroupsArray == nil )
//	{
//		return nil;
//	}
//    
//    UIView *footerView = [[UIView alloc] init];
//    footerView.backgroundColor = [UIColor clearColor];
//    
//    if (section == 0) {
//        UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, UISCREEN_BOUNDS_SIZE.width - 15, 20)];
//        contactLabel.textAlignment = NSTextAlignmentLeft;
//        contactLabel.font = FONT_TEXT_SIZE_14;
//        contactLabel.textColor = COLOR_SUBHEAD_TEXT;
//        contactLabel.text = NSLocalizedString(@"STR_CONTACT_GROUP", @"好友分组");
//        
//        [footerView addSubview:contactLabel];
//    }
//    
//    return footerView;
//}

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_CONTACT_LIST_CELL;
}

// 设置footer的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    float headerSectionHight = 0;
    switch (section) {
        case 0:
        {
            headerSectionHight = 20;
        }
            break;
        
        default:
            break;
    }
    
	return headerSectionHight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat fHeightForHeader = 0.0;
    
    if (section > 0) {
        fHeightForHeader = HEIGHT_MORE_LIST_CELL;
    }
    
    return fHeightForHeader;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 添加HeaderView
    return [self addContactGroupInfoView:section];
}

/* 响应用户在联系人列表上的点击动作 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 0:
        {
            // 点击添加新朋友与群聊
            [self touchNewFriendAndGroupChatCell:indexPath];
        }
            break;
            
        default:
        {
            // 点击我的好友进入好友详情
            FriendDetailViewController *friendDetailViewCtr = [[FriendDetailViewController alloc] initWithNibName:nil bundle:NULL];
            
             FriendGroupsTable *friendGroupsTable = [self.friendGroupsArray objectAtIndex:(indexPath.section - SECTION_DEFULT_NUMBER)];
            
            if ([[self.friendListDic allKeys] containsObject:friendGroupsTable.contactGroupsId]) {
                NSArray *friendsArray = [self.friendListDic objectForKey:friendGroupsTable.contactGroupsId];
                // 获取对应的ContactTable
                FriendTable *friendTable = [friendsArray objectAtIndex:indexPath.row];
                friendDetailViewCtr.userAccount = friendTable.friendAccount;
                
                friendDetailViewCtr.hidesBottomBarWhenPushed = YES;
                
                [self.navigationController pushViewController:friendDetailViewCtr animated:YES];
            }
        }
            break;
    }
}

- (void)touchNewFriendAndGroupChatCell:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            // 新的朋友
            NewFriendViewController *newContactViewController = [[NewFriendViewController alloc] init];
            newContactViewController.hidesBottomBarWhenPushed = YES;
            
            if (self.appDelegate.userProfilesInfo.isHaveNewfriendNotice == YES) {
                self.appDelegate.userProfilesInfo.isHaveNewfriendNotice = NO;
                [self.appDelegate.userProfilesInfo saveUserProfiles];
            }
            
            [self.navigationController pushViewController:newContactViewController animated:YES];
        }
            break;
        case 1:
        {
            // 群聊
            RKCloudUIContactGroupViewController *groupChatlistCtr = [[RKCloudUIContactGroupViewController alloc] initWithNibName:nil bundle:NULL];
            groupChatlistCtr.hidesBottomBarWhenPushed = YES;
            
            [self.navigationController pushViewController:groupChatlistCtr animated:YES];
        }
            break;
        case 2:
        {
            // 启动连接客服进行服务
            [RKCustomerServiceSDK startConnectCustomerService:RONG_KE_SERVICE_APPKEY
                                                  userAccount:self.appDelegate.userProfilesInfo.userAccount
                                                   themeColor:[UIColor colorWithRed:55/255.0 green: 161/255.0 blue: 219/255.0 alpha:1.0]];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate

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
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    switch (alertView.tag)
    {
        case ALERT_CONTACT_GROUPS_NAME_NEW: // 添加新分组ALERTVIEW的Tag值
        {
            UITextField * titleField = [alertView textFieldAtIndex:0];
            NSString *stringTrim = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
//            [titleField resignFirstResponder];
            
            if (stringTrim.length == 0) {
                [UIAlertView showAutoHidePromptView:@"分组名称不能为空" background:nil showTime:1.5];
                return;
            }
            
            // 判断需要创建的群名称是否存在
            NSArray *arrayGroupTable = [self.appDelegate.databaseManager getAllFriendGroupsTable];
            for (FriendGroupsTable *friendGroupsTable in arrayGroupTable)
            {
                // 判断是否存在组名
                if ([friendGroupsTable.contactGroupsName isEqualToString:stringTrim]) {
                    [UIAlertView showAutoHidePromptView:@"群组已存在" background:nil showTime:1.5];
                    return;
                }
            }
            
            // 向服务器提交新的分组信息
            [self submitContactGroupsNameToServer:titleField.text withOptionGroupsNameType:ContactGroupsOprationTypeAdd];
        }
            break;
            
        case ALERT_CONTACT_GROUPS_NAME_DELETE: // 删除分组ALERTVIEW的Tag值
        {
            // 向服务器提交新的分组信息
            [self submitContactGroupsNameToServer:nil withOptionGroupsNameType:ContactGroupsOprationTypeDelete];
        }
            break;
        case ALERT_CONTACT_GROUPS_NAME_CHANGE:
        {
            UITextField * titleField = [alertView textFieldAtIndex:0];
            NSString *stringTrim = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (stringTrim.length == 0) {
                [UIAlertView showAutoHidePromptView:@"分组名称不能为空" background:nil showTime:1.5];
                return;
            }
            // 向服务器提交新的分组信息
            [self submitContactGroupsNameToServer:titleField.text withOptionGroupsNameType:ContactGroupsOprationTypeChange];
            
//            [titleField resignFirstResponder];
        }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark TextFieldDelegate Method

- (void)textDidChange:(NSNotification *)obj{
    
    if (self.navigationController.visibleViewController != self)
    {
        return;
    }
    
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


#pragma mark -
#pragma mark SelectFriendsViewControllerDelegate

- (void)selectFriendsSuccessDelegateMethod
{
    // 初始联系人相关的数据
    [self initFriendInfoListDic];
    
    [self.contactTableView reloadData];
}



@end
