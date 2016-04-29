//
//  UIAlertView+CustomAlertView.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (CustomAlertView)

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 *  @param title    alertView的表填
 *  @param text     button的文字
 *  @param delegate 响应代理
 */
+ (void)showSimpleAlert:(NSString*)message withTitle:(NSString*)title withButton:(NSString*)text toTarget:(id)delegate;

/**
 *  提示用户强制升级程序版本
 *
 *  @param delegate 响应代理
 */
+ (void)showForcedUpdateVersionAlert:(id)delegate;

/// 重复登录提示窗口
+ (void)showRepeatLoginAlert:(id)delegate;

/// 提示用户被禁止使用
+ (void)showBannedUsersAlert:(id)delegate;

/**
 *  提示用户升级程序版本
 *
 *  @param delegate 响应代理
 */
+ (void)showUpdateVersionAlert:(id)delegate;

/**
 *  提示用户无需更新版本
 *
 *  @param delegate 响应代理
 */
+ (void)showNoUpdateVersionAlert:(id)delegate;


// 检查并提示用户开启推送通知
+ (void)checkAndShowPushNotificationDisableAlert;

// 显示一个创建新的群聊会话的弹出提示框
+ (void)showCreateNewGroupChatAlert:(id)delegate;


#pragma mark -
#pragma mark Prompt MaskView Prompt

// 显示模态的等待框
+ (void)showWaitingMaskView:(NSString *)title;
// 隐藏模态的等待框
+ (void)hideWaitingMaskView;


#pragma mark - Show Auto Hide Prompt View

// 只是提示文字，默认为2秒的停留并自动消失
+ (void)showAutoHidePromptView:(NSString *)message;

// 添加可以自动隐藏的提示框
+ (void)showAutoHidePromptView:(NSString*)string background:(UIImage*)image showTime:(int)duration;

// 提示系统错误
+ (void)showSystemError;

// Jacky.Chen:2016.02.03:将hidePromptView方法加为公有方法
// 去除等待提示窗口遮罩层
+ (void)hidePromptView;


#pragma mark - Show UIAlertView

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 */
+ (void)showSimpleAlert:(NSString*)message;

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 *  @param title    alertView的表填
 *  @param text     button的文字
 *  @param delegate 响应代理
 */
+ (void)showSimpleAlert:(NSString*)message
              withTitle:(NSString*)title
             withButton:(NSString*)text
               toTarget:(id)delegate
                    tag:(int)tag;

// 显示带有输入框的alertView
+ (void)showAlertViewWithInputText:(NSString *)alertTitle
                  withCancelButton:(NSString *)cancelButtonTitle
                    withDoneButton:(NSString *)doneButtonTitle
                          delegate:(id)delegate;

// 显示两个按钮的alertView
+ (void)showAlertViewTitle:(NSString *)alertTitle
                   message:(NSString *)message
          withCancelButton:(NSString *)cancelButtonTitle
            withDoneButton:(NSString *)doneButtonTitle
                  delegate:(id)delegate;

// 显示两个按钮的alertView
+ (void)showAlertViewTitle:(NSString *)alertTitle
                   message:(NSString *)message
          withCancelButton:(NSString *)cancelButtonTitle
            withDoneButton:(NSString *)doneButtonTitle
                  delegate:(id)delegate
                       tag:(int)tag;

@end
