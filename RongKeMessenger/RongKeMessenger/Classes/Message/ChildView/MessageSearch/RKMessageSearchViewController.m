//
//  RKMessageSearchViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 16/4/14.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKMessageSearchViewController.h"
#import "RKCloudChatMessageManager.h"
#import "SessionListTableCell.h"
#import "ToolsFunction.h"
#import "RKSessionListSearchViewController.h"
#import "RKChatSessionViewController.h"

#define RKSearchMessageKey   @"SearchMessageKey"
#define RKSearchSessionKey   @"SearchSessionKey"

@interface RKMessageSearchViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *messageSearchBar;
@property (nonatomic, weak) IBOutlet UITableView *messageSearchTableView;
@property (nonatomic, strong) NSMutableDictionary *searchResultDic;

@end

@implementation RKMessageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.searchResultDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array],RKSearchMessageKey, [NSMutableArray array],RKSearchSessionKey,nil];
    
    [self.messageSearchBar becomeFirstResponder];
    
    self.messageSearchTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.messageSearchTableView.bounds.size.width, 0.01f)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark  Custom Method

- (IBAction)touchCancelButton:(id)sender
{
    [self.messageSearchBar resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// 计算每个搜索section对应的cell个数
- (NSUInteger)getCellCountsWithSection:(NSInteger)section
{
    NSUInteger cellCounts = 0;
    
    NSMutableArray *messageObjectArray = [self getMessageObjectArrayForSection:section];
    if (messageObjectArray) {
        cellCounts = [messageObjectArray count];
    }
    return cellCounts;
}

// 获取枚举对应的搜索结果对象数组
- (NSMutableArray <NSDictionary *>*)getMessageObjectArrayForSection:(NSInteger)section
{
    NSArray *searchTypeKeyArray = [self.searchResultDic allKeys];
    NSMutableArray *messageObjectArray = nil;
    switch (section) {
        case 0: // 消息记录搜索
        {
            if ([searchTypeKeyArray containsObject:RKSearchMessageKey])
            {
                messageObjectArray = [self.searchResultDic objectForKey:RKSearchMessageKey];
            }
        }
            break;
        case 1: // 会话搜索
        {
            if ([searchTypeKeyArray containsObject:RKSearchSessionKey])
            {
                messageObjectArray = [self.searchResultDic objectForKey:RKSearchSessionKey];
            }
        }
            break;
        default:
            break;
    }
    return messageObjectArray;
}

- (RKCloudChatBaseChat *)getSessionObjectWithSection:(NSIndexPath *)indexPath
{
    NSArray *searchTypeKeyArray = [self.searchResultDic allKeys];
    RKCloudChatBaseChat *sessionObject = nil;
    switch (indexPath.section) {
        case 0: // 消息记录搜索
        {
            if ([searchTypeKeyArray containsObject:RKSearchMessageKey])
            {
                NSArray *sessionArray = [self.searchResultDic objectForKey:RKSearchMessageKey];
                NSDictionary *sessionDic = [sessionArray objectAtIndex:indexPath.row];
                NSString *sessionId = [sessionDic allKeys].lastObject;
                
                if (sessionId) {
                    sessionObject = [RKCloudChatMessageManager queryChat:sessionId];
                    sessionObject.unReadMsgCnt = 0;
                    
                    TextMessage *lastMessage = [[TextMessage alloc] init];
                    NSInteger searchMessageCount = ((NSArray *)[sessionDic objectForKey:sessionId]).count;
                    lastMessage.textContent = [NSString stringWithFormat:NSLocalizedString(@"STR_MESSAGE_SEARCH_COUNT", @""),searchMessageCount];
                    
                    sessionObject.lastMessageObject = lastMessage;
                }
            }
        }
            break;
        case 1: // 会话搜索
        {
            NSArray *sessionObjectArray = [self.searchResultDic objectForKey:RKSearchSessionKey];
            sessionObject = [sessionObjectArray objectAtIndex:indexPath.row];
            
        }
            break;
        default:
            break;
    }
    return sessionObject;
}

// 获取搜索的SessionObjectList数组
- (NSMutableArray *)getSessionObjectListArray:(NSIndexPath *)indexPath
{
    NSMutableArray *sessionObjectArray = nil;
    NSArray *searchMessageObjectArray = [self getMessageObjectArrayForSection:indexPath.section];
    if (searchMessageObjectArray.count > 0) {
        
        NSDictionary *resultSearchDic = [searchMessageObjectArray objectAtIndex:indexPath.row];
        NSString *sessionId = (NSString *)([resultSearchDic allKeys].lastObject);
        
        NSArray *messageObjectArray = [resultSearchDic objectForKey:sessionId];
        
        sessionObjectArray = [NSMutableArray array];
        
        
        if (messageObjectArray.count > 0) {
            
            for (int i = 0; i < messageObjectArray.count; i++)
            {
                RKCloudChatBaseMessage *messageObject = [messageObjectArray objectAtIndex:i];
                
                // 获取对应的SessionObject
                RKCloudChatBaseChat *sessionObject = [RKCloudChatMessageManager queryChat:sessionId];
                sessionObject.unReadMsgCnt = 0;
                
                // 把搜索到的message作为左后一条消息 记录到sessionObject.lastMessageObject
                sessionObject.lastMessageObject = messageObject;
                sessionObject.lastMsgCreatedTime = messageObject.createTime;
                [sessionObjectArray addObject:sessionObject];
            }
        }
    }
    return sessionObjectArray;
}

- (void)searchSessionNameWithSearchStr:(NSString *)searchStr
{
    // 获取到所有的SessionObject
    NSArray *sessionArray = [RKCloudChatMessageManager queryAllChats];
    
    if (sessionArray && sessionArray.count > 0) {
        NSMutableDictionary *searchMutDic = [[NSMutableDictionary alloc] init];
        
        // 获取消息会话列表
        NSArray * arrayChatSession= [[NSArray alloc] initWithArray:sessionArray];
        RKCloudChatBaseChat * sessionObject = nil;
        
        for (int i = 0; i < [arrayChatSession count]; i++)
        {
            sessionObject = [arrayChatSession objectAtIndex:i];
            if (sessionObject.sessionShowName && [[sessionObject.sessionShowName uppercaseString] rangeOfString:[searchStr uppercaseString]].length > 0)
            {
                [searchMutDic setObject:sessionObject forKey:sessionObject.sessionID];
            }
        }
        
        NSMutableArray *sessionArray = [self.searchResultDic objectForKey:RKSearchSessionKey];
        [sessionArray removeAllObjects];
        
        if ([searchMutDic allValues].count > 0) {
            [sessionArray addObjectsFromArray:[searchMutDic allValues]];
        }
    }
}

#pragma mark -
#pragma mark UISearchBarDelegate methods

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 去除空格
    NSString *searchKeyStr = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (searchKeyStr.length > 0) {
        // 从数据库中查询关键字搜索的的对象
        [RKCloudChatMessageManager queryMessageKeyword:searchKeyStr onSuccess:^(NSArray<NSDictionary *> *messageObjectArray) {
            NSMutableArray *resultArray = (NSMutableArray *)[self.searchResultDic objectForKey:RKSearchMessageKey];
            [resultArray removeAllObjects];
            
            if (messageObjectArray && messageObjectArray.count > 0)
            {
                // 判断是否应经有RKSearchMessageKey值
                if (messageObjectArray && messageObjectArray.count > 0) {
                    [resultArray addObjectsFromArray:messageObjectArray];
                }
            }
            
        } onFailed:^(int errorCode) {
            
        }];
        
        // 搜索会话名称中包含的关键字
        [self searchSessionNameWithSearchStr:searchKeyStr];
    }
    else
    {
        // 清空所有数据
        [[self.searchResultDic objectForKey:RKSearchSessionKey] removeAllObjects];
        [[self.searchResultDic objectForKey:RKSearchMessageKey] removeAllObjects];
    }
    
    [self.messageSearchTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.messageSearchBar resignFirstResponder];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

#pragma mark -
#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滑动的时候取消键盘
    [self.messageSearchBar resignFirstResponder];
}

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.searchResultDic allKeys].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self getCellCountsWithSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SessionListTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SearchMessageListCell"];
    if (cell == nil) {
        cell = [ToolsFunction loadTableCellFromNib: @"SessionListTableCell"];
        // 设置线条的偏移
        [tableView setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    }
    
    RKCloudChatBaseChat *sessionObject = [self getSessionObjectWithSection:indexPath];
    
    if (sessionObject) {
        SessionListShowType sessionType = SessionListShowTypeSearchListMain;
        
        NSString *markSearchStr = nil;
        if (indexPath.section == 1)
        {
            // 消息名称搜索
            sessionType = SessionListShowTypeSearchSessionName;
            markSearchStr = self.messageSearchBar.text;
        }
        
        [cell configSessionListByChatSessionObject:sessionObject  withListType: indexPath.section == 0 ? sessionType :SessionListShowTypeSearchSessionName withMarkColorStr:markSearchStr];
    }
    
    return cell;
}

// 设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_MESSAGE_LIST_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated: NO];
    
    switch (indexPath.section) {
        case 0:   // 搜索消息记录
        {
            // 获取对应的SessionObject列表
            NSMutableArray *sessionListArray = [self getSessionObjectListArray:indexPath];
            
            if (sessionListArray.count > 1) {
                RKSessionListSearchViewController *sessionListSearchCtr = [[RKSessionListSearchViewController alloc] initWithNibName:@"RKSessionListSearchViewController" bundle:nil];
                
                sessionListSearchCtr.sessionListSearchArray = sessionListArray;
                sessionListSearchCtr.markColorStr = self.messageSearchBar.text;
                
                [self.navigationController pushViewController:sessionListSearchCtr animated:YES];
            }
            else  if(sessionListArray.count == 1) // 直接进入会话
            {
                [self pushChatSessionViewControllerWithSessionObject:(RKCloudChatBaseChat *)[sessionListArray objectAtIndex:0] withSessionType:SessionListShowTypeSearchListCategory];
            }
        }
            break;
        case 1:  // 搜索会话记录
        {
            // 获取当前的SessionObject
            RKCloudChatBaseChat *chatObject = [self getSessionObjectWithSection:indexPath];
            
            [self pushChatSessionViewControllerWithSessionObject:chatObject withSessionType:SessionListShowTypeNomal];
        }
            break;
        default:
            break;
    }
}

- (void)pushChatSessionViewControllerWithSessionObject:(RKCloudChatBaseChat *)chatObject withSessionType:(SessionListShowType)sessionType
{
    if (chatObject) {
        RKChatSessionViewController *sessionViewCtr = [[RKChatSessionViewController alloc] initWithNibName:NSStringFromClass([RKChatSessionViewController class]) bundle:nil];
        
        sessionViewCtr.sessionShowType = sessionType;
        sessionViewCtr.currentSessionObject = chatObject;
        
        [self.navigationController pushViewController:sessionViewCtr animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setEditing:false animated:true];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSInteger headerHeight = 0.1;
    NSInteger cellNum = [self getCellCountsWithSection:section];
    
    if (cellNum > 0) {
        headerHeight = 36;
    }
    return headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *searchTitleLabel = nil;
    switch (section) {
        case 0:
        {
            // 检查是都有对应的搜索结果
            NSMutableArray *resultArray = [self.searchResultDic objectForKey:RKSearchMessageKey];
            if (resultArray.count > 0)
            {
                searchTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width - 40, 26)];
                searchTitleLabel.font = FONT_TEXT_SIZE_14;
                searchTitleLabel.textColor = COLOR_MAIN_TEXT;
                searchTitleLabel.text = NSLocalizedString(@"TITLE_CHAT_MESSAGE_RECORD", @"聊天记录");
            }
        }
            break;
        case 1:
        {
            // 检查是都有对应的搜索结果
            NSMutableArray *resultArray = [self.searchResultDic objectForKey:RKSearchSessionKey];
            if (resultArray.count > 0)
            {
                searchTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, tableView.frame.size.width - 40, 26)];
                searchTitleLabel.font = FONT_TEXT_SIZE_14;
                searchTitleLabel.textColor = COLOR_MAIN_TEXT;
                searchTitleLabel.text = NSLocalizedString(@"TITLE_CHAT_SESSION_RECORD", @"会话记录");
            }
        }
            break;
        default:
            break;
    }
    return searchTitleLabel;
}



@end
