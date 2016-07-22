//
//  SelectGroupMemberViewController.m
//  RongKeMessenger
//
//  Created by ivan on 16/7/18.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "SelectGroupMemberViewController.h"
#import "AppDelegate.h"
#import "RKCloudChatMessageManager.h"
#import "FriendTable.h"
#import "DatabaseManager.h"
#import "DatabaseManager+FriendTable.h"
#import "UserProfilesInfo.h"
#import "RKCloudUIContactTableCell.h"
#import "GroupChat.h"

@interface SelectGroupMemberViewController ()

@property (nonatomic, strong) IBOutlet UITableView *selectFriendsTableView;
@property (nonatomic, strong) NSMutableArray *allFriendTableArray;  // 所有好友的FriendTable数组
@property (nonatomic, strong) NSMutableArray *allIndexArray;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *allSectionTitlesArray;

@property (nonatomic) BOOL isAtAllGroupMember;

@end

@implementation SelectGroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSLocalizedString(@"STR_SELECT_FRIENDS", @"选择好友");
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 获取所有的联系人
    NSArray *groupMemberArray = [NSMutableArray arrayWithArray:[RKCloudChatMessageManager queryGroupUsers: self.groupId]];
    
    self.allFriendTableArray = [NSMutableArray array];
    
    // 过滤空数据
    FriendTable *friendTable = nil;
    for (NSString *accountString in groupMemberArray)
    {
        friendTable = [appDelegate.databaseManager getContactTableByFriendAccount: accountString];
        
        if (friendTable != nil && [accountString isEqualToString:appDelegate.userProfilesInfo.userAccount] == NO)
        {
            [self.allFriendTableArray addObject:friendTable];
        }
    }
    
    GroupChat *groupChat = (GroupChat *)[RKCloudChatMessageManager queryChat: self.groupId];
    if (groupChat.groupCreater && [groupChat.groupCreater isEqualToString: appDelegate.userProfilesInfo.userAccount])
    {
        self.isAtGroupMember = YES;
    }
    
    // 初始化好友数据
    [self initSectionIndex];

    // 初始化NavigationBar上的按钮
    [self initNavigationBarButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Instance methods

- (void)initNavigationBarButton
{
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchCancelButton:)];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
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
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    // 按照关键字过滤对象
    FriendTable *friendTable = nil;
    for (int i = 0; i < [self.allFriendTableArray count]; i++)
    {
        friendTable = [self.allFriendTableArray objectAtIndex: i];
        
        friendTable.highGradeName = [appDelegate.contactManager displayFriendHighGradeName:friendTable.friendAccount];
        
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
    
    self.sectionArray = sections;
}

#pragma mark -
#pragma mark UIButton Action methods

- (void)touchCancelButton:(id)sender
{
    // 设置动画
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
    
    // 收回注册页面
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -  UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectiongNum = [self.sectionArray count];
    if (self.isAtGroupMember) {
        sectiongNum++;
    }
    
    return sectiongNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && self.isAtGroupMember) {
        // 显示@所有成员
        return 1;
    }
    
    int indexSection = (int)section;
    if (self.isAtGroupMember)
    {
        indexSection = indexSection - 1;
    }
    if (indexSection >= [self.sectionArray count])
    {
        // 语言不一样，索引就不一样和为了设置联系人的个数
        return 0;
    }
    
    return [[self.sectionArray objectAtIndex: indexSection] count];
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
    
    // @所有成员
    if (self.isAtGroupMember && indexPath.section == 0) {
        [friendInfoTableViewCell setLabelText: @"所有成员"];
        return;
    }
    
    int indexSection = (int)indexPath.section;
    if (self.isAtGroupMember)
    {
        indexSection = indexSection - 1;
    }
    
    NSArray *friendArray = [self.sectionArray objectAtIndex:indexSection];
    if ([friendArray count] == 0) {
        return;
    }
    
    // 设置cell的线条显示模式
    if ([friendArray count] == 1) // 单个好友
    {
        friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Single;
    }
    else
    {
        // 多个好友
        if (indexPath.row == 0)
        {
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
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_SELECT_CONTACT_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // @所有成员
    if (self.isAtGroupMember && indexPath.section == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(atAllGroupMember)])
        {
            [self.delegate atAllGroupMember];
        }
        
        [self touchCancelButton: nil];
        return;
    }
    
    int indexSection = (int)indexPath.section;
    if (self.isAtGroupMember)
    {
        indexSection = indexSection - 1;
    }
    
    NSArray *friendArray = [self.sectionArray objectAtIndex: indexSection];
    if (friendArray.count == 0) {
        return;
    }
    
    // 获取当前的FriendTable
     FriendTable *friendTable = [friendArray objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedGroupMember:)])
    {
        [self.delegate selectedGroupMember: @[friendTable]];
    }
    
    [self touchCancelButton: nil];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    // 显示搜索的结果
    if (self.sectionArray == nil)
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
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.allIndexArray;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.isAtGroupMember && section == 0) {
        return nil;
    }
    // 减去搜索栏的位置的索引
    NSInteger index = section;
    if (self.isAtGroupMember) {
        index = index - 1;
    }
    
    if (index >= [self.allSectionTitlesArray count])
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

@end
