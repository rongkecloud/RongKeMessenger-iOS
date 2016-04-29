//
//  RKChatSessionListViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "RKCloudChat.h"
#import "ToolsFunction.h"
#import "RKChatSessionListViewController.h"
#import "RKChatSessionViewController.h"
#import "RKCloudUIContactViewController.h"
#import "SessionListTableCell.h"
#import "AppDelegate.h"
#import "SelectFriendsViewController.h"
#import "RKMessageSearchViewController.h"

@interface RKChatSessionListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *sessionListTableView; // 此表主要是按照联系人显示消息统计信息
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarItem; // 搜索控件

@property (nonatomic, strong) NSMutableDictionary  *searchSessionObjectDict; // 搜索的MMS结果字典，key为sessionID,value为SessionTable
@property (nonatomic, strong) NSMutableArray *allSessionArray; // 保存所有会话的会话对象chatSession
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer; // 播放消息铃声

@property (nonatomic, weak) RKChatSessionViewController *messageSessionViewController; // 打开的消息列表

@property (nonatomic, assign) BOOL isSlideDelete; // 是否是快速删除会话，默认为NO
@end

@implementation RKChatSessionListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UITabBarItem *itemTabBar = [[UITabBarItem alloc]
                                    initWithTitle:NSLocalizedString(@"TITLE_MESSAGE_SESSION", "会话")
                                    image:[UIImage imageNamed:@"tabbar_icon_chat_normal"]
                                    tag:1];
        self.tabBarItem = itemTabBar;
        
        // 初始化保存上传、下载进度值（messageID为Key）
        self.progressDic = [[NSMutableDictionary alloc] init];
        self.allSessionArray = [[NSMutableArray alloc] init];
        
        self.isSlideDelete = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TITLE_MESSAGE_SESSION", "会话");
    
    // 初始化界面
    // 左边按钮
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_EDIT", "编辑")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(touchEditButton)];
    self.navigationItem.leftBarButtonItem = leftButton;
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_CREAT_CHAT", "发起群聊") style:UIBarButtonItemStylePlain target:self action:@selector(touchCreateChatButton)];
    
    // 添加修改好友备注名 修改群聊名称 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdateUserInfoNotification:) name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedUpdateUserInfoNotification:) name:NOTIFICATION_CHAT_SESSION_CHANGE_GROUP_NAME object:nil];
    // 下载图片成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAvatarSuccessNotification:) name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    
    // 添加消除searchBar 跳动代码
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.messageSessionViewController = nil;
}

- (void)dealloc
{
    // 移除修改好友备注名 修改群聊名称 通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CHAT_SESSION_CHANGE_GROUP_NAME object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
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
	if (self.searchBarItem.text && [self.searchBarItem.text length] > 0)
	{
		return [self.searchSessionObjectDict count];
	}
	
    return [self.allSessionArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 加载定制的MessageTable Cell
	SessionListTableCell *cell = (SessionListTableCell *)[tableView dequeueReusableCellWithIdentifier:SESSION_LIST_TABLE_CELL];
    if (cell == nil)
	{
		// 获取MessageTableCell
		cell = [ToolsFunction loadTableCellFromNib:SESSION_LIST_TABLE_CELL];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // 获取allMMSMutDic的key
    NSArray *arrayChatSession = nil;
    
    if (self.searchBarItem.text && [self.searchBarItem.text length] > 0)
    {
        arrayChatSession = [[NSArray alloc] initWithArray:[self.searchSessionObjectDict allValues]];
    }
    else
    {
        arrayChatSession = [[NSArray alloc] initWithArray:self.allSessionArray];
    }
    
    RKCloudChatBaseChat *chatObject = [self.allSessionArray objectAtIndex:indexPath.row];
    if (chatObject) {
        // 配置会话列表Cell的相关会话的信息
        [cell configSessionListByChatSessionObject:chatObject  withListType:SessionListShowTypeNomal withMarkColorStr:nil];
    }
    
    // 设置线条的偏移
    [tableView setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    
	return cell;
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// 删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            // 删除消息会话列表记录的一行中的所有记录包含这个会话
            [self deleteMessageSessionListRecordForRow:indexPath.row];
            
            // 删除指定的cell
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            // 通知界面刷新
            [tableView reloadData];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark UITableViewDelegate

// 设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return HEIGHT_MESSAGE_LIST_CELL;
}

// 用户点击联系人消息记录时直接阅读消息 & 查看联系人消息记录详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// 获取选择的会话
	NSArray * arrayChatSession = nil;
    
    // 初始化cell上的新增短信标志提示
    SessionListTableCell *cell = (SessionListTableCell *)[tableView cellForRowAtIndexPath: indexPath];
    cell.missReadLabel.hidden = YES;
    cell.missReadImageView.hidden = YES;
    
	RKChatSessionViewController *vwcMessageSession = [[RKChatSessionViewController alloc]
													 initWithNibName:@"RKChatSessionViewController" bundle:nil];
	vwcMessageSession.parentChatSessionListViewController = self;
    
	if (self.searchBarItem.text && [self.searchBarItem.text length] > 0) {
		// 按关键字显示联系人
		arrayChatSession = [[NSArray alloc] initWithArray:[self.searchSessionObjectDict allValues]];
	}
	else  {
		// 全部联系人
		arrayChatSession = [[NSArray alloc] initWithArray:self.allSessionArray];
	}
	
	if (arrayChatSession && [arrayChatSession count] > indexPath.row)
	{
        if ([self.searchBarItem isFirstResponder]) {
            [self searchBarCancelButtonClicked:self.searchBarItem];
            [self.searchDisplayController setActive:NO];
        }
        
		RKCloudChatBaseChat *selectedSessionObject = (RKCloudChatBaseChat *)[arrayChatSession objectAtIndex:indexPath.row];
        vwcMessageSession.currentSessionObject = selectedSessionObject;
		// 为detail页面准备数据，加载该群组的消息
        vwcMessageSession.hidesBottomBarWhenPushed = YES;
        
        self.messageSessionViewController = vwcMessageSession;
        
		[self.navigationController pushViewController:vwcMessageSession animated:YES];
	}
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isSlideDelete = YES;
    
	self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"STR_FINISH", "完成");
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isSlideDelete = NO;
    
	self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"STR_EDIT", "编辑");
	self.navigationItem.rightBarButtonItem.enabled = YES;
}

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
// 返回编辑的类型
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.searchBarItem.text && [self.searchBarItem.text length] > 0)
	{
		return UITableViewCellEditingStyleNone;
	}
	return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark Touch Button Actions

// 调用UITableView的编辑功能
- (void)touchEditButton
{
    self.isSlideDelete = NO;
    
    [self.sessionListTableView setEditing:!self.sessionListTableView.editing animated:YES];
	//self.sessionListTableView.editing = !self.sessionListTableView.editing;
	if (self.sessionListTableView.editing)
	{
		self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"STR_FINISH", "完成");
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	else
	{
		self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"STR_EDIT", "编辑");
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}
    
}

// 打开选择好友页面
- (void)touchCreateChatButton
{
    SelectFriendsViewController *selectFriendCtr = [[SelectFriendsViewController alloc] init];
    selectFriendCtr.friendsListType = FriendsListTypeCreatChat;
    // Push进入消息详情页面之前将TabBar隐藏，并且设置选择消息Tab索引
    selectFriendCtr.hidesBottomBarWhenPushed = YES;
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    [self.navigationController pushViewController:selectFriendCtr animated: NO];
}


#pragma mark -
#pragma mark Custom Methods

// 加载所有的会话列表
- (void)loadAllChatSessionList
{
    [self.allSessionArray removeAllObjects];
    
    // 获取所有的会话信息数据
    NSArray *chatSessionList = [RKCloudChatMessageManager queryAllChats];
    if (chatSessionList && [chatSessionList count] > 0) {
        [self.allSessionArray addObjectsFromArray:chatSessionList];
    }
    
    // 刷新tableview
    if (self.sessionListTableView)
    {
        [self.sessionListTableView reloadData];
    }
    // Jacky.Chen 2016.02.02,当没有会话数据时禁用leftBarButtonItem
    [self resetLeftBarButtonItemState];
}

// 创建一个新的消息聊天窗口页面
- (void)createNewChatView:(RKCloudChatBaseChat *)chatSession
{
    if (chatSession == nil || chatSession.sessionID == nil)
    {
        NSLog(@"DEMO-SESSION-ERROR: createNewChatView: chatSession.sessionID = %@", chatSession.sessionID);
        return;
    }
    
    NSLog(@"DEMO-SESSION: createNewChatView: chatSession.sessionID = %@", chatSession.sessionID);
    
    // 聊天会话页面
    RKChatSessionViewController *vwcMessageSession = [[RKChatSessionViewController alloc]
                                                      initWithNibName:@"RKChatSessionViewController" bundle:nil];
    vwcMessageSession.parentChatSessionListViewController = self;
    vwcMessageSession.currentSessionObject = chatSession;
    
    // Push进入消息详情页面之前将TabBar隐藏，并且设置选择消息Tab索引
    vwcMessageSession.hidesBottomBarWhenPushed = YES;
    
    self.messageSessionViewController = vwcMessageSession;
    
    // 进入详细会话页面
    [self.navigationController pushViewController:vwcMessageSession animated:YES];
}

// 加载所有的会话列表
- (void)resetLeftBarButtonItemState
{
    if (self.allSessionArray && self.allSessionArray.count > 0) {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    
}
// 搜索指定的消息会话列表
- (void)searchMMSByKeyWord:(NSString *)keyWord
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    if (keyWord == nil)
    {
        return;
    }
    else if ([keyWord length] <= 0)
    {
        // 通知界面刷新
        [self.sessionListTableView reloadData];
        return;
    }
    
    NSMutableDictionary *searchMutDic = [[NSMutableDictionary alloc] init];
    
    // 获取消息会话列表
    NSArray * arrayChatSession= [[NSArray alloc] initWithArray:self.allSessionArray];
    RKCloudChatBaseChat * sessionObject = nil;
    
    for (int i = 0; i < [arrayChatSession count]; i++)
    {
        sessionObject = [arrayChatSession objectAtIndex:i];
        if (sessionObject.sessionShowName && [[sessionObject.sessionShowName uppercaseString] rangeOfString:[keyWord uppercaseString]].length > 0)
        {
            [searchMutDic setObject:sessionObject forKey:sessionObject.sessionID];
        }
    }
    self.searchSessionObjectDict = searchMutDic;
    
    // 通知界面刷新
    [self.sessionListTableView reloadData];
}


// 如果在消息页面中,删除了所有的消息,则把与之对应的会话列表也删除
- (void)removeMmsRowTable:(RKCloudChatBaseChat *)sessionObject
{
	NSLog(@"MMS: RKChatSessionListViewController -> removeMmsRowTable selectKey = %@", sessionObject);
	if (sessionObject == nil)
	{
		NSLog(@"ERROR: RKChatSessionListViewController -> removeMmsRowTable selectKey = %@ return", sessionObject);
		return;
	}
	
	// 从搜索列表中删除
	[self.searchSessionObjectDict removeObjectForKey:sessionObject.sessionID];
    
	// 从消息会话列表数据中删除
    if ([self.allSessionArray respondsToSelector:@selector(removeObject:)]) {
        [self.allSessionArray removeObject:sessionObject];
    }
    
	// 通知界面刷新
	[self.sessionListTableView reloadData];
}

// 删除消息会话列表记录的一行中的所有记录包含这个会话
- (void)deleteMessageSessionListRecordForRow:(NSInteger)rowSession
{
    // 获取短信列表的所有key值
    NSArray * arraySessionObject = nil;
    if (self.searchBarItem.text && [self.searchBarItem.text length] > 0)
    {
        arraySessionObject = [[NSArray alloc] initWithArray:[self.searchSessionObjectDict allKeys]];
    }
    else
    {
        arraySessionObject = [[NSArray alloc] initWithArray:self.allSessionArray];
    }
    
    RKCloudChatBaseChat *sessionObject = nil;
    if (arraySessionObject && [arraySessionObject count] > rowSession)
    {
        // 获取选择的sessionObject值
        sessionObject = [arraySessionObject objectAtIndex:rowSession];
        if (sessionObject.sessionID)
        {
            // 删除DB中的当前选择的会话的所有的消息记录
            [RKCloudChatMessageManager deleteAllMsgsInChat:sessionObject.sessionID withFile:YES];
         
            // 删除当前选择的会话
            [RKCloudChatMessageManager deleteChat:sessionObject.sessionID withFile:YES];
        }
        
        // 删除与该列表相关联的信息
        [self removeMmsRowTable:sessionObject];
        
        // 若删除了所有的消息，需要改变编辑按钮的状态，并恢复tableview的editing状态
        if ([self.allSessionArray count] == 0)
        {
            self.isSlideDelete = YES;
        }
    }
    
    // Gray.Wang:2014.08.01: 因iOS7系统存在滑动Cell，点击“删除”按钮后，不响应didEndEditingRowAtIndexPath代理方法
    // 所以在此判断下，如果是iOS7之后的系统在此进行恢复导航栏上的操作按钮状态。
    if (self.isSlideDelete == YES) {
        
        // 快速删除完成后改变TableView的编辑状态，改变编辑按钮状态
        [self.sessionListTableView setEditing:!self.sessionListTableView.editing animated:YES];
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"STR_EDIT", "编辑");
        self.navigationItem.rightBarButtonItem.enabled = YES;
        // Jacky.Chen 2016.02.02,当没有会话数据时禁用leftBarButtonItem
        [self resetLeftBarButtonItemState];
        
        self.isSlideDelete = NO;
    }
}

// 处理是否显示新消息提醒
- (void)dealPromptViewForNewMessage:(RKCloudChatBaseMessage *)msgObj
                     withForSession:(RKCloudChatBaseChat *)chatObj
{
    // 状态栏上显示提示消息
    if (chatObj.isRemindStatus)
    {
        NSString *userName = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:msgObj.senderName];
        NSString *describeMessage = [ChatManager getMessageDescription:msgObj];
        NSString *promptString = [NSString stringWithFormat:@"%@: %@", userName, describeMessage];
        
        [self performSelectorOnMainThread:@selector(delayShowReceivedMessageText:)
                               withObject:promptString
                            waitUntilDone:NO];
    }
}

// 显示状态栏提示信息
- (void)delayShowReceivedMessageText:(NSString *)promptString
{
    [ToolsFunction showStatusBarPrompt:promptString
                          withDuration:TIME_SHOW_MEAASGE
                                  type:NORMAL_PROMPT];
}


#pragma mark -
#pragma mark UISearchBar Delegate

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	if (searchBar)
	{
		[searchBar resignFirstResponder];
		searchBar.text = @"";
		[self searchMMSByKeyWord:@""];
	}
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    // 进入到搜索定制页面
    RKMessageSearchViewController *searchViewController = [[RKMessageSearchViewController alloc] initWithNibName:@"RKMessageSearchViewController" bundle:nil];
    
    RKNavigationController *navChatSessionListViewController = [[RKNavigationController alloc] initWithRootViewController:searchViewController];
    
    [self presentViewController:navChatSessionListViewController animated:YES completion:nil];
    
    return NO;
}

// When the search text changes, update the array
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
//	[self searchMMSByKeyWord:searchText];
    
}

// When the search button (i.e. "Done") is clicked, hide the keyboard
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	if (searchBar)
	{
		[searchBar resignFirstResponder];
	}
}


#pragma mark -
#pragma mark UIScrollViewDelegate

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	// 滚动tabview页面时将搜索键盘收起。
	if (self.searchBarItem && [self.searchBarItem isFirstResponder])
	{
        [self.searchBarItem resignFirstResponder];
	}
}


#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([string isEqualToString:@""] == NO)
    {
        //将要替换的后的新字串
        NSMutableString *newValue = [textField.text mutableCopy];
        [newValue replaceCharactersInRange:range withString:string];
        
        //对新字串长度进行判断 超过MAX_GROUP_TITLE_LENGTH长度则不进行字符替换
        if (newValue.length > MAX_GROUP_TITLE_LENGTH)
        {
            return NO;
        }
    }
    
	return YES;
}

- (void)willPresentAlertView:(UIAlertView *)alertView
{
	// 设置文本框为第一响应
	UITextField *titleField = (UITextField*)[alertView viewWithTag:CHAT_TITLE_TEXTFIELD];
	[titleField becomeFirstResponder];
}


#pragma mark -
#pragma mark UISearchDisplayDelegate

// called when table is shown/hidden
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    NSLog(@"willShowSearchResultsTableView");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView{
    NSLog(@"didShowSearchResultsTableView");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView{
    NSLog(@"willHideSearchResultsTableView");
    [self searchMMSByKeyWord:controller.searchBar.text];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView{
    NSLog(@"didHideSearchResultsTableView");
    [self searchMMSByKeyWord:controller.searchBar.text];
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatSession

/**
 * @brief 代理方法:更新整个会话列表数据
 *
 * @param chatSessionList 所有聊天会话session
 *
 * @return
 */
- (void)didUpdateChatSessionList:(NSArray *)chatSessionList
{
    NSLog(@"CHAT-LIST-DELEGATE: didUpdateChatSessionList: chatSessionList count = %lu", (unsigned long)[chatSessionList count]);
    
    [self.allSessionArray removeAllObjects];
    
    // 重新获取会话记录
    if (chatSessionList && [chatSessionList count] > 0) {
        [self.allSessionArray addObjectsFromArray:chatSessionList];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 刷新tableview
        if (self.sessionListTableView)
        {
            [self.sessionListTableView reloadData];
            
            // Jacky.Chen 2016.02.26,更新leftBarButtonItem状态，解决进入会话收到新消息leftBarButtonItem不能用的问题
            [self resetLeftBarButtonItemState];

        }
    });
}

/**
 * @brief 代理方法: 更新指定的会话信息
 *
 * @param chatSession 此聊天对象的session数据
 *
 * @return
 */
- (void)didUpdateChatSessionInfo:(RKCloudChatBaseChat *)chatSession
{
    NSLog(@"CHAT-LIST-DELEGATE: didUpdateChatSessionInfo: sessionID = %@", chatSession.sessionID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (chatSession == nil) {
            return;
        }
        
        if (self.messageSessionViewController) {
            [self.messageSessionViewController didUpdateChatSessionInfo:chatSession];
        }
        
        // 判断是否存在，如果存在更新列表
        BOOL isExist = NO;
        RKCloudChatBaseChat *sessionObject = nil;
        
        for (int i = 0; i < [self.allSessionArray count]; i++) {
            sessionObject = (RKCloudChatBaseChat *)[self.allSessionArray objectAtIndex:i];
            if ([chatSession.sessionID isEqualToString:sessionObject.sessionID]) {
                isExist = YES;
                break;
            }
        }
        
        // 重新获取会话记录
        if (isExist) {
            [self.allSessionArray removeObject:sessionObject];
            [self.allSessionArray insertObject:chatSession atIndex:0];
        }
        else {
            [self.allSessionArray insertObject:chatSession atIndex:0];
        }
        
        // 刷新tableview
        if (self.sessionListTableView)
        {
            [self.sessionListTableView reloadData];
        }
    });
}

/**
 * @brief 代理方法: 显示一个聊天会话页面
 *
 * @param chatSession 此聊天对象的session数据
 *
 * @return
 */
- (void)didShowChatViewWithChatSession:(RKCloudChatBaseChat *)chatSession
{
    NSLog(@"CHAT-LIST-DELEGATE: didShowChatViewWithChatSession: sessionID = %@", chatSession.sessionID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 选择会话tabbar
        AppDelegate *appDelegate = [AppDelegate appDelegate];
        appDelegate.mainTabController.selectedIndex = 0;
        
        // 跳转到RKChatSessionViewController页面，创建聊天会话
        [self createNewChatView:chatSession];
    });
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatReceivedMsg

/**
 * @brief 代理方法: 消息内容发生变化之后的回调
 *
 * @param messageID 消息的唯一编号
 *
 * @return
 */
- (void)didMsgHasChanged:(RKCloudChatBaseMessage *)messageObject
{
    NSLog(@"CHAT-LIST-DELEGATE: didMsgHasChanged: messageID = %@, sessionID = %@", messageObject.messageID, messageObject.sessionID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.messageSessionViewController && [self.messageSessionViewController.currentSessionObject.sessionID isEqualToString:messageObject.sessionID])
        {
            [self.messageSessionViewController didMsgHasChanged:messageObject];
        }
    });
}

/**
 * @brief 代理方法: 收到单条消息之后的回调
 *
 * @param msgObj   RKCloudChatBaseMessage对象 收到的消息
 * @param chatObj  RKCloudChatBaseChat对象 消息所属的会话信息
 *
 * @return
 */
- (void)didReceivedMsg:(RKCloudChatBaseMessage *)msgObj withForSession:(RKCloudChatBaseChat *)chatObj
{
    NSLog(@"CHAT-LIST-DELEGATE: didReceivedMsg: messageID = %@, sessionID = %@", msgObj.messageID, chatObj.sessionID);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.messageSessionViewController &&
            [self.messageSessionViewController.currentSessionObject.sessionID isEqualToString:chatObj.sessionID])
        {
            [self.messageSessionViewController didReceivedMsg:msgObj withForSession:chatObj];
        }
        else if (msgObj.msgDirection == MESSAGE_RECEIVE &&
                 msgObj.messageStatus == MESSAGE_STATE_RECEIVE_RECEIVED) {
            // 处理是否显示新消息提醒
            [self dealPromptViewForNewMessage:msgObj withForSession:chatObj];
        }
    });
}

/**
 * @brief 代理方法: 收到多条消息之后的回调
 * @attention 收到的消息按照不同的会话进行划分，并且每个会话中的消息按照产生的时间升序排列
 * @param dictChatToMessages 字典类型，key为RKCloudChatBaseChat对象，值为RKCloudChatBaseMessage对象数组
 *
 * @return
 */
- (void)didReceivedMsgs:(NSArray *)arrayChatMessages
{
    NSLog(@"CHAT-LIST-DELEGATE: didReceivedMsgs: arrayChatMessages count = %lu", (unsigned long)[arrayChatMessages count]);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (arrayChatMessages == nil || [arrayChatMessages count] == 0) {
            return;
        }
        
        NSMutableArray *arrayBatchMessageOjbect = [NSMutableArray array];
        
        for (RKCloudChatBaseMessage *messageObject in arrayChatMessages)
        {
            if (self.messageSessionViewController && [messageObject.sessionID isEqualToString:self.messageSessionViewController.currentSessionObject.sessionID])
            {
                [arrayBatchMessageOjbect addObject:messageObject];
            }
            
            // 获取单个会话的基本信息，不包含会话的最后一条消息对象
            RKCloudChatBaseChat *baseChatObject = [RKCloudChatMessageManager queryChat:messageObject.sessionID];
            
            // 处理是否显示新消息提醒
            [self dealPromptViewForNewMessage:messageObject withForSession:baseChatObject];
        }
        
        if ([arrayBatchMessageOjbect count] > 0)
        {
            [self.messageSessionViewController didReceivedMessageArray:arrayBatchMessageOjbect];
        }
    });
}

/**
 * @brief 代理方法: 改变会话中的未读消息总条数
 *
 * @param totalCount 未读消息总条数
 *
 * @return
 */
- (void)didUnReadMessageTotal:(int)totalCount
{
    NSLog(@"CHAT-LIST-DELEGATE: didUnReadMessageTotal: totalCount = %d", totalCount);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新tabBar的badgeValue
        if (totalCount > 0 ){
            self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", totalCount];
        }
        else {
            self.tabBarItem.badgeValue = nil;
        }
    });
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatGroup
// 云视互动即时通信对于群的回调接口

/**
 * @brief 代理方法: 单个群信息有变化
 *
 * @param groupId NSString 群ID
 *
 * @return
 */
- (void)didGroupInfoChanged:(NSString *)groupId
{
    NSLog(@"CHAT-LIST-DELEGATE: didGroupInfoChanged: groupId = %@", groupId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.messageSessionViewController == nil || [self.messageSessionViewController.currentSessionObject.sessionID isEqualToString:groupId] == NO) {
            return;
        }
        
        [self.messageSessionViewController didGroupInfoChanged:groupId];
    });
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
    NSLog(@"CHAT-LIST-DELEGATE: didGroupRemoved: groupId = %@, removeType = %lu", groupId, (unsigned long)removeType);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.messageSessionViewController == nil || [self.messageSessionViewController.currentSessionObject.sessionID isEqualToString:groupId] == NO) {
            return;
        }
        
        [self.messageSessionViewController didGroupRemoved:groupId withRemoveType:removeType];
    });
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
    NSLog(@"CHAT-LIST-DELEGATE: didGroupUsersChanged: groupId = %@", groupId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.messageSessionViewController == nil || [self.messageSessionViewController.currentSessionObject.sessionID isEqualToString:groupId] == NO) {
            return;
        }
        
        [self.messageSessionViewController didGroupUsersChanged:groupId];
    });
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatContact
// 云视互动即时通信中调用应用层的通讯录使用的接口

/**
 * @brief 代理方法: 根据云视互动中分配的账号获取应用AP通讯录中的联系人头像信息
 *
 * @param userName 用户在云视互动中分配的账号
 *
 * @return userName头像路径字符串
 */
- (NSString *)getContactAvatarPhotoPath:(NSString *)userName
{
    return nil;
}

/**
 * @brief 代理方法: 批量获取应用APP通讯录中指定用户的头像信息
 *
 * @param arrayUserName 批量的用户在云视互动中分配的账号数组
 *
 * @return NSDictionary userName对应的头像路径字符串
 */
- (NSDictionary *)getContactsAvatarPhotoPath:(NSArray *)arrayUserName
{
    return nil;
}

/**
 * @brief 代理方法: 根据云视互动中分配的账号获取应用APP通讯录中的联系人昵称
 *
 * @param userName 用户在云视互动中分配的账号
 *
 * @return uuserName对应的昵称字符串
 */
- (NSString *)getContactNicknameString:(NSString *)userName
{
    return nil;
}

/**
 * @brief 代理方法: 批量获取应用APP通讯录中指定的用户昵称
 *
 * @param arrayUserName 批量的用户在云视互动中分配的账号数组
 *
 * @return NSDictionary userName对应的昵称字符串
 */
- (NSDictionary *)getContactsNicknameString:(NSArray *)arrayUserName
{
    return nil;
}



#pragma mark - Notification

- (void)receivedUpdateUserInfoNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 刷新tableview
        if (self.sessionListTableView)
        {
            [self.sessionListTableView reloadData];
        }
    });
}

// 下载图片成功通知方法
- (void)downloadAvatarSuccessNotification:(NSNotification *)notification
{
    if (notification == nil || notification.object == nil) {
        return;
    }
    
    if ([self.allSessionArray count] == 0)
    {
        return;
    }

    PersonalInfos *personalInfo = notification.object;
    
    for (RKCloudChatBaseChat *sessionObject in self.allSessionArray)
    {
        if ([sessionObject.sessionShowName isEqualToString:personalInfo.userAccount])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新tableview
                if (self.sessionListTableView)
                {
                    [self.sessionListTableView reloadData];
                }
            });
            
            break;
        }
    }
}

@end
