//
//  UIControlTagMacroDefinition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_UIControlTagMacroDefinition_h
#define EnjoySkyLine_UIControlTagMacroDefinition_h

//*******************************************************************************
#pragma mark -
#pragma mark 提示窗口的tag值

// 提示窗口使用(100~120)
#define ALERT_PROMPT_WAITING_TAG			100	// 提示等待alert窗口
#define ALERT_UPLOAD_ADDRESSBOOK_TAG		101	// 上传通讯录提示
#define ALERT_FORCED_UPDATE_VERSION_TAG		104	// 提示用户强制程序版本升级
#define ALERT_UPDATE_VERSION_TAG			105	// 提示用户程序版本升级
#define ALERT_REPEAT_LOGIN_TAG				106	// 提示用户重复登录
#define ALERT_PUSH_NOTIFICATIONS_TAG		107	// 提示用户开启推送通知
#define ALERT_BANNED_USERS_TAG				109    // 提示用户被禁止使用
#define ALERT_ADDRESSBOOK_DISEABLE_TAG      110    // 提示用户开启通讯录使用权限（ios5之后使用）
#define ALERT_CLEAR_MESSAGES_TAG            111	// 提示用户清空消息记录的TAG
#define ALERT_EXIT_SESSION_TAG              112	// 提示用户退出会话的TAG
#define ALERT_CREATE_NEW_GROUP_TAG          113	// 提示创建一个新的群聊提示Tag
#define ALERT_PROMPT_REGISTER_TAG           114    // 注册alert窗口
#define ALERT_CONTACT_GROUPS_NAME_NEW       115    // 添加新分组ALERTVIEW的Tag值
#define ALERT_CONTACT_GROUPS_NAME_DELETE    116    // 删除分组ALERTVIEW的Tag值
#define ALERT_CONTACT_GROUPS_NAME_CHANGE    117    // 编辑分组ALERTVIEW的Tag值
#define ALERT_FORWARD_MESSAGE_TAG           118	// 提示转发消息操作
#define ALERT_CLOSE_CHAT_SESSION_TAG        119    // 提示被踢或者群解散时的Tag值

#define MMSWINDOW_TAG						121	// 状态栏新消息提醒中使用的window tag
#define PROMPT_WAITING_VIEW_TAG             122	// 提示view 遮罩层TAG

//#define ADD_CONTACT_BUTTON					1105    // 会话消息的添加联系人按钮

// 显示群组消息使用
#define GROUP_MESSAGE_LABEL_TAG             1107	// 群组消息文字LabelTAG
#define ALERT_MODIFY_GROUP_NAME             1108	// 修改群组名称
#define CELL_RESETID_TAG                    1109    // 更多页面中登出按钮的tag
#define GROUP_MESSAGE_SEPARATEDLINE_L_TAG	1110	// 分割线左
#define GROUP_MESSAGE_SEPARATEDLINE_R_TAG	1111	// 分割线右
#define ALERT_MODIFY_GROUP_DESCRIPTION      1112	// 修改群组描述

// 显示窗口使用(2001~3000)
#define MASK_VIEWS_TAG						2001	// 会话消息遮罩层TAG (隐藏键盘使用-此功能可考虑使用手势替代)
#define CHAT_TITLE_TEXTFIELD				2003	// 多人会话标题设定文本框

#define PROMPT_APNS_VIEW_TAG                2013    // 提示打开Apns通知view的tag
#define PROGRESS_VIEW_TAG                   2015    // 显示进度条信息View的tag

// 账号相关 textField 的Tag值（预留值10000 - 10010）
#define TEXTFIELD_REGISTER_MOBILE_TAG               10003   // 注册手机号输入框
#define TEXTFIELD_REGISTER_PASSWORD_TAG             10004   // 注册密码输入框
#define TEXTFIELD_REGISTER_REPEAT_PASSWORD_TAG      10005   // 注册再次输入密码输入框

// 联系人分组Section Header View Tag 10100-10200
#define CONTACT_SECTION_GROUPS_TAG      10100   // 联系人页面分组HeaderView的Tag值

// 联系人分组名称编辑TextField 的 Tag 10200-10300
#define CONTACT_GROUPS_NAME_EDIT_TEXTFIELD_TAG     10100   // 联系人页面分组HeaderView的Tag值

// 好友详情操作按钮的Tag值10400 - 10420
#define FRIEND_FETAIL_OPTION_BUTTON_TAG      10400   // 联系人页面操作按钮的Tag值

// 语音与视频页面的操作按钮Tag值10430 - 10450
#define CALL_OPRATION_BUTTON_TAG      10430   // 语音与视频页面的按钮Tabg


#define SETTING_CLEAN_RECORD_ALERTVIEW_TAG                        4001 // 清空消息
#define SETTING_LOGOUT_ALERTVIEW_TAG                              4002 // 退出登录
#define SETTING_PERSONAL_DETAIL_MOBILE_ALERTVIEW_TAG              4003 // mobile
#define SETTING_PERSONAL_DETAIL_EMAIL_ALERTVIEW_TAG               4004 // email
#define SETTING_PERSONAL_DETAIL_NAME_ALERTVIEW_TAG                4005 // name
#define SETTING_PERSONAL_DETAIL_ADDRESS_ALERTVIEW_TAG             4006 // address
#define SETTING_PERSONAL_DETAIL_AVATAR_ACTIONSHEET_TAG            4007 // avatar
#define SETTING_PERSONAL_DETAIL_SEX_ACTIONSHEET_TAG               4008 // sex
#define SETTING_PERSONAL_DETAIL_IMAGEVIEW                         4009 // imageview

#define ALERTVIEW_FRIEND_DETAIL_ADD_TAG                           5000 // 好友详情添加好友
#define ALERTVIEW_FRIEND_DETAIL_DELETE_TAG                        5001 // 好友详情 删除好友
#define ALERTVIEW_MODIFY_FRIEND_REMARK                            5002 // 修改备注
#define ALERTVIEW_SESSIONINFO_DELETE_CONTACT_TAG                  5003 // 会话信息界面 删除成员

#define MEETING_HEADER_LABEL_TAG                                  5010  // 多人语音headerLabel Tag
#define MEETING_HEADER_COUNT_LABEL_TAG                            5011  // 多人语音headerLabel Tag

#endif
