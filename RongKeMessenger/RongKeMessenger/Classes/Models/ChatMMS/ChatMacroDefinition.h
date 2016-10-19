//
//  ChatMacroDefinition.h
//  RKCloudDemo
//
//  Created by WangGray on 15/6/10.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef RKCloudDemo_ChatMacroDefinition_h
#define RKCloudDemo_ChatMacroDefinition_h

static const int CELL_MESSAGE_TOP_DISTANCE = 9; // 消息cell顶端预留的距离
static const int CELL_MESSAGE_BUTTOM_DISTANCE = 9; // 消息cell底端预留的距离
static const int CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE = 9; // 消息cell中内容距离左边或右边的间距

static const int CELL_MESSAGE_BUBBLE_HEAD_TOP_SEPARATION = 20; // 消息中头像顶端和消息泡泡的间距

static const int CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE = 5; // cell中头像和泡泡之间的距离
static const int CELL_DISTANCE_BETWEEN_AVATAR_AND_NAME = 13; // cell中头像和名字之间的距离

static const int CELL_BUBBLE_ARROW_WIDTH = 8; // 泡泡中箭头的宽度
static const int CELL_DISTANCE_BETWEEN_STATUS_AND_LEFT_OF_BUBBLE = 12; // 发送消息的状态和泡泡的横向间距
static const int CELL_DISTANCE_BETWEEN_TIME_AND_LEFT_OF_STATUS = 6; // 发送消息的时间和状态的横向间距
static const int CELL_DISTANCE_BETWEEN_STATUS_AND_BOTTOM_OF_BUBBLE = 9; // 发送消息的状态和泡泡底部之间的间距
static const int CELL_DISTANCE_BETWEEN_TIME_AND_BOTTOM_OF_BUBBLE = 10; // 发送消息的时间和泡泡底部之间的间距

static const int CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE = 10; // 文本Icon和文字之间的距离
static const int CELL_MESSAGE_FILE_ICON_WIDTH = 19; // 文件消息icon的宽度
static const int CELL_MESSAGE_USER_NAME_HEIGHT = 16; // 消息中用户的名字高度

static const int CELL_TEXT_MIDDLE_SPACE_IOS7_EARLIER = 20; // 文本类型消息中间间距高度，上间距为10，下间距为10

static const int TEXT_BUBBLE_MIN_HEIGHT = 41; // 单行文本CELL的最小高度
static const int VOICE_BUBBLE_HEIGHT = 41; // 语音泡泡的高度
static const int IMAGE_BUBBLE_HEIGHT = 43; // 图片CELL默认高度
static const int FILE_BUBBLE_HEIGHT = 56; // 文件CELL默认高度

static const int CELL_AVATAR_WIDTH = 40; // 消息中头像的宽度

// 联系人头像图片圆角半径
#define CELL_AVATAR_IMAGE_CORNER_RADIUS CELL_AVATAR_WIDTH/2.0

// 收到的消息泡泡距屏幕左边的间距 收到消息的联系人头像距屏幕左边的间距+头像宽度+头像距泡泡左尖的距离
#define CELL_MESSAGE_BUBBLE_LEFT_DISTANCE CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE + CELL_AVATAR_WIDTH + CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE

#define CELL_MESSAGE_BUBBLE_RIGHT_DISTANCE CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE - CELL_AVATAR_WIDTH - CELL_BUBBLE_ARROW_WIDTH - CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE

// 收到的消息泡泡距离cell上边的距离
#define CELL_MESSAGE_BUBBLE_TOP_DISTANCE CELL_MESSAGE_BUBBLE_HEAD_TOP_SEPARATION + CELL_MESSAGE_TOP_DISTANCE

// 发送文本消息泡泡内容距屏幕右边缘间距(iOS7之后)
#define CELL_TEXT_BUBBLE_RIGHT_DISTANCE CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE + CELL_AVATAR_WIDTH + CELL_TEXT_LEFT_AND_RIGHT + CELL_BUBBLE_ARROW_WIDTH + CELL_DISTANCE_BETWEEN_AVATAR_AND_BUBBLE 
// 发送文本消息泡泡内容距屏幕右边缘间距(iOS7之前)
#define CELL_TEXT_BUBBLE_RIGHT_DISTANCE_IOS7_EARLIER  CELL_MESSAGE_LEFT_OR_RIGHT_DISTANCE + CELL_AVATAR_WIDTH + CELL_TEXT_LEFT_AND_RIGHT_IOS7_EARLIER + CELL_BUBBLE_ARROW_WIDTH //32


#define TIP_MESSAGE_TEXT_FONT  [UIFont systemFontOfSize:11] // 提示信息的字体大小
#define MESSAGE_TEXT_FONT      [UIFont systemFontOfSize:16] // 消息文本字体的字体大小

#define MESSAGE_LOCAL_CONTENT_WIDTH   UISCREEN_BOUNDS_SIZE.width - 150 // 本地消息的最大宽度
#define MESSAGE_TEXT_CONTENT_WIDTH	  UISCREEN_BOUNDS_SIZE.width - 150 //187 // 消息内容区域的宽度

#define MESSAGE_LINE_HEIGHT			 20.0 // 消息内容区域每行的高度
#define MESSAGE_TEXT_MAX_LINE		  150 // 消息文本的最大行数
#define MESSAGE_EMOTICON_WIDTH         21 // 消息内容区域的表情符号宽度
#define MESSAGE_EMOTICON_HEIGHT        20 // 消息内容区域的表情符号高度

#define CELL_HEAD_HEIGHT			    5 // CELL上面预留的高度
#define CELL_ADD_HEIGHT                15 // 调整会话页面的联系人位置，页面中各个控件分别调整的固定值

#define CELL_TEXT_BUBBLE_MIN_WIDTH     27 // 文本消息泡泡的最小宽度

#define CELL_TEXT_LEFT_AND_RIGHT       5 // 文本消息框距泡泡的左间距加上右间距,上间距为5，下间距为5
#define CELL_TEXT_LEFT_AND_RIGHT_IOS7_EARLIER   10 // ios7以前版本文本消息框距泡泡的左间距加上右间距，左间距为10，右间距为10

#define MMS_THUMBNAIL_SCALE_LENGTH_120     120 // MMS缩略图缩放时最长边的长度
#define MMS_THUMBNAIL_SHORTEST_LENGTH_43    43 // MMS缩略图缩放时最短边的长度

// 消息中文字的颜色（本地）
#define MESSAGE_TEXT_COLOR_SELF  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1]
// 消息中文字的颜色（对方）
#define MESSAGE_TEXT_COLOR_OTHER  [UIColor colorWithRed:39/255.0 green:39/255.0 blue:39/255.0 alpha:1]
/******************************************文件消息cell内部间距宏定义***************************************************/
#define CELL_MESSAGE_FILEICON_TOP     10   //文本Icon距离泡泡上端的距离
#define CELL_MESSAGE_FILEICON_LEFT    10   //文本Icon距离泡泡左端的距离
#define CELL_MESSAGE_FILETEXT_RIGHT   10   //文本消息中文件名据右边的距离

#define CELL_MESSAGE_FILE_WIDTH       (UISCREEN_BOUNDS_SIZE.width - 115)  //文件泡泡的宽度 (Jacky.Chen修改文件消息宽度)

#define CELL_MESSAGE_FILETEXT_TOP     10   //文本消息中文件名据泡泡上边和下边的距离

// Jacky.Chen:Add 文件名称内容区域的最大宽度
#define MESSAGE_FILE_CONTENT_WIDTH    (CELL_MESSAGE_FILE_WIDTH - CELL_MESSAGE_FILE_ICON_WIDTH -CELL_MESSAGE_FILEICON_LEFT - CELL_MESSAGE_FILEICON_AND_TEXT_DISTANCE - CELL_MESSAGE_FILETEXT_RIGHT)

#endif
