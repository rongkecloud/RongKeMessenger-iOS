//
//  RKCustomerServiceSDK.h
//  RKCustomerServiceSDK
//
//  Created by ivan on 16/1/22.
//  Copyright © 2016年 ivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern NSString *kRKCustomerServiceSDKVersion;  // 客户SDK的版本号: 1.0.1.11

@interface RKCustomerServiceSDK : NSObject

#pragma mark -
#pragma mark 匿名接入多媒体客户SDK

/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                         themeColor:(UIColor *)themeColor;


/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param agentGroupId  客服组的id
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                       agentGroupId:(NSString *)agentGroupId
                         themeColor:(UIColor *)themeColor;

/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param agentGroupId  客服组的id
 * @param agentId       客服的id
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                       agentGroupId:(NSString *)agentGroupId
                            agentId:(NSString *)agentId
                         themeColor:(UIColor *)themeColor;


#pragma mark -
#pragma mark 实名接入多媒体客户SDK

/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param userAccount   客户用户名
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                        userAccount:(NSString *)userAccount
                         themeColor:(UIColor *)themeColor;

/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param userAccount   客户用户名
 * @param agentGroupId  客服组的id
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                        userAccount:(NSString *)userAccount
                       agentGroupId:(NSString *)agentGroupId
                         themeColor:(UIColor *)themeColor;


/**
 * @brief 连接多媒体客户SDK的方法，必须调用此方法才能进行业务层的处理。
 * @attention 第三方APP使用集成客户SDK，调用的方法。
 *
 * @param enterpriseKey 多媒体客服企业的key
 * @param userAccount   客户用户名
 * @param agentGroupId  客服组的id
 * @param agentId       客服的id
 * @param themeColor    主题颜色
 *
 * @return void
 */
+ (void)startConnectCustomerService:(NSString *)enterpriseKey
                        userAccount:(NSString *)userAccount
                       agentGroupId:(NSString *)agentGroupId
                            agentId:(NSString *)agentId
                         themeColor:(UIColor *)themeColor;

#pragma mark -
#pragma mark 消息提醒相关接口

/**
 * @brief 设置新消息是否声音提醒 默认有声音
 * @attention 调用startConnectCustomerService函数后调用
 *
 * @param isAllow  是否允许
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNoticeBySound:(BOOL)isAllow;

/**
 * @brief 设置新消息是否振动提醒 默认有震动
 * @attention 调用startConnectCustomerService函数后调用
 *
 * @param isAllow  是否允许
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNoticedByVibrate:(BOOL)isAllow;

/**
 * @brief 设置声音提醒时的音乐 默认播放的文件为2.caf
 * @attention 调用startConnectCustomerService函数后调用
 *
 * @param musicUri 消息声音提醒时播放的音乐路径
 *
 * @return BOOL YES:设置成功 NO:设置失败
 */
+ (BOOL)setNotifyRingUri:(NSString *)musicUri;


@end
