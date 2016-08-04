//
//  SearchContactViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/7/27.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SearchAddContactViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "RKTableViewCell.h"
#import "AppDelegate.h"
#import "SearchFriendTableViewCell.h"
#import "RegularCheckTools.h"
#import "DatabaseManager+FriendTable.h"
#import "FriendTable.h"
#import "FriendDetailViewController.h"
#import "PersonalDetailViewController.h"


@interface SearchAddContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, strong) UITableView *searchContactTableView;
@property (nonatomic, strong) UISearchBar *contactSearchBar;
@property (nonatomic, strong) UISearchDisplayController *strongSearchDisplayController;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) NSMutableArray *searchContactArray;  // 查找的联系人Array

@end

@implementation SearchAddContactViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.appDelegate = [AppDelegate appDelegate];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"TITLE_ADD_FREIND", "添加好友");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendListNoticeMethod:) name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendListNoticeMethod:) name:NOTIFICATION_SEARCH_AND_ADD_FRIEND_VERIFY_YES object:nil];
    
    [self addSearchTableView];
    
    // 添加搜索框
    [self addSearchBar];
    
    // 添加消除searchBar 跳动代码
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    // Jacky.Chen:2016.02.02push和pop时底部tabbar滑动出现布局闪卡
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // 注册TextField通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)dealloc
{
    self.contactSearchBar.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SEARCH_AND_ADD_FRIEND_VERIFY_YES object:nil];
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


#pragma mark - Add Serach Bar & TableView

- (void)addSearchTableView
{
    // 添加contactTableView
    CGRect tableviewFrame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-STATU_NAVIGATIONBAR_HEIGHT);
    self.searchContactTableView = [[UITableView alloc] initWithFrame:tableviewFrame style:UITableViewStylePlain];
    self.searchContactTableView.delegate = self;
    self.searchContactTableView.dataSource = self;
    self.searchContactTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.searchContactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.searchContactTableView];
}

- (void)addSearchBar
{
    self.contactSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    self.contactSearchBar.placeholder = NSLocalizedString(@"TITLE_SEARCH_FRIEND", "搜索好友");
    // 设置键盘类型
    self.contactSearchBar.keyboardType = UIKeyboardTypeASCIICapable;
    
    self.contactSearchBar.delegate = self;
    
    // 添加 searchbar 到 headerview
    [self.searchContactTableView setTableHeaderView:self.contactSearchBar];
    
    // 用 searchbar 初始化 SearchDisplayController 并把 searchDisplayController 和当前 controller 关联起来
    self.strongSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.contactSearchBar contentsController:self];
    
    self.strongSearchDisplayController.searchResultsDataSource = self;
    self.strongSearchDisplayController.searchResultsDelegate = self;
    self.strongSearchDisplayController.delegate = self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
       return self.searchContactArray.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.strongSearchDisplayController.searchResultsTableView) {
        SearchFriendTableViewCell *searchContactCell = [tableView dequeueReusableCellWithIdentifier:@"SearchContactCell"];
        
        if (searchContactCell == nil) {
            searchContactCell = [[SearchFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"SearchContactCell"];
            searchContactCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if ([self.searchContactArray count] > 0)
        {
            searchContactCell.friendsNotifyTable = [self.searchContactArray objectAtIndex:indexPath.row];
        }
        
        [searchContactCell setNeedsDisplay];
        
        return searchContactCell;
    }
    
    RKTableViewCell *contactEditCell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    if (contactEditCell == nil) {
        contactEditCell = [[RKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"];
        contactEditCell.cellFromType = Cell_From_Type_Other;
    }
    return contactEditCell;
}

#pragma mark -
#pragma mark - UITableViewDelegate

// 行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_CONTACT_LIST_CELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.5f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (self.searchContactArray == nil || [self.searchContactArray count] == 0) {
        return nil;
    }
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 0.5)];
    UILabel * lineLabel =[[UILabel alloc]initWithFrame:CGRectMake(15, 0, UISCREEN_BOUNDS_SIZE.width-15, 0.5)];
    lineLabel.backgroundColor = [UIColor colorWithRed:193.0/255.0 green:192.0/255.0 blue:197.0/255.0 alpha:1.0];
    [view addSubview:lineLabel];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendDetailViewController *vwcFriendDetail = [[FriendDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        FriendsNotifyTable *friendsNotifyTable = [self.searchContactArray objectAtIndex:indexPath.row];
        
        NSString *paramUserId = friendsNotifyTable.friendAccount;
        
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
}


#pragma mark -
#pragma mark - UISearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    if (self.searchContactArray.count > 0) {
        [self.searchContactArray removeAllObjects];
    }
}

// 点击搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    // 验证搜索的用户名是否为：搜索条件由数字和字母组成，并以字母开头
    if (![RegularCheckTools isCheckSearchUserName:self.contactSearchBar.text])
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_INPUT_CORRECT_CONTENT_TYPE", nil) background:nil showTime:1.5];
        
        return;
    }
    
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    // 提交服务器搜索
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *arraySearchContact = [self.appDelegate.contactManager searchContactWithFilterString:self.contactSearchBar.text];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            [UIAlertView hideWaitingMaskView];
            
            if ([arraySearchContact count] > 0) {
                if (self.searchContactArray.count > 0) {
                    [self.searchContactArray removeAllObjects];
                }
                
                self.searchContactArray = arraySearchContact;
                
                // 刷新SearchTable
                [self.strongSearchDisplayController.searchResultsTableView reloadData];
            }
        });
    });
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    if (self.searchContactArray.count > 0) {
        [self.searchContactArray removeAllObjects];
    }
}

#pragma mark -
#pragma mark - UISearchDisplayController Delegate

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
//    SearchFriendTableViewCell *searchContactCell = [tableView dequeueReusableCellWithIdentifier:@"SearchContactCell"];
//    
//    if (searchContactCell == nil) {
//        searchContactCell = [[SearchFriendTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchContactCell"];
//    }
}

#pragma mark -
#pragma mark - SearchContactTableViewCellDelegate Delegate

- (void)sendFriendApplySuccessDelegate:(FriendTable *)contactTable
{
    
}

#pragma mark - Notification

// 更新联系人分组
- (void)updateFriendListNoticeMethod:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.strongSearchDisplayController.searchResultsTableView reloadData];
    });
}

#pragma mark -
#pragma mark TextFieldDelegate Method

- (void)textDidChange:(NSNotification *)obj{
    
    NSInteger maxLength = USER_NAME_MAX_LENGTH;
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
            if (toBeString.length > maxLength) {
                textField.text = [toBeString substringToIndex:maxLength];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > maxLength) {
            textField.text = [toBeString substringToIndex:maxLength];
        }
    }
}


@end
