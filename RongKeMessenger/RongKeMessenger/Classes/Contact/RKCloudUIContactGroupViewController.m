//
//  RKCloudUIContactGroupViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudUIContactGroupViewController.h"
#import "AppDelegate.h"
#import "RKCloudChat.h"
#import "RKChatSessionViewController.h"
#import "RKCloudUIContactTableCell.h"
#import "RKChatSessionListViewController.h"
#import "SelectFriendsViewController.h"
#import "ToolsFunction.h"
#import "Definition.h"

@interface RKCloudUIContactGroupViewController ()<ChatSelectFriendsViewControllerDelegate>

@end

@implementation RKCloudUIContactGroupViewController

#pragma mark - Initializer

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"TITLE_GROUP_CHAT_LIST", "群聊列表");
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//
//    self.searchBarItem = [[UISearchBar alloc] initWithFrame:CGRectZero];
//    self.searchBarItem.delegate = self;
//    [self.searchBarItem sizeToFit];
//    //self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBarItem contentsController:self];
//    self.searchDisplayController.searchResultsDataSource = self;
//    self.searchDisplayController.searchResultsDelegate = self;
//    self.searchDisplayController.delegate = self;
//    self.tableView.tableHeaderView = self.searchBarItem;
    
    // 初始化群聊的选择segment
    [self initGroupChatSegment];
    
    // 获取所有的群聊会话信息数据
    
    NSArray * arrayAllGroupList = [RKCloudChatMessageManager queryAllMyCreatedGroups];
    self.allGroupChatArray = [NSArray arrayWithArray:arrayAllGroupList];
    
    // 增加左边导航按钮为创建群聊会话
//    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                                                            target:self
//                                                                                            action:@selector(touchCreateChatButton)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 页面回滚到顶端
    [self.tableView scrollRectToVisible:self.searchBarItem.frame animated:NO];
    // 重新加载列表数据
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (animated) {
        // 显现滚动条一小段时间，然后会自动消失
        [self.tableView flashScrollIndicators];
    }
}

- (void)dealloc {
    [self.tableView.tableHeaderView removeFromSuperview];
    
    self.searchBarItem = nil;
}

/*
- (void)scrollTableViewToSearchBarAnimated:(BOOL)animated
{
    [self.tableView scrollRectToVisible:self.searchBarItem.frame animated:animated];
}*/

#pragma mark - Custom Method

- (void)initGroupChatSegment
{
    // 增加群聊分类选择的SegmentBar
    NSArray *arraySegmented = [[NSArray alloc] initWithObjects:
                               NSLocalizedString(@"STR_GROUP_CREAT_BY_ME",""),
                               NSLocalizedString(@"STR_GROUP_CREAT_WITH_ME","联系人详情"),
                               nil];
    
    UISegmentedControl *groupChatSegmentControl = [[UISegmentedControl alloc] initWithItems:arraySegmented];
    [groupChatSegmentControl addTarget:self action:@selector(touchSegmentActionMethod:) forControlEvents:UIControlEventValueChanged];
    
    // 设置颜色
    groupChatSegmentControl.tintColor = COLOR_WITH_RGB(25, 174, 240);
    
    // 设置segment title未选中时的字体的样式
    [groupChatSegmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName:COLOR_WITH_RGB(25, 174, 240),
                                                      NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                           forState:UIControlStateNormal];
    
    [groupChatSegmentControl setTitleTextAttributes:@{NSForegroundColorAttributeName: COLOR_WITH_RGB(255, 255, 255),
                                                      NSFontAttributeName: [UIFont systemFontOfSize:16]}
                                           forState:UIControlStateSelected];
    
    groupChatSegmentControl.frame = CGRectMake(11, 11.5, self.view.frame.size.width - 22, 35);
    groupChatSegmentControl.selectedSegmentIndex = 0;
    
    // Jacky.Chen:2016.02.24 ADD 背景View
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:groupChatSegmentControl];
    
    [self.tableView setTableHeaderView:headerView];
}

- (void)touchSegmentActionMethod:(id)sender
{
     UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex == 0)
    {
        // 获取我创建的群列表
        self.allGroupChatArray  = [RKCloudChatMessageManager queryAllMyCreatedGroups];
    }
    else
    {
        // 获取我参与的群列表
        self.allGroupChatArray  = [RKCloudChatMessageManager queryAllMyAttendedGroups];
    }
    [self.tableView reloadData];
}

// 打开选择好友页面
- (void)touchCreateChatButton
{
    SelectFriendsViewController *selectFriendCtr = [[SelectFriendsViewController alloc] init];
    selectFriendCtr.friendsListType = FriendsListTypeOnlyCreatGroupChat;
    selectFriendCtr.chatDelegate = self;
    
    // Push进入消息详情页面之前将TabBar隐藏，并且设置选择消息Tab索引
    selectFriendCtr.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    [self.navigationController pushViewController:selectFriendCtr animated:NO];
}

#pragma mark - ChatSelectFriendsViewControllerDelegate 

- (void)selectChatFriendsWithAccout:(NSArray *)accoutArray
{
    if (accoutArray.count > 2)
    {
        // 少于2人则提示无法不覅和建群的条件
        [UIAlertView showAutoHidePromptView:@"建群失败，选择成员个数至少需要2人" background:nil showTime:1.5];
        return;
    }
    else
    {
        // 显示一个创建新的群聊会话的弹出提示框
        [UIAlertView showCreateNewGroupChatAlert:self];
    }
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchBarItem.text && [self.searchBarItem.text length] > 0)
    {
        return [self.filteredGourps count];
    }
    
    return [self.allGroupChatArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *identifier = @"Cell";
    // Configure the cell...
    
    RKCloudUIContactTableCell * cell = [RKCloudUIContactTableCell creatCellWithTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:identifier fromType:Cell_From_Type_Other];
    
    NSInteger cellNum = 0;
    RKCloudChatBaseChat *rkCloudessionObject = nil;
    if (self.searchBarItem.text && [self.searchBarItem.text length] > 0) {
        rkCloudessionObject = (RKCloudChatBaseChat *)[self.filteredGourps objectAtIndex:indexPath.row];
        cellNum = self.filteredGourps.count;
    } else {
        rkCloudessionObject = (RKCloudChatBaseChat *)[self.allGroupChatArray objectAtIndex:indexPath.row];
        cellNum = self.allGroupChatArray.count;
    }

    // 群聊名称
    [cell setLabelText:[NSString stringWithFormat:@"%@(%d)",rkCloudessionObject.sessionShowName,rkCloudessionObject.userCounts]];
    [cell setCellImage:[UIImage imageNamed:@"default_icon_group_avatar"]];
    if (self.contactMode != CONTACT_ADD) {
        [cell setCheckedImageHide:YES];
    }else{
        [cell setCheckedImageHide:NO];
    }
    
    if (indexPath.row == 0) {
        cell.cellPositionType = Cell_Position_Type_Top;
    }
    else if(indexPath.row == (cellNum - 1))
    {
        cell.cellPositionType = Cell_Position_Type_Bottom;
    }
    else
    {
        cell.cellPositionType = Cell_Position_Type_Middle;
    }
    [cell setNeedsDisplay];
    return cell;
}


#pragma mark - UITableViewDelegatetab
// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 获取ContactObject对象
    RKCloudChatBaseChat *sessionObject = nil;
    
    if (self.searchBarItem.text && [self.searchBarItem.text length] > 0) {
        sessionObject = (RKCloudChatBaseChat *)[self.filteredGourps objectAtIndex:indexPath.row];
    }
    else
    {
        sessionObject = (RKCloudChatBaseChat *)[self.allGroupChatArray objectAtIndex:indexPath.row];
    }
    
    if (sessionObject == nil) {
        return;
    }
    
    if (self.contactMode == CONTACT_FORWARD)
    {
        // 保存选中的转发群聊名称
        self.forwardSessionID = sessionObject.sessionID;
        
        //清除聊天记录
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"确定转发消息"
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                              otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
        alert.tag = ALERT_FORWARD_MESSAGE_TAG;
        [alert show];
    }
    else {
        // 滚动tabview页面时将搜索键盘收起。
        if ([self.searchBarItem isFirstResponder]) {
            [self searchBarCancelButtonClicked:self.searchBarItem];
            
#ifndef __IPHONE_8_0
            [self.searchDisplayController setActive:NO];
#endif
        }
        
        // 弹出到根视图
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        appDelegate.mainTabController.selectedIndex = 0;
        
        // 新建一个聊天会话,如果会话存在，打开聊天页面
        [appDelegate.rkChatSessionListViewController createNewChatView:sessionObject];
    }
}

#pragma mark - Search Delegate

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    if (searchBar)
    {
        [searchBar resignFirstResponder];
        searchBar.text = @"";
        [self buildSectionsByKeyword:@""];
    }
}

// When the search text changes, update the array
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self buildSectionsByKeyword:searchText];
}

// When the search button (i.e. "Done") is clicked, hide the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar)
    {
        [searchBar resignFirstResponder];
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 滚动tabview页面时将搜索键盘收起。
    if (self.searchBarItem && [self.searchBarItem isFirstResponder])
    {
        [self.searchBarItem resignFirstResponder];
    }
}

// 根据关键字创建列表
- (void)buildSectionsByKeyword:(NSString *)keyword
{
    NSString *tempString = [[NSString alloc] initWithFormat:@"%@", keyword];
    if ([tempString length] > 0)
    {
        NSString* upString = [tempString uppercaseString];
        NSRange range;
        
        // 搜索结果
        NSMutableArray *contactMutableArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [self.allGroupChatArray count]; i++)
        {
            RKCloudChatBaseChat *sessionObject = [self.allGroupChatArray objectAtIndex: i];
            
            // Filtering contact object
            if ([keyword length] != 0 && sessionObject != nil)
            {
                range = [[sessionObject.sessionShowName uppercaseString] rangeOfString:upString];
                if (range.length > 0)
                {
                    // 联系人匹配成功
                    [contactMutableArray addObject:sessionObject];
                }
            }
        }
        self.filteredGourps = contactMutableArray;
    }else{
        self.filteredGourps = self.allGroupChatArray;
    }
    
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UIAlertViewDelegate methods
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ALERT_FORWARD_MESSAGE_TAG:
        {
            if (buttonIndex == 1) {
                
                // 转发MMS消息记录方法
                [RKCloudChatMessageManager forwardChatMsg:self.currentMessageObject.messageID
                                    toUserNameOrSessionID:self.forwardSessionID];
                
                
                // 返回两级 回到聊天页
                NSUInteger index = [[self.navigationController viewControllers]indexOfObject:self];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:index-2]animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

@end
