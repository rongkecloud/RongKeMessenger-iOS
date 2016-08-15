//
//  FriendDetailViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/8/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "FriendInfoTable.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "DatabaseManager+FriendTable.h"
#import "ContactManager.h"
#import "RKTableViewCell.h"
#import "FriendInfoHeaderView.h"
#import "UIBorderButton.h"
#import "UserInfoManager.h"
#import "DatabaseManager+FriendsNotifyTable.h"
#import "FriendsNotifyTable.h"
#import "FriendTable.h"
#import "DatabaseManager+FriendTable.h"
#import "FriendDetailOptionView.h"

@interface FriendDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UITextFieldDelegate ,FriendDetailOptionViewDelegate>

@property (nonatomic,strong) UITableView *friendInfoTableView;
@property (nonatomic, assign) AppDelegate *appDelegate;
@property (nonatomic, strong) FriendInfoTable *friendInfoTable;
@property (nonatomic, strong) UILabel *accountLabel;
@property (nonatomic, strong) UILabel *markNameLabel;
@property (nonatomic, strong) FriendInfoHeaderView *friendInfoHeaderView;
@property (nonatomic, strong) FriendsNotifyTable *friendsNotifyTable;
@property (nonatomic, assign) CGRect firstFrame;
@property (nonatomic, strong) UIImageView *fullImageView;
@property (nonatomic, strong) FriendTable *friendTable;

@end

@implementation FriendDetailViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAvatarSuccessNotification:) name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFriendListNoticeMethod:) name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
    
    // Do any additional setup after loading the view.
    // 查询好友的详情
    self.friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:self.userAccount];
    self.friendTable = [self.appDelegate.databaseManager getContactTableByFriendAccount:self.userAccount];
    
    if (self.friendInfoTable == nil)
    {
        self.friendInfoTable = [[FriendInfoTable alloc] init];
        self.friendInfoTable.account = self.userAccount;
        [self.appDelegate.databaseManager saveFriendInfoTable:self.friendInfoTable];
    }

    [self addTableView];
    
    // 添加头像HeaderView
    [self addTableViewHeaderView];
    
    [self setTableViewAppearanceMode];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 注册TextField通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 移除TextField通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
    
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
#pragma mark Custom Method

- (void)setTableViewAppearanceMode
{
//    self.title = [self.appDelegate.contactManager displayFriendHighGradeName:self.userAccount];
    self.title = @"详细资料";
    
    // 向服务器获取联系人详情
    [self getFriendInfoFromServer];
    
    // 判断是否需要更新下载头像
    if ([self.friendInfoTable.friendServerAvatarVersion integerValue] > 0 &&  ([self.friendInfoTable.friendThumbnailAvatarVersion integerValue] < [self.friendInfoTable.friendServerAvatarVersion integerValue] || ![ToolsFunction isFileExistsAtPath:[ToolsFunction getFriendThumbnailAvatarPath:self.friendInfoTable.account]]))
    {
        // 异步获取个人头像(小图)
        [self.appDelegate.userInfoManager asyncDownloadThumbnailAvatarWithAccount:self.friendInfoTable.account];
    }

    if (self.personalDetailType == PersonalDetailTypeFriend || [ToolsFunction isRongKeServiceAccount:self.userAccount])
    {
        // 添加底部的操作按钮
        [self addTableViewBottomOptionButton];
    }
    else
    {
        // 获取对应的FriendsNotifyTable、得到当前的状态
        FriendsNotifyTable *friendsNotifyTable = [self.appDelegate.databaseManager getFriendsNotifyTableByFriendAccout:self.userAccount];
        if (friendsNotifyTable)
        {
            // 若是已经申请状态则不需要显示添加好友按钮
            if ([friendsNotifyTable.status integerValue] == AddFriendCurrentStateWaitingValidation)
            {
                // return;
            }
        }
        
        [self addTableViewBottomAddFriendButton];
    }
}

// 页面中控件的添加与设置
- (void)addTableView
{
    // 添加contactTableView
    CGRect tableviewFrame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height-STATU_NAVIGATIONBAR_HEIGHT);
    self.friendInfoTableView = [[UITableView alloc]initWithFrame:tableviewFrame style:UITableViewStylePlain];
    self.friendInfoTableView.delegate = self;
    self.friendInfoTableView.dataSource = self;
    self.friendInfoTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.friendInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.friendInfoTableView];
}

// 添加头像HeaderView
- (void)addTableViewHeaderView
{
    self.friendInfoHeaderView = [[FriendInfoHeaderView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 90)];
    [self.friendInfoHeaderView initAvatarAndNameLabel:self andUserAccount:self.userAccount];
    [self.friendInfoHeaderView updateAvatarAndLabelInfo];
    [self.friendInfoTableView setTableHeaderView:self.friendInfoHeaderView];
}

// 添加底部的操作按钮
- (void)addTableViewBottomOptionButton
{
    CGFloat optionY = UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - 50;
    FriendDetailOptionView *optionView = [FriendDetailOptionView creatFriendOptionMenu:YES frame:CGRectMake(0, optionY, UISCREEN_BOUNDS_SIZE.width, 50)];
    optionView.delegate = self;
    [self.view addSubview:optionView];
    [self.view bringSubviewToFront:optionView];
    /*
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 190)];
    
    for (int i = 0; i<3; i++)
    {
        float optionButtonFrameOriginY = 15 + (15+40)*i;
        UIBorderButton *optionButton = [[UIBorderButton alloc] initWithFrame:CGRectMake(15, optionButtonFrameOriginY, UISCREEN_BOUNDS_SIZE.width - 15 -15, 40)];
        optionButton.tag = FRIEND_FETAIL_OPTION_BUTTON_TAG + i;
        optionButton.titleLabel.font = FONT_TEXT_SIZE_16;
        
        NSString *buttonTitle = nil;
        switch (i) {
            case 0:
            {
                buttonTitle = NSLocalizedString(@"STR_FRIEND_OPERATION_CHART", @"发消息");
                optionButton.backgroundStateNormalColor = COLOR_OK_BUTTON_NOMAL;
                optionButton.backgroundStateHighlightedColor = COLOR_OK_BUTTON_HIGHLIGHTED;
                [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            case 1:
            {
                buttonTitle = NSLocalizedString(@"STR_FRIEND_OPERATION_VIDIO", @"发起视频通话");
                optionButton.backgroundStateNormalColor = COLOR_OK_BUTTON_NOMAL;
                optionButton.backgroundStateHighlightedColor = COLOR_OK_BUTTON_HIGHLIGHTED;
                [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            case 2:
            {
                buttonTitle = NSLocalizedString(@"TITLE_FRIEND_OPERATION_DELETE_FRIEND", @"删除好友");
                optionButton.backgroundStateNormalColor = [UIColor redColor];
                optionButton.backgroundStateHighlightedColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:51.0/255.0 alpha:1];
                [optionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
                break;
            default:
                break;
        }
        
        [optionButton setTitle:buttonTitle forState:UIControlStateNormal];
        
        [optionButton addTarget:self action:@selector(touchOptionButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [footerView addSubview:optionButton];
        
        // 若是小秘书则只显示发消息按钮
        if ([ToolsFunction isRongKeServiceAccount:self.userAccount]) {
            break;
        }
    }
    
    [self.friendInfoTableView setTableFooterView:footerView];
    */
}

// 添加底部的操作按钮 (陌生人情况下，添加朋友按钮)
- (void)addTableViewBottomAddFriendButton
{
    CGFloat optionY = UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - 50;
    FriendDetailOptionView *optionView = [FriendDetailOptionView creatFriendOptionMenu:NO frame:CGRectMake(0, optionY, UISCREEN_BOUNDS_SIZE.width, 50)];
    optionView.delegate = self;
    [self.view addSubview:optionView];
    [self.view bringSubviewToFront:optionView];
    /*
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 80)];
    
    UIBorderButton *buttonAddFriend = [[UIBorderButton alloc] initWithFrame:CGRectMake(15, 15, UISCREEN_BOUNDS_SIZE.width - 15 -15, 40)];
    buttonAddFriend.titleLabel.font = FONT_TEXT_SIZE_16;
    
    NSString *buttonTitle = NSLocalizedString(@"TITLE_ADD_FREIND", nil);
    buttonAddFriend.backgroundStateNormalColor = COLOR_OK_BUTTON_NOMAL;
    buttonAddFriend.backgroundStateHighlightedColor = COLOR_OK_BUTTON_HIGHLIGHTED;
    [buttonAddFriend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [buttonAddFriend setTitle:buttonTitle forState:UIControlStateNormal];
    
    [buttonAddFriend addTarget:self action:@selector(touchAddFriendButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:buttonAddFriend];
    
    [self.friendInfoTableView setTableFooterView:footerView];
     */
}


- (void)getFriendInfoFromServer
{
    // 没有网络则提示没有连接
    if ([ToolsFunction checkInternetReachability] == NO)
    {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    //    [ToolsFunction showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.friendInfoTable = [self.appDelegate.contactManager getContactInfoByUserAccount:self.userAccount];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //            [ToolsFunction hideWaitingMaskView];
            if (self.friendInfoTable != nil) {
                [self.friendInfoTableView reloadData];
                
                // 刷新个人头像信息
                self.friendInfoHeaderView.friendinfoTable = self.friendInfoTable;
                [self.friendInfoHeaderView updateAvatarAndLabelInfo];
            }
        });
    });
}

- (void)submitContactGroupsNameToServer
{
    // 判断网络是否连接有效
    if (![ToolsFunction checkInternetReachability]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    //    [ToolsFunction showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSuccessChange = [[AppDelegate appDelegate].contactManager syncModifyFriendInfo:self.friendTable];
        
        if (isSuccessChange) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[ToolsFunction hideWaitingMaskView];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME object:nil];
                
                [self.friendInfoTableView reloadData];
            });
        }
    });
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.personalDetailType == PersonalDetailTypeFriend)
    {
        return 2;
    } else {
        return 1;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.personalDetailType == PersonalDetailTypeFriend)
    {
        if (section == 0) {
            return 1;
        } else {
            return 2;
        }
    } else {
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RKTableViewCell *friendInfoTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"FriendInfoTableViewCell"];
    
    if (friendInfoTableViewCell == nil) {
        friendInfoTableViewCell = [[RKTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"FriendInfoTableViewCell"];
        friendInfoTableViewCell.cellFromType = Cell_From_Type_Other;
    }
    
    [self configCellInfoCell:friendInfoTableViewCell withIndexPath:indexPath];
    
    return friendInfoTableViewCell;
}

- (void)configCellInfoCell:(RKTableViewCell *)friendInfoTableViewCell withIndexPath:(NSIndexPath *)indexPath
{
    friendInfoTableViewCell.detailTextLabel.font = FONT_TEXT_SIZE_14;
    friendInfoTableViewCell.textLabel.font = FONT_TEXT_SIZE_16;
    
    if (self.personalDetailType == PersonalDetailTypeFriend)
    {
        switch ([indexPath section])
        {
            case 0:
            {
                friendInfoTableViewCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                friendInfoTableViewCell.textLabel.text = NSLocalizedString(@"TITLE_REMARK_NAME", "备注");
                
                NSString *friendRemark = [self.appDelegate.databaseManager getFriendRemarkNameByFriendAccount:self.friendInfoTable.account];
                
                if (friendRemark == nil || [friendRemark length] == 0)
                {
                    friendInfoTableViewCell.detailTextLabel.text = NSLocalizedString(@"TITLE_NO_SETTING", "未设置");
                } else {
                    friendInfoTableViewCell.detailTextLabel.text = friendRemark;
                }
                
                friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Single;
            }
                break;
                
            case 1:
            {
                switch (indexPath.row) {
                    case 0:
                    {
                        friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        friendInfoTableViewCell.textLabel.text = NSLocalizedString(@"TITLE_NAME", @"姓名");
                        if (self.friendInfoTable) {
                            friendInfoTableViewCell.detailTextLabel.text = self.friendInfoTable.name;
                        }
                        friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Top;
                    }
                        break;
                    case 1:
                    {
                        friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        friendInfoTableViewCell.textLabel.text = NSLocalizedString(@"TITLE_ADDRESS", @"地址");
                        if (self.friendInfoTable) {
                            friendInfoTableViewCell.detailTextLabel.text = self.friendInfoTable.address;
                        }
                        friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Bottom;
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
                
            default:
                break;
        }
        
    } else {
        switch (indexPath.row) {
            case 0:
            {
                friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                friendInfoTableViewCell.textLabel.text = NSLocalizedString(@"TITLE_NAME", @"姓名");
                if (self.friendInfoTable) {
                    friendInfoTableViewCell.detailTextLabel.text = self.friendInfoTable.name;
                }
                friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Top;
            }
                break;
            case 1:
            {
                friendInfoTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
                friendInfoTableViewCell.textLabel.text = NSLocalizedString(@"TITLE_ADDRESS", @"地址");
                if (self.friendInfoTable) {
                    friendInfoTableViewCell.detailTextLabel.text = self.friendInfoTable.address;
                }
                friendInfoTableViewCell.cellPositionType = Cell_Position_Type_Bottom;
            }
                break;
            default:
                break;
        }
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.personalDetailType == PersonalDetailTypeFriend)
    {
        if ([indexPath section] == 0 && [indexPath row] == 0)
        {
            UIAlertView *creatGroupsNameAlertView = [[UIAlertView alloc]
                                                     initWithTitle:@"修改备注名称"
                                                     message:nil
                                                     delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"")
                                                     otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
            creatGroupsNameAlertView.tag = ALERTVIEW_MODIFY_FRIEND_REMARK;
            
            creatGroupsNameAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            UITextField * titleField = [creatGroupsNameAlertView textFieldAtIndex:0];
            titleField.delegate = self;
            //设置字体大小
            [titleField setFont:[UIFont systemFontOfSize:16]];
            //设置右边消除键出现模式
            //    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
            //设置文字垂直居中
            titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
            //设置键盘背景色透明
            //    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
            titleField.keyboardType = UIKeyboardTypeDefault;
            
            if ([self.appDelegate.databaseManager getFriendRemarkNameByFriendAccount:self.friendInfoTable.account] != nil || [[self.appDelegate.databaseManager getFriendRemarkNameByFriendAccount:self.friendInfoTable.account] length] == 0)
            {
                titleField.text = [self.appDelegate.databaseManager getFriendRemarkNameByFriendAccount:self.friendInfoTable.account];
            }
            
            titleField.placeholder = NSLocalizedString(@"PROMPT_PLEASE_INPUT_REMARK_NAME", "请输入备注名");
            [titleField becomeFirstResponder];
            
            [creatGroupsNameAlertView show];
        }
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (self.personalDetailType == PersonalDetailTypeFriend)
    {
        return 15.0;
    } else {
        return 0.01;
    }
}
#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

#pragma mark -
#pragma mark - Touch Option Button Method

- (void)deleteFriend
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isSuccessDelete = [self.appDelegate.contactManager syncDeleteFriendByFriendAccount:self.friendInfoTable.account];
        
        if (isSuccessDelete) {
            // 删除FriendTable与FriendInfoTable
            [self.appDelegate.databaseManager deleteFriendInfoTableByAccount:self.friendInfoTable.account];
            [self.appDelegate.databaseManager deleteFriendTable:self.friendInfoTable.account];
            [self.appDelegate.databaseManager deleteFriendsNotifyTable:self.friendInfoTable.account];
            
            // 删除当前选择的会话
            [RKCloudChatMessageManager deleteChat:self.friendInfoTable.account withFile:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // 更新好友列表
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_FRIEND_LIST object:nil];
                
                [self.navigationController popViewControllerAnimated:YES];
            });
        }
    });
}

#pragma mark -
#pragma mark - FriendDetailOptionViewDelegate Method

-  (void)touchUpInsideWithButtonTag:(NSUInteger)btnTag
{
    
    NSInteger buttonTag = btnTag;
    switch (buttonTag - FRIEND_FETAIL_OPTION_BUTTON_TAG) {
        case 0:   // 发消息
        {
            // 新建一个聊天会话,如果会话存在，打开聊天页面
          [SingleChat buildSingleChat:self.friendInfoTable.account
                              onSuccess:^{
                                  [self.navigationController popViewControllerAnimated: NO];
                                  
                                  AppDelegate *appDelegate = [AppDelegate appDelegate];
                                  appDelegate.mainTabController.selectedIndex = 0;
                                  
                                  RKCloudChatBaseChat *sessionObject = [RKCloudChatMessageManager queryChat: self.friendTable.friendAccount];
                                  // 新建一个聊天会话,如果会话存在，打开聊天页面
                                  [appDelegate.rkChatSessionListViewController createNewChatView:sessionObject];
                                  
                                  NSLog(@"DEBUG: buildSingleChat: chatUserName = %@, onSuccess", self.friendInfoTable.account);
                              }
                               onFailed:^(int errorCode) {
                                   NSLog(@"DEBUG: buildSingleChat: chatUserName = %@, onFailed: errorCode = %d", self.friendInfoTable.account, errorCode);
                               }];
        }
            break;
        case 1:   // 发起视频通话
        {
            // Jacky.Chen.2016.03.04.ADD 根据系统版本8.0以上使用UIAlertController弹出菜单避免ipad上模态弹出出现crash的问题，8.0以前使用UIActionSheet
            if ([ToolsFunction getCurrentiOSMajorVersion] < 8.0) {
                // 8.0以前
                UIActionSheet *photoActionSheet = [[UIActionSheet alloc]
                                                   initWithTitle:nil
                                                   delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"STR_CANCEL",nil)
                                                   destructiveButtonTitle:nil
                                                   otherButtonTitles:NSLocalizedString(@"STR_FRIEND_OPERATION_AUDIO", "语音"),NSLocalizedString(@"STR_FRIEND_OPERATION_VIDIO", "视频"),
                                                   nil];
                [photoActionSheet showInView:self.view];
            }
            else
            {
                // 8.0及以后
                // 初始化UIAlertController
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                // 设置模态弹出锚点和位置，（iphone等小屏幕上无影响和以前的actionSheet位置相同）
                alert.popoverPresentationController.sourceView = self.view;
                alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height - 50, 1.0, 1.0);
                
                // 设置箭头朝下
                alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
                // 初始化3个操作项
                UIAlertAction *actionAudio = [UIAlertAction actionWithTitle:NSLocalizedString(@"STR_FRIEND_OPERATION_AUDIO", "语音") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 呼叫语音电话
                    [self.appDelegate.callManager dialAudioCall:self.friendInfoTable.account];
                    
                }];
                UIAlertAction *actionVideo = [UIAlertAction actionWithTitle:NSLocalizedString(@"STR_FRIEND_OPERATION_VIDIO", "视频") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    // 呼叫视频电话
                    [self.appDelegate.callManager dialVideoCall:self.friendInfoTable.account];
                }];
                UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"STR_CANCEL",nil) style:UIAlertActionStyleCancel handler:nil];
                
                // 添加
                [alert addAction:actionAudio];
                [alert addAction:actionVideo];
                [alert addAction:actionCancel];
                
                // 模态弹出
                [self presentViewController:alert animated:YES completion:nil];
            }
            
        }
            break;
        case 2:  // 删除好友
        {
            UIAlertView *deleteFriendAlertView = [[UIAlertView alloc]
                                                  initWithTitle:@"提示" message:NSLocalizedString(@"PROMPT_FRIEND_OPERATION_DELETE_FRIEND", "确定删除好友？")
                                                  delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"") otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
            
            deleteFriendAlertView.tag = ALERTVIEW_FRIEND_DETAIL_DELETE_TAG;
            
            [deleteFriendAlertView show];
        }
            break;
        case 3:  // 陌生人添加好友
        {
            self.friendsNotifyTable = [[FriendsNotifyTable alloc] init];
            self.friendsNotifyTable.friendAccount = self.friendInfoTable.account;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                BOOL isSuccess = [self.appDelegate.contactManager syncAddFriend:self.friendsNotifyTable];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (isSuccess == YES)
                    {
                        self.personalDetailType = PersonalDetailTypeFriend;
                        
                        [self setTableViewAppearanceMode];
                        
                        [self.friendInfoTableView reloadData];
                        
                        // 新建一个聊天会话,如果会话存在，打开聊天页面
                        [SingleChat buildSingleChat:self.friendsNotifyTable.friendAccount
                                          onSuccess:^{
                                              LocalMessage *callLocalMessage = nil;
                                              
                                              // 向对方发送验证通过的消息
                                              callLocalMessage = [LocalMessage buildReceivedMsg:self.friendsNotifyTable.friendAccount withMsgContent:NSLocalizedString(@"RKCLOUD_SINGLE_CHAT_MSG_CALL", nil) forSenderName:self.friendsNotifyTable.friendAccount];
                                              // 保存扩展信息
                                              [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_SINGLE_TYPE];
                                              
                                          }
                                           onFailed:^(int errorCode) {
                                           }];
                    }
                    else
                    {
                        // 弹出申请AlertView
                        UIAlertView *addContactAlertView = [[UIAlertView alloc]
                                                            initWithTitle:NSLocalizedString(@"TITLE_ADD_CONTACT_TITLE", @"对方需要验证")
                                                            message:nil
                                                            delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", @"")
                                                            otherButtonTitles:NSLocalizedString(@"STR_OK", @""), nil];
                        addContactAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                        addContactAlertView.tag = ALERTVIEW_FRIEND_DETAIL_ADD_TAG;
                        
                        UITextField *addTitleTextField = [addContactAlertView textFieldAtIndex:0];
                        addTitleTextField.delegate = self;
                        NSString *disPlayName = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
                        
                        NSString *stringResultName = disPlayName;
                        // 优化个人姓名显示 长度不超过20位 否则无法添加好友
                        if (disPlayName != nil && [disPlayName length] > 20)
                        {
                            stringResultName = [disPlayName substringToIndex:20];
                        }
                        addTitleTextField.text = [NSString stringWithFormat:@"%@ 请求添加您为好友。", stringResultName];
                        
                        [addContactAlertView show];
                    }
                });
            });

        }
            break;

        default:
            break;
    }

}
#pragma mark -
#pragma mark - UIAlertView Delegate Method

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
        case ALERTVIEW_MODIFY_FRIEND_REMARK:
        {
            UITextField * titleField = [alertView textFieldAtIndex:0];
            NSString *applyStr = [titleField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            self.friendTable.remarkName = applyStr;
            self.markNameLabel.text = applyStr;
            // 向服务器提交新的分组信息
            [self submitContactGroupsNameToServer];
        }
            break;
            
        case ALERTVIEW_FRIEND_DETAIL_DELETE_TAG:
        {
            // 删除好友
            [self deleteFriend];
        }
            break;
            
        case ALERTVIEW_FRIEND_DETAIL_ADD_TAG:
        {
            UITextField *addFriendTextField = [alertView textFieldAtIndex:0];
            NSString *applyStr = [addFriendTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            
            if (applyStr.length == 0) {
                
                [UIAlertView showAutoHidePromptView:@"申请信息不能为空" background:nil showTime:1.5];
                return;
            }
            
            if ([applyStr length] > USER_NAME_MAX_LENGTH)
            {
                NSLog(@"[applyStr length] = %lu", (unsigned long)[applyStr length]);
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CONTENT_TOO_LONG", "申请信息过长") background:nil showTime:1.5];
                return;
            }
            
            // 判断网络是否连接有效
            if (![ToolsFunction checkInternetReachability]) {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                           background:nil
                                             showTime:TIMER_NETWORK_ERROR_PROMPT];
                return;
            }
            
            // 向服务器提交申请信息
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.friendsNotifyTable.content = applyStr;
                
                // 提交申请
                [[AppDelegate appDelegate].contactManager syncAddFriend:self.friendsNotifyTable];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_WAITING_VALIDATION", @"等待对方验证中") background:nil showTime:2.0];
                });
            });
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:  // 语音
        {
            // 呼叫语音电话
            [self.appDelegate.callManager dialAudioCall:self.friendInfoTable.account];
        }
            break;
        case 1:  // 视频
        {
            // 呼叫视频电话
            [self.appDelegate.callManager dialVideoCall:self.friendInfoTable.account];
        }
            break;
        default:
            break;
    }
}

#pragma mark - CustomAvatarImageView

- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount
{
    [self tapImageViewToZoomingBig:avatarUserAccount];
}

#pragma mark - Zooming Image

// 放大图片
-(void)tapImageViewToZoomingBig:(NSString *)paramUserId
{
    // 避免非好友 self.friendInfoTable == nil
    self.friendInfoTable = [self.appDelegate.databaseManager getFriendInfoTableByAccout:self.userAccount];
    
    self.firstFrame = CGRectMake(20,64.0 + 20, 80, 80);
    
    self.fullImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height)];
    
    self.fullImageView.backgroundColor=[UIColor blackColor];
    
    self.fullImageView.userInteractionEnabled=YES;
    
    // 添加图片点击手势
    [self.fullImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewToZoomingSmall:)]];
    
    self.fullImageView.contentMode=UIViewContentModeScaleAspectFit;
    
    if (![self.fullImageView superview])
    {
        // 小图路径
        NSString *thumbnailAvatarImagePath = [ToolsFunction getFriendThumbnailAvatarPath:paramUserId];
        // 大图路径
        NSString *AvatarImagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",paramUserId]];
        
        if ([self.friendInfoTable.friendServerAvatarVersion intValue] > 0 && ([self.friendInfoTable.friendOriginalAvatarVersion intValue] < [self.friendInfoTable.friendServerAvatarVersion intValue] || ![ToolsFunction isFileExistsAtPath:AvatarImagePath]))
        {   // 不存在
            self.fullImageView.image = [UIImage imageWithContentsOfFile:thumbnailAvatarImagePath];
            
            // 异步下载自己的原始头像
            [self.appDelegate.userInfoManager asyncDownloadOriginalAvatarWithAccount:paramUserId];
            
        } else { // 存在
            // 拼接大图路径
            self.fullImageView.image = [UIImage imageWithContentsOfFile:AvatarImagePath];
        }
        
        [self.view.window addSubview:self.fullImageView];
        self.fullImageView.frame = self.firstFrame;
        [UIView animateWithDuration:0.35 animations:^{
            self.fullImageView.frame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height);
        } completion:^(BOOL finished) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }];
    }
}

// 缩小图片
-(void)tapImageViewToZoomingSmall:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.35 animations:^{
        self.fullImageView.frame = self.firstFrame;
    } completion:^(BOOL finished) {
        
        [self.fullImageView removeFromSuperview];
    }];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
}

// 下载图片成功通知方法
- (void)downloadAvatarSuccessNotification:(NSNotification *)notificatio
{
    if (notificatio == nil || notificatio.object == nil) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        PersonalInfos *personalInfos = notificatio.object;
        
        if (self.userAccount != personalInfos.userAccount)
        {
            return;
        }
        
        if ([personalInfos.avatarType intValue] == UploadAndDownloadRequestTypeDownloadBigAvatar)
        {
            // 下载大图
            self.fullImageView.image = [[UIImage alloc] initWithContentsOfFile:[self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", self.friendInfoTable.account]]];
        }
    });
}

// 更新联系人分组
- (void)updateFriendListNoticeMethod:(NSNotification *)notice
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.friendInfoTableView reloadData];
    });
}

#pragma mark -
#pragma mark TextFieldDelegate Method

- (void)textDidChange:(NSNotification *)obj{
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField.text length] + [string length] > USER_NAME_MAX_LENGTH  && ![string isEqualToString:@""]) {
        
        return NO;
    }
    return YES;
}

@end
