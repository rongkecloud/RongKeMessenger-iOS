//
//  Definition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_Definition_h
#define EnjoySkyLine_Definition_h

#import "MessageJsonMacroDefinition.h"
#import "FileCachesMacroDefinition.h"
#import "NotificationMacroDefinition.h"
#import "EnumMacroDefinition.h"
#import "UIControlTagMacroDefinition.h"
#import "HttpAPIMacroDefinition.h"
#import "UIAlertView+CustomAlertView.h"
#import "HttpClientKit.h"
#import "RKNavigationController.h"
#import "UIBorderButton.h"
#import "JSON.h"

//*******************************************************************************
#define APP_DISPLAY_NAME   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"] // 应用程序显示的名字

#define APP_AES_PASSPHRASE   @"FDGeguert3%$^%dfaqtq^*&^#%g&*" // 用于客户端本地AES加密公钥密码
#define APP_AES_IV           @"SETdgdfe$&$^%&*^_)(*" // 用于客户端本地AES加密公钥IV

#define RKCLOUD_SDK_APPKEY   @"ee5646b5d8be3a57918c9857850b53be90ce1004"
#define RONG_KE_SERVICE      @"rongkeservice1"   // 云视互动小秘书固定账号
#define RONG_KE_SERVICE_APPKEY @"6f2683bb7f9b98aa09283fd8b47f4086aec37b56"  // 多媒体客服融科通企业Key

//*******************************************************************************
// #define LAN_SERVER // 内网RD开发服务器
 #define WAN_TEST_SERVER // 公网集成测试服务器

//*******************************************************************************
#ifdef DEBUG // 是Debug版本（开发版本）

#ifdef LAN_SERVER // Debug版本增加是否内网测试宏LAN_SERVER，无定义=非内网测试，定义=内网服务器测试
// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"192.168.1.163:8083"// 内网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"192.168.1.162"// 内网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      8080

#else // else LAN_SERVER

#ifdef WAN_TEST_SERVER

// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"apiqa.rongkecloud.com:443"// 公网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"apiqa.rongkecloud.com"// 公网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      443

#else // else WAN_TEST_SERVER

// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"apiqa.rongkecloud.com:443"// 公网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"apiqa.rongkecloud.com"// 公网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      443

#endif // WAN_TEST_SERVER
#endif // LAN_SERVER

#define DEBUG_ERROR_ALERT   // Debug模式下使用Debug错误弹出框

#else // 是Release版本（发布版本）

#ifdef LAN_SERVER // Release版本增加是否内网测试宏LAN_SERVER，无定义=非内网测试，定义=内网服务器测试
// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"192.168.1.163:8083"// 内网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"192.168.1.162"// 内网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      8080

#else

#ifdef WAN_TEST_SERVER

// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"apiqa.rongkecloud.com:443"// 公网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"apiqa.rongkecloud.com" // 公网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      443

#else // else WAN_TEST_SERVER

// HTTP API Server地址
#define DEFAULT_HTTP_API_SERVER_ADDRESS  @"apiqa.rongkecloud.com:443"// 公网API入口地址
// 云视互动地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_ADDRESS   @"apiqa.rongkecloud.com" // 公网云视互动Root服务器地址
#define DEFAULT_RKCLOUD_ROOT_SERVER_PORT      443

#endif // WAN_TEST_SERVER
#endif // LAN_SERVER

#endif // DEBUG
//*******************************************************************************

#define DebugLog(fmt, ...) NSLog((@"DEBUG: ---%s [Line %d]---" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

// 全局的方法宏定义
#ifdef DEBUG_LOG

#define NONUSE_TRY_CATCH // Debug调试版本和Ad Hoc测试版本都不使用Try Catch来避免Crash问题，让Crash在测试阶段暴露出来。

#endif // DEBUG_LOG
//*******************************************************************************

// App两段版本号，不带build号（主.次）
#define APP_SHORT_VERSION         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
// App完整三段版本号，带build号（主.次.build）
#define APP_WHOLE_VERSION         [NSString stringWithFormat:@"%@.%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]]

// 新特性页面展示版本号,版本号需要在每次更新引导页图片后更新
#define NEWFEATURE_VERSION  @"VERSION_01"
// main tabbar index
typedef NS_ENUM(NSUInteger, MainTabbarIndex) {
    FlightDynamicsTabIndex = 0,
    AirportServiceTabIndex = 1,
    CateringShoppingTabIndex = 2,
    PersonalCenterTabIndex = 3,
};

#define USER_ACCOUNT_MAX_LENGTH   20 // 用户名的最大长度限制
#define USER_PASSWORD_MAX_LENGTH  20 // 密码的最大长度限制
#define USER_NAME_MAX_LENGTH      30 // 姓名最大长度
#define USER_ACCOUNT_MIN_LENGTH   6 // 用户名的最小长度限制
#define USER_PASSWORD_MIN_LENGTH   6 // 密码的最小长度限制
#define USER_PINCODE_LENGTH        6 // 验证码长度
#define USER_FEED_BACK_CONTENT_MAX_LENGTH   256 // 投诉，评价，意见反馈，退款原因
#define REFUND_PRICE_MAX_LENGTH   10 // 退款金额
#define EMAIL_MAX_LENGTH   50 // 邮箱输入的限制
#define ADDRESSL_MAX_LENGTH   50 // 地址输入长度的限制
#define USER_NAME_MAX_LENGTH   30 // 姓名输入长度的限制
#define TABLEVIEW_CELL_NOMAL_HEIGHT      44 // TableViewCell默认的高度
#define TABLEVIEW_SECTION_NOMAL_HEIGHT   20 // TableViewSection默认的高度
#define FLIGHT_SEARCH_MAX_LENGTH  20 // 航班搜索最大长度限制

#define CONTACT_GROUPS_NAME_MAX_LENGTH      30 // 分组名称最长的限制

#define SEGMENTED_CONTROL_HEIGHT  30 // UISegmentedControl默认的高度

#define DEFAULT_AIRPORT_STRING_LENGTH   36.0 // 默认机场长度
//*******************************************************************************
// 浏览器上APP在AppStore的下载地址
#define APP_STORE_DOWNLOAD_URL   @"https://itunes.apple.com/cn/app/rong-ke-tong/id1035234616?mt=8"

// iOS上APP在AppStore的评论地址
#define APP_STORE_COMMENT_URL    @"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1035234616"
// iOS上APP在AppStore的详情地址
#define APP_STORE_DETAILS_URL    @"itms-apps://itunes.apple.com/app/id1035234616"

//*******************************************************************************
#pragma mark -
#pragma mark Timer

#define TIMER_UPDATE_PROFILE_DATE	           24*60*60 // 更新GetProfile时间间隔
#define TIMER_SYNC_ATTENTION_FLIGHT_DATE       24*60*60 // 更新关注航班动态时间间隔
#define TIMER_SYNC_AVAILABLE_AIRPORT_DATE      24*60*60 // 更新可用机场和航站楼信息的时间间隔
#define TIMER_SYNC_PRODUCT_CLASSIFICATION_DATE 24*60*60 // 更新GetProfile的时间间隔
#define DEFAULT_TIMER_WAITING_VIEW              2 // 默认等待时间
#define TIMER_UPDATE_USER_INFO_DATE                5*60 // 获取用户信息时间间隔

#define TIMER_NETWORK_ERROR_PROMPT      2 // 网络错误或超时的提示时间2秒
#define TIMER_NO_PRODUCTION_PROMPT      1 // 加载商品列表，无更多信息
#define TIMER_PROMPT_MEETING_ROOM       1 // 自动隐藏提示view时间

// 应用程序的运行状态
#define APPSTATE_RESET_USER            (1<<0) // 是否重置帐号过程中
#define APPSTATE_LOGIN_USER            (1<<1) // 是否登录账号过程中

// 收到Push通知消息时的状态
#define PUSHMSG_RECEIVED_NCR       (1<<0) // 收到APNS Push通知新来电
#define PUSHMSG_ENTER_FOREGROUND   (1<<1) // 切换应用到前台模式

//*******************************************************************************
#define PROGRESS_IMAGE_WIDTH          32  // 消息上传、下载进度条动画图片的宽
#define PROGRESS_IMAGE_HEIGHT         32  // 消息上传、下载进度条动画图片的高

// 通讯录模式
enum _contact_mode {
    CONTACT_DEFAULT = 0, // 普通通讯录
    CONTACT_ADD = 1,     // 添加会话成员通讯录（没有群组）
    CONTACT_FORWARD = 2  // 转发通讯录（有群组但是只能单选）
};

//*******************************************************************************
// 列表的TableCell单个Cell高度的宏定义
#pragma mark -
#pragma mark 列表的TableCell单个Cell高度的宏定义

#define HEIGHT_MESSAGE_LIST_CELL   60.0
#define HEIGHT_CONTACT_LIST_CELL   60.0
#define HEIGHT_SELECT_CONTACT_CELL 55.0
#define HEIGHT_MORE_LIST_CELL      50.0

//*******************************************************************************
#pragma mark -
#pragma mark 颜色值定义宏 Color Define

// 带RGB参数生成Color的宏定义2
#define COLOR_WITH_RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

// Navigationbar Tint Color
#define COLOR_NAVIGATIONBAR_TINT [UIColor whiteColor]

// Tabbar Tint Color
#define COLOR_TABBAR_TINTCOLOR   COLOR_WITH_RGB(0, 153, 219)

// SegmentedControl Tint Color
#define COLOR_SEGMENTED_CONTROL_TINTCOLOR   COLOR_WITH_RGB(0, 184, 236)

// 界面背景色（界面、间隔距离颜色）
#define COLOR_VIEW_BACKGROUND COLOR_WITH_RGB(242, 243, 247)

// 聊天页面背景色
#define COLOR_CHAT_VIEW_BACKGROUND COLOR_WITH_RGB(235, 235, 235)

// 搜索框背景色
#define COLOR_SEARCH_VIEW_BACKGROUND COLOR_WITH_RGB(236, 237, 241)

// 时间颜色（首页显示时间文字）
#define COLOR_TIME_LABEL_TEXT COLOR_WITH_RGB(166, 166, 166)

// 输入框placeholder文字颜色
#define COLOR_PLACEHOLDER_TEXT COLOR_WITH_RGB(191, 191, 191)

// 界面间隔线颜色
#define COLOR_SEPARATED_VIEW_BACKGROUND COLOR_WITH_RGB(223, 223, 223)

// 注册登录界面线的颜色
#define COLOR_LOGIN_LABEL_WITH_RGB COLOR_WITH_RGB(204, 204, 204)

// UITableViewCell顶部与底部的线条的背景颜色
#define COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND COLOR_WITH_RGB(193, 193, 193)

// 确定按钮Nomal的通用背景颜色49 182 240、提示按钮字体颜色
#define COLOR_OK_BUTTON_NOMAL   COLOR_WITH_RGB(49, 182, 240)

// 确定按钮Highlighted的通用背景颜色0 153  220
#define COLOR_OK_BUTTON_HIGHLIGHTED  COLOR_WITH_RGB(0, 153, 220)

// 确定按钮Disadle的通用背景颜色
#define COLOR_OK_BUTTON_DISABLE  COLOR_WITH_RGB(228, 228, 228)

// 页面中字体颜色 （标题、正文 偏黑色）
#define COLOR_MAIN_TEXT    COLOR_WITH_RGB(50, 50, 50)

// 页面副标题字体颜色 （副标题 偏灰色）
#define COLOR_SUBHEAD_TEXT    COLOR_WITH_RGB(128, 128, 128)

// 页面提示类字体颜色 （价格 偏红色）
#define COLOR_NOTICE_TEXT    COLOR_WITH_RGB(255, 102, 51)

// 页面中字体颜色 （首页显示的最后一条消息文字,灰色）
#define COLOR_LAST_MESSAGE_TEXT    COLOR_WITH_RGB(154, 154, 154)

// 导航栏左右item的字体颜色
#define COLOR_NAVBAR_ITEM_TITLE    COLOR_WITH_RGB(128, 128, 128)

// 会话界面用户昵称字体颜色
#define COLOR_USER_NAME_TEXT    COLOR_WITH_RGB(115, 115, 115)

// 重要文字颜色（列表名称、内容文字，偏黑色）
#define COLOR_KEY_TEXT    COLOR_WITH_RGB(59, 59, 59)

// 页面提醒字体颜色（删除、退出、消息提醒等操作，偏红色）
#define COLOR_WARNING_TEXT    COLOR_WITH_RGB(247, 76, 49)

// 按钮颜色点缀色
#define COLOR_BUTTON_BACKGROUND    COLOR_WITH_RGB(25, 174, 240)

// 按钮禁用点缀色
#define COLOR_BUTTON_DISABLE    COLOR_WITH_RGB(114, 206, 246)
//*******************************************************************************
#pragma mark -
#pragma mark 字体大小定义宏 Font Define

#define FONT_TEXT_SIZE_12   [UIFont systemFontOfSize:12]
#define FONT_TEXT_SIZE_13   [UIFont systemFontOfSize:13]
#define FONT_TEXT_SIZE_14   [UIFont systemFontOfSize:14]
#define FONT_TEXT_SIZE_16   [UIFont systemFontOfSize:16]
#define FONT_TEXT_SIZE_18   [UIFont systemFontOfSize:18]
#define FONT_TEXT_SIZE_20   [UIFont systemFontOfSize:20]

//*******************************************************************************
#pragma mark -
#pragma mark iOS设备硬件信息

#define UISCREEN_BOUNDS_SIZE      [UIScreen mainScreen].bounds.size // 屏幕的物理尺寸
#define UISCREEN_RESOLUTION_SIZE  [UIScreen mainScreen].preferredMode.size // 屏幕的分辨率(Pixels)

#define BOUNDS_SIZE_480     480 // iPhone3GS,iPhone4/4S设备高
#define BOUNDS_SIZE_568     568 // iPhone5/5S设备高
#define BOUNDS_SIZE_667     667 // iPhone6设备高
#define BOUNDS_SIZE_736     736 // iPhone6 Plus设备高

#define RESOLUTION_SIZE_480   480  // iPhone3GS设备高的分辨率         {320, 480} - {320, 480}
#define RESOLUTION_SIZE_960   960  // iPhone4/4S设备高的分辨率        {320, 480} - {640, 960}
#define RESOLUTION_SIZE_1136  1136 // iPhone5/5S设备高的分辨率        {320, 568} - {640, 1136}
#define RESOLUTION_SIZE_1334  1334 // iPhone6设备高的分辨率      标准：{375, 667} - {750, 1334}   放大：{320, 568} - {640, 1136}
#define RESOLUTION_SIZE_2208  2208 // iPhone6 Plus设备高的分辨率 标准：{414, 736} - {1242, 2208}  放大：{375, 667} - {1125, 2001}

// 状态栏和view的navigationbar的高度
#define STATU_NAVIGATIONBAR_HEIGHT ([UIApplication sharedApplication].statusBarFrame.size.height+44)

// iOS设备硬件类型枚举
enum _ios_machine_hardware_type {
    // 未知的设备
    MACHINE_UNKNOWN,  // unknown device
    
    // 模拟器
    MACHINE_SIMULATOR, // on the simulator
    
    // iPod Touch
    MACHINE_IPOD_1G,  // on iPod Touch
    MACHINE_IPOD_2G,  // on iPod Touch Second Generation
    MACHINE_IPOD_3G,  // on iPod Touch Third Generation
    MACHINE_IPOD_4G,  // on iPod Touch Fourth Generation
    MACHINE_IPOD_5G,  // on iPod Touch Five Generation
    
    // iPhone
    MACHINE_IPHONE_1G,  // on iPhone
    MACHINE_IPHONE_3G,  // on iPhone 3G
    MACHINE_IPHONE_3GS, // on iPhone 3GS
    MACHINE_IPHONE_4,   // on iPhone 4
    MACHINE_IPHONE_4S,  // on iPhone 4S
    MACHINE_IPHONE_5,   // on iPhone 5  @"iPhone5,1"-model A1428, AT&T/Canada; @"iPhone5,2"-model A1429
    MACHINE_IPHONE_5C,  // on iPhone 5C @"iPhone5,3"-iPhone5c-GSM-A1526; @"iPhone5,4"-iPhone5c-CDMA-A1532
    MACHINE_IPHONE_5S,  // on iPhone 5S @"iPhone6,1"-iPhone5s-GSM-A1528; @"iPhone6,2"-iPhone5s-CDMA-A1533
    MACHINE_IPHONE_6,   // on iPhone 6
    MACHINE_IPHONE_6P,  // on iPhone 6 Plus
    
    // iPad
    MACHINE_IPAD_1G,   // on iPad 1rd, WiFi and 3G
    MACHINE_IPAD_2G,   // on iPad 2rd, iPad2,1->WiFi, iPad2,2->GSM 3G, iPad2,3->CDMA 3G
    MACHINE_IPAD_3G,   // on iPad 3rd, iPad3,1->WiFi, iPad3,2->GSM, iPad3,3->CDMA
    MACHINE_IPAD_4G,   // on iPad 4th Generation iPad @"iPad3,4"
    MACHINE_IPAD_MINI, // on iPad Mini
};
typedef NSInteger IOSMachineType;

//*******************************************************************************
#pragma mark -
#pragma mark 消息会话列表显示相关的宏定义

#define MAX_GROUP_TITLE_LENGTH		  30  // 最大的群组标题字数（字母/汉字/数字 个字）
//#define MAX_TEXT_MESSAGE_LENGTH     1000  // 最大的文本消息字数（字母/汉字/数字 个字）
#define FRIEND_SOURCE_DESCRIPTION_OR_ADVANTAGE_LENGTH       150 // 意见反馈文字长度
#define FRIEND_ADDRESS_TEXT_LENGTH       50 // 好友地址
//*******************************************************************************

#pragma mark - Image Layer CornerRadius

#define DEFAULT_IMAGE_CORNER_RADIUS     5.0

#pragma mark - Separated Line Width
#define SEPARATED_LINE_WIDTH 0.5
#endif


#define UIViewAnimationCurveCustom  7 // 键盘弹出和隐藏时的动画节奏是7, 如果动画节奏是7特点: 无论上一次动画是否执行完毕, 会直接过度到当前动画
