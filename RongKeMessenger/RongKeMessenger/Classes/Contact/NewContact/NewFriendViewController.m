//
//  NewContactViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "NewFriendViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "RKTableViewCell.h"
#import "DatabaseManager+FriendsNotifyTable.h"
#import "NewFriendTableViewCell.h"
#import "FriendDetailViewController.h"
#import "PersonalDetailViewController.h"

@interface NewFriendViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *contactTableView;
@property (nonatomic, strong) NSMutableArray *contactArray;
@property (nonatomic, assign) AppDelegate *appDelegate;

@end

@implementation NewFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"STR_NEW_FRIEND", nil);
    
    // Do any additional setup after loading the view.
    self.appDelegate = [AppDelegate appDelegate];
    
    [self addSearchTableView];
    
    // 获取未成为好友列表
    [self getAllNewContactTable];
    
    [self initNavigationBarButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.appDelegate.userProfilesInfo.isHaveNewfriendNotice = NO;
    
    // 更新好友列表
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
}

- (void)initNavigationBarButton
{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_DELETE_ALL", "清空")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    if ([self.contactArray count] > 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark - Custom Method

- (void)getAllNewContactTable
{
    // 获取所有的新好友
    self.contactArray = [NSMutableArray arrayWithArray:[self.appDelegate.databaseManager getAllFriendsNotifyTable]];
}

- (void)addSearchTableView
{
    // 添加contactTableView
    CGRect tableviewFrame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-STATU_NAVIGATIONBAR_HEIGHT);
    self.contactTableView = [[UITableView alloc]initWithFrame:tableviewFrame style:UITableViewStylePlain];
    self.contactTableView.delegate = self;
    self.contactTableView.dataSource = self;
    self.contactTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.contactTableView];
}

- (void)touchRightButton:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"清空提示"
                                                        message:@"确认清空朋友通知消息吗？"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", nil)
                                              otherButtonTitles:NSLocalizedString(@"STR_OK", nil), nil];
    [alertView show];
}

#pragma mark -
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendTableViewCell *newContactTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"NewContactTableViewCell"];
    
    if (newContactTableViewCell == nil) {
        newContactTableViewCell = [[NewFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ContactCell"];
    }
    
    newContactTableViewCell.friendsNotifyTable = [self.contactArray objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0) {
        newContactTableViewCell.cellPositionType = Cell_Position_Type_Top;
    }
    else if(indexPath.row == (self.contactArray.count - 1))
    {
       newContactTableViewCell.cellPositionType = Cell_Position_Type_Bottom;
    }
    else
    {
        newContactTableViewCell.cellPositionType = Cell_Position_Type_Middle;
    }
    
    [newContactTableViewCell setNeedsDisplay];
    
    return newContactTableViewCell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_CONTACT_LIST_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FriendsNotifyTable *friendsNotifyTable = [self.contactArray objectAtIndex:indexPath.row];
    
    NSString *paramUserId = friendsNotifyTable.friendAccount;
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


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex)
    {
        return;
    }
    
    [self.appDelegate.databaseManager deleteAllDataOfTableByTableName:[FriendsNotifyTable tableName]];
    
    [self getAllNewContactTable];
    
    [self initNavigationBarButton];
    
    [self.contactTableView reloadData];
}


@end
