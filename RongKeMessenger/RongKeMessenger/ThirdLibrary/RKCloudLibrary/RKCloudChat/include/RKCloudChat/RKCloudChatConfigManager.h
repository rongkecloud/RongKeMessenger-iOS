//
//  RKCloudChatConfigManager.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RKCloudChatConfigManager : NSObject

#pragma mark -
#pragma mark Chat Config Function

/**
 * @brief 获取新消息是否声音提醒
 *
 * @return BOOL
 */
+ (BOOL)getNoticeBySound;

/**
 * @brief 设置新消息是否声音提醒
 *
 * @param isAllow  是否允许
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNoticeBySound:(BOOL)isAllow;

/**
 * @brief 获取新消息是否振动提醒
 *
 * @return BOOL
 */
+ (BOOL)getNoticedByVibrate;

/**
 * @brief 设置新消息是否振动提醒
 *
 * @param isAllow  是否允许
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNoticedByVibrate:(BOOL)isAllow;

/**
 * @brief 获取是否在通知栏中显示新消息
 *
 * @return BOOL
 */
+ (BOOL)getNotificationEnable;

/**
 * @brief 设置是否在通知栏中显示新消息
 *
 * @param isAllow  是否允许
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNotificationEnable:(BOOL)isAllow;

/**
 * @brief 获取新消息声音提醒时播放的音乐本地路径
 *
 * @return NSString 消息声音提醒时播放的音乐路径
 */
+ (NSString *)getNotifyRingUri;

/**
 * @brief 设置声音提醒时的音乐
 *
 * @param musicUri 消息声音提醒时播放的音乐路径
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNotifyRingUri:(NSString *)musicUri;

/**
 * @brief 获取播放语音消息时的模式
 *
 * @return BOOL YES:听筒播放 NO:扬声器模式
 */
+ (BOOL)getVoicePlayModel;

/**
 * @brief 设置播放语音消息的模式
 *
 * @param earphone BOOL YES:听筒播放 NO:扬声器模式
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setVoicePlayModel:(BOOL)earphone;


@end
