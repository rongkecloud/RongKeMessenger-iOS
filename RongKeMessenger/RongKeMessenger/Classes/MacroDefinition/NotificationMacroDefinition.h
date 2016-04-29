//
//  NotificationMacroDefinition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/26.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_NotificationMacroDefinition_h
#define EnjoySkyLine_NotificationMacroDefinition_h

//*******************************************************************************
#pragma mark -
#pragma mark 通知事件宏定义

#define NOTIFICATION_UPDATE_USER_PROFILE                        @"UpdateUserProfile" // 更新用户个人资料通知
#define NOTIFICATION_RUN_PROGRESS_ANIMATION                     @"RunProgressAnimAtion" // 运行MMS下载进度动画的通知
#define NOTIFICATION_CLEAR_MESSAGES_OF_SESSION                  @"ClearMessagesOfSession" // 清空消息的通知
#define NOTIFICATION_UPDATE_GROUPS_INFO                         @"UpdateGroupsInfo" // 更新分组信息
#define NOTIFICATION_UPDATE_FRIEND_LIST                         @"UpdateFriendList" // 更新好友列表

//*******************************************************************************

#pragma mark - 上传头像成功通知

#define NOTIFICATION_UPLOAD_AVATAR_SUCCESS                      @"UploadAvatarSuccess" // 上传个人头像成功
#define NOTIFICATION_UPLOAD_AVATAR_FAIL                         @"UploadAvatarFail" // 上传个人头像失败

#define NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS                    @"downloadAvatarSuccessNotification" // 下载个人头像成功

#define NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS             @"CompletePersonalInfoSuccess" // 晚上个人信息

//*******************************************************************************

#pragma mark - 修改好友备注名 修改群名

#define NOTIFICATION_CHAT_SESSION_CHANGE_FRIEND_REMARK_NAME     @"ChatSessionChangeFriendRemarkName" // 修改好友备注
#define NOTIFICATION_CHAT_SESSION_CHANGE_GROUP_NAME             @"ChatSessionChangeGroupName" // 修改群名称

#pragma mark - 添加好友的结果返回

#define NOTIFICATION_SEARCH_AND_ADD_FRIEND_VERIFY_YES           @"SearchAndAddFriendVerifyYes" // 添加好友 需要验证


#endif
