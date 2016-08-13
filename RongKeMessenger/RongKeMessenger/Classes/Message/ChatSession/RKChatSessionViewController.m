//
//  RKChatSessionViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKChatSessionViewController.h"
#import "RKChatSessionListViewController.h"
#import "RKChatSessionInfoViewController.h"
#import "ToolsFunction.h"
#import "RKCloudUIContactViewController.h"
#import "MessageVoiceTableCell.h"
#import "ImagePreviewViewController.h"
#import "AppDelegate.h"
#import "RKChatImagesBrowseViewController.h"
#import "SelectFriendsViewController.h"
#import "CallManager.h"
#import "RKMessageContainerToolsView.h"
#import "FriendDetailViewController.h"
#import "DatabaseManager+FriendTable.h"
#import "FriendTable.h"
#import "PersonalDetailViewController.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"
#import "MessageVoiceTableCell.h"
#import "MessageTextTableCell.h"
#import "MessageImageTableCell.h"
#import "MessageFileTableCell.h"
#import "MessageLocalRecordTableCell.h"
#import "DownloadIndicator.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoMessage.h"
#import "MessageVideoCell.h"
#import "SelectGroupMemberViewController.h"
#import "HPTextViewInternal.h"
#import "MJRefresh.h"

// 键盘的高度
#define TOOLVIEW_HEIGHT 190
// 输入文本工具栏的高度
#define INPUT_TEXT_TOOL_VIEW_HEIGHT 45
// 工具栏窗口的高度
#define MESSAGE_TOOLS_VIEW_HEIGHT 49

//按钮文字颜色
#define BUTTON_TEXT_COLOR [UIColor colorWithRed:113/255.0 green:114/255.0 blue:116/255.0 alpha:1.0]
//按钮文字颜色
#define GROUP_MESSAGE_BGCOLOR [UIColor colorWithRed:173.0/255.0 green:183.0/255.0 blue:194.0/255.0 alpha:1.0]
//表格背景色
#define MMSTABLE_BGCOLOR [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f]

#define MESSAGE_CONTAINER_TOOLS_VIEW_INIT_FRAME CGRectMake(0, UISCREEN_BOUNDS_SIZE.height- STATU_NAVIGATIONBAR_HEIGHT - MESSAGE_TOOLS_VIEW_HEIGHT, UISCREEN_BOUNDS_SIZE.width, MESSAGE_TOOLS_VIEW_HEIGHT)

//########################################################
// MessageTable的初始化坐标
#define MESSAGE_TABLE_INIT_FRAME  CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - MESSAGE_TOOLS_VIEW_HEIGHT)
// Growing TextView的初始化坐标
#define GROWING_TEXTVIEW_INIT_FRAME  CGRectMake(0, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - INPUT_TEXT_TOOL_VIEW_HEIGHT + 2, UISCREEN_BOUNDS_SIZE.width, INPUT_TEXT_TOOL_VIEW_HEIGHT)
// chatButtonView 下移时的坐标
#define CHAT_BUTTONVIEW_DOWN_FRAME CGRectMake(0, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - self.messageContainerToolsView.frame.size.height, UISCREEN_BOUNDS_SIZE.width, self.messageContainerToolsView.frame.size.height)

#define DEFAULT_MESSAGE_SESSION_CELL_HEIGHT 30 // 默认表格单元高度

#define TIME_BLANK  2          // 按照时间分组的时间间隔（单位分钟）
#define LOAD_MESSAGE_COUNT 20  // 每次加载消息记录的数量

// 群消息信息（邀请/时间等）表格单元标识符
#define CELL_MESSAGEGROUPINFO @"MessageMCTableCell"

@interface RKChatSessionViewController () <RKMessageContainerToolsViewDelegate,UITableViewDataSource,UITableViewDelegate, SelectGroupMemberDelegate>
{
	NSInteger currentTextViewLocation;  // 文本输入当前光标位置
	
	CGRect chatTextViewRect;     // 保存chatTextView的位置
	
	BOOL isShowToolsControlView; // 是否显示了控制窗口
	BOOL isEditing;              // 是否显示编辑界面
    CGRect systemKeyboardRect;   // 系统键盘的矩形位置
    NSInteger  loadMessageCount;       // 记录当前载入的消息个数（不包括分组的时间消息及其他未存入数据库的消息）
                                 /*Jacky.Chen:2016.02.16:添加成员变量记录从数据库中加载显示的消息个数,作为下拉加载更多的判断条件，解决当前项目中历史消息显示不全的问题*/
    BOOL isFirstLoadMMS;
}

@property (nonatomic, strong) UITableView *messageSessionContentTableView;        // 此表用于显示消息记录的具体内容
@property (nonatomic, strong) IBOutlet UIProgressView *timeProgressView;          // 录音或者放音的进度条
@property (nonatomic, strong) IBOutlet UIImageView *voicePeakImageView;           // 显示声音高低的音浪
@property (nonatomic, strong) IBOutlet UIView *recordingView;                     // 录音时显示的正在录音的View
@property (nonatomic, strong) IBOutlet UIView *recordingWarnningView;             // 显示按键时间太短的提示view
@property (nonatomic, strong) IBOutlet UIView *microphoneControlView;             // 声浪提示的窗口
@property (nonatomic, strong) IBOutlet UILabel *countTimeLable;                   // 记录显示当前录音时长的lable
@property (nonatomic, strong) IBOutlet UILabel *recordingWarnningLable;           // 按键时间短的提示文字

@property (nonatomic, strong) NSMutableArray *visibleSortMessageRecordArray; // 此数组用于装载分类后的消息，二维数组

@property (nonatomic, retain) NSTimer *updateVoicePeakPowerTimer; // 刷新声音波浪大小的定时器
@property (nonatomic, retain) RKCloudChatBaseMessage *selectedMessageObject; // 当前选择的消息对象
@property (nonatomic, retain) UIDocumentInteractionController * docInteractionController; // 文档的容器类对象

@property (nonatomic, weak) RKChatSessionInfoViewController *sessionInfoViewController; // 会话信息管理页面
@property (nonatomic, strong) UIView *meetingPromptView; // 多人会议与会中提示view
@property (nonatomic, strong) RKMessageContainerToolsView *messageContainerToolsView; // 消息会话底部工具栏
// Jacky.Chen:2016.02.24,添加三个属性用于录音时上滑操作
@property (weak, nonatomic) IBOutlet UIImageView *recordingBgView; // 录音背景
@property (weak, nonatomic) DownloadIndicator *downloadIndicatorView; // 弧形进度条
@property (weak, nonatomic) UIView *maskView;// 点击录音按键时的遮盖

@property (nonatomic, strong) NSDate *lastDivideGroupDate; // 最近分组的时间

@property (nonatomic, assign) BOOL isRefreshing; // Jacky.Chen ,03.18 ,Add增加属性防止多次重复刷新阻塞主线程

@property (nonatomic, assign) CGPoint lastTouchPoint; // Jacky.Chen.03.10.记录录音时手指最后的触摸点

// 增加@功能
@property (nonatomic, strong) NSMutableArray *atUserArray;  // @指定的用户
@property (nonatomic) BOOL isAtAll;      // 是否@all
@property (nonatomic) BOOL isExecuteAt;  // 是否执行@功能
@property (nonatomic) BOOL isPushAtView; // 是否弹出@选择页面

@end

@implementation RKChatSessionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        // 初始化所有变量值
        [self initAllVariableValue];
        
        self.sessionShowType = SessionListShowTypeNomal;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Jacky.Chen:2016.02.17:初始化messageSessionContentTableView
    [self setupMessageContentTableView];
    
    self.visibleSortMessageRecordArray = [NSMutableArray array];
    self.arrayVoiceJustDownload = [NSMutableArray array];
    
    // Jacky.Chen:2016.02.24:向recordView中添加进度条控件
    [self setupRecordingView];
    
    // 按组载入消息记录
    // [self loadMessageRecord:YES];
    
    // 初始化底部的工具栏View
    [self createMessageToolsContainerView];
    
    // 创建表情符号窗口
	[self creatToolsControlView];
    
	// 初始化AudioSession
	[self startAudioSession];
    
    // 初始化bar上的button
	[self initNavigationBarButton];
    
    // 初始化UI和控件窗口
    [self initUIControlView];
    
    // 初始化聊天会话上滑和下拉控件和加载数据的block
    [self initChatSessionRefreshingControl];

    // 注册更新昵称和头像的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateUserProfileNotification:)
                                                 name:NOTIFICATION_UPDATE_USER_PROFILE
                                               object: nil];
    
    // 注册清空消息的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearMessagesNotification:)
                                                 name:NOTIFICATION_CLEAR_MESSAGES_OF_SESSION
                                               object:nil];
    
    // 告知其它平台清空新消息提示
    [RKCloudChatMessageManager clearOtherPlatformNewMMSCounts: self.currentSessionObject.sessionID];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"DEBUG: RKChatSessionViewController - viewWillAppear begin");
    self.isPushAtView = NO;
    
    // 给meetingManager的会话对象赋值 用于本地进出多人语音添加提示语
    [AppDelegate appDelegate].meetingManager.currentSessionObject = self.currentSessionObject;
    
    // 增加所有的通知事件方法
    [self addAllNotificationCenter];
    
    // 设置状态栏默认风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 拍照或者是选择相册的时候，navigationBar被隐藏了，再次回到该页面，要把navigationBar显示出来
    self.navigationController.navigationBarHidden = NO;
	// 设置导航栏是否透明
	[self.navigationController.navigationBar setTranslucent:NO];
    
    // 重设表格位置
    [self moveMessageTableViewFrame];
    
    if (self.isAppearFirstly == YES)
    {
        // 只在初次显示页面时自动滚动到最后一行（编辑状态下不改变滚动的位置）
        if (!isEditing && [self.visibleSortMessageRecordArray count] > 0)
        {
            // 自动滚动到tabView的最后一行(表格所含内容的最底部)
            NSUInteger sectionCount = [self.messageSessionContentTableView numberOfSections];
            if (sectionCount) {
                
                NSUInteger rowCount = 0;
                
                UITableViewScrollPosition  ScrollPosition =  UITableViewScrollPositionBottom;
                
                switch (self.sessionShowType) {
                    case SessionListShowTypeNomal: {
                        {
                            rowCount = [self.messageSessionContentTableView numberOfRowsInSection:0] - 1;
                        }
                        break;
                    }
                    case SessionListShowTypeSearchListMain:
                    case SessionListShowTypeSearchListCategory: {
                        {
                            rowCount = [self getCurrentSessionObjectIndexInArray];
                            ScrollPosition =  UITableViewScrollPositionTop;
                        }
                        break;
                    }
                    default: {
                        break;
                    }
                }
                 ;
                if (rowCount) {
                    
                    NSUInteger ii[2] = {0, rowCount};
                    NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                    [self.messageSessionContentTableView scrollToRowAtIndexPath:indexPath
                                                               atScrollPosition:ScrollPosition animated:NO];
                }
            }
        }
        
        self.isAppearFirstly = NO;
    }
    
    // 更新当前会话聊天对象
    self.currentSessionObject = [RKCloudChatMessageManager queryChat:self.currentSessionObject.sessionID];
    
    // 设置聊天会话页面的标题
    if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        // 如果该会话为群聊，则查找该会话中的人数
        self.title = [NSString stringWithFormat:@"%@(%d)", self.currentSessionObject.sessionShowName, self.currentSessionObject.userCounts];
    }
    else if (self.currentSessionObject.sessionType == SESSION_SINGLE_TYPE)
    {
        self.title = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:self.currentSessionObject.sessionShowName];
    }
    
    // 如果此会话自定义背景图存在，设置背景图片
    UIImage *bgImage = [[UIImage alloc] initWithContentsOfFile:self.currentSessionObject.backgroundImagePath];
    if (bgImage != nil)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[ToolsFunction scaleImageSize:bgImage toSize:UISCREEN_BOUNDS_SIZE]];
    }
    else {
        self.view.backgroundColor = MMSTABLE_BGCOLOR;
    }
    
    // 解决图片下载时从预览页面返回后转圈的动画停止袋问题
    if (self.messageSessionContentTableView) {
        [self reloadTableView];
        [self voiceCellPlaying];
    }
    
    // 更新当前会话的提示消息为已读状态
    [RKCloudChatMessageManager updateMsgsReadedInChat:self.currentSessionObject.sessionID];
    self.currentSessionObject.unReadMsgCnt = 0;
    
    // 添加多人会议提示view
    [self addInMeetingMarkingView];
    
    NSLog(@"DEBUG: RKChatSessionViewController - viewWillAppear end");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 注销notification
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    // 更新输入框的位置
    chatTextViewRect = self.messageContainerToolsView.frame;
    
    // Jacky.Chen:2016.02.03:若MenuController可见，则隐藏。
    if ([UIMenuController sharedMenuController].menuVisible) {
        
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    
    // 判断是否当前在录音或者播放语音
    if ([self.audioToolsKit isRecordingVoice] || [self.audioToolsKit isPlayingVoice])
    {
        // 停止且不发送语音
        [self didStopRecordAndPlaying];
    }
    
    // Gray.Wang:2016.03.01: 删除过滤掉@“\U0000fffc\U0000fffc”系统语音设别自动生成的文本输入Unicode字符
    // http://stackoverflow.com/questions/27119299/how-to-remove-characters-u0000fffc-from-nsstring-ios
    NSString *codeString = @"\uFFFC";
    NSString *msgInputContent = [self.messageContainerToolsView.inputContainerToolsView.growingTextView.text stringByReplacingOccurrencesOfString:codeString withString:@""];
    
    // Jacky.Chen:2016.03.05:增加[ToolsFunction isEmptySpace:msgInputContent]判断输入框是否为空格若为空格则不存草稿
    // 如果文本输入框中存在未发送的字符串则保存为草稿
    if ([msgInputContent length] > 0 && [ToolsFunction isEmptySpace:msgInputContent] == NO) {
        [RKCloudChatMessageManager saveDraft:msgInputContent
                                forSessionID:self.currentSessionObject.sessionID
                               withExtension:nil];
    }
    
    // 更新当前会话的提示消息为已读状态
    [RKCloudChatMessageManager updateMsgsReadedInChat:self.currentSessionObject.sessionID];
    self.currentSessionObject.unReadMsgCnt = 0;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // Jacky.Chen.2016.03.05.Add,将此部分代码移至viewDidDisappear中，修改使用手势右滑造成的本级页面回来后又pop的bug
    [self touchBackButton];
}


- (void)viewDidUnload {
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self releaseOutlets];
	
	// 为简单起见，当View被卸载之后，重新加载时默认自动滚动到最后一行
	self.isAppearFirstly = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
	// 判断是否在主线程,如果是则调用,如果不是,则返回主线程调用
	if (![NSThread isMainThread])
	{
        [self performSelectorOnMainThread:@selector(releaseOutlets) withObject:nil waitUntilDone:YES];
    }
	else
	{
		[self releaseOutlets];
	}
	
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPDATE_USER_PROFILE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_CLEAR_MESSAGES_OF_SESSION object:nil];
	
	self.visibleSortMessageRecordArray = nil;
	self.selectedMessageObject = nil;
    self.audioToolsKit = nil;
    self.currentSessionObject = nil;
    
	if (self.updateVoicePeakPowerTimer != nil)
	{
		[self.updateVoicePeakPowerTimer invalidate];
		self.updateVoicePeakPowerTimer = nil;
	}
	currentTextViewLocation = 0;
}

// 释放IB资源
- (void)releaseOutlets {
	// views
	self.messageSessionContentTableView = nil;
	self.timeProgressView = nil;
	self.voicePeakImageView = nil;
	self.recordingView = nil;
	self.recordingWarnningView = nil;
    self.microphoneControlView = nil;
    
    [self.messageContainerToolsView removeFromSuperview];
    self.messageContainerToolsView = nil;
    
    self.toolsControlView = nil;
    self.docInteractionController = nil;
	
	// lable
	self.recordingWarnningLable = nil;
	self.countTimeLable = nil;
}


#pragma mark -
#pragma mark Initialization Function Method

// 判断当前账号是否是云视小秘书
- (BOOL)isRongKeServiceAccount
{
    return [self.currentSessionObject.sessionID isEqualToString:RONG_KE_SERVICE];
}

// Jacky.Chen:2016.02.24 方法封装 初始化tableView
- (void)setupMessageContentTableView
{
    self.messageSessionContentTableView = [[UITableView alloc] initWithFrame:MESSAGE_TABLE_INIT_FRAME];
    [self.view insertSubview:self.messageSessionContentTableView atIndex:0];
    self.messageSessionContentTableView.delegate = self;
    self.messageSessionContentTableView.dataSource = self;
    self.messageSessionContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageSessionContentTableView.backgroundColor = COLOR_CHAT_VIEW_BACKGROUND;
    
}

// Jacky.Chen:2016.02.24 add
// 向RecordingView中添加进度条控件
- (void)setupRecordingView
{
    // 添加语音录制转圈方式显示时长view
    if (self.downloadIndicatorView)
    {
        [self.downloadIndicatorView removeFromSuperview];
    }
    
    // 初始化圆弧Frame
    DownloadIndicator *downloadIndicator = [[DownloadIndicator alloc] initWithFrame:CGRectMake(-1, -1, 116+2, 116+2) type: kRMClosedIndicator];
    [downloadIndicator setBackgroundColor:[UIColor clearColor]];
    self.downloadIndicatorView = downloadIndicator;
    [self.recordingView insertSubview:self.downloadIndicatorView atIndex:0];
    
    // 设置圆弧填充颜色以及线条颜色
    [self.downloadIndicatorView setFillColor:[UIColor clearColor]];
    [self.downloadIndicatorView setStrokeColor:COLOR_WITH_RGB(55, 185, 239)];
    
    // 设置圆弧线宽等参数
    self.downloadIndicatorView.radiusPercent = 0.5;
    self.downloadIndicatorView.coverWidth = 3.0;
    self.downloadIndicatorView.radiusWidth = 3.0;
    self.downloadIndicatorView.isStickShop = NO;
    
    self.downloadIndicatorView.closedIndicatorBackgroundStrokeColor = [UIColor clearColor];
    [self.downloadIndicatorView loadIndicator];

}
// 创建点击录音按钮时的maskView
- (void)showMaskView
{
    if (self.maskView) {
        self.maskView.hidden = NO;
        return;
    }
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, -64,UISCREEN_RESOLUTION_SIZE.width, UISCREEN_RESOLUTION_SIZE.height - 49)];
    
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.5f;
    
    [self.view insertSubview:maskView aboveSubview:self.messageSessionContentTableView];
    self.maskView = maskView;
    
}
// 隐藏MaskView
- (void)removeMaskView
{
    if(self.maskView && self.maskView.hidden == NO)
    {
        self.maskView.hidden = YES;
    }
}

// 创建消息会话工具栏窗口
- (void)createMessageToolsContainerView
{
    self.messageContainerToolsView = [[RKMessageContainerToolsView alloc] initWithFrame:MESSAGE_CONTAINER_TOOLS_VIEW_INIT_FRAME];
    self.messageContainerToolsView.delegate = self;
    [self.view addSubview:self.messageContainerToolsView];
    
    // 设置其他控件可用
    [self enableViewAction:YES];
}

// 初始化所有变量值
- (void)initAllVariableValue
{
    // 创建使用系统打开文档的容器类对象
    UIDocumentInteractionController * tempDocInteractionController = [[UIDocumentInteractionController alloc] init];
    self.docInteractionController = tempDocInteractionController;
    self.docInteractionController.delegate = self;
    
    // 初始化加载数量参数
    isEditing                = NO;
    currentTextViewLocation  = 0;
    self.isAppearFirstly     = YES;
    self.lastDivideGroupDate = nil;
    isShowToolsControlView   = NO;
    loadMessageCount         = 0;
    self.isRefreshing        = NO;
    self.lastTouchPoint      = CGPointZero;
    self.isExecuteAt = YES;
    self.isAtAll = NO;
    self.atUserArray = [NSMutableArray array];
    isFirstLoadMMS = YES;
}

// 初始化bar上的button
- (void)initNavigationBarButton
{
    NSString *rightButtonImageName = nil;
    // 群聊
    if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE){
        rightButtonImageName = @"button_session_group_details_info";
    }
    else {
        // 单聊
        rightButtonImageName = @"button_session_single_details_info";
    }
    
    // 增加导航栏右侧按钮，点击后进入会话信息管理页面
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:rightButtonImageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                    style:UIBarButtonItemStyleBordered
                                                                   target:self
                                                                   action:@selector(touchSessioninfoButton)];
    self.navigationItem.rightBarButtonItem = rightButton;

    // 定制返回按钮
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_BACK", @"返回")  style:UIBarButtonItemStylePlain  target:self  action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

// 初始化UI和控件窗口
- (void)initUIControlView
{
    NSLog(@"DEBUG: initUIControlView");
    
    // 设置捕捉触摸事件的遮罩层
	UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height)];
	maskView.backgroundColor = [UIColor clearColor]; //设置为透明
	maskView.tag = MASK_VIEWS_TAG; //设定TAG标记View
	maskView.hidden = YES;
	[self.view insertSubview:maskView belowSubview:self.toolsControlView];
	
	// 设置表格背景色（2013.02.28设置TableView中列表背景色设置为MMSTABLE_BGCOLOR则会引起UI上的一条不明的线条？，
    // 所以将TableView背景色清除，默认显示出View的背景色）
	self.messageSessionContentTableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = MMSTABLE_BGCOLOR;
    
	//设置编辑状态下可以选择
	self.messageSessionContentTableView.allowsSelectionDuringEditing = YES;
	
	// 初始化控件坐标
	chatTextViewRect = GROWING_TEXTVIEW_INIT_FRAME;
    
    // 增加新消息提醒view
    self.nMessagePromptButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect rx = [UIScreen mainScreen].bounds;
    self.nMessagePromptButton.frame = CGRectMake(rx.size.width+135,15, 500.0/3, 120.0/4);
    [self.nMessagePromptButton addTarget:self action:@selector(hideNewMessagePromptView:) forControlEvents:UIControlEventTouchUpInside];
    [self.nMessagePromptButton setBackgroundImage:[UIImage imageNamed:@"msglist_newmsgtip_bg_n"]
                             forState:UIControlStateNormal];
    [self.nMessagePromptButton setBackgroundImage:[UIImage imageNamed:@"msglist_newmsgtip_bg_h"]
                             forState:UIControlStateHighlighted];
    self.nMessagePromptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.nMessagePromptButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.nMessagePromptButton.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    [self.nMessagePromptButton setTitleColor:[UIColor colorWithRed:69/255.0 green:192/255.0 blue:26/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.view addSubview:self.nMessagePromptButton];
    // 累积的新消息个数(一般用于用户正翻看历史消息时)
    self.addNewMessageCount = 0;
    
    // 一屏显示最大文本条数，如果多余此数，显示未读信息提醒view
    if (self.currentSessionObject.unReadMsgCnt > 6)
    {
        // 未读消息提醒view
        self.nMessageUnReadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.nMessageUnReadButton.frame = CGRectMake(rx.size.width-135,15, 500.0/3, 120.0/4);
        [self.nMessageUnReadButton addTarget:self action:@selector(hideUnReadMessagePromptView:) forControlEvents:UIControlEventTouchUpInside];
        [self.nMessageUnReadButton setBackgroundImage:[UIImage imageNamed:@"msglist_unreadtip_bg_n"]
                                             forState:UIControlStateNormal];
        [self.nMessageUnReadButton setBackgroundImage:[UIImage imageNamed:@"msglist_unreadtip_bg_h"]
                                             forState:UIControlStateHighlighted];
        self.nMessageUnReadButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.nMessageUnReadButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.nMessageUnReadButton.titleLabel.font = [UIFont systemFontOfSize: 12.0];
        [self.nMessageUnReadButton setTitle:[NSString stringWithFormat:@"您有%d条未读消息",self.currentSessionObject.unReadMsgCnt] forState:UIControlStateNormal];
        [self.nMessageUnReadButton setTitleColor:[UIColor colorWithRed:69/255.0 green:192/255.0 blue:26/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.view addSubview:self.nMessageUnReadButton];
    }
    
    // 默认隐藏录音提示和声浪的窗口
    self.recordingView.hidden = YES;
    // 默认隐藏录音不到一秒的警告窗口
    self.recordingWarnningView.hidden = YES;
    
    // 获取当前会话的草稿信息，如果存在直接赋值给输入框，并将键盘弹起来（从ViewWillAppear---ViewDidLoad,解决聊天页面切换到其他modal出来页面再返回后底部工具条被键盘挡住的问题）
    NSString *textDraft = [RKCloudChatMessageManager getDraft:self.currentSessionObject.sessionID];
    if ([textDraft length] > 0) {
        self.messageContainerToolsView.inputContainerToolsView.growingTextView.text = textDraft;
        [self.messageContainerToolsView.inputContainerToolsView.growingTextView becomeFirstResponder];
    }
}

// 增加所有的通知事件方法
- (void)addAllNotificationCenter
{
    // 注册键盘显示事件
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 注册键盘隐藏事件
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // 注册状态栏frame改变事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willChangeStatusBarFrameNotification:)
                                                 name:UIApplicationWillChangeStatusBarFrameNotification
                                               object:nil];
    
    // 提醒功能只对群聊启用
    if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        // 注册UITextView的text改变的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textViewTextDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object: nil];
    }
}

// 初始化聊天会话上滑和下拉控件和加载数据的block
- (void)initChatSessionRefreshingControl
{
    
    // 为了dealloc方法能够响应，必须使用weakSelf指针
    __weak RKChatSessionViewController *weakSelf = self;
    
    // 增加下拉刷新
    weakSelf.messageSessionContentTableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        NSString *messageId = nil;
        if (self.visibleSortMessageRecordArray && [self.visibleSortMessageRecordArray count] > 0)
        {
            for (RKCloudChatBaseMessage *existMessageObject in self.visibleSortMessageRecordArray)
            {
                // 判断消息记录是否存在
                if ([existMessageObject isKindOfClass:[RKCloudChatBaseMessage class]])
                {
                    messageId = existMessageObject.messageID;
                    break;
                }
            }
        }
        
        [RKCloudChatMessageManager queryChatMsgs:weakSelf.currentSessionObject.sessionID
                                        chatType:(weakSelf.currentSessionObject.sessionType+1)
                                           msgId:messageId
                                       msgCounts:LOAD_MESSAGE_COUNT
                                        callBack:^(NSArray<RKCloudChatBaseMessage *> *messageObjectArray) {
                                            int row = (int)weakSelf.visibleSortMessageRecordArray.count;
                                            if (messageObjectArray && [messageObjectArray count] > 0) {
                                                // 加载排序后的消息内容
                                                [weakSelf loadSortMessageRecord:messageObjectArray withLoadDirection:LoadMessageOld];
                                            }
                                            row = (int)self.visibleSortMessageRecordArray.count - row;
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.messageSessionContentTableView.header endRefreshing];
                                                
                                                // 重新加载表格数据
                                                [self reloadTableView];
                                                // 判断滑动时播放声音，当声音Cell可见时，继续播放动画
                                                [self voiceCellPlaying];
                                                
                                                
                                                if (self.visibleSortMessageRecordArray && self.visibleSortMessageRecordArray.count > 0)
                                                {
                                                    if (isFirstLoadMMS == NO)
                                                    {
                                                        [self.messageSessionContentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                                    }
                                                    else
                                                    {
                                                        [self.messageSessionContentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.visibleSortMessageRecordArray.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                                                    }
                                                }
                                                
                                                isFirstLoadMMS = NO;

                                            });
                                            
                                            // 获取所有的未读消息，用于页面一屏显示的数据不足全部未读条数，右上角提醒按钮使用
                                            /*if (isFirstLoadMMS == YES && self.unReadMessageArray == nil)
                                            {
                                                self.unReadMessageArray = [RKCloudChatMessageManager queryLocalChatMsgs:self.currentSessionObject.sessionID
                                                                                                         withCreateDate:headmostMessageTimestamp
                                                                                                       withStorageIndex:0
                                                                                                           messageCount:self.currentSessionObject.unReadMsgCnt];
                                            }*/
                                            
                                            
                                        }];
        
    }];
    
    // 加载历史记录
    [self.messageSessionContentTableView.header beginRefreshing];
}


#pragma mark -
#pragma mark Message Record Load/Update Function

/*
 loadSortMessageRecord-加载排序后的消息内容
 按时间从早到晚排列，此方法将消息以时间间隔分组消息。(详见TIME_BLANK)每隔TIME_BLANK秒，为一个消息组，
 并且仅限排重处理
 */
- (void)loadSortMessageRecord:(NSArray *)arraySortMessageRecord withLoadDirection:(LoadMessageDirection)loadDirection
{
    // 非空验证
    if (!arraySortMessageRecord || [arraySortMessageRecord count] == 0)
    {
        return;
    }
    
    NSLog(@"MMS: loadSortMessageRecord: arraySortMessageRecord count = %lu", (unsigned long)[arraySortMessageRecord count]);
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    
    // 消息个数
    NSUInteger messageCount = [arraySortMessageRecord count];
    
    RKCloudChatBaseMessage *messageObject = nil;
    // 遍历本会话的所有记录将未发送的记录并且不在发送队列中的记录置为“发送失败”状态
    for (int i = (int)messageCount-1; i >= 0; i--)
    {
        // 获取消息对象
        messageObject = [arraySortMessageRecord objectAtIndex:i];
        if ([messageObject isKindOfClass:[RKCloudChatBaseMessage class]] == NO)
        {
            continue;
        }
        // 防止同一条消息重复显示
        BOOL bExist = NO;
        for (RKCloudChatBaseMessage *existMessageObject in self.visibleSortMessageRecordArray)
        {
            // 判断消息记录是否存在
            if ([existMessageObject isKindOfClass:[RKCloudChatBaseMessage class]] &&
                [existMessageObject.messageID isEqualToString:messageObject.messageID])
            {
                bExist = YES;
                break;
            }
        }
        
        // 此条消息记录已经存在则继续下一条
        if (bExist) {
            continue;
        }
        
        // 如果当前消息和之前最后一条消息时间间隔大于TIME_BLANK 或者 当前消息和上一条消息有一个是邀请消息但另一个不是邀请消息时，建立新分组
        NSString *dateString = [self createTimeGroupWithMessageCreateTime:[NSDate dateWithTimeIntervalSince1970:messageObject.sendTime] andLastMessageDate:self.lastDivideGroupDate];
        if (dateString)
        {
            [mutableArray addObject:dateString];
        }
        
        // 将消息添加至数组
        [mutableArray addObject:messageObject];
    }
    
    // 如果有数据，添加到visibleSortMessageRecordArray中
    if (mutableArray)
    {
        NSLog(@"MMS: loadSortMessageRecord: mutableArray count = %lu", (unsigned long)[mutableArray count]);
        
        switch (loadDirection)
        {
            case LoadMessageOld:
            {
                {
                    [mutableArray addObjectsFromArray:self.visibleSortMessageRecordArray];
                    self.visibleSortMessageRecordArray = mutableArray;
                }
                break;
            }
            case LoadMessageNew:
            {
                {
                    [self.visibleSortMessageRecordArray addObjectsFromArray:mutableArray];
                }
                break;
            }
            default:
            {
                break;
            }
        }
        
        NSLog(@"MMS: loadSortMessageRecord: visibleSortMessageRecordArray count = %lu", (unsigned long)[self.visibleSortMessageRecordArray count]);
    }
}

// 进入消息窗口页面时，调用的加载消息
- (void)loadMessageRecord:(BOOL)isFirstLoad
{
    switch (self.sessionShowType)
    {
        case SessionListShowTypeNomal:
        {
            {
                [self loadMessageSessionRecord:isFirstLoad withLoadDirection:LoadMessageOld];
            }
            break;
        }
        case SessionListShowTypeSearchListMain:
        case SessionListShowTypeSearchListCategory:
        {
            {
                if (isFirstLoad)
                {
                    // 查询搜索消息前后的MessageObjec对象
                    [RKCloudChatMessageManager queryLocalChatMsgs:self.currentSessionObject.sessionID
                                             withCurrentMessageId:self.currentSessionObject.lastMessageObject.messageID
                                                    messageCounts:20
                                                        onSuccess:^(NSArray<RKCloudChatBaseMessage *> *resultArray) {
                                                            if (resultArray && resultArray.count > 0)
                                                            {
                                                                [self.visibleSortMessageRecordArray addObjectsFromArray:resultArray];
                                                            }
                                                        } onFailed:^(int errorCode) {
                        
                    }];
                }
                else
                {
                    [self loadMessageSessionRecord:isFirstLoad withLoadDirection:LoadMessageOld];
                }
            }
            break;
        }
        default:
            break;
    }
}

- (NSArray *)loadOldMessage:(long)headmostMessageTimestamp
{
    // 分组消息
    headmostMessageTimestamp = [ToolsFunction getCurrentSystemDateSecond];
    long headmostMessageIndex = 0;
    
    // 初始化消息数组
    if (self.visibleSortMessageRecordArray && [self.visibleSortMessageRecordArray count] > 0)
    {
        RKCloudChatBaseMessage *headmostMessageObject = nil;
        for (int i = 0; i < [self.visibleSortMessageRecordArray count]; i++)
        {
            headmostMessageObject = [self.visibleSortMessageRecordArray objectAtIndex:i];
            if ([headmostMessageObject isKindOfClass:[RKCloudChatBaseMessage class]])
            {
                headmostMessageTimestamp = headmostMessageObject.sendTime;
                headmostMessageIndex = headmostMessageObject.indexStorage;
                break;
            }
        }
    }
    
    // 获取排序后消息数据库对象数组（RKCloudChatBaseMessage）
    NSArray *arraySortMessageRecord = [RKCloudChatMessageManager queryLocalChatMsgs:self.currentSessionObject.sessionID
                                                                     withCreateDate:headmostMessageTimestamp
                                                                   withStorageIndex:headmostMessageIndex
                                                                       messageCount:LOAD_MESSAGE_COUNT];
    
    return arraySortMessageRecord;
}

- (NSArray *)loadNewMessage:(long)headmostMessageTimestamp
{
    headmostMessageTimestamp = [ToolsFunction getCurrentSystemDateSecond];
    long headmostMessageIndex = 0;
    // 初始化消息数组
    if (self.visibleSortMessageRecordArray && [self.visibleSortMessageRecordArray count] > 0)
    {
        RKCloudChatBaseMessage *headmostMessageObject = nil;
        for (int i = (int)([self.visibleSortMessageRecordArray count] - 1); i >= 0; i--)
        {
            headmostMessageObject = [self.visibleSortMessageRecordArray objectAtIndex:i];
            if ([headmostMessageObject isKindOfClass:[RKCloudChatBaseMessage class]])
            {
                headmostMessageTimestamp = headmostMessageObject.sendTime;
                headmostMessageIndex = headmostMessageObject.indexStorage;
                break;
            }
        }
    }
    
    // 获取排序后消息数据库对象数组（RKCloudChatBaseMessage）
    NSArray *arraySortMessageRecord = [RKCloudChatMessageManager queryNewChatMsgs:self.currentSessionObject.sessionID withCreateDate:headmostMessageTimestamp withStorageIndex:headmostMessageIndex messageCount:LOAD_MESSAGE_COUNT];
    
    return arraySortMessageRecord;
}

// 按组载入消息记录
- (void)loadMessageSessionRecord:(BOOL)isFirstLoad withLoadDirection:(LoadMessageDirection)loadDirection
{
    // 非空验证
    if (!self.currentSessionObject)
    {
        return;
    }
    
    NSLog(@"MMS: ***** loadMessageSessionRecord: isFirstLoad = %d begin *****", isFirstLoad);
    
    NSArray *arraySortMessageRecord = nil;
    
    // 分组消息
    long headmostMessageTimestamp = [ToolsFunction getCurrentSystemDateSecond];
    
    // 从数据库中获取相关的数据
    switch (loadDirection)
    {
        case LoadMessageOld:
        {
            arraySortMessageRecord = [self loadOldMessage:headmostMessageTimestamp];
        }
            break;
        case LoadMessageNew:
        {
            arraySortMessageRecord = [self loadNewMessage:headmostMessageTimestamp];
        }
        default:
            break;
    }
    
    if ([arraySortMessageRecord count] > 0)
    {
        // 加载排序后的消息内容
        [self loadSortMessageRecord:arraySortMessageRecord withLoadDirection:loadDirection];
    }
    
    // 获取所有的未读消息，用于页面一屏显示的数据不足全部未读条数，右上角提醒按钮使用
    if (isFirstLoad == YES && self.unReadMessageArray == nil)
    {
        self.unReadMessageArray = [RKCloudChatMessageManager queryLocalChatMsgs:self.currentSessionObject.sessionID
                                                                 withCreateDate:headmostMessageTimestamp
                                                               withStorageIndex:0
                                                                   messageCount:self.currentSessionObject.unReadMsgCnt];
    }
    
    NSLog(@"MMS: ***** loadMessageSessionRecord end *****");
}

// 加载更多消息
- (void)loadHistoryMessageRecord:(LoadMessageDirection)loadDirection
{
    NSLog(@"UA: loadHistoryMessageRecord");
    
    // Jacky.Chen:2016.02.16:本地加载的所有消息数
    NSUInteger messageCounts = self.visibleSortMessageRecordArray.count;
    // 加载更多历史消息
    [self loadMessageSessionRecord:NO  withLoadDirection:loadDirection];
    // Jacky.Chen:2016.02.16:加载完毕后滚动到的行
    NSUInteger row = self.visibleSortMessageRecordArray.count - messageCounts;
    
    // 重新加载表格数据
    [self reloadTableView];
    // 判断滑动时播放声音，当声音Cell可见时，继续播放动画
    [self voiceCellPlaying];
    
    if (loadDirection == LoadMessageOld)
    {
        // (Jacky.Chen:2016.02.16:优化原有滚动方法）滚动至加载前表格位置(无动画)
        [self.messageSessionContentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}


#pragma mark -
#pragma mark Message Object Function Method

// 根据messageObject删除消息
- (void)deleteMMSWithMessageObject:(RKCloudChatBaseMessage *)messageObject
{
    if (messageObject == nil) {
        return;
    }
    
    NSLog(@"MMS: deleteMMSWithMessageObject: messageID = %@", messageObject.messageID);
    
    NSUInteger delMessageIndex = [self.visibleSortMessageRecordArray indexOfObject:messageObject];
    
    // 删除此条选中的消息数据
    [RKCloudChatMessageManager deleteChatMsg:messageObject.messageID];
    // 从内存数组中移除此消息记录
    [self.visibleSortMessageRecordArray removeObject:messageObject];
    // 修改加载消息个数
    loadMessageCount--;
    
    // 删除最后的时间分组或者删除前后都是时间分组的前一个
    if ([self.visibleSortMessageRecordArray count] > 0 &&
        delMessageIndex <= [self.visibleSortMessageRecordArray count])
    {
        // 获得删除消息的前一条消息
        RKCloudChatBaseMessage *previousMessageObject = [self.visibleSortMessageRecordArray objectAtIndex:delMessageIndex-1];
        
        // 如果删除的是最后一条消息记录
        if (delMessageIndex == [self.visibleSortMessageRecordArray count])
        {
            // 删除最后一条记录后前一条不是消息记录，即删除时间分组文本字符
            if(![previousMessageObject isKindOfClass:[RKCloudChatBaseMessage class]])
            {
                [self.visibleSortMessageRecordArray removeObject:previousMessageObject];
            }
        }
        else {
            // 获得删除消息的下一条消息
            RKCloudChatBaseMessage *nextMessageObject = [self.visibleSortMessageRecordArray objectAtIndex:delMessageIndex];
            
            // 如果删除的消息记录前后都是时间分组则需要删除前一条时间分组
            if(![nextMessageObject isKindOfClass:[RKCloudChatBaseMessage class]] &&
               ![previousMessageObject isKindOfClass:[RKCloudChatBaseMessage class]])
            {
                [self.visibleSortMessageRecordArray removeObject:previousMessageObject];
            }
        }
    }
    
	// 重新加载消息
	[self reloadTableView];
    // 判断滑动时播放声音，当声音Cell可见时，继续播放动画
    [self voiceCellPlaying];
}


// 根据messageObject转发消息消息
- (void)forwardMMSWithMessageObject:(RKCloudChatBaseMessage *)messageObject
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    SelectFriendsViewController *selectFriendsViewCtroller = [[SelectFriendsViewController alloc] init];
    selectFriendsViewCtroller.friendsListType = FriendsListTypeForward;
    selectFriendsViewCtroller.currentMessageObject = messageObject;
    
    // 设置动画
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    [self.navigationController pushViewController:selectFriendsViewCtroller animated: NO];
}

// 根据messageObject撤回消息消息
- (void)revokeMMSWithMessageObject:(RKCloudChatBaseMessage *)messageObject
{
    [RKCloudChatMessageManager syncRevokeMessage:messageObject.messageID onSuccess:^(NSString *messageId)
    {
         NSLog(@"MESSAGE-SESSION:: revokeMMSWithMessageObject: Success");
    } onFailed:^(int errorCode) {
        
    }];
}

// 增加新的消息记录到数组中
- (void)addNewMessageToArray:(RKCloudChatBaseMessage *)currentObject
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    if (currentObject == nil) {
        NSLog(@"ERROR: addNewMessageToArray: currentObject = %@", currentObject);
        return;
    }

    RKCloudChatBaseMessage *lastMessage = nil;
    id obj = nil;
    for (int i = (int)[self.visibleSortMessageRecordArray count] - 1; i >= 0; i--)
    {
        obj = [self.visibleSortMessageRecordArray objectAtIndex: i];
        if ([obj isKindOfClass:[RKCloudChatBaseMessage class]])
        {
            lastMessage = (RKCloudChatBaseMessage *)obj;
            break;
        }
    }
    
    // 初始化时间，若当前没有消息则默认时间为最早时间，若有消息则为最后一条消息的时间
    NSDate *lastMessageDate = nil;
    if (self.visibleSortMessageRecordArray && [self.visibleSortMessageRecordArray count] > 0)
    {
        // 存放消息列表内最后一条消息的到达时间
        lastMessageDate = [NSDate dateWithTimeIntervalSince1970:lastMessage.sendTime];
    }
    
    NSDate * currentObjectCreateDate = [NSDate dateWithTimeIntervalSince1970:currentObject.sendTime];
    
    // 创建时间分组
    NSString *dateString = [self createTimeGroupWithMessageCreateTime:currentObjectCreateDate andLastMessageDate:lastMessageDate];
    if (dateString) {
        [self.visibleSortMessageRecordArray addObject:dateString];
    }
    
    // 将消息添加至数组
    [self.visibleSortMessageRecordArray addObject:currentObject];
    // 修改已加载消息的数目
    loadMessageCount++;
    
    NSLog(@"MESSAGE-SESSION: addNewMessageToArray: currentObject.messageID = %@, self.visibleSortMessageRecordArray count = %lu", currentObject.messageID, (unsigned long)[self.visibleSortMessageRecordArray count]);
}

// 创建时间分组
- (NSString *)createTimeGroupWithMessageCreateTime:(NSDate *)messageCreateDate
                                andLastMessageDate:(NSDate *)lastMessageDate
{
    NSString *timeStr = nil;
    
    // 时间间隔是TIME_BLANK
    if (lastMessageDate == nil || [ToolsFunction sameDayWithNewDate:messageCreateDate andOldDate:self.lastDivideGroupDate withTimeBlank:TIME_BLANK] == NO)
    {
        // 保存最近一次分组的时间
        self.lastDivideGroupDate = messageCreateDate;
        
        // 返回的时间格式类型有四种  1，当天 （HH:mm）；2，昨天 （昨天 HH:mm） 3，本周（星期三 HH:mm）；4，其它（yyyy年mm月dd日 HH:mm）
        timeStr = [ToolsFunction formatDateString:messageCreateDate];
    }
    
    return timeStr;
}


// 重发选择的记录
- (void)resendSelectRecord
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // 重试发送MMS消息或文件
    [RKCloudChatMessageManager reSendChatMsg:self.selectedMessageObject.messageID];
    
    // 临时将状态设置为发送中
    self.selectedMessageObject.messageStatus = MESSAGE_STATE_SEND_SENDING;
    
    // 若拿到消息不为空（即取到消息对象）
    NSUInteger row = [self.visibleSortMessageRecordArray indexOfObject:self.selectedMessageObject];
    // 仅当找到消息时，才做UI更新
    if (row != NSNotFound)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [self.messageSessionContentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                 withRowAnimation:UITableViewRowAnimationNone];
    }
}



#pragma mark -
#pragma mark System Interface Methods

// 打开系统相机准备拍照
- (void)openSystemCameraPickerController:(BOOL)isphoto
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // 照相 设置各种参数，不能使用设备时提示
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    
    // 当进入时，移除状态栏上提示，以避免同时执行两个动画
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (window.tag == MMSWINDOW_TAG) {
            [window setHidden:YES];
            break;
        }
    }
    
    //判断当前设备是否支持摄像头
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //设置资源类型为摄像机
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        if (isphoto) {
            pickerController.mediaTypes = @[(NSString *)kUTTypeImage];
        }
        else  // 视频
        {
            pickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            // 设置录制视频的质量
            [pickerController setVideoQuality:UIImagePickerControllerQualityTypeMedium];
            //设置最长摄像时间
            [pickerController setVideoMaximumDuration:10.0f];
            // 设置是否可以管理已经存在的图片或者视频
//            [pickerController setAllowsEditing:YES];
            pickerController.modalPresentationStyle= UIModalPresentationOverFullScreen;
        }
        
        //将拍照视图推入当前视图
        [self presentViewController:pickerController animated:YES completion:^{
            
        }];
    }
    else {
        [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_UNSUPPORT_CAMERA", "您的设备不支持摄像头")
                             withTitle:nil
                            withButton:NSLocalizedString(@"STR_OK", "确定")
                              toTarget:nil];
    }
}

// 打开系统相册选择照片
- (void)openSystemPhotoLibraryPickerController
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // 照相 设置各种参数，不能使用设备时提示
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    
    //判断当前设备是否支持照片库
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        //设置资源类型为照片库
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //将相册视图推入当前视图
        [self presentViewController:pickerController animated:YES completion:^{
            // 设置状态栏默认风格
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

// 多人语音
- (void)manyPeopleVoiceChat
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];

    if ([appDelegate.meetingManager isOwnInMeeting])
    {
        if ([self.currentSessionObject.sessionID isEqualToString:appDelegate.meetingManager.sessionId] == NO)
        {
            [UIAlertView showAutoHidePromptView:@"发起多人语音失败：当前有正在进行的多人语音" background:nil showTime:1.5];
            
            return;
        }
        
        [appDelegate.meetingManager pushMeetingRoomViewControllerInViewController:self];
    }
    else {
        [appDelegate.meetingManager createMeetingRoomByMeetingId:self.currentSessionObject.sessionID andMeetingMembers:[RKCloudChatMessageManager queryGroupUsers:self.currentSessionObject.sessionID] andViewController:self];
    }
}

// 语音
- (void)voiceCall
{
    // 呼叫语音电话
    [[AppDelegate appDelegate].callManager dialAudioCall:self.currentSessionObject.sessionID];
}

// 视频
- (void)videoCall
{
    // 呼叫视频电话
    [[AppDelegate appDelegate].callManager dialVideoCall:self.currentSessionObject.sessionID];

}

#pragma mark -
#pragma mark Touch Actions Methods

// 返回上一级
- (void)touchBackButton
{
    NSLog(@"UA: RKChatSessionViewController - touchBackButton");
    
	// 回到消息会话后，更新会话对象，如果会话中没有一条消息则删除此会话对象。
	if (self.parentChatSessionListViewController && [self.parentChatSessionListViewController isKindOfClass:[RKChatSessionListViewController class]])
	{
        // 聊天结束清理缓存数据
        [RKCloudChatMessageManager cleanupChatCacheData:self.currentSessionObject.sessionID];
        
        // 加载所有的会话列表
        [(RKChatSessionListViewController *)self.parentChatSessionListViewController loadAllChatSessionList];
	}
	
}

// 查看会话信息管理页面
- (void)touchSessioninfoButton
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	// 查看会话信息管理页面
	RKChatSessionInfoViewController *vwcSessionInfo = [[RKChatSessionInfoViewController alloc] initWithNibName:@"RKChatSessionInfoViewController" bundle:nil];
    vwcSessionInfo.rkChatSessionViewController = self;
    
    self.sessionInfoViewController = vwcSessionInfo;
    
	[self.navigationController pushViewController:vwcSessionInfo animated:YES];
}

// 显示表情页面
- (void)touchDownEmotionButton{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    // 判断当前表情窗口是否显示
    if (isShowToolsControlView)
    {
        // 判断键盘打开还是关闭，键盘之间的切换
        if ([self.messageContainerToolsView.inputContainerToolsView.growingTextView.internalTextView isFirstResponder])
        {
            // 取消键盘
            [self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
            
            // 弹出更多操作工具窗口
            [self showToolsControlView:YES];
            
            // 显示表情窗口
            [self.toolsControlView showEmoticonView:YES];
            
            // 重置TableView的位置
            [self moveMessageTableViewFrame];
        }
        else
        {
            // 弹出键盘
            //[self.inputContainerToolsView.textView becomeFirstResponder];
            
            // 弹出更多操作工具窗口
            [self showToolsControlView:YES];
            
            // 显示表情窗口
            [self.toolsControlView showEmoticonView:YES];
            
            // 重置TableView的位置
            [self moveMessageTableViewFrame];
        }
    }
    else
    {
        // 表情符号窗口没有显示，如果键盘打开着则关闭键盘
        if ([self.messageContainerToolsView.inputContainerToolsView.growingTextView.internalTextView isFirstResponder]) {
            // 取消键盘
            [self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
        }
        
        // 使遮罩层可见
        UIView *maskView = (UIView *)[self.view viewWithTag:MASK_VIEWS_TAG];
        [maskView setHidden:NO];
        
        // 弹出更多操作工具窗口
        [self showToolsControlView:YES];
        
        // 显示表情界面
        [self.toolsControlView showEmoticonView:YES];
        
        // 重置TableView的位置
        [self moveMessageTableViewFrame];

    }
}

// 点击发送文本消息的发送按钮
- (void)touchSendButton {
    // 发送文字消息
    [self sendTextMessage];
}

// 点击重发按钮事件
- (void)touchResendButton:(RKCloudChatBaseMessage *)messageObject
{
	if (messageObject == nil) {
		return;
	}
    
	self.selectedMessageObject = messageObject;
    
    // 重发
    [self resendSelectRecord];
}

// 点击播放音频文件
- (void)touchPlayButton:(MessageVoiceTableCell *)voiceCell
{
    if ([AppDelegate appDelegate].callManager.callViewController != nil || [[AppDelegate appDelegate].meetingManager isOwnInMeeting] == YES)
    {
        [UIAlertView showAutoHidePromptView:@"设备正忙，请稍后重试。" background:nil showTime:1.5];
        
        return;
    }
    
    NSLog(@"UA: RKChatSessionViewController -> touchPlayButton - messageID = %@", voiceCell.audioMessage.messageID);

    // 将音频消息状态从未读更新为已读
	if (voiceCell.audioMessage.messageStatus == MESSAGE_STATE_RECEIVE_DOWNED)
	{
		// 更新消息状态为“已读”状态（已下载/未读 --> 已读）
        [RKCloudChatMessageManager updateMsgStatusHasReaded:voiceCell.audioMessage.messageID];
	}
    
    // 删除所有待播的语音文件
    [self.arrayVoiceJustDownload removeAllObjects];
    
    // 先停止正在播放的声音
    [self.audioToolsKit stopPalyVoice];
    // 设置播放代理
    self.audioToolsKit.playerDelegate = voiceCell;
    // 开始播放MMS语音消息
    [self.audioToolsKit startPalyVoice:voiceCell.audioMessage];
}

- (void)pushSelectedGroupMemberView
{
    SelectGroupMemberViewController *viewController = [[SelectGroupMemberViewController alloc] initWithNibName:@"SelectGroupMemberViewController" bundle:nil];
    viewController.groupId = self.currentSessionObject.sessionID;
    viewController.delegate = self;
    viewController.isAtGroupMember = YES;
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [ToolsFunction moveUpTransition:YES forLayer: appDelegate.window.layer];
    [self.navigationController pushViewController:viewController animated: NO];
}

- (void)textViewTextDidChangeNotification:(NSNotification *)notification
{
    if (self.isExecuteAt == NO || self.isPushAtView)
    {
        return;
    }

    HPTextViewInternal *textView = (HPTextViewInternal *)[notification object];
    
    if (textView.text && [textView.text length] > 0)
    {
        NSString *inputString = textView.text;
        if ([inputString hasSuffix: @"@"])
        {
            if (self.isPushAtView == NO) {
                self.isPushAtView = YES;
            }
            
            [self pushSelectedGroupMemberView];
        }
    }
}

// 检测发送的文本中是否存在at的成员
- (void)derectAtGroupMember:(NSString *)sendText
{
    if (self.isAtAll || [self.atUserArray count] == 0)
    {
        return;
    }
    
    NSString *atAccount = nil;
    NSRange range;
    for (int i = 0; i < [self.atUserArray count]; i++)
    {
        atAccount = [self.atUserArray objectAtIndex: i];
        range = [sendText rangeOfString: atAccount];
        if (range.length <= 0)
        {
            [self.atUserArray removeObject: atAccount];
        }
    }
}


#pragma mark -
#pragma mark SelectGroupMemberDelegate methods

- (void)selectedGroupMember:(NSArray *)selectedMemberArray
{
    if (selectedMemberArray == nil || [selectedMemberArray count] == 0)
    {
        return;
    }
    
    FriendTable *friendTable = [selectedMemberArray firstObject];
    
    if (friendTable.friendAccount == nil)
    {
        return;
    }
    self.isAtAll = NO;
    
    [self insertStringToTextView: friendTable.friendAccount];
    
    // 添加@的人
    [self.atUserArray addObject: friendTable.friendAccount];
}

- (void)atAllGroupMember
{
    self.isAtAll = YES;
    
    [self.atUserArray removeAllObjects];
    
    [self insertStringToTextView: @"所有成员"];
}

- (void)insertStringToTextView:(NSString *)textString
{
    // 将表情符号插入到相应的textView输入框的光标处
    NSMutableString *stringText = [NSMutableString stringWithString:self.messageContainerToolsView.inputContainerToolsView.growingTextView.text];
    [stringText insertString:textString atIndex:currentTextViewLocation];
    
    // 显示到textView输入框中
    self.messageContainerToolsView.inputContainerToolsView.growingTextView.text = stringText;
    
    // 移动当前光标位置
    currentTextViewLocation += [textString length];
    
    // 设置光标到输入表情的后面
    self.messageContainerToolsView.inputContainerToolsView.growingTextView.selectedRange = NSMakeRange(currentTextViewLocation, 0);
}

#pragma mark - Show New Message Prompt View

// 显示新消息提醒（用户滑动位置不在tableview最底部时提醒）
- (void)showNewMessagePromptView
{
    CGRect mainScreenBounds = [UIScreen mainScreen].bounds;
    
    if (CGRectGetMinX(self.nMessagePromptButton.frame) < CGRectGetWidth(mainScreenBounds)) {
        return;
    }
    
    // 开始位置
    [self.nMessagePromptButton setFrame:CGRectMake(mainScreenBounds.size.width+135,15, 500.0/3, 120.0/4)];
    [UIView beginAnimations:@"showNewMessagePromptViewAnimation" context:nil];
    // 设置动画时间
    [UIView setAnimationDuration:0.8f];
    // 接受动画代理
    [UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(imageViewDidStop:finished:context:)];
    // 结束位置
    [self.nMessagePromptButton setFrame:CGRectMake(mainScreenBounds.size.width-135,15, 500.0/3, 120.0/4)];
    //提交动画
    [UIView commitAnimations];
}

// 隐藏新消息提醒（用户滑动位置不在tableview最底部时提醒）
- (void)hideNewMessagePromptView:(id)sender
{
    CGRect mainScreenBounds = [ UIScreen mainScreen ].bounds;
    
    if (CGRectGetMinX(self.nMessagePromptButton.frame) > CGRectGetWidth(mainScreenBounds)) {
        return;
    }
    
    // 开始位置
    [self.nMessagePromptButton setFrame:CGRectMake(mainScreenBounds.size.width-135, 15, 500.0/3, 120.0/4)];
    [UIView beginAnimations:@"hideNewMessagePromptViewAnimation" context:nil];
    // 设置动画时间
    [UIView setAnimationDuration:0.2f];
    // 动画代理
    [UIView setAnimationDelegate:self];
    // 动画结束后执行方法
    if ([sender isKindOfClass:[UIButton class]])
    {
        [UIView setAnimationDidStopSelector:@selector(moveScrollToViewButtom)];
    }
    
    // 结束位置
    [self.nMessagePromptButton setFrame:CGRectMake(mainScreenBounds.size.width+135, 15, 500.0/3, 120.0/4)];
    //提交动画
    [UIView commitAnimations];
}

// scroll移动到view最底部
-(void)moveScrollToViewButtom
{
    // 清除提醒新消息个数
    self.addNewMessageCount = 0;
    // 自动滚动到tabView的最后一行(表格所含内容的最底部)
    [self.messageSessionContentTableView scrollRectToVisible:CGRectMake(0, self.messageSessionContentTableView.contentSize.height - 1, UISCREEN_BOUNDS_SIZE.width, 1)
                                  animated:YES];
}

// 隐藏未读消息提醒（用户滑动位置不在tableview最底部时提醒）
- (void)hideUnReadMessagePromptView:(id)sender
{
    CGRect rx = [UIScreen mainScreen].bounds;
    // 开始位置
    [self.nMessageUnReadButton setFrame:CGRectMake(rx.size.width-135,15, 500.0/3, 120.0/4)];
    [UIView beginAnimations:@"hideNewMessagePromptViewAnimation" context:nil];
    // 设置动画时间
    [UIView setAnimationDuration:0.2f];
    // 动画代理
    [UIView setAnimationDelegate:self];
    // 动画结束后执行方法
    if ([sender isKindOfClass:[UIButton class]])
    {
        [UIView setAnimationDidStopSelector:@selector(moveScrollToViewTop)];
    }
    else {
        self.unReadMessageArray = nil;
    }
    // 结束位置
    [self.nMessageUnReadButton setFrame:CGRectMake(rx.size.width+135,15, 500.0/3, 120.0/4)];
    //提交动画
    [UIView commitAnimations];
}

// scroll移动到view最顶部
- (void)moveScrollToViewTop
{
    RKCloudChatBaseMessage *messageObject = nil;
    
    // 加载数据
    for (int i = 0; i < [self.unReadMessageArray count]; i++)
    {
        messageObject = [self.unReadMessageArray objectAtIndex:i];
        if ([messageObject isKindOfClass: [RKCloudChatBaseMessage class]])
        {
            // 防止同一条消息重复显示
            BOOL bExist = NO;
            for (RKCloudChatBaseMessage *existMessageObject in self.visibleSortMessageRecordArray)
            {
                // 判断消息记录是否存在
                if ([existMessageObject isKindOfClass:[RKCloudChatBaseMessage class]] &&
                    [existMessageObject.messageID isEqualToString:messageObject.messageID])
                {
                    bExist = YES;
                    break;
                }
            }
            
            // 防止同一条消息重复显示
            if (bExist == NO)
            {
                // 增加未读消息记录到数组中
                [self.visibleSortMessageRecordArray insertObject:messageObject atIndex:0];
            }
        }
    }
    
    // 刷新tableview
    [self reloadTableView];
    [self voiceCellPlaying];
    
    // 自动滚动到tabView的第一行(表格所含内容的最顶部)
    [self.messageSessionContentTableView scrollRectToVisible:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 1) animated:YES];
    
    self.unReadMessageArray = nil;
}


#pragma mark -
#pragma mark UI Control Methods

// Jacky.Chen.2016.03.04:使能或者禁止导航控制器的popViewcontroller操作
- (void)enablePopAction:(BOOL)flag
{
    self.navigationController.navigationBar.userInteractionEnabled = flag;
    self.navigationController.interactivePopGestureRecognizer.enabled = flag;
}

- (void)enableViewAction:(BOOL)flag
{
	self.navigationItem.leftBarButtonItem.enabled = flag;
	self.navigationItem.rightBarButtonItem.enabled = flag;
	self.messageSessionContentTableView.userInteractionEnabled = flag;
	self.messageContainerToolsView.userInteractionEnabled = flag;
}

// 根据消息对象记录判断是否滚动到列表最下端
- (void)scrollTableViewPosition:(RKCloudChatBaseMessage *)chatMessage
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    if ([self.visibleSortMessageRecordArray count] <= 0 || chatMessage == nil) {
        NSLog(@"WARNGIN: scrollTableViewPosition - [self.visibleMessageArray count] <= 0 || currentObject == nil");
        return;
    }
    
    // 设置表格位置
    [self moveMessageTableViewFrame];
    
    float mmsCellHeight = [ChatManager heightForMessage:chatMessage];
    NSInteger nTableViewHeight = self.messageSessionContentTableView.contentOffset.y + self.messageSessionContentTableView.frame.size.height + mmsCellHeight;
    NSInteger nTableViewContentSizeHeight = self.messageSessionContentTableView.contentSize.height;
    
    // 只有消息在底部的时（允许30个像素的向上的偏移量）或者此消息是自己发送的最后一条消息，TableView滑动到最低部
    if (nTableViewHeight >= nTableViewContentSizeHeight - 30 ||
        (chatMessage.msgDirection == MESSAGE_SEND && [[self.visibleSortMessageRecordArray lastObject] isEqual:chatMessage]))
    {
        // 自动滚动到tabView的最后一行(表格所含内容的最底部)
        [self.messageSessionContentTableView scrollRectToVisible:CGRectMake(0, self.messageSessionContentTableView.contentSize.height - 1, UISCREEN_BOUNDS_SIZE.width, 1)
                                      animated:NO];
    }
    else {
        // 累积的新消息个数(一般用于用户正翻看历史消息时)
        self.addNewMessageCount += 1;
    }
}


#pragma mark -
#pragma mark UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case ALERT_CLOSE_CHAT_SESSION_TAG:
        {
            // 如果接收到通知登陆者被踢出群聊而且登陆者正在此群聊会话中，需通知登陆者群聊已结束，并返回到列表页面
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;

        default:
            break;
    }
}


#pragma mark -
#pragma mark Create TableView Cell

// 创建一个时间分组或群组提示信息的表格单元
- (UITableViewCell *)createGroupInfoCell
{
    UITableViewCell *invCell = nil;
    
    //初始化多人聊天信息cell
    invCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_MESSAGEGROUPINFO];
    if ([ToolsFunction iSiOS7Earlier] == NO)
    {
        [invCell setBackgroundColor: [UIColor clearColor]];
    }
    
    //创建显示邀请消息的label
    UILabel *tempLabel = [[UILabel alloc] init];
    [tempLabel setNumberOfLines:0];
    [tempLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [tempLabel setTextColor:COLOR_WITH_RGB(154, 154, 154)];
    [tempLabel setBackgroundColor:[UIColor clearColor]];
    [tempLabel setFont:TIP_MESSAGE_TEXT_FONT];
    
    [tempLabel setTag:GROUP_MESSAGE_LABEL_TAG];
    [invCell addSubview:tempLabel];
    
    //设置该cell状态下不能选定
    [invCell setEditingAccessoryType:UITableViewCellAccessoryNone];
    [invCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [invCell setUserInteractionEnabled:NO];
    return invCell;
}

// 初始化提示表格单元的文字信息
- (void)initCellContentOf:(UITableViewCell*)invCell withString:(NSString*)invString
{
    // 设置分割线位置 (左)
    UIView *lineL = [invCell viewWithTag:GROUP_MESSAGE_SEPARATEDLINE_L_TAG];
    UIView *lineR = [invCell viewWithTag:GROUP_MESSAGE_SEPARATEDLINE_R_TAG];

    UILabel *invLabel = (UILabel*)[invCell viewWithTag:GROUP_MESSAGE_LABEL_TAG];
    
    CGSize invSize = [ToolsFunction getSizeFromString:invString
                                             withFont:invLabel.font
                                    constrainedToSize:CGSizeMake(270, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - TOOLVIEW_HEIGHT)];

    // 更新字符串
    [invLabel setFrame:CGRectMake((UISCREEN_BOUNDS_SIZE.width - invSize.width)/2.0, 3+5, invSize.width, invSize.height)];
    
    // 设置分割线frame
    [lineL setFrame:CGRectMake(20, 14.5, (UISCREEN_BOUNDS_SIZE.width - invSize.width - 70)/2 , 1)];
    [lineR setFrame:CGRectMake(CGRectGetMaxX(invLabel.frame) + 15, 14.5, (UISCREEN_BOUNDS_SIZE.width - invSize.width - 70)/2 , 1)];

    [invLabel setText:invString];
    
}


#pragma mark -
#pragma mark UITableViewDataSource

// 当前Sections的数量
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// 返回每一个Section有多少个元素
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.visibleSortMessageRecordArray count];
}

//  指定cell的高度（修改获取文本高度，通过对象中保存的高度动态改变，并整理代码）
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	CGFloat cellHeight = DEFAULT_MESSAGE_SESSION_CELL_HEIGHT;
    
    //如果是消息,则读取消息;如果不是消息,则是时间返回默认高度
    if ([[self.visibleSortMessageRecordArray objectAtIndex:indexPath.row] isKindOfClass:[RKCloudChatBaseMessage class]])
	{
        // 根据当前索引获取需要显示的MessageTable
        RKCloudChatBaseMessage *messageObject = [self.visibleSortMessageRecordArray objectAtIndex:indexPath.row];
        
        cellHeight = [ChatManager heightForMessage:messageObject];
    }
	return cellHeight;
}

// 返回定制的cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cellMessage = nil;
    // 根据当前索引获取需要显示的MessageTable
    RKCloudChatBaseMessage *messageObject = [self.visibleSortMessageRecordArray objectAtIndex:indexPath.row];
    
    BOOL isNewCreateCell = NO;
    
    // 需要展示的字符串
    NSString *tipMessageString = nil;
    int mmsType = MESSAGE_TYPE_TIME;
    
    // 判断消息类型
    if ([messageObject isKindOfClass:[RKCloudChatBaseMessage class]])
    {
        // 获取当前消息类型
        mmsType = messageObject.messageType;
        
        // 判断当前cell是不是未读消息的最后一条
        if ([self.unReadMessageArray count] > 0)
        {
            RKCloudChatBaseMessage *messageObjectLast = [self.unReadMessageArray lastObject];
            if ([messageObjectLast.messageID isEqualToString:messageObject.messageID]) {
                // 隐藏未读消息提醒view
                [self hideUnReadMessagePromptView:nil];
            }
        }
    }
    
    // 根据类型创建不同的MMS消息表格单元
    NSString *cellIndentifier = nil;
    switch (mmsType)
    {
        case MESSAGE_TYPE_TEXT: // 文本消息
            cellIndentifier = CELL_TABLE_MESSAGE_TEXT;
            break;
            
        case MESSAGE_TYPE_IMAGE: // 图片消息
            cellIndentifier = CELL_TABLE_MESSAGE_IMAGE;
            break;
            
        case MESSAGE_TYPE_VOICE: // 语音消息
            cellIndentifier = CELL_TABLE_MESSAGE_VOICE;
            break;
            
        case MESSAGE_TYPE_FILE: // 附件消息
            cellIndentifier = CELL_TABLE_MESSAGE_FILE;
            break;
            
        case MESSAGE_TYPE_LOCAL: // 本地消息记录（音视频/会议 呼叫记录）
        {
            if ([messageObject.mimeType isEqualToString:kMessageMimeTypeLocal]) {
                cellIndentifier = CELL_TABLE_MESSAGE_LOCAL_RECORD;
            }
            else if ([messageObject.mimeType isEqualToString:kMessageMimeTypeTip])
            {
                cellIndentifier = CELL_MESSAGEGROUPINFO;
                
                tipMessageString = [ChatManager getMeetingTipStringWithMessageObject:messageObject];
            }
        }
            break;
            
        case MESSAGE_TYPE_GROUP_JOIN: // 加入群消息
        case MESSAGE_TYPE_GROUP_LEAVE: // 离开群消息
        {
            cellIndentifier = CELL_MESSAGEGROUPINFO;
            // 拼装邀请或者离开的群消息
            tipMessageString = [ChatManager getGroupTipStringWithMessageObject:messageObject];
        }
            break;
            
        case MESSAGE_TYPE_TIME: // 时间字符串(不存数据库)
        {
            cellIndentifier = CELL_MESSAGEGROUPINFO;
            
            // 显示时间分组
            //NSLog(@"DEBUG: self.visibleSortMessageRecordArray count = %lu, MESSAGE_TYPE_TIME - indexPath.row = %ld", (unsigned long)[self.visibleSortMessageRecordArray count],  (long)indexPath.row);
            tipMessageString = [NSString stringWithString:[self.visibleSortMessageRecordArray objectAtIndex:indexPath.row]];
        }
            break;
        case MESSAGE_TYPE_VIDEO: // 视频
        {
            cellIndentifier = CELL_TABLE_MESSAGE_VIDEO;
        }
            break;
        case MESSAGE_TYPE_REVOKE: // 撤回消息
        {
            cellIndentifier = CELL_MESSAGEGROUPINFO;
            
            tipMessageString = [ChatManager getRevokeStringWithMessageObject:messageObject];
        }
            break;
        default:
            NSLog(@"ERROR: unknown mms type = %lu, failed to create cell!", (unsigned long)messageObject.messageType);
            return nil;
    }
    
    // 是否为提示信息，如果不是提示信息按照消息类型进行加载，否则按照提示信息绘制
    if (cellIndentifier && ![cellIndentifier isEqualToString:CELL_MESSAGEGROUPINFO]) {
        // 根据类型查找表格单元
        MessageBubbleTableCell *mmsCell = (MessageBubbleTableCell *)[tableView dequeueReusableCellWithIdentifier:cellIndentifier];
        if (mmsCell == nil) {
            mmsCell = [ToolsFunction loadTableCellFromNib:cellIndentifier];
            isNewCreateCell = YES;
        }
        
        // 初始化不同Cell类型数据
        [mmsCell setVwcMessageSession:self];
        [mmsCell initCellContent:messageObject
                       isEditing:self.messageSessionContentTableView.editing];
        
        mmsCell.selectionStyle = UITableViewCellSelectionStyleNone;
        [mmsCell disableButtonAction:NO];
        
        cellMessage = mmsCell;
    }
    else {
        // 群组消息和时间表格单元
        UITableViewCell *invCell = [tableView dequeueReusableCellWithIdentifier:CELL_MESSAGEGROUPINFO];
        if (invCell == nil) {
            invCell = [self createGroupInfoCell];
            isNewCreateCell = YES;
        }
        
        // 创建分割线
        UIView *separatedLeftLine = [invCell viewWithTag:GROUP_MESSAGE_SEPARATEDLINE_L_TAG];
        UIView *separatedRightLine = [invCell viewWithTag:GROUP_MESSAGE_SEPARATEDLINE_R_TAG];

        if (mmsType == MESSAGE_TYPE_TIME)
        {
            if (!separatedLeftLine) {
                separatedLeftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.5f)];
                [separatedLeftLine setTag:GROUP_MESSAGE_SEPARATEDLINE_L_TAG];
                separatedLeftLine.backgroundColor = COLOR_WITH_RGB(216, 216, 216);
                [invCell addSubview:separatedLeftLine];
            }
            if (!separatedRightLine) {
                separatedRightLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 0.5f)];
                [separatedRightLine setTag:GROUP_MESSAGE_SEPARATEDLINE_R_TAG];
                separatedRightLine.backgroundColor = COLOR_WITH_RGB(216, 216, 216);
                [invCell addSubview:separatedRightLine];
            }
        }
        else
        {
            if (separatedLeftLine) {
                [separatedLeftLine removeFromSuperview];
            }
            if (separatedRightLine) {
                [separatedRightLine removeFromSuperview];
            }
        }
        // 更新表格单元内容
        [self initCellContentOf:invCell withString:tipMessageString];
        
        cellMessage = invCell;
    }
    
    if (isNewCreateCell == NO)
    {
        // 兼容ios7中，重用cell的时候不能触发cell的绘制
        [cellMessage setNeedsDisplay];
    }
    
    return cellMessage;
}


#pragma mark -
#pragma mark UITableViewDelegate

// 返回编辑的类型
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    //如果不是MMS消息,则不做任何操作
    if (![[self.visibleSortMessageRecordArray objectAtIndex:indexPath.row] isKindOfClass:[RKCloudChatBaseMessage class]])
    {
        return ;
    }
}


#pragma mark -
#pragma mark RKMessageContainerToolsViewDelegate

- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (self.sessionShowType == SessionListShowTypeSearchListCategory)
    {
        self.sessionShowType = SessionListShowTypeNomal;
        [self.visibleSortMessageRecordArray removeAllObjects];
        [self loadMessageSessionRecord:YES withLoadDirection:LoadMessageOld];
        [self.messageSessionContentTableView reloadData];
    }
    
    return YES;
}

- (BOOL)growingTextViewShouldEndEditing:(HPGrowingTextView *)growingTextView
{
    // 保存光标位置，为了插入表情符号使用
    currentTextViewLocation = growingTextView.selectedRange.location;
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    // 获取高度差
    float diff = (growingTextView.frame.size.height - height);
    CGRect tempFrame = self.messageContainerToolsView.frame;
    tempFrame.size.height -= diff;
    tempFrame.origin.y += diff;
    
    self.messageContainerToolsView.frame = tempFrame;
    
    // 设置表格位置
    [self moveMessageTableViewFrame];
}

- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    // 点击发送文本消息的发送按钮
    [self touchSendButton];
    
    return YES;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView didChangeHeight:(float)height
{
    
}


- (BOOL)growingTextView:(HPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)atext
{
    if ([atext isEqualToString: @""])
    {
        self.isExecuteAt = NO;
    }
    else
    {
        self.isExecuteAt = YES;
    }
    return YES;
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    // 如果清空输入框中的字符则删除草稿信息
    if ([growingTextView.text length] == 0)
    {
        // 删除保存的草稿文本信息
        [RKCloudChatMessageManager deleteDraft:self.currentSessionObject.sessionID];
    }
}

// 点击表情、键盘按钮代理函数
- (void)touchEmoticonButtonDelegateMethod
{
    [self touchDownEmotionButton];
}

// 点击MessageContainerToolsView中的键盘按钮时的代理方法
- (void)touchRecorderAndKeyboardButtonDelegate:(BOOL)isRecorderType
{
    if (isRecorderType)
    {
        if ([self.messageContainerToolsView.inputContainerToolsView.growingTextView isFirstResponder])
        {
            // 判断键盘打开还是关闭，键盘之间的切换，取消键盘
            [self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
        }
        
        // 将工具栏移动到最底部
        [self moveContainerToolsViewToBottom:isRecorderType];
        
        // 隐藏更多操作工具窗口
        [self showToolsControlView:NO isRecordType:NO];
    }
    else
    {
        if (![self.messageContainerToolsView.inputContainerToolsView.growingTextView isFirstResponder])
        {
            // 判断键盘打开还是关闭，键盘之间的切换，取消键盘
            [self.messageContainerToolsView.inputContainerToolsView.growingTextView becomeFirstResponder];
        }
        
        // 设置MessageToolsContainerView位置坐标
        [self.messageContainerToolsView setFrame:CGRectMake(self.messageContainerToolsView.frame.origin.x,
                                                            self.messageContainerToolsView.frame.origin.y,
                                                            self.messageContainerToolsView.frame.size.width,
                                                            self.messageContainerToolsView.inputContainerToolsView.frame.size.height)];
    }
}

// 点击录音时锁定的取消按钮
- (void)touchLockingCancelButtonDelegateMethod
{
    [self enableViewAction:YES];
}

// 点击录音时锁定的发送按钮
- (void)touchLockingSendButtonDelegateMethod
{
    // 发送消息
    [self sendVoiceMessage];
}

- (void)touchMoreOptionButtonDelegate
{
    // 切换更多操作窗口和键盘窗口
    if (isShowToolsControlView == YES) {
        
        // 隐藏工具窗口界面
        [self showToolsControlView:NO];
        
        // 使输入框做为第一响应，光标为输入框中
        [self.messageContainerToolsView.inputContainerToolsView.growingTextView becomeFirstResponder];
    }
    else
    {
        // 弹出工具窗口界面
        [self showToolsControlView:YES];
        
        if ([self.messageContainerToolsView.inputContainerToolsView.growingTextView isFirstResponder])
        {
            // 取消键盘
            [self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
        }
    }
}

// 发送文字消息
- (void)sendTextMessage
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // Jacky.Chen:2016.03.01: 删除过滤掉@“\U0000fffc\U0000fffc”系统语音设别自动生成的文本输入Unicode字符
    // http://stackoverflow.com/questions/27119299/how-to-remove-characters-u0000fffc-from-nsstring-ios
    NSString *codeString = @"\uFFFC";
    NSString *msgInputContent = [self.messageContainerToolsView.inputContainerToolsView.growingTextView.text stringByReplacingOccurrencesOfString:codeString withString:@""];
    // 判断是否为空
    if (msgInputContent == nil ||
        [msgInputContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0 ||
        [msgInputContent isEqualToString:@""]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_SEND_MESSAGE_CONTENT_LIMIT", @"发送消息不能为空或全为空格") background:nil showTime:2];
        return;
    }
    
    // 发送文本消息
    NSMutableString *stringSendText = [[NSMutableString alloc] initWithString:msgInputContent];
    NSString * stringKey = nil;
    NSString * stringReplacement = nil;
    NSArray *arrayKeys = [appDelegate.chatManager.emoticonMultilingualStringToESCDict allKeys];
    
    // 发送时将文本中的表情描述转换为表情转义字符串
    for (int i = 0; i < [arrayKeys count]; i++)
    {
        NSRange range = NSMakeRange(0, [stringSendText length]);
        
        stringKey = [arrayKeys objectAtIndex:i];
        stringReplacement = [[AppDelegate appDelegate].chatManager.emoticonMultilingualStringToESCDict objectForKey:stringKey];
        if (stringKey && stringReplacement)
        {
            // 替换表情描述字符串为表情转义字符串
            [stringSendText replaceOccurrencesOfString:stringKey
                                            withString:stringReplacement
                                               options:NSCaseInsensitiveSearch
                                                 range:range];
        }
    }
    
    // 检测是否有@群用户
    [self derectAtGroupMember: stringSendText];
    
    TextMessage *textMessage = [TextMessage buildMsg:self.currentSessionObject.sessionID
                                      withMsgContent:stringSendText];
    // @功能
    if (self.isAtAll)
    {
        textMessage.atUser = @"all";
    }
    else if ([self.atUserArray count] > 0)
    {
        textMessage.atUser = [self.atUserArray JSONRepresentation];
    }
    
    // 发送文字消息
    [RKCloudChatMessageManager sendChatMsg:textMessage];
    
    // Gray.Wang:2016.01.21:保存最后一条消息记录对象
    self.currentSessionObject.lastMessageObject = textMessage;
    
    // 发送后清空文本输入内容
    self.messageContainerToolsView.inputContainerToolsView.growingTextView.text = nil;
    // 清除文本输入当前光标位置
    currentTextViewLocation = 0;
    // 删除保存的草稿文本信息
    [RKCloudChatMessageManager deleteDraft:self.currentSessionObject.sessionID];
    
    // 增加新的消息记录到数组中
    [self addNewMessageToArray:textMessage];
    
    // 刷新tableview
    [self reloadTableView];
    [self voiceCellPlaying];
    
    // 根据msgID消息记录判断是否滚动到列表最下端
    [self scrollTableViewPosition:textMessage];
}


#pragma mark -
#pragma mark UI Control Methods

// 点击遮蔽层后把ContainerToolsView移动到初始的位置
- (void)moveContainerToolsViewToBottom:(BOOL)isRecorderType
{
    // 当捕捉到触摸事件时，取消textView的第一响应
    [self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
    
    // 修正输入框容器窗口的位置坐标
    if (isRecorderType)
    {
        self.messageContainerToolsView.frame = MESSAGE_CONTAINER_TOOLS_VIEW_INIT_FRAME;
    }
    else
    {
        self.messageContainerToolsView.frame = CGRectMake(self.messageContainerToolsView.frame.origin.x,
                                                          UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - self.messageContainerToolsView.frame.size.height,
                                                          self.messageContainerToolsView.frame.size.width,
                                                          self.messageContainerToolsView.frame.size.height);
    }
    
    // 设置表格位置
    [self moveMessageTableViewFrame];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// 照相代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    @autoreleasepool {
        //移除当前模态视图
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        NSString *mediaType = info[UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])  // 视频的处理
        {
            NSURL *videoURL = info[UIImagePickerControllerMediaURL];
            AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
            
            CMTime audioDuration = avAsset.duration;
            int audioDurationSeconds = (int)CMTimeGetSeconds(audioDuration);
            
            NSURL *videoMp4 = [ToolsFunction videoConvertToMp4:avAsset];
            NSFileManager *fileman = [NSFileManager defaultManager];
            if ([fileman fileExistsAtPath:videoURL.path]) {
                NSError *error = nil;
                [fileman removeItemAtURL:[videoURL URLByDeletingLastPathComponent] error:&error];
                if (error) {
                    NSLog(@"failed to remove file, error:%@.", error);
                }
            }
            
            // 发送视频消息
            [self sendVedioMessage:videoMp4 withDurationSeconds:audioDurationSeconds];
            
        }else
        {
            // 判断当前所获取媒体类型为图片
            if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
            {
                // 获取当前摄像图片
                UIImage *selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
                // 若是拍照就不再显示预览页面，直接发送图片
                if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
                {
                    [self saveAndSendImage:selectImage];
                }
                else
                {
                    // 加载图片预览页面
                    [self performSelector:@selector(delayPushImagePreviewController:) withObject:selectImage afterDelay:0.5];
                }
            }
        }
    }
}

//加载图片预览页面
- (void)delayPushImagePreviewController:(UIImage *)selectImage
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    //加载图片预览页面（使用查看原图的页面）
    ImagePreviewViewController *imagePreviewCtr = [[ImagePreviewViewController alloc] initWithNibName:@"ImagePreviewViewController" bundle:nil];
    imagePreviewCtr.displayImage = selectImage;
    imagePreviewCtr.parent = self;
    imagePreviewCtr.isImagePreview = YES;
    
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    
    [self.navigationController pushViewController:imagePreviewCtr animated:NO];
}

#pragma mark -
#pragma mark Photos & Image Operation Methods

- (void)sendVedioMessage:(NSURL *)videoPath  withDurationSeconds:(int)duration
{
    VideoMessage *videoMessage = [VideoMessage  buildMsg:self.currentSessionObject.sessionID withVideoPath:[videoPath path] withDuration:duration];
    
    if (videoMessage == nil) {
        return;
    }
    
    [RKCloudChatMessageManager sendChatMsg:videoMessage];
    
    self.currentSessionObject.lastMessageObject = videoMessage;
    
    // 增加新的消息记录到数组中
    [self addNewMessageToArray:videoMessage];
    // 刷新tableview
    [self reloadTableView];
    [self voiceCellPlaying];
    
    // 根据msgID消息记录判断是否滚动到列表最下端
    [self scrollTableViewPosition:videoMessage];
}

// 保存图片并发送
- (void)saveAndSendImage:(UIImage *)selectImage
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    ImageMessage *imageMessage = [ImageMessage buildMsg:self.currentSessionObject.sessionID
                                          withImageData:selectImage];
    
    // 发送图片
    [RKCloudChatMessageManager sendChatMsg:imageMessage];
    
    // Gray.Wang:2016.01.21:保存最后一条消息记录对象
    self.currentSessionObject.lastMessageObject = imageMessage;
    
    // 增加新的消息记录到数组中
    [self addNewMessageToArray:imageMessage];
    
    // 刷新tableview
    [self reloadTableView];
    [self voiceCellPlaying];
    
    // 根据msgID消息记录判断是否滚动到列表最下端
    [self scrollTableViewPosition:imageMessage];
}

// 进入浏览照片的窗口
- (void)pushImageBrowseViewController:(RKCloudChatBaseMessage *)messageObject
{
    RKChatImagesBrowseViewController *imagesBrowseViewController = [[RKChatImagesBrowseViewController alloc] initWithCurrentMessage:messageObject andLoadedMessage:self.visibleSortMessageRecordArray];
    
    [self.navigationController pushViewController:imagesBrowseViewController animated:YES];
    
}

// 进入图片显示的ViewController
- (void)pushImagePreviewViewController:(RKCloudChatBaseMessage *)messageObject isThumbnail:(BOOL)isThumbnail
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    [self pushImageBrowseViewController:messageObject];
}

// 刷新图片显示的ViewController（图片下载完成）
- (void)updateImagePreviewViewController:(RKCloudChatBaseMessage *)messageObject
{
    if ([[self.navigationController visibleViewController] isKindOfClass:[RKChatImagesBrowseViewController class]] == NO)
    {
        return;
    }
    
    RKChatImagesBrowseViewController *imageBrowseVC = (RKChatImagesBrowseViewController *)[self.navigationController visibleViewController];
    
    if (messageObject.messageType == MESSAGE_TYPE_IMAGE &&
        messageObject.messageStatus == MESSAGE_STATE_RECEIVE_DOWNED) {
        
        // 刷新下载下来的图片
        [imageBrowseVC updateImage:messageObject];
    }
}


#pragma mark -
#pragma mark UIResponder

// 遮罩层处理方法
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	UITouch *touch = [touches anyObject];
	if ([touch view].tag == MASK_VIEWS_TAG)
	{
		// 当捕捉到触摸事件时，取消UITextField的第一响应
		[self.messageContainerToolsView.inputContainerToolsView.growingTextView resignFirstResponder];
		
        // 设置为录音按钮背景
//        [self.inputContainerToolsView setRecordVoiceImage:YES];
        
        
        // 隐藏更多操作工具窗口
		[self showToolsControlView:NO];
        
        // 重置TableView的位置
        [self moveMessageTableViewFrame];
	}
}

// 遮罩层处理方法
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	// 响应完毕设置UIview隐藏
	UITouch *touch = [touches anyObject];
	if ([touch view].tag == MASK_VIEWS_TAG) {
		UIView *maskView = (UIView *)[self.view viewWithTag:MASK_VIEWS_TAG];
		[maskView setHidden:YES];
	}
}


// 遮罩层处理方法
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// 响应完毕设置UIview隐藏
	UITouch *touch = [touches anyObject];
	if ([touch view].tag == MASK_VIEWS_TAG) {
		UIView *maskView = (UIView *)[self.view viewWithTag:MASK_VIEWS_TAG];
		[maskView setHidden:YES];
	}
}

- (NSInteger)getCurrentSessionObjectIndexInArray
{
    NSInteger index = 0;
    for (int i = 0; i<self.visibleSortMessageRecordArray.count; i++) {
        RKCloudChatBaseMessage *messageObject = [self.visibleSortMessageRecordArray objectAtIndex:i];
        if (messageObject && [messageObject isKindOfClass:[RKCloudChatBaseMessage class]] && [self.currentSessionObject.lastMessageObject.messageID isEqualToString:messageObject.messageID]) {
            index =  i;
            break;
        }
    }
    return index;
}

// 设置表格位置
- (void)moveMessageTableViewFrame
{
    if ([self.messageContainerToolsView isHidden] == YES) {
        return;
    }
    
    // 设置MessageTableView位置动画
    [UIView animateWithDuration:self.isAppearFirstly ? 0.0 : 0.25 animations:^{
        int moveFrameHeight = 0;
    
        // 键盘隐藏状态 用emoticonControlView是否在最底部来判断键盘或者表情View是否开启，之前的判断方式不适合屏幕大于480的设备
        // 这种方式判断必须保证emoticonControlView在非使用状态下的Y坐标为UISCREEN_BOUNDS_SIZE.height －By jacob 14.04.12
        if (self.messageContainerToolsView.frame.origin.y == UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - self.messageContainerToolsView.frame.size.height)
        {
            // 计算输入框的高度差
            CGRect messageTableFrame = CGRectMake(0,
                                                  0,
                                                  UISCREEN_BOUNDS_SIZE.width,
                                                  self.messageContainerToolsView.frame.origin.y);
            
            
            // 设置消息表格位置以及contentSize
            [self.messageSessionContentTableView setFrame:messageTableFrame];
            
            // Gray.Wang:2014.01.29:得到输入框比原始一行高度的变化值，使用MessageTable的ContentSize去计算偏移了多少增量
            moveFrameHeight = self.messageSessionContentTableView.contentSize.height - (self.messageSessionContentTableView.contentOffset.y + self.messageSessionContentTableView.frame.size.height);
            // Gray.Wang:2014.01.29:如果已经不是一行，输入框高度有增加，并且增加的高度小于等于输入框的最大增量高度，则增加MessageTableView的contentOffset的Y值
            if (moveFrameHeight > 0 && moveFrameHeight <= self.messageContainerToolsView.frame.size.height) {
                self.messageSessionContentTableView.contentOffset = CGPointMake(self.messageSessionContentTableView.contentOffset.x, self.messageSessionContentTableView.contentOffset.y + moveFrameHeight);
            }
        }
        else
        {
            // 键盘开启状态，显示键盘
            moveFrameHeight = self.messageSessionContentTableView.contentSize.height - self.messageContainerToolsView.frame.origin.y;
            if (moveFrameHeight > 0)
            {
                
    
                if (self.messageSessionContentTableView.contentSize.height < self.messageSessionContentTableView.frame.size.height)
                {
                    [self.messageSessionContentTableView setFrame:CGRectMake(0,
                                                                             -moveFrameHeight,
                                                                             self.messageSessionContentTableView.frame.size.width,
                                                                             self.messageSessionContentTableView.frame.size.height)];
    
                }
                else
                {
                    NSLog(@"MMS-DEBUG: self.messageContainerToolsView.frame = %@, self.messageSessionContentTableView.frame = %@", NSStringFromCGRect(self.messageContainerToolsView.frame), NSStringFromCGRect(self.messageSessionContentTableView.frame));
                    
                    [self.messageSessionContentTableView setFrame:CGRectMake(0,
                                                                             self.messageContainerToolsView.frame.origin.y - self.messageSessionContentTableView.frame.size.height,
                                                                             self.messageSessionContentTableView.frame.size.width,
                                                                             self.messageSessionContentTableView.frame.size.height)];
                }
            }
        }

    }];
   
}

#pragma mark -
#pragma mark Record Voice Function

// 初始化AudioSession
- (void)startAudioSession
{
    NSLog(@"MMS: MessageSessionViewController -> startAudioSession");
    
    // 初始化录音工具类对象
    self.audioToolsKit = [[RKCloudChatAudioToolsKit alloc] initAudioToolsKit];
    self.audioToolsKit.recorderDelegate = self;
    
    // 设置录音按钮的可用状态
    self.messageContainerToolsView.recorderContainerToolsView.recordVoiceButton.enabled = [self.audioToolsKit inputIsAvailable];
}

// 显示录音声浪的窗口
- (void)showRecordPeakPowerView
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // 取消警告框的关闭
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hiddenRecordWarnningView)
                                               object:nil];
    
    // 隐藏录音警告窗口
    self.recordingWarnningView.hidden = YES;
    
    // 显示录音声浪的窗口
    self.recordingView.backgroundColor = [UIColor clearColor];
    self.recordingView.hidden = NO;
    
    // Jacky.Chen:02.24 ADD
    self.microphoneControlView.hidden = NO;
    self.downloadIndicatorView.hidden = NO;
    
    // 重置背景图
    self.recordingBgView.image = [UIImage imageNamed:@"background_recording_view_up"];
    
    // 将其上面的控件置为初始状态
    self.countTimeLable.text = @"00\"";
    self.timeProgressView.progress = 0;
}

// 显示录音按键时间短提示view
- (void)showRecordWarnningView
{
    NSLog(@"WARNING: showRecordWarnningView record voice duration < 1s");
    
    // 隐藏录音view
    self.recordingView.hidden = YES;
	// 显示录音警告view
	self.recordingWarnningView.hidden = NO;
	// 显示提示语言
	[self.recordingWarnningLable setText:NSLocalizedString(@"STR_PRESS_TIME_SHORT", nil)];
	// 0.5秒后自动隐藏
	[self performSelector:@selector(hiddenRecordWarnningView) withObject:nil afterDelay:0.5];
}

//隐藏录音按键时间太短提示的view
- (void)hiddenRecordWarnningView
{
    NSLog(@"WARNING: hiddenRecordWarnningView");
    
	// 隐藏录音view
	self.recordingView.hidden = YES;
	// 隐藏录音警告view
	self.recordingWarnningView.hidden = YES;
	
	// 设置其他控件可用
	[self enableViewAction:YES];
}

// 更新录音进度条
- (void)updateRecorderProgress
{
    //NSLog(@"MMS: updateRecorderProgress");
    
    // 更新录音时间
    int recorderDuration = [self.audioToolsKit.audioRecorder currentTime];
    
    // 得到当前录音的声浪值
    NSInteger voicePeakPower = [self.audioToolsKit getAudioRecorderPeakPower];
    //NSLog(@"DEBUG: updateRecorderProgress -> voicePeakPower = %d, recorderDuration = %d", voicePeakPower, recorderDuration);
    
    UIImage *imagePeakPower = [UIImage imageNamed:[NSString stringWithFormat:@"voice_peak_%ld", (long)voicePeakPower]];
    
    self.voicePeakImageView.frame = CGRectMake((self.recordingView.frame.size.width - imagePeakPower.size.width / 2) / 2, 3, imagePeakPower.size.width / 2, imagePeakPower.size.height / 2);
    
    // 更新声浪的图片
    [self.voicePeakImageView setImage:imagePeakPower];
    
    // Jacky.Chen:02.24 ADD
    // 绘制录音进度圆弧
    [self.downloadIndicatorView updateWithTotalBytes:60 downloadedBytes:recorderDuration];
    
	// 更新进度条
	self.timeProgressView.progress = (float)recorderDuration/60.00;
    
	// 更新时间进度显示 (00" - 60")
	[self.countTimeLable setText:[NSString stringWithFormat:@"%.2d\"", recorderDuration]];
    
    // 如果录音达到最大默认时长则发送
    if (recorderDuration == [RKCloudChatMessageManager getAudioMaxDuration])
    {
        self.messageContainerToolsView.recorderContainerToolsView.recordVoiceButton.isAutoFinishRecord = YES;
        
        // 更新toolView的布局
        [self.messageContainerToolsView updateRecorderContainerToolsView:RecorderInitType];
        
        [self sendVoiceMessage];
    }
}

// 创建语音消息
- (void)createVoiceMessage
{
    NSLog(@"MMS: createVoiceMessage");
    
    // Jacky.Chen.2016.03.04 add
    // 禁止导航控制器的pop功能
    [self enablePopAction:NO];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.audioToolsKit];
    
    if ([AppDelegate appDelegate].callManager.callViewController != nil || [[AppDelegate appDelegate].meetingManager isOwnInMeeting] == YES)
    {
        [UIAlertView showAutoHidePromptView:@"设备正忙，请稍后重试。" background:nil showTime:1.5];
        return;
    }
    
    // 判断音频设备是否可以用
    if ([ToolsFunction checkAudioDeviceIsAvailable] == NO) {
        // 增加音频设备不可用提示
        [UIAlertView showSimpleAlert:NSLocalizedString(@"STR_OPEN_MICROPHONE_GUIDE", @"请在[设置]>[隐私]>[麦克风]中开启[融科通]访问权限")
                           withTitle:NSLocalizedString(@"STR_MICROPHONE_CLOSED", @"麦克风已关闭")
                          withButton:NSLocalizedString(@"STR_OKAY", @"好的")
                            toTarget:nil];
        return;
    }

    // Jacky.Chen:02.24 ADD
    // 显示遮罩
    [self showMaskView];
    
    // 显示录音声浪的窗口
    [self showRecordPeakPowerView];
    
    // 屏蔽其他事件
    [self enableViewAction:NO];
    
    // 做录音准备工作
    [self.audioToolsKit prepareRecord];
    
    // 0.1秒之内未取消则开始录音
    [self.audioToolsKit performSelector:@selector(startRecordVoice)
                             withObject:nil
                             afterDelay:0.1];
    
    // 更新toolView的布局
    [self.messageContainerToolsView updateRecorderContainerToolsView:RecorderInitType];
}

// 发送语音消息
- (void)sendVoiceMessage {
    
    if ([AppDelegate appDelegate].callManager.callViewController != nil || [[AppDelegate appDelegate].meetingManager isOwnInMeeting] == YES)
    {
        return;
    }
    
    // Jacky.Chen:02.24 ADD
    // 隐藏遮罩
    [self removeMaskView];
    
    // Jacky.Chen.2016.03.04 add
    // 恢复导航控制器的pop功能
    [self enablePopAction:YES];
    
    // audioplayer 和 recorderplayer duration 相差 0.094
    int recorderDuration = ([self.audioToolsKit.audioRecorder currentTime] - floor([self.audioToolsKit.audioRecorder currentTime]) > 0.906) ? ceil([self.audioToolsKit.audioRecorder currentTime]) : [self.audioToolsKit.audioRecorder currentTime];
    
    // 发送前先停止录音
    [self.audioToolsKit stopRecordVoice];
    
    // 设置其他控件可用
    [self enableViewAction:YES];
    
    // 录音时长小于1秒
    if (recorderDuration < 1 || self.audioToolsKit.recordVoiceFilePath == nil)
    {
        // 如果取消录音，则取消启动录制语音方法
        [NSObject cancelPreviousPerformRequestsWithTarget:self.audioToolsKit
                                                 selector:@selector(startRecordVoice)
                                                   object:nil];
        
        // 如果隐私麦克风被禁止则不提示录音时间太短
        if ([ToolsFunction checkAudioDeviceIsAvailable] == YES) {
            // 显示录音时间太短提示
            [self showRecordWarnningView];
        }
        
        // 删除当前录制的语音
        [self.audioToolsKit deleteRecordVoice];
        return;
    }
    
    NSLog(@"MMS: sendVoiceMessage");
    
    // 进度条置零
    self.timeProgressView.progress = 0.0f;
    // 隐藏相关view
    self.recordingView.hidden = YES;
    // 设置其他事件可用
    [self enableViewAction:YES];
    
    // 如果取消录音，则取消启动录制语音方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self.audioToolsKit selector:@selector(startRecordVoice) object:nil];
    
    // 对声音文件进行封装发送
    AudioMessage *audioMessage = [AudioMessage buildMsg:self.currentSessionObject.sessionID withLocalPath:self.audioToolsKit.recordVoiceFilePath withDuration:recorderDuration];
    // 发送语音消息
    [RKCloudChatMessageManager sendChatMsg:audioMessage];
    
    // Gray.Wang:2016.01.21:保存最后一条消息记录对象
    self.currentSessionObject.lastMessageObject = audioMessage;
    
    // 增加新的消息记录到数组中
    [self addNewMessageToArray:audioMessage];
    
    // 刷新tableview
    [self reloadTableView];
    // 判断滑动时播放声音，当声音Cell可见时，继续播放动画
    [self voiceCellPlaying];
    
    // 根据msgID消息记录判断是否滚动到列表最下端
    [self scrollTableViewPosition:audioMessage];
    
    // 置空voiceName，用于后续添加新voice时进行判断
    self.audioToolsKit.recordVoiceFilePath = nil;
    // 置空audiorecorder
    self.audioToolsKit.audioRecorder = nil;
    
    // 隐藏警告提示框
    [self hiddenRecordWarnningView];
}

// Jacky.Chen:02.24 ADD
// 发送语音消息
- (void)cancelSendingVoiceMessage
{
    // 隐藏遮罩
    [self removeMaskView];
    
    // Jacky.Chen.2016.03.04 add
    // 恢复导航控制器的pop功能
    [self enablePopAction:YES];
    
    // 取消启动录制语音方法
    [NSObject cancelPreviousPerformRequestsWithTarget:self.audioToolsKit selector:@selector(startRecordVoice) object:nil];
    
    // 停止录音
    [self.audioToolsKit stopRecordVoice];
    
    // 删除已经录制的语音
    [self.audioToolsKit deleteRecordVoice];
    
    // 隐藏相关控件
    self.recordingView.hidden = YES;
    
    // 清空进度值
    self.timeProgressView.progress = 0;
    
    // 设置其他事件可用
    [self enableViewAction:YES];
    
    // 置空voiceName，用于后续添加新voice时进行判断
    self.audioToolsKit.recordVoiceFilePath = nil;
    
    // 置空audiorecorder
    self.audioToolsKit.audioRecorder = nil;

    // 隐藏警告提示框
    [self hiddenRecordWarnningView];
}

// Jacky.Chen:02.24 ADD
// 根据滑动点更新界面显示
- (void)refreshRecordingViewWithSlipPoint:(CGPoint)point
{
    // 根据触摸结束点判断松开位置
    if (point.y < 0) {
        // 在RecordButton外部
        // 隐藏录音声浪页面
        self.microphoneControlView.hidden = YES;
        self.downloadIndicatorView.hidden = YES;
        
        // 更换录音背景图片
        [self.recordingBgView setImage:[UIImage imageNamed:@"record_slip_cancel_image"]];
    }
    else
    {
        // RecordButton按钮上
        self.microphoneControlView.hidden = NO;
        self.downloadIndicatorView.hidden = NO;
        // 更换录音背景图片
        [self.recordingBgView setImage:[UIImage imageNamed:@"background_recording_view_up"]];

    }

    
}
#pragma mark -
#pragma mark AVAudioSessionDelegate

// 根据硬件状态，判断当前是否支持录音
- (void)inputIsAvailableChanged:(BOOL)isInputAvailable
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	NSLog(@"DEBUG: inputIsAvailableChanged: isInputAvailable = %d", isInputAvailable);
    // 设置录音按钮的可用状态
    self.messageContainerToolsView.recorderContainerToolsView.recordVoiceButton.enabled = isInputAvailable;
}


#pragma mark -
#pragma mark AudioToolsKitRecorderDelegate

// 录制成功
- (void)didRecorderSuccess {
    NSLog(@"AUDIO-KIT: didRecorderSuccess");
    
    // 更新进度条
    self.updateVoicePeakPowerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                      target:self
                                                                    selector:@selector(updateRecorderProgress)
                                                                    userInfo:nil
                                                                     repeats:YES];
}

// 录制失败
- (void)didRecorderFail {
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    // 隐藏录音中的view
    [self.recordingView setHidden:YES];
}

// 停止录音
- (void)didStopRecorderSuccess
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    // 停止进度条更新的定时器
    if (self.updateVoicePeakPowerTimer != nil ) {
        [self.updateVoicePeakPowerTimer invalidate];
        self.updateVoicePeakPowerTimer = nil;
    }
}

- (void)didStopRecordAndPlaying {
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	NSLog(@"MMS: didStopRecordAndPlaying");
    
	// 停止正在播放的语音消息
	[self.audioToolsKit stopPalyVoice];
    
	// 停止当前的录音
	[self.audioToolsKit stopRecordVoice];
    
    // 删除当前录制的语音
	[self.audioToolsKit deleteRecordVoice];
	
	// 置其他事件可用
	[self hiddenRecordWarnningView];
}

- (void)didPlayFinish:(RKCloudChatBaseMessage *)messageObject
{
    // 删除已经播放完成的语音
    [self.arrayVoiceJustDownload removeObject:messageObject];
    // 尝试播放刚下载的语音文件，如果有新下载的则播放
    [self playVoiceJustDownload];
}

#pragma mark -
#pragma mark Create/Show/Hidden Tools Control View

// 创建工具控制窗口
- (void)creatToolsControlView
{
    NSLog(@"DEBUG: creatToolsControlView");
    
	// 如果表情符号的窗口不存在则创建
	if (self.toolsControlView == nil)
	{
		self.toolsControlView = [[ToolsControlView alloc] initWithFrame:CGRectMake(0, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT, UISCREEN_BOUNDS_SIZE.width, TOOLVIEW_HEIGHT) withParent:self withRKCloudChatBaseChat:self.currentSessionObject];
        self.toolsControlView.delegate = self;
        self.toolsControlView.backgroundColor = [UIColor whiteColor];
        
		// 默认隐藏
		[self showToolsControlView:NO];
	}
	
	// 添加本窗口中
    [self.view insertSubview:self.toolsControlView belowSubview:self.messageContainerToolsView];
}

// 显示或者隐藏表情view
- (void)showToolsControlView:(BOOL)isShow
{
    [self showToolsControlView:isShow isRecordType:YES];
}

// 显示或隐藏更多操作工具窗口(Jacky.Chen.03.30.添加此方法区分点击录音button)
- (void)showToolsControlView:(BOOL)isShow isRecordType:(BOOL)isRecordTye
{
    NSLog(@"UI: showToolsControlView: isShow = %d", isShow);
    
    // Jacky.Chen.2016.03.24.增加键盘弹起时若当前tableView显示的最后一条消息不是数组中最后一条则滚动到最底部
    // 最后一条消息的index
    if (self.visibleSortMessageRecordArray && self.visibleSortMessageRecordArray.count > 1 && isRecordTye)
    {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.visibleSortMessageRecordArray.count - 1 inSection:0];
        // 取出可见的cell数组
        NSArray *visibleCells = [self.messageSessionContentTableView visibleCells];
        
        // 判断显示的最后一条是否为数组中最后一条
        if ([[visibleCells lastObject] isEqual:[self.messageSessionContentTableView cellForRowAtIndexPath:indexPath]] == NO )
        {
            // 不是则滚动到底部
            [self.messageSessionContentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }

    // 工具容器窗口是否在顶层
    isShowToolsControlView = isShow;
    
    // 显示表情窗口
    [self.toolsControlView showEmoticonView:NO];
    
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve: UIViewAnimationCurveCustom];
	if (isShow)
	{
        // 使遮罩层可见
        UIView *maskView = (UIView *)[self.view viewWithTag:MASK_VIEWS_TAG];
        [maskView setHidden:NO];
        
        // 设置chatButtonView位置动画(上移)
        [UIView setAnimationDuration: 0.25];
        
        // 移动工具操作容器窗口
        self.toolsControlView.frame = CGRectMake(0, UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - TOOLVIEW_HEIGHT, UISCREEN_BOUNDS_SIZE.width, TOOLVIEW_HEIGHT);
        
        // 移动输入工具栏容器窗口
        CGRect chatGrowingViewFrame = self.messageContainerToolsView.frame;
        chatGrowingViewFrame.origin.y = CGRectGetMinY(self.toolsControlView.frame) - self.messageContainerToolsView.frame.size.height;
        [self.messageContainerToolsView setFrame:chatGrowingViewFrame];
        
        [self moveMessageTableViewFrame];
	}
	else
	{
        // 设置chatButtonView位置动画(下移)
        [UIView setAnimationDuration: 0.2];
        
        // 移动工具操作容器窗口
        self.toolsControlView.frame = CGRectMake(0, UISCREEN_BOUNDS_SIZE.height, UISCREEN_BOUNDS_SIZE.width, TOOLVIEW_HEIGHT);
        
        // 移动输入工具栏容器窗口为初始化位置
        self.messageContainerToolsView.frame = CHAT_BUTTONVIEW_DOWN_FRAME;
	}
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark UIDocumentInteractionController

// 文件浏览方法（优化打开文件代码）
- (void)openFilesWithFilePath:(NSString *)filePath withShowName:(NSString *)titleName
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	if (filePath == nil || ![ToolsFunction isFileExistsAtPath:filePath])
	{
		return;
	}
    
    // 默认控制播放属性为外音播放(放到此处的原因: 录制语音后，首次播放MP3不会自动播放)
    // 而目前会导致iPhone上第一次打开MP3不会自动播放！
    [ToolsFunction enableSpeaker:YES];
	
	// 需要打开的文件Url
	NSURL *fileUrl = [[NSURL alloc] initFileURLWithPath:filePath];
    self.docInteractionController.URL = fileUrl;
	
	// 文档显示的标题名称
    self.docInteractionController.name = titleName;
    
	// 调用controller浏览文件
	if([self.docInteractionController presentPreviewAnimated:YES] == NO)
    {
        // 如果打开失败，则弹出Alert提示（iOS4不支持打开mp3文件）
		[UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_UNSUPPORT_FORMAT", "格式不支持，无法打开")
                             withTitle:nil
                            withButton:NSLocalizedString(@"STR_CLOSE", "关闭")
                              toTarget:nil];
	}
    
    //[docInteractionController release];
}


#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
	// 将文件浏览view加载到self上
    return self;
}

- (void)loadMessageFromeDBWithDirection:(LoadMessageDirection)loadDirection
{
    // 获得会话中的消息数量
    int messageSumCount = [RKCloudChatMessageManager queryChatMsgCountBySession:self.currentSessionObject.sessionID];
    
    // 滑动到最上端若还有未显示的信息完则继续载入更多信息（Jacky.Chen:2016.02.16:修改判断条件解决历史消息加载不完全的问题）
    if (messageSumCount > loadMessageCount)
    {
        [self loadHistoryMessageRecord:loadDirection];
    }
}


#pragma mark -
#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*// 判断是否滑动到最顶端
    if(self.messageSessionContentTableView.contentOffset.y < 0 )
    {
        [self loadMessageFromeDBWithDirection:LoadMessageOld];
    }
    else if (self.messageSessionContentTableView.contentOffset.y > (self.messageSessionContentTableView.contentSize.height - CGRectGetHeight(self.messageSessionContentTableView.bounds)) && !self.isAppearFirstly)
    {
        [self loadMessageFromeDBWithDirection:LoadMessageNew];
    }
    
    // 判断是否滑动到最低端
    CGFloat height = scrollView.frame.size.height;
    CGFloat contenYoffset = scrollView.contentOffset.y;
    CGFloat distanceFromButtom = scrollView.contentSize.height-contenYoffset;
    // 判断如果用户没有点击消息提醒按钮而是滑动到底部，隐藏消息提醒按钮
    if (distanceFromButtom < height+30) {
        CGRect rx = [ UIScreen mainScreen ].bounds;
        if (self.nMessagePromptButton.frame.origin.x < rx.size.width)
        {
            [self hideNewMessagePromptView:nil];
            // 清除提醒新消息个数
            self.addNewMessageCount = 0;
        }
    }
    
    // 判断滑动时播放声音，当声音Cell可见时，继续播放动画
    [self voiceCellPlaying];
    */
}

#pragma mark -
#pragma mark RecordVoiceButtonDelegate methods

- (void)touchBegin
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // 按下语音录制按钮
    [self createVoiceMessage];
}

- (void)touchMove:(CGPoint)point
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    NSLog(@"touchMove point = %@", NSStringFromCGPoint(point));
    // Jacky.Chen:02.24 ADD
    // 记录移动触摸点
    self.lastTouchPoint = point;
    // 根据滑动点位置更新页面控件布局
    [self refreshRecordingViewWithSlipPoint:point];
}

- (void)touchEnd:(CGPoint)point
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    // 根据触摸结束点判断松开位置
    if (point.y < 0) {
        // 在RecordButton外部松开,则取消发送
        [self cancelSendingVoiceMessage];
    }
    else
    {
        // 松开RecordButton按钮,发送消息
        [self sendVoiceMessage];
    }

}

- (void)touchCancel
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    // Jacky.Chen.2016.03.10.录音过程用户点击home键若触摸点不在录音button上则取消发送
    if (![NSStringFromCGPoint(self.lastTouchPoint) isEqualToString:NSStringFromCGPoint(CGPointZero)]&&self.audioToolsKit.isRecordingVoice && self.lastTouchPoint.y < 0) {
        // 取消发送
        [self cancelSendingVoiceMessage];
    }else
    {
        // 离开按钮焦点时，若取消前触摸点在录音按钮上则发送语音消息
        [self sendVoiceMessage];
    }
}


#pragma mark -
#pragma mark ToolsControlViewDelegate

- (void)didTouchSelectedToolsControlButtonDelegateMethod:(NSInteger)nButtonIndex
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    switch (nButtonIndex) {
        case 1: // 相册
            // 打开系统相册选择照片
            [self openSystemPhotoLibraryPickerController];
            break;
        case 2: // 照相
            // 打开系统相机准备拍照
            [self openSystemCameraPickerController:YES];
            break;
        case 3: // 视频s
            // 打开系统相机准备拍照
            [self openSystemCameraPickerController:NO];
            break;
        case 4:
        {
            if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
            {
                // 多人语音
                [self manyPeopleVoiceChat];
            }
            else
            {
                // 语音聊天
                [self voiceCall];
            }
        }
            break;
            
        case 5:
        {
            // 视频聊天
            [self videoCall];
        }
            break;
            
        default:
            [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_COMING_SOON", "敬请期待！") background:nil showTime:2];
            break;
    }
    
    // 将操作栏View退出
    // 弹出表情界面
    [self showToolsControlView:NO];
    // 重置TableView的位置
    [self moveMessageTableViewFrame];
}

#pragma mark -
#pragma mark EmoticonViewDelegate

- (void)didSelectedEmoticonKey:(NSString *)stringEmoticonKey
{
    // Gray.Wang:2016.02.25: 判断是否已经超过最大输入文本限制大小
    if (currentTextViewLocation >= [RKCloudChatMessageManager getTextMaxLength] || [self.messageContainerToolsView.inputContainerToolsView.growingTextView.text length] >= [RKCloudChatMessageManager getTextMaxLength]) {
        NSLog(@"MMS-WARNING: currentTextViewLocation = %ld, [messageContainerToolsView.inputContainerToolsView.growingTextView.text length] = %lu, [RKCloudChatMessageManager getTextMaxLength] = %d", (long)currentTextViewLocation, (unsigned long)[self.messageContainerToolsView.inputContainerToolsView.growingTextView.text length], [RKCloudChatMessageManager getTextMaxLength]);
        return;
    }
    
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    
    if (stringEmoticonKey)
    {
        // 将表情符号插入到相应的textView输入框的光标处
        NSMutableString *stringText = [NSMutableString stringWithString:self.messageContainerToolsView.inputContainerToolsView.growingTextView.text];
        [stringText insertString:NSLocalizedString(stringEmoticonKey, nil) atIndex:currentTextViewLocation];
        
        // 显示到textView输入框中
        self.messageContainerToolsView.inputContainerToolsView.growingTextView.text = stringText;
        
        // 移动当前光标位置
        currentTextViewLocation += [NSLocalizedString(stringEmoticonKey, nil) length];
    }
    
    // 设置光标到输入表情的后面
    self.messageContainerToolsView.inputContainerToolsView.growingTextView.selectedRange = NSMakeRange(currentTextViewLocation, 0);
}

// 发送基本表情
- (void)sendEmotionButtonDelegateMethod
{
    // 点击发送文本消息的发送按钮
    [self touchSendButton];
}

// 判断自定义搜索框是否在搜索的状态
- (BOOL)isSearchBarWork
{
    return NO;
}

#pragma mark -
#pragma mark NotificationCenter

- (void)keyboardWillShowNotification:(NSNotification *)note
{
    // 针对在ios7上，只要焦点在文本框上，都会触发keyboardWillShowNotification操作，进行兼容
    // 因通知在不同页面都可以收到，所以若当前界面不是可见界面，则不执行键盘操作
    if (self.navigationController.visibleViewController != self || self.isAppearFirstly == YES)
    {
        if ([self isSearchBarWork])
        {
            self.isAppearFirstly = NO;
        }
        return;
    }
    // 若当前界面不是可见界面，则不执行下列操作
    NSDictionary *userInfo = [note userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    // 得到键盘的高度
    systemKeyboardRect = keyboardRect;
    
    // 使遮罩层可见
    UIView *maskView = (UIView *)[self.view viewWithTag:MASK_VIEWS_TAG];
    [maskView setHidden:NO];
    
    // 隐藏工具窗口界面
    [self showToolsControlView:NO];
    
    // 设置MessageTableView位置动画
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve: UIViewAnimationCurveCustom];
    [UIView setAnimationDuration: 0.25];
    
    // 设置输入工具栏和表情符号控制窗口的位置
    [self.messageContainerToolsView setFrame:CGRectMake(self.messageContainerToolsView.frame.origin.x,
                                                        systemKeyboardRect.origin.y - self.messageContainerToolsView.inputContainerToolsView.frame.size.height,
                                                        self.messageContainerToolsView.frame.size.width,
                                                        self.messageContainerToolsView.frame.size.height)];
    [UIView commitAnimations];
    // 重置TableView的位置
    [self moveMessageTableViewFrame];
}

- (void)keyboardWillHideNotification:(NSNotification *)note
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    // 若当前界面不是可见界面，则不执行下列操作
    if (self.navigationController.visibleViewController != self || self.isAppearFirstly) {
        //DebugLog(@"keyboardWillHideNotification return");
        return ;
    }
    
	currentTextViewLocation = self.messageContainerToolsView.inputContainerToolsView.growingTextView.selectedRange.location;
    // 打开按钮可用性
	self.toolsControlView.userInteractionEnabled = YES;
    
    // 因通知在不同页面都可以收到，所以若当前界面不是可见界面，则不执行键盘操作
    if (self.navigationController.visibleViewController != self || self.isAppearFirstly) {
        //DebugLog(@"keyboardWillHideNotification return");
        return ;
    }
    
    currentTextViewLocation = self.messageContainerToolsView.inputContainerToolsView.growingTextView.selectedRange.location;
    
    systemKeyboardRect = CGRectZero;
    
    /*
    NSDictionary* userInfo = [note userInfo];
    
    //     Restore the size of the text view (fill self's view).
    //     Animate the resize so that it's in sync with the disappearance of the keyboard.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    // 设置输入工具栏和表情符号控制窗口的位置
    CGRect messageContainerToolsView = self.messageContainerToolsView.frame;
    messageContainerToolsView.origin.y = UISCREEN_BOUNDS_SIZE.height - STATU_NAVIGATIONBAR_HEIGHT - self.messageContainerToolsView.frame.size.height;
    [self.messageContainerToolsView setFrame:messageContainerToolsView];

    
    [UIView commitAnimations];
    */
    
    // 重置TableView的位置
    [self moveMessageTableViewFrame];
}

// 更新用户的昵称和头像
- (void)updateUserProfileNotification:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadTableView];
        [self voiceCellPlaying];
    });
}

// 状态栏frame改变事件
- (void)willChangeStatusBarFrameNotification:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    NSValue *statusBarFrameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    // react on changes of status bar height (e.g. incoming call, tethering, ...)
    if ([statusBarFrameValue CGRectValue].size.height==20)
    {
        CGRect growTextFrame =self.messageContainerToolsView.frame;
        growTextFrame.origin.y += 20;
        [self.messageContainerToolsView setFrame:growTextFrame];
        
        CGRect emoFrame =self.toolsControlView.frame;
        emoFrame.origin.y += 20;
        [self.toolsControlView setFrame:emoFrame];
    }
    else {
        CGRect growTextFrame =self.messageContainerToolsView.frame;
        growTextFrame.origin.y -= 20;
        [self.messageContainerToolsView setFrame:growTextFrame];
        
        CGRect emoFrame =self.toolsControlView.frame;
        emoFrame.origin.y -= 20;
        [self.toolsControlView setFrame:emoFrame];
    }
}

// 清空消息的通知
- (void)clearMessagesNotification:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"%s %d", __FUNCTION__,__LINE__);
#endif
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.visibleSortMessageRecordArray removeAllObjects];
        
        [self reloadTableView];
        [self voiceCellPlaying];
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
    NSLog(@"CHAT-SESSION-DELEGATE: didMsgHasChanged: messageID = %@, sessionID = %@", messageObject.messageID, messageObject.sessionID);
    
    RKCloudChatBaseMessage *lastMessage = nil;
    id obj = nil;
    for (int i = (int)[self.visibleSortMessageRecordArray count] - 1; i >= 0; i--)
    {
        obj = [self.visibleSortMessageRecordArray objectAtIndex: i];
        if ([obj isKindOfClass:[RKCloudChatBaseMessage class]])
        {
            lastMessage = (RKCloudChatBaseMessage *)obj;
            
            // 如果是相同的消息ID则替换消息数组的消息对象为更新后的
            if ([lastMessage.messageID isEqualToString:messageObject.messageID])
            {
                [self.visibleSortMessageRecordArray replaceObjectAtIndex:i withObject:messageObject];
                
                [self reloadTableView];
                [self voiceCellPlaying];
                
                // 刷新显示大图界面
                [self updateImagePreviewViewController:messageObject];
                
                if ((messageObject.messageType == MESSAGE_TYPE_FILE
                     || messageObject.messageType == MESSAGE_TYPE_VOICE
                     || messageObject.messageType == MESSAGE_TYPE_VIDEO)
                    && messageObject.messageStatus == MESSAGE_STATE_RECEIVE_DOWNED)
                {
                    // 发送已读通知
                    [RKCloudChatMessageManager sendReadedReceipt: messageObject];
                }
                
                break;
            }
        }
    }
    
    [self.messageSessionContentTableView reloadData];
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
    NSLog(@"CHAT-SESSION-DELEGATE: didReceivedMsg: messageID = %@, sessionID = %@", msgObj.messageID, chatObj.sessionID);
    
    if (msgObj == nil || [msgObj.sessionID isEqualToString:self.currentSessionObject.sessionID] == NO) {
        return;
    }
    
    // 撤回消息的处理
    
    // 防止同一条消息重复显示
    BOOL bExist = NO;
    for (RKCloudChatBaseMessage *existMessageObject in self.visibleSortMessageRecordArray)
    {
        // 判断消息记录是否存在
        if ([existMessageObject isKindOfClass:[RKCloudChatBaseMessage class]] &&
            [existMessageObject.messageID isEqualToString:msgObj.messageID])
        {
            bExist = YES;
            break;
        }
    }
    
    if (bExist == NO) {
        // 增加新的消息记录到数组中
        [self addNewMessageToArray:msgObj];
        
        [self reloadTableView];
        [self voiceCellPlaying];
        
        // 根据msgID消息记录判断是否滚动到列表最下端
        [self scrollTableViewPosition:msgObj];
    }
    
    // 如果累积的新消息个数大于5条时，每再加载5条显示新消息提醒
    if (self.addNewMessageCount > 0 /*&& self.addNewMessageCount % 5 == 0*/)
    {
        [self.nMessagePromptButton setTitle:[NSString stringWithFormat:@"您有%d条新消息", self.addNewMessageCount] forState:UIControlStateNormal];
        
        [self showNewMessagePromptView];
    }
    
    // 更新当前会话的提示消息为已读状态
    [RKCloudChatMessageManager updateMsgsReadedInChat:self.currentSessionObject.sessionID];
    self.currentSessionObject.unReadMsgCnt = 0;
}

/// 收到多条消息之后的回调
- (void)didReceivedMessageArray:(NSArray *)arrayBatchChatMessages
{
    NSLog(@"CHAT-SESSION-DELEGATE: didReceivedMessageArray: arrayBatchChatMessages count = %lu", (unsigned long)[arrayBatchChatMessages count]);
    
    // 告知其它平台清空新消息提示
    [RKCloudChatMessageManager clearOtherPlatformNewMMSCounts: self.currentSessionObject.sessionID];
    
    // 循环遍历出批量消息的数组元素
    for (RKCloudChatBaseMessage *chatMessage in arrayBatchChatMessages)
    {
        // 防止同一条消息重复显示
        if (chatMessage && [chatMessage isKindOfClass:[RKCloudChatBaseMessage class]])
        {
            BOOL bExist = NO;
            for (RKCloudChatBaseMessage *existMessageObject in self.visibleSortMessageRecordArray)
            {
                if ([existMessageObject isKindOfClass:[RKCloudChatBaseMessage class]] &&
                    [existMessageObject.messageID isEqualToString:chatMessage.messageID])
                {
                    bExist = YES;
                    break;
                }
            }
            
            if (bExist == NO) {
                // 增加新的消息记录到数组中
                [self addNewMessageToArray:chatMessage];
                
                // 刷新tableview
                [self reloadTableView];
                [self voiceCellPlaying];
                
                // 根据msgID消息记录判断是否滚动到列表最下端
                [self scrollTableViewPosition:chatMessage];
            }
        }
    }
    
    // 如果累积的新消息个数大于5条时，每再加载5条显示新消息提醒
    if (self.addNewMessageCount > 0 /*&& self.addNewMessageCount % 5 == 0*/)
    {
        [self.nMessagePromptButton setTitle:[NSString stringWithFormat:@"您有%d条新消息", self.addNewMessageCount] forState:UIControlStateNormal];
        
        [self showNewMessagePromptView];
    }
    
    // 更新当前会话的提示消息为已读状态
    [RKCloudChatMessageManager updateMsgsReadedInChat:self.currentSessionObject.sessionID];
    self.currentSessionObject.unReadMsgCnt = 0;
}



#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatGroup
// 云视互动即时通信对于群的回调接口

/*!
 * @brief 代理方法: 单个群信息有变化
 *
 * @param groupId NSString 群ID
 * @param changedType 修改群信息的类型，具体看ChangedType定义
 *
 * @return
 */
- (void)didGroupInfoChanged:(NSString *)groupId changedType:(ChangedType)changedType
{
    NSLog(@"CHAT-SESSION-DELEGATE: didGroupInfoChanged: groupId = %@", groupId);
    
    if ([groupId isEqualToString:self.currentSessionObject.sessionID] == NO || self.sessionInfoViewController == nil) {
        return;
    }
    
    // 更新当前会话聊天对象
    self.currentSessionObject = [RKCloudChatMessageManager queryChat:self.currentSessionObject.sessionID];
    
    // 设置聊天会话页面的标题
    if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        // 如果该会话为群聊，则查找该会话中的人数
        self.title = [NSString stringWithFormat:@"%@(%d)", self.currentSessionObject.sessionShowName, self.currentSessionObject.userCounts];
    }
    
    [self.sessionInfoViewController didGroupInfoChanged:groupId changedType: changedType];
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
    NSLog(@"CHAT-SESSION-DELEGATE: didGroupRemoved: groupId = %@, removeType = %lu", groupId, (unsigned long)removeType);
    
    if ([groupId isEqualToString:self.currentSessionObject.sessionID] == NO) {
        return;
    }
    
    switch (removeType) {
        case LEAVE_PASSIVE_TYPE:
        {
            // 如果在当前退出群的多人语音中 hangup多人语音
            if ([[AppDelegate appDelegate].meetingManager isOwnInMeeting] &&
                [self.currentSessionObject.sessionID isEqualToString:[AppDelegate appDelegate].meetingManager.sessionId])
            {
                [[AppDelegate appDelegate].meetingManager asyncHandUpMeeting];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您已经被此群组的群主移除此群！"
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"STR_OK", "确定")
                                                  otherButtonTitles:nil];
            alert.tag = ALERT_CLOSE_CHAT_SESSION_TAG;
            [alert show];
        }
            break;
            
        case LEAVE_DISSOLVE_TYPE:
        {
            // 如果在当前退出群的多人语音中 hangup多人语音
            if ([[AppDelegate appDelegate].meetingManager isOwnInMeeting] &&
                [self.currentSessionObject.sessionID isEqualToString:[AppDelegate appDelegate].meetingManager.sessionId])
            {
                [[AppDelegate appDelegate].meetingManager asyncHandUpMeeting];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"您当前的群组对话已被解散！"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            alert.tag = ALERT_CLOSE_CHAT_SESSION_TAG;
            [alert show];
        }
            break;
            
        default:
            break;
    }
    
    if (self.sessionInfoViewController) {
        [self.sessionInfoViewController didGroupRemoved:groupId withRemoveType:removeType];
    }
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
    NSLog(@"CHAT-SESSION-DELEGATE: didGroupUsersChanged: groupId = %@", groupId);
    
    if ([groupId isEqualToString:self.currentSessionObject.sessionID] == NO) {
        return;
    }
    
    // 更新当前会话聊天对象
    self.currentSessionObject = [RKCloudChatMessageManager queryChat:self.currentSessionObject.sessionID];
    
    // 设置聊天会话页面的标题
    if (self.currentSessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        // 如果该会话为群聊，则查找该会话中的人数
        self.title = [NSString stringWithFormat:@"%@(%d)", self.currentSessionObject.sessionShowName, self.currentSessionObject.userCounts];
        [self.messageSessionContentTableView reloadData];
    }
    
    // 会话信息管理页面
    if (self.sessionInfoViewController != nil) {
        [self.sessionInfoViewController didGroupUsersChanged:groupId];
    }
}


#pragma mark -
#pragma mark RKCloudChatDelegate - RKCloudChatSession

/**
 * @brief 代理方法: 更新指定的会话信息
 *
 * @param chatSession 此聊天对象的session数据
 *
 * @return
 */
- (void)didUpdateChatSessionInfo:(RKCloudChatBaseChat *)chatSession
{
    NSLog(@"CHAT-SESSION-DELEGATE: didUpdateChatSessionInfo: chatSession.sessionID = %@", chatSession.sessionID);
    
    if (chatSession == nil || [chatSession.sessionID isEqualToString:self.currentSessionObject.sessionID] == NO) {
        return;
    }
    
    // 如果编辑状态下，不刷新
    if (self.messageSessionContentTableView == nil ||
        self.messageSessionContentTableView.editing == YES) {
        return;
    }
    
    // 更新当前会话的提示消息为已读状态
    [RKCloudChatMessageManager updateMsgsReadedInChat:self.currentSessionObject.sessionID];
    self.currentSessionObject.unReadMsgCnt = 0;
    
    // 刷新数据列表
    [self reloadTableView];
    [self voiceCellPlaying];
}


#pragma mark -
#pragma mark CustomAvatarImageViewDelegate

// 点击用户image头像，应该显示用户详细信息
- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount
{
    FriendDetailViewController *vwcFriendDetail = [[FriendDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    // 判断点击头像的类型  个人
    if ([avatarUserAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
    {
        PersonalDetailViewController *vwcPersonalDetail = [[PersonalDetailViewController alloc] initWithNibName:@"PersonalDetailViewController" bundle:nil];
        
        [self.navigationController pushViewController:vwcPersonalDetail animated:YES];
    }
    else if ([[AppDelegate appDelegate].contactManager isOwnFriend:avatarUserAccount])
    {
        // 好友
        vwcFriendDetail.personalDetailType = PersonalDetailTypeFriend;
        vwcFriendDetail.userAccount = avatarUserAccount;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
    else
    {
        // 陌生人
        vwcFriendDetail.personalDetailType = PersonalDetailTypeStranger;
        vwcFriendDetail.userAccount = avatarUserAccount;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
}

// 在tableview中可见的Cell中查找，正在播放声音的cell
-(void)voiceCellPlaying
{
    // 如果当前没有播放任何声音则直接返回
    if (![self.audioToolsKit isPlayingVoice]) {
        return;
    }
    
    NSArray *visibleCells = [self.messageSessionContentTableView visibleCells];
    for (int i=0; i < [visibleCells count]; i++) {
        MessageBubbleTableCell *mmsCell = [visibleCells objectAtIndex:i];
        
        // Cell中得messageId是否是AudioToolsKit中正在播放的messageid，如果是则播放动画
        if ([mmsCell isKindOfClass:[MessageVoiceTableCell class]] && [((MessageVoiceTableCell *)mmsCell).audioMessage.messageID isEqualToString:self.audioToolsKit.playMessageObject.messageID])
        {
            MessageVoiceTableCell *voiceCell = (MessageVoiceTableCell*)mmsCell;
            self.audioToolsKit.playerDelegate = voiceCell;
        }
    }
}

// 添加刚下载的语音到待播数组中
- (void)addVoiceJustDownload:(RKCloudChatBaseMessage *)messageObject{
    [self.arrayVoiceJustDownload addObject:messageObject];
}

// 播放刚下载的语音文件
- (void)playVoiceJustDownload{
    [self performSelector:@selector(delayPlayVoiceJustDownload) withObject:nil afterDelay:1.0f];
}

- (void)delayPlayVoiceJustDownload{
    if ([self.audioToolsKit isPlayingVoice]) {
        return;
    }
    
    if ([AppDelegate appDelegate].callManager.callViewController != nil || [[AppDelegate appDelegate].meetingManager isOwnInMeeting] == YES)
    {
        [UIAlertView showAutoHidePromptView:@"设备正忙，请稍后重试。" background:nil showTime:1.5];
        
        return;
    }
    
    if ([self.arrayVoiceJustDownload count] > 0) {
        RKCloudChatBaseMessage *messageObject = [self.arrayVoiceJustDownload objectAtIndex:0];
        // 先停止正在播放的声音
        [self.audioToolsKit stopPalyVoice];
        // 设置播放代理
        self.audioToolsKit.playerDelegate = nil;
        
        NSArray *visibleCells = [self.messageSessionContentTableView visibleCells];
        for (int i=0; i < [visibleCells count]; i++) {
            MessageBubbleTableCell *mmsCell = [visibleCells objectAtIndex:i];
            
            // Cell中得messageId是否是AudioToolsKit中正在播放的messageid，如果是则播放动画
            
            if ([mmsCell isKindOfClass:[MessageVoiceTableCell class]] &&
                [((MessageVoiceTableCell *)mmsCell).audioMessage.messageID isEqualToString:messageObject.messageID]) {
                MessageVoiceTableCell *voiceCell = (MessageVoiceTableCell*)mmsCell;
                self.audioToolsKit.playerDelegate = voiceCell;
            }
        }
        
        // 开始播放MMS语音消息
        [self.audioToolsKit startPalyVoice:messageObject];
    }
}

#pragma mark -
#pragma mark in meeting MaskView View

/**
 *  正在会议中的View
 *
 *  @return view
 */
- (void)addInMeetingMarkingView
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 多人语音提示view 不存在且当前用户在会议中 创建提示view
    if (self.meetingPromptView == nil && [appDelegate.meetingManager isOwnInMeeting])
    {
        self.meetingPromptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width,50.0)];
        self.meetingPromptView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
        
        UILabel *meetingLabel = [[UILabel alloc] initWithFrame:CGRectMake(UISCREEN_BOUNDS_SIZE.width/2 - 100.0, 10, 200.0, 30.0)];
        meetingLabel.textAlignment = NSTextAlignmentCenter;
        meetingLabel.font = [UIFont systemFontOfSize:14.0];
        meetingLabel.textColor = COLOR_WITH_RGB(220.0, 220.0, 220.0);
        meetingLabel.text = NSLocalizedString(@"PROMPT_MANY_PERSONAL_AUDIO_MEETING", "点击进入多人语音会议室");
        meetingLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.meetingPromptView addSubview:meetingLabel];
        
        // 添加会议状态view 点击事件
        // 添加一个点击手势 用来进行会议室的push
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(tapGestureRecognizer:)];
        
        [self.meetingPromptView addGestureRecognizer: tapGesture];
        
        [self.view addSubview:self.meetingPromptView];
    }
    // 判断多人会议与会中提示view 显示或者隐藏
    if ([appDelegate.meetingManager isOwnInMeeting] == YES && [self.currentSessionObject.sessionID isEqualToString:appDelegate.meetingManager.sessionId] == YES)
    {
        self.meetingPromptView.hidden = NO;
    } else {
        self.meetingPromptView.hidden = YES;
    }
}

#pragma mark - TapGestureRecognizer selector

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    [appDelegate.meetingManager pushMeetingRoomViewControllerInViewController:self];
}

#pragma mark - Customer reload selector

// Jacky.Chen add 自定义刷新列表方法，避免堵塞主线程
- (void)reloadTableView
{
    if (self.isRefreshing) {
        return;
    }
    
    // 进行刷新
    [UIView animateWithDuration:0 animations:^{
        self.isRefreshing = YES;
        [self.messageSessionContentTableView reloadData];
    } completion:^(BOOL finished) {
        self.isRefreshing = NO;
    }];
}
@end
