//
//  SelectFriendsViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SelectFriendsViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "RKTableViewCell.h"
#import "AppDelegate.h"
#import "ContactManager.h"
#import "DatabaseManager+FriendTable.h"
#import "RKCloudUIContactTableCell.h"
#import "ContactHorizontalList.h"
#import "ContactListItem.h"
#import "ContactManager.h"

@interface SelectFriendsViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *selectFriendsTableView;
@property (nonatomic, strong) NSMutableArray *allFriendTableArray;  // 所有好友的FriendTable数组
@property (nonatomic, strong) NSMutableArray *selectFriendTableArray; // 选择的FriendTable数组
@property (nonatomic) AppDelegate *appDelegate;

@property (nonatomic, strong) NSMutableArray *allIndexArray;
@property (nonatomic, strong) NSMutableArray *allContactSectionArray;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *allSectionTitlesArray;

@end

@implementation SelectFriendsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.selectFriendTableArray = [NSMutableArray array];
        self.appDelegate = [AppDelegate appDelegate];
        self.title = NSLocalizedString(@"STR_SELECT_FRIENDS", @"选择好友");
        // 获取所有的联系人
        NSArray *arrayAllFriendTable = [NSMutableArray arrayWithArray:[self.appDelegate.databaseManager getAllFriendTable]];
        
        self.allFriendTableArray = [NSMutableArray array];
        
        // 过滤空数据
        for (FriendTable *friendTable in arrayAllFriendTable)
        {
            NSString *friendAccount = nil;
            if ([friendTable.friendAccount isKindOfClass:[NSNumber class]]) {
                NSLog(@"WARNING: SelectFriendsViewController - configCellInfoCell - friendTable.groupId First = %@", friendTable.groupId);
                friendAccount = [NSString stringWithFormat:@"%@", friendTable.friendAccount];
            } else {
                friendAccount = friendTable.friendAccount;
            }
            
            if (friendAccount != nil && ![friendAccount isEqualToString:self.appDelegate.userProfilesInfo.userAccount])
            {
                [self.allFriendTableArray addObject:friendTable];
            }
        }
    
        [self initSectionIndex];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNavigationBarButton];
    
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchCancelButton:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self addTableView];
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

#pragma mark - Section Method

- (void)touchCancelButton:(id)sender
{
    // 设置动画
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
    
    // 收回注册页面
    [self.navigationController popViewControllerAnimated:NO];
}

// 初始化排序的索引值
- (void)initSectionIndex
{
    NSLog(@"CONTACT: initSectionIndex");
    
    // 采用操作系统自身的排序方式
    UILocalizedIndexedCollation* collation = [UILocalizedIndexedCollation currentCollation];
    
    // 准备sectionTitles数组
    NSMutableArray* titlesArray = [[NSMutableArray alloc] initWithArray:[collation sectionTitles]];
    
    // 准备sectionIndexTitles数组
    NSMutableArray* indexsArray = [[NSMutableArray alloc] initWithArray:[collation sectionIndexTitles]];
    
    BOOL isHanTw = [[ToolsFunction getLocaliOSLanguage] isEqualToString: @"zh-Hant"];
    if (isHanTw)
    {
        // 针对ios7下，繁体的系统的索引不能够准确的定位，因此，title和索引的数组都使用sectionTitles数组初始化
        // 去掉繁体下的注音索引，即：ㄅ,ㄆ,ㄇ,ㄈ,ㄉ,ㄊ,ㄋ,ㄌ,ㄍ,ㄎ,ㄏ,ㄐ,ㄑ,ㄒ,ㄓ,ㄔ,ㄕ,ㄖ,ㄗ,ㄘ,ㄙ,ㄚ,ㄛ,ㄜ,ㄝ,ㄞ,ㄟ,ㄠ,ㄡ,ㄢ,ㄣ,ㄤ,ㄥ,ㄦ,ㄧ,ㄨ,ㄩ
        self.allSectionTitlesArray = titlesArray;
        // 如果是ios6之前的系统，则去掉“以上”
        NSString *indexTitleString = nil;
        NSString *indexString = nil;
        NSMutableArray *indexMutableArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [titlesArray count]; i++)
        {
            indexTitleString = [titlesArray objectAtIndex: i];
            NSRange range;
            if ([ToolsFunction getCurrentiOSMajorVersion] < 5)
            {
                range = [indexTitleString rangeOfString:@"劃"];
            }
            else
            {
                range = [indexTitleString rangeOfString:@"畫"];
            }
            
            if (range.length > 0)
            {
                indexString = [[NSString alloc] initWithFormat: @"%@", [indexTitleString substringToIndex:range.location]];
            }
            else
            {
                indexString = [[NSString alloc] initWithFormat: @"%@", indexTitleString];
            }
            [indexMutableArray addObject:indexString];
        }
        
        self.allIndexArray = indexMutableArray;
    }
    else
    {
        self.allSectionTitlesArray = titlesArray;
        self.allIndexArray = indexsArray;
    }
    
    // 添加搜索栏索引
//    [self.allIndexArray insertObject:UITableViewIndexSearch atIndex:0];
    
    NSInteger index;
    BOOL bSimpleZH = NO;
    
    // 准备section数组
    NSInteger sections_count = [self.allSectionTitlesArray count];
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSMutableArray* array = nil;
    for (int i = 0; i < sections_count; i++)
    {
        array = [[NSMutableArray alloc] init];
        [sections addObject:array];
    }
    
    // Magic: For simple chinese, use "ABC instead of 啊窝哦"
    bSimpleZH = [[ToolsFunction getLocaliOSLanguage] isEqualToString:@"zh-Hans"];
    // 按照关键字过滤对象
    for (int i = 0; i < [self.allFriendTableArray count]; i++)
    {
        FriendTable *friendTable = [self.allFriendTableArray objectAtIndex: i];
        
        friendTable.highGradeName = [self.appDelegate.contactManager displayFriendHighGradeName:friendTable.friendAccount];
        
        // 默认按用户名称排序
        index = [collation sectionForObject:friendTable collationStringSelector:@selector(highGradeName)];
        
        if(sections_count == 24 && bSimpleZH && (index>=23 && index<=46)) {
            index -= 23;  // For simple chinese, merge english and chinese section with same letter
        }
        
        if (index < [sections count])
        {
            [[sections objectAtIndex:index] addObject:friendTable];
        }
    }
    
    // Now that all the data's in place, each section array needs to be sorted.
    for (int j = (int)sections_count-1; j>=0; j--)
    {
        NSMutableArray* section = [sections objectAtIndex:j];
        // 因iOS5下分组中排序非常耗时，所以不在iOS5上进行Section内部排序
        if ([section count]!= 0)
        {
            // If the table view or its contents were editable, you would make a mutable copy here.
            NSArray *sortedSection = [collation sortedArrayFromArray:section collationStringSelector:@selector(highGradeName)];
            // Replace the existing array with the sorted array.
            [sections replaceObjectAtIndex:j withObject:sortedSection];
        }
    }
    
    //self.allContactsArray = allContacts;
    self.allContactSectionArray = sections;
    self.sectionArray = self.allContactSectionArray;
}


#pragma mark - Custom Method

// 判断当前的friend是否是群聊中的成员
- (BOOL)identifyingFriendTableIsChatMembers:(FriendTable *)friendTable
{
    BOOL isChatMember = NO;
    if (self.friendsListType == FriendsListTypeChatAddFriend)
    {
        for (int i = 0; i<self.groupChatMembersArray.count; i++)
        {
            NSString *account = [self.groupChatMembersArray objectAtIndex:i];
            
            NSString *friendAccount = nil;
            if ([friendTable.friendAccount isKindOfClass:[NSNumber class]]) {
                NSLog(@"WARNING: SelectFriendsViewController - configCellInfoCell - friendTable.groupId Second = %@", friendTable.groupId);
                friendAccount = [NSString stringWithFormat:@"%@", friendTable.friendAccount];
            } else {
                friendAccount = friendTable.friendAccount;
            }
            
            if ([friendAccount isEqualToString:account])
            {
                isChatMember = YES;
                break;
            }
        }
    }
    return isChatMember;
}

// 页面中控件的添加与设置
- (void)addTableView
{
    // 添加contactTableView
    CGRect tableviewFrame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-STATU_NAVIGATIONBAR_HEIGHT);
    self.selectFriendsTableView = [[UITableView alloc]initWithFrame:tableviewFrame style:UITableViewStylePlain];
    self.selectFriendsTableView.delegate = self;
    self.selectFriendsTableView.dataSource = self;
    self.selectFriendsTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.selectFriendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.selectFriendsTableView];
}

- (void)initNavigationBarButton
{
    if (self.friendsListType != FriendsListTypeForward) {
        // 左边按钮
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_OK", @"")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(touchSelectFriendMethod:)];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    if ([self.selectFriendTableArray count] == 0)
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

#pragma mark - Friend Groups Opration Method

// 响应 选中成员并在底部显示方法
-(void)touchModifyMemberButton
{
    // 如果没有选择的成员对象，删除底部view
    UIView *contactHorizontalView = (UIView *)[self.view viewWithTag:1001];
    if (contactHorizontalView) {
        [contactHorizontalView removeFromSuperview];
    }
    
    // 调整tableview位置
    if ([self.selectFriendTableArray count] == 0)
    {
        self.selectFriendsTableView.frame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-70);
    }
    else {
        self.selectFriendsTableView.frame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-70-70);
    }
    
    // 构建底部选中成员view
    NSMutableArray *contactHorizontalArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < [self.selectFriendTableArray count]; i++) {
        FriendTable *friendTable = [self.selectFriendTableArray objectAtIndex:i];
        NSString *chatName = friendTable.friendAccount;
        ContactListItem *item1 = [[ContactListItem alloc] initWithFrame:CGRectZero image:[ToolsFunction getFriendAvatarWithFriendAccount:chatName andIsThumbnail:YES] text:chatName];
        [contactHorizontalArray addObject:item1];
    }
    
    if (contactHorizontalArray.count > 0) {
        // 显示被选中的成员图标
        ContactHorizontalList *contactHorizontalList = [[ContactHorizontalList alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, UISCREEN_BOUNDS_SIZE.width, 80) title:[NSString stringWithFormat:@"%lu位成员", (unsigned long)self.selectFriendTableArray.count] items:contactHorizontalArray];
        contactHorizontalList.parent = self;
        contactHorizontalList.tag = 1001;
        
        // 自动滚动到最右部
        [contactHorizontalList.scrollView scrollRectToVisible:CGRectMake(0, 20, contactHorizontalList.scrollView.contentSize.width, 60) animated:YES];
        // 增加新页面
        [self.view addSubview: contactHorizontalList];
    }
}

// 响应 底部选中成员方法
- (void)touchDeleteMemberButton:(id)sender
{
    // 删除底部显示
    ContactListItem *item = (ContactListItem *)sender;
    NSString *chatName = item.imageTitle;
    
    // 找到对应的FriendTable并删除
    for (int i =0; i <= [self.selectFriendTableArray count]; i++) {
        FriendTable *friendTable = [self.selectFriendTableArray objectAtIndex:i];
        
        NSString *friendAccount = nil;
        if ([friendTable.friendAccount isKindOfClass:[NSNumber class]]) {
            NSLog(@"WARNING: SelectFriendsViewController - configCellInfoCell - friendTable.groupId Third = %@", friendTable.groupId);
            friendAccount = [NSString stringWithFormat:@"%@", friendTable.friendAccount];
        } else {
            friendAccount = friendTable.friendAccount;
        }
        
        if ([friendAccount isEqualToString:chatName]) {
            [self.selectFriendTableArray removeObject:friendTable];
            
            // 找到对应的数据之后 不再执行循环 直接跳出
            break;
        }
    }
    
    [self.selectFriendsTableView reloadData];
    
    // 选中成员并在底部显示方法
    [self touchModifyMemberButton];
}

// 好友分组操作
- (void)oprationFriendListMethod
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    // 提交服务器搜索
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *friendArray = [NSMutableArray array];
        for (FriendTable *friendTable in self.selectFriendTableArray) {
            [friendArray addObject:friendTable.friendAccount];
        }
        
        NSString *accountsStr = [friendArray componentsJoinedByString:@","];
        BOOL isSuccessOpration = [self.appDelegate.contactManager asynOperationGroupMembers:accountsStr withGroupId:self.groupId];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIAlertView hideWaitingMaskView];
            
            if (isSuccessOpration) {
                
                // 修改数据库中FriendTable对应groupid
                for (FriendTable *friendTable in self.selectFriendTableArray) {
                    friendTable.groupId = self.groupId;
                    [self.appDelegate.databaseManager saveFriendTable:friendTable];
                }
                
                if ([self.delegate respondsToSelector:@selector(selectFriendsSuccessDelegateMethod)]) {
                    [self.delegate selectFriendsSuccessDelegateMethod];
                }
                
                // 设置动画
                AppDelegate *appDelegate = [AppDelegate appDelegate];
                [ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
                [self.navigationController popViewControllerAnimated:NO];
            }
        });
    });
}

#pragma mark - Creat Chat Method

// 根据选择的friendTable获取friendAccount
- (NSArray *)friendAccountArray
{
    NSMutableArray *friendArray = [NSMutableArray array];
    for (int i = 0; i < [self.selectFriendTableArray count]; i++) {
        FriendTable *friendTable = [self.selectFriendTableArray objectAtIndex:i];
        
        [friendArray addObject:friendTable.friendAccount];
    }
    return friendArray;
}

// 根据选择的好友创建消息会话
- (void)creatChat
{
    if (self.selectFriendTableArray.count > 1) // 群聊
    {
        // 弹出创建群聊名称的AlertView
        // 显示一个创建新的群聊会话的弹出提示框
        [UIAlertView showCreateNewGroupChatAlert:self];
    }
    else // 创建单聊
    {
        // 新建一个聊天会话,如果会话存在，打开聊天页面
        
        FriendTable *friendTable = [self.selectFriendTableArray objectAtIndex:0];
        [SingleChat buildSingleChat:friendTable.friendAccount
                          onSuccess:^{
                              // 视图返回到根视图
                              // [self.navigationController popToRootViewControllerAnimated:NO];
                              
                              AppDelegate *appDelegate = [AppDelegate appDelegate];
                              appDelegate.mainTabController.selectedIndex = 0;
                              
                              RKCloudChatBaseChat *sessionObject = [RKCloudChatMessageManager queryChat: friendTable.friendAccount];
                              // 新建一个聊天会话,如果会话存在，打开聊天页面
                              [appDelegate.rkChatSessionListViewController createNewChatView:sessionObject];
                              
                          }
                           onFailed:^(int errorCode) {
                               
                           }];
    }
}

- (void)touchSelectFriendMethod:(id)sender
{
    if (self.selectFriendTableArray.count == 0) {
        return;
    }
    
    switch (self.friendsListType) {
        case FriendsListTypeFriendGroupsOpration:  // 好友分组操作
        {
            [self oprationFriendListMethod];
        }
            break;
        case FriendsListTypeCreatChat: // 创建会话
        {
            [self creatChat];
        }
            break;
        case FriendsListTypeOnlyCreatGroupChat: // 创建会话
        {
            if (self.selectFriendTableArray.count < 2) {
                // 少于2人则提示无法不覅和建群的条件
                [UIAlertView showAutoHidePromptView:@"建群失败，选择成员个数至少需要2人" background:nil showTime:1.5];
                return;
            }
            
            // 显示一个创建新的群聊会话的弹出提示框
            [UIAlertView showCreateNewGroupChatAlert:self];
        }
            break;
        case FriendsListTypeChatAddFriend: // 邀请好友加入会话
        {
            if ([self.chatDelegate respondsToSelector:@selector(selectChatFriendsWithAccout:)])
            {
                // 邀请对象聊天代理方法
                [self.chatDelegate selectChatFriendsWithAccout:[self friendAccountArray]];
                
                // 设置动画
                AppDelegate *appDelegate = [AppDelegate appDelegate];
                [ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
                [self.navigationController popViewControllerAnimated:NO];
            }
        }
            break;
        case FriendsListTypeForward: // 转发消息
        {
            
        }
            break;
        default:
            break;
    }
    
    
}


#pragma mark -  UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectiongNum = [self.sectionArray count];

    return sectiongNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 显示搜索的结果
//    if (isSearchContact)
//    {
//        return [self.searchContactArray count];
//    }
    
    if (section >= [self.sectionArray count])
    {
        // 语言不一样，索引就不一样和为了设置联系人的个数
        return 0;
    }
    
    // section-1 说明：
    //table第一个section添加了分组项 其他分组数据从sectionArray和allSectionTitlesArray中取
    return [[self.sectionArray objectAtIndex: (section)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKCloudUIContactTableCell *friendInfoTableViewCell = [RKCloudUIContactTableCell creatCellWithTableView:tableView style:UITableViewCellStyleDefault reuseIdentifier:@"FriendInfoTableViewCell" fromType:Cell_From_Type_Select_Contact];
    
    friendInfoTableViewCell.textLabel.font = FONT_TEXT_SIZE_16;
    
    [self configCellInfoCell:friendInfoTableViewCell withIndexPath:indexPath];
    
    return friendInfoTableViewCell;
}

- (void)configCellInfoCell:(RKCloudUIContactTableCell *)friendInfoTableViewCell withIndexPath:(NSIndexPath *)indexPath
{
    if ([self.sectionArray count] == 0) {
        return;
    }
    
    NSArray *friendArray = [self.sectionArray objectAtIndex:indexPath.section];
    if ([friendArray count] == 0) {
        return;
    }
    
    // 设置cell的线条显示模式
    if ([friendArray count] == 1) // 单个好友
    {
        friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Single;
    }
    else { // 多个好友
        if (indexPath.row == 0) {
            friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Top;
        }
        else if(indexPath.row == (friendArray.count - 1))
        {
            friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Bottom;
        }
        else
        {
            friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Middle;
        }
    }
    
    [friendInfoTableViewCell setNeedsDisplay];
    
    FriendTable *friendTable = [friendArray objectAtIndex:indexPath.row];
    if (friendTable == nil) {
        return;
    }
    
    [friendInfoTableViewCell setLabelText:friendTable.highGradeName];
    [friendInfoTableViewCell setCellAvatarImageWithFriendAccount:friendTable.friendAccount];
    
    switch (self.friendsListType) {
        case FriendsListTypeForward:  // 转发消息
        {
            friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            [friendInfoTableViewCell setCheckedImageHide:YES];
        }
            break;
            
        default:
        {
            // 设置选择属性
            NSString *friendGroupId = [NSString stringWithFormat:@"%@", friendTable.groupId];
            
            // 设置联系人是否已经选中
            if ([friendGroupId isEqualToString:self.groupId] ||
                [self identifyingFriendTableIsChatMembers:friendTable]) {
                [friendInfoTableViewCell setChecked:YES];
                [friendInfoTableViewCell setCheckedImageDisable:YES];
                friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else if ([self.selectFriendTableArray containsObject:friendTable]) {
                [friendInfoTableViewCell setChecked:YES];
                friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
            else
            {
                [friendInfoTableViewCell setChecked:NO];
                friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }
            break;
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_SELECT_CONTACT_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSArray *friendArray = [self.sectionArray objectAtIndex:indexPath.section];
    if (friendArray.count == 0) {
        return;
    }
    
    // 获取当前的FriendTable
    FriendTable *friendTable = [friendArray objectAtIndex:indexPath.row];
    
    switch (self.friendsListType) {
        case FriendsListTypeFriendGroupsOpration:  // 好友分组操作
        {
            NSString *friendGroupId = nil;
            if ([friendTable.groupId isKindOfClass:[NSNumber class]]) {
                NSLog(@"WARNING: SelectFriendsViewController - configCellInfoCell - friendTable.groupId Fivth = %@", friendTable.groupId);
                friendGroupId = [NSString stringWithFormat:@"%@", friendTable.groupId];
            } else {
                friendGroupId = friendTable.groupId;
            }
            
            if ([friendGroupId isEqualToString:self.groupId])  // 已存在群组中则不做处理
            {
                return;
            }
        }
            break;
            
        case FriendsListTypeCreatChat:  // 创建会话操作
        case FriendsListTypeChatAddFriend:  // 会话中添加联系人操作
        {
            if ([self identifyingFriendTableIsChatMembers:friendTable])  // 点击已存在的好友不做处理
            {
                return;
            }
        }
            break;
            
        case FriendsListTypeForward:  // 转发消息操作
        {
            // 转发消息
            [self.selectFriendTableArray addObject:friendTable];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:@"确定转发消息"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"取消")
                                                  otherButtonTitles:NSLocalizedString(@"STR_OK", @"确定"), nil];
            alert.tag = ALERT_FORWARD_MESSAGE_TAG;
            [alert show];
            
            return;
        }
            break;
        default:
            break;
    }
    
    if ([self.selectFriendTableArray containsObject:friendTable])  // 添加到数组中
    {
        [self.selectFriendTableArray removeObject:friendTable];
    }
    else // 将选中的移除出数组
    {
        [self.selectFriendTableArray addObject:friendTable];
    }
    
    // 重置 确定按钮的状态
    [self initNavigationBarButton];
    
    // 布局底部已选的好友列表
    [self touchModifyMemberButton];
    
    [self.selectFriendsTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // 显示搜索的结果
    if (self.sectionArray == nil)
    {
        return 0;
    }
    
    if (title == UITableViewIndexSearch) {
//        [self.selectFriendsArray scrollRectToVisible:self.searchBarItem.frame animated:NO];
        return -1;
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
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.allIndexArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 减去搜索栏的位置的索引
    NSInteger index = section;
    
    if (section < 0 || index >= [self.allSectionTitlesArray count])
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
    
    // 得到每个分组的标题返回
    NSString *titleString = nil;
    if (index < [self.allSectionTitlesArray count])
    {
        titleString = [self.allSectionTitlesArray objectAtIndex:index];
    }
    return titleString;
}

#pragma mark - UIAlertViewDelegate

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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    switch (alertView.tag)
    {
        case ALERT_FORWARD_MESSAGE_TAG:
        {
            // 转发MMS消息记录方法
            FriendTable *friendTable = [self.selectFriendTableArray objectAtIndex:0];
            [RKCloudChatMessageManager forwardChatMsg:self.currentMessageObject.messageID
                                toUserNameOrSessionID:friendTable.friendAccount];
            
            // 设置动画
            AppDelegate *appDelegate = [AppDelegate appDelegate];
            [ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
            [self.navigationController popViewControllerAnimated:NO];
        }
            break;
            
        case ALERT_CREATE_NEW_GROUP_TAG:
        {
            UITextField *titleField = [alertView textFieldAtIndex:0];
            titleField.placeholder = NSLocalizedString(@"STR_TEMP_GROUP_NAME", "临时群");
            
            // 返回群组的名字
            NSString *groupName = titleField.placeholder;
            NSString *stringTrim = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            // 若用户在文本框内输入文字并且点击确定则使用用户创建的名字，否则为空
            if ([stringTrim length] > 0) {
                // 点击“确定”按钮
                groupName = titleField.text;
            }
            
            // 去除文本框
            [titleField resignFirstResponder];
            titleField.delegate = nil;
            
            [UIAlertView showWaitingMaskView:NSLocalizedString(@"PROMPT_CREATE_MULTI_CHAT", "正在创建群...")];
            
            // 调用接口（创建群聊会话操作,只有出现操作失败的时候才会有返回值，成功后直接跳转到RKChatSessionViewController）
            [RKCloudChatMessageManager applyGroup:[self friendAccountArray]
                                    withGroupName:groupName
                                        onSuccess:^(NSString *groupID) {
                                            [UIAlertView hideWaitingMaskView];
                                            
                                            // 视图返回到根视图
                                            [self.navigationController popToRootViewControllerAnimated:NO];
                                            
                                            /*
                                            AppDelegate *appDelegate = [AppDelegate appDelegate];
                                            appDelegate.mainTabController.selectedIndex = 0;
                                            
                                            // 新建一个聊天会话，如果会话存在，打开聊天页面
                                            GroupChat *groupChat = [[GroupChat alloc] initGroupChat:groupID];
                                            [appDelegate.rkChatSessionListViewController createNewChatView:groupChat];
                                             */
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
                                             /*[UIAlertView showSimpleAlert:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode]
                                                                withTitle:nil
                                                               withButton:NSLocalizedString(@"STR_OK",nil)
                                                                 toTarget:nil];*/
                                             
                                             [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"%@\n(%d)", errString, errorCode] background:nil showTime: 2];
                                         }];
        }
            break;
            
        default:
            break;
    }
}


@end
