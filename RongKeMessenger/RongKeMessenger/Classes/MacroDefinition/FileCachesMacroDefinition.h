//
//  FileCachesMacroDefinition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_FileCachesMacroDefinition_h
#define EnjoySkyLine_FileCachesMacroDefinition_h

//*******************************************************************************
#pragma mark -
#pragma mark Documents目录下的文件夹，存放用户生成的文件，会被同步到iCloud中

// 用户数据的根目录
#define USER_HOME_DIRECTORY [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@"]

//*****Documents目录下的文件夹，与用户帐号相关的目录*****
//// 图片默认路径
//#define USER_IMAGE_PATH	 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@/Image"]
//// 声音默认路径
//#define USER_VOICE_PATH	 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@/Voice"]
//// 数据文件默认路径
//#define USER_FILE_PATH	 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@/File"]
// plist文件路径
#define USER_PLIST_PATH  [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@/PlistFile"]
// 保存有关用户头像文件的路径
#define USER_AVATAR_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/%@/UserAvatar"]

//*******************************************************************************
#pragma mark -
#pragma mark Library目录下的文件夹，存放用户的公共文件，不会被同步到iCloud中
// Library/Caches目录下会被系统重启或者其他第三方软件清空，只能存放缓存文件，如果要固定存储的需要独立创建文件夹。

// 公共的缓存文件目录
//#define LIBRARY_CACHES_PATH		  [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"]
#define LIBRARY_CACHES_IMAGE_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Image"]
// 保存Debug日志文件信息的目录
#define LIBRARY_DEBUG_LOG_PATH    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/DebugLog"]

// 公共的Plist文件目录
#define LIBRARY_PLIST_PATH		[NSHomeDirectory() stringByAppendingPathComponent:@"Library/PlistFile"]
// 公共的数据（序列化）文件目录
#define LIBRARY_DATAFILE_PATH	[NSHomeDirectory() stringByAppendingPathComponent:@"Library/DataFile"]

//*******************************************************************************
#pragma mark -
#pragma mark 缓存的Plist文件名定义

// 保存APP配置信息Plist文件
#define APP_CONFIG_INFO		@"app_config_info.plist"

// 保存缓存序列化的查询历史数组
#define QUERY_CONDITION_HISTORY @"QueryConditionHistory"

// 保存wizard显示情况的文件
#define SHOW_WIZARD_INFO        @"show_wziard_info.plist"
//*******************************************************************************

#endif
