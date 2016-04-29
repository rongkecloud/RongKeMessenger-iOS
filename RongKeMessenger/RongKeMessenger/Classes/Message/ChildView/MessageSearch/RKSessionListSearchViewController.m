//
//  RKSessionListSearchViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 16/4/19.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKSessionListSearchViewController.h"
#import "SessionListTableCell.h"
#import "ToolsFunction.h"
#import "RKChatSessionViewController.h"

@interface RKSessionListSearchViewController ()<UITabBarControllerDelegate,UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *sessionListTableView;

@end

@implementation RKSessionListSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    RKCloudChatBaseChat *chatObject = [self.sessionListSearchArray lastObject];
    self.title = chatObject.sessionShowName;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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

#pragma mark -
#pragma mark UITableViewDelegate & UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sessionListSearchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SessionListTableCell *cell = [tableView dequeueReusableCellWithIdentifier: @"SearchMessageListCell"];
    if (cell == nil) {
        cell = [ToolsFunction loadTableCellFromNib: @"SessionListTableCell"];
        
        // 设置线条的偏移
        [tableView setSeparatorInset:UIEdgeInsetsMake(0,10,0,0)];
    }
    
    RKCloudChatBaseChat *sessionObject = [self.sessionListSearchArray objectAtIndex:indexPath.row];
    
    if (sessionObject) {
        [cell configSessionListByChatSessionObject:sessionObject  withListType:SessionListShowTypeSearchListCategory withMarkColorStr:self.markColorStr];
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
    
    RKChatSessionViewController *sessionViewController = [[RKChatSessionViewController alloc] initWithNibName:@"RKChatSessionViewController" bundle:nil];
    sessionViewController.sessionShowType = SessionListShowTypeSearchListCategory;
    
    RKCloudChatBaseChat *sessionObject = [self.sessionListSearchArray objectAtIndex:indexPath.row];
    sessionViewController.currentSessionObject = sessionObject;
    
    [self.navigationController pushViewController:sessionViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self setEditing:false animated:true];
}


@end
