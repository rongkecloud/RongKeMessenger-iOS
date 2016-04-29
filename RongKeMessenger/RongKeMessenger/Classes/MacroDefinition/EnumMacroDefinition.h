//
//  EnumMacroDefinition.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#ifndef EnjoySkyLine_EnumMacroDefinition_h
#define EnjoySkyLine_EnumMacroDefinition_h


//*******************************************************************************
// 发送pincode的模式，注册服务：1，找回密码：2
typedef NS_ENUM(NSUInteger, SendPincodeMode) {
    SEND_PINCODE_REGISTER_ACCOUNT = 1, // 注册服务：1
    SEND_PINCODE_RETRIEVE_PASSWORD = 2, // 找回密码：2
};
//*******************************************************************************

#pragma mark -
#pragma mark   检查更新App自动与手动模式  手动需要显示提示Alert的

typedef NS_ENUM(NSInteger, UpdateSoftwareType){
    UpdateSoftwareTypeAuto = 0, // 检查更新App自动模式
    UpdateSoftwareTypeManual = 1, // 检查更新App手动模式
};
//*******************************************************************************
#pragma mark -
#pragma mark 状态栏消息提示功能宏定义

#define TIME_SHOW_MEAASGE		2    // 消息提醒时间（秒）

// 提示层显示的模式
enum _prompt_type {
    NORMAL_PROMPT, // 普通提示层
    ERROR_PROMPT   // 错误提示层
};
//*******************************************************************************

#pragma mark -
#pragma mark 联系人分组信息操作

// 联系人分组信息操作
typedef NS_ENUM(NSInteger, ContactGroupsOprationType){
    ContactGroupsOprationTypeAdd = 1, // 添加联系人分组
    ContactGroupsOprationTypeChange = 2, // 修改联系人分组
    ContactGroupsOprationTypeDelete = 3, // 删除联系人分组
};
//*******************************************************************************

#pragma mark -
#pragma mark 联系人分组信息操作

// 联系人分组信息操作
typedef NS_ENUM(NSInteger, AddFriendCurrentState){
    AddFriendCurrentStateNomal = 0, // 搜索到好友，未发起验证
    AddFriendCurrentStateSuccess = 1, // 无需验证 加好友成功
    AddFriendCurrentStateWaitingValidation = 2, // 已提交验证信息等待验证
    AddFriendCurrentStateWaitingAuthorize = 3, // 对方申请加为好友
};
//*******************************************************************************

#pragma mark - 文件上传下载操作

// 上传图片和下载图片类型
typedef NS_ENUM(NSInteger, UploadAndDownloadRequestType) {
    UploadAndDownloadRequestTypeUpAvatar = 0, // 设置界面上传图片
    UploadAndDownloadRequestTypeDownloadBigAvatar = 1, // 下载大图片
    UploadAndDownloadRequestTypeDownloadThumbNailAvatar = 2, // 下载小图
};
//*******************************************************************************

#pragma mark - 好友列表使用模式

// 上传图片和下载图片类型
typedef NS_ENUM(NSInteger, FriendsListType) {
    FriendsListTypeFriendGroupsOpration = 0, // 联系人分组模式
    FriendsListTypeCreatChat = 1, // 创建会话模式
    FriendsListTypeOnlyCreatGroupChat = 2, // 只创建群会话
    FriendsListTypeChatAddFriend = 3, // 消息会话增加群成员
    FriendsListTypeForward = 4, // 转发消息模式
};
//*******************************************************************************

#pragma mark - Complete Personal Info

typedef NS_ENUM(NSInteger, PersonalInfoType) {
    PersonalInfoTypeMobile = 0, // 电话号码
    PersonalInfoTypeEmail = 1, // 邮箱
    PersonalInfoTypeName = 2, // 姓名
};
//*******************************************************************************

// 进入会议的类型
typedef NS_ENUM(NSInteger, JoinMeetingType) {
    JoinMeetingNoneType = 0, // 没有任何会议
    JoinMeetingCreateType = 1, // 创建进入类型
    JoinMeetingInviteType = 2, // 邀请进入类型
};
//*******************************************************************************

typedef NS_ENUM(NSInteger, PersonalDetailType) {
    PersonalDetailTypeFriend = 0, // 好友的个人详情
    PersonalDetailTypeStranger = 1, // 陌生人个人详情
};

//*******************************************************************************

typedef NS_ENUM(NSInteger, SessionListShowType) {
    SessionListShowTypeNomal = 0, // 会话列表正常显示模式
    SessionListShowTypeSearchListMain = 1, // 会话列表搜索显示结果一级页面
    SessionListShowTypeSearchSessionName = 2, // 会话列表搜索会话名称显示结果一级页面
    SessionListShowTypeSearchListCategory = 3, // 搜索结果详细的会话列表
};

//*******************************************************************************

typedef NS_ENUM(NSInteger, LoadMessageDirection) {
    LoadMessageOld = 0, // 获取旧的消息，也就是之前的消息
    LoadMessageNew = 1, // 获取新的消息，也就是之前的消息
};

#endif
