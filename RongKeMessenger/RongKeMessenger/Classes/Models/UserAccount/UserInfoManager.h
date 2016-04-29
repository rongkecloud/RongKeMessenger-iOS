//
//  SettingsManager.h
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/7/31.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PersonalInfos.h"
#import "FriendInfoTable.h"

@interface UserInfoManager : NSObject

/**
 *  上传个人图片
 *
 *  @param localImagePath 图片存储的本地路径
 */
- (void)asyncUploadPersonalOriginalAvatarWithLocalImagePath:(NSString *)localImagePath;


/**
 *  同步操作个人信息
 *
 *  @param key     键：服务器对应的键
 *  @param content 值：用户改变的内容
 */
- (void)syncOperationPersonalInfoWithKey:(NSString *)key andContent:(NSString *)content;

/**
 *  异步获取个人头像
 *
 *  @param account 账户名
 */
- (void)asyncDownloadThumbnailAvatarWithAccount:(NSString *)account;

/**
 *  异步下载原始头像（自己或好友的）
 *
 *  @param account 自己或好友的帐号
 */
- (void)asyncDownloadOriginalAvatarWithAccount:(NSString *)account;

/**
 *  获取个人信息
 *
 *  @return 个人信息对象
 */
- (PersonalInfos*)syncGetPersonalInfos;

#pragma mark - Async Update Info

/**
 *  根据条件判断是否下载个人头像以及更新个人信息
 */
- (void)asyncUpdateMyInfo;

/**
 *  显示个人优先级最高的名字
 *
 *  @return 要显示的名字
 */
- (NSString*)displayPersonalHighGradeName;

@end
