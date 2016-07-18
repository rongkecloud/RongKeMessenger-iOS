//
//  UIAlertView+CustomAlertView.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/18.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "UIAlertView+CustomAlertView.h"
#import "Definition.h"
#import "ToolsFunction.h"

#define DURATION_TIME 2

@implementation UIAlertView (CustomAlertView)

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 *  @param title    alertView的表填
 *  @param text     button的文字
 *  @param delegate 代理对象
 */
+ (void)showSimpleAlert:(NSString*)message
              withTitle:(NSString*)title
             withButton:(NSString*)text
               toTarget:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:delegate
                          cancelButtonTitle:text
                          otherButtonTitles: nil];
    if (alert) {
        [alert show];
    }
}

/**
 *  提示用户升级程序版本
 *
 *  @param delegate 响应代理
 */
+ (void)showForcedUpdateVersionAlert:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_UPDATE", nil)
                                                    message:NSLocalizedString(@"PROMPT_FORCED_UPDATE_VERSION", "您的软件版本过低，可能会导致软件无法正常使用，请点击“到AppStore升级”，为您跳转到AppStore后，请点击“更新”按钮进行升级至最新版本。")
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"STR_UPDATE", "到AppStore升级")
                                          otherButtonTitles:nil];
    alert.tag = ALERT_FORCED_UPDATE_VERSION_TAG;
    [alert show];
}

// 重复登录提示窗口
+ (void)showRepeatLoginAlert:(id)delegate {
    // 提示用户重复登录提示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"PROMPT_REPEATLOGIN_WARNING", @"您的帐号在其它地点登录，已被迫下线")
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"STR_OK", "确定")
                                          otherButtonTitles:nil];
    alert.tag = ALERT_REPEAT_LOGIN_TAG;
    [alert show];
}

// 提示用户被禁止使用
+ (void)showBannedUsersAlert:(id)delegate
{
    // 提示用户被禁止
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:NSLocalizedString(@"STR_PHONE_NUMBER_FORBIDDEN", nil)
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"STR_OK", "确定")
                                          otherButtonTitles:nil];
    alert.tag = ALERT_BANNED_USERS_TAG;
    [alert show];
}

/**
 *  提示用户升级程序版本
 *
 *  @param delegate 响应代理
 */
+ (void)showUpdateVersionAlert:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_UPDATE", nil)
                                                    message:NSLocalizedString(@"PROMPT_UPDATE_VERSION", "本软件有最新版本请您使用，请点击“到AppStore升级”，为您跳转到AppStore后，请点击“更新”按钮进行升级至最新版本。")
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                          otherButtonTitles:NSLocalizedString(@"STR_UPDATE", "到AppStore升级"), nil];
    alert.tag = ALERT_UPDATE_VERSION_TAG;
    [alert show];
}

/**
 *  提示用户无需更新版本
 *
 *  @param delegate 响应代理
 */
+ (void)showNoUpdateVersionAlert:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_UPDATE", nil)
                                                    message:NSLocalizedString(@"PROMPT_NO_UPDATE_VERSION", "您的版本是最新。")
                                                   delegate:delegate
                                          cancelButtonTitle:NSLocalizedString(@"STR_OK", "取消")
                                          otherButtonTitles:nil, nil];
    alert.tag = ALERT_UPDATE_VERSION_TAG;
    [alert show];
}


// 检查并提示用户开启推送通知
+ (void)checkAndShowPushNotificationDisableAlert
{
    UIApplication *application = [UIApplication sharedApplication];
    UIRemoteNotificationType notifyType = [application enabledRemoteNotificationTypes];
    // 判断Push推送功能是否开启
    NSLog(@"TOOLS: [application enabledRemoteNotificationTypes] = %lu", (unsigned long)notifyType);
    
    // 判断系统的Notifications是否开启
    if ((notifyType & UIRemoteNotificationTypeAlert) == NO ||
        (notifyType & UIRemoteNotificationTypeBadge) == NO ||
        (notifyType & UIRemoteNotificationTypeSound) == NO)
    {
        // 提示用户开启Push通知
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_PUSH_NOTIFICATIONS_DISABLED", nil)
                                                        message:NSLocalizedString(@"PROMPT_PUSH_NOTIFICATIONS_DISABLED", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"STR_OK", nil)
                                              otherButtonTitles:nil];
        alert.tag = ALERT_PUSH_NOTIFICATIONS_TAG;
        [alert show];
    }
}

// 显示一个创建新的群聊会话的弹出提示框
+ (void)showCreateNewGroupChatAlert:(id)delegate
{
    // 创建多聊会话(设置会话标题，初始化alertView)
    UIAlertView *setChatTitleAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TITLE_CREATE_MULTI_USER_GROUP", "创建群")																message:nil
                                                               delegate:delegate
                                                      cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                      otherButtonTitles:NSLocalizedString(@"STR_OK", "确定"), nil];
    
    
    setChatTitleAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    setChatTitleAlert.tag = ALERT_CREATE_NEW_GROUP_TAG;
    
    UITextField * titleField = [setChatTitleAlert textFieldAtIndex:0];
    titleField.placeholder = NSLocalizedString(@"STR_TEMP_GROUP_NAME", "临时群");
    //设置文本框代理
    titleField.delegate = delegate;
    titleField.tag = CHAT_TITLE_TEXTFIELD;
    //设置字体大小
    [titleField setFont:[UIFont systemFontOfSize:16]];
    //设置右边消除键出现模式
    [titleField setClearButtonMode:UITextFieldViewModeWhileEditing];
    //设置文字垂直居中
    titleField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    //设置键盘背景色透明
    titleField.keyboardAppearance = UIKeyboardAppearanceAlert;
    [titleField resignFirstResponder];
    
    // 显示创建多人会话的标题输入框
    [setChatTitleAlert show];
}

#pragma mark -
#pragma mark Prompt MaskView Prompt

// 显示模态的等待框
+ (void)showWaitingMaskView:(NSString *)title
{
    // 先检查下是否已经存在一个提示等待框，如果存在先关闭这一个
    [UIAlertView hideWaitingMaskView];
    
    // 生成模态的view
    UIView *alertMaskView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height)];
    // 模态view设置为透明色
    [alertMaskView setBackgroundColor:[UIColor clearColor]];
    alertMaskView.tag = ALERT_PROMPT_WAITING_TAG;
    
    UIFont *fontPromptText = [UIFont systemFontOfSize:16];
    // 设定绘制字符串高和宽
    CGSize sizeTitleString = [ToolsFunction getSizeFromString:title withFont:fontPromptText constrainedToSize:CGSizeMake(UISCREEN_BOUNDS_SIZE.width/2, UISCREEN_BOUNDS_SIZE.height/3)];
    
    float alertOvalViewWidth = UISCREEN_BOUNDS_SIZE.width/3;
    float alertOvalViewHeight = UISCREEN_BOUNDS_SIZE.width/3;
    
    // 中间显示提示文字与活动指示器的view
    UIView *alertOvalView = [[UIView alloc] initWithFrame:CGRectMake(alertMaskView.center.x - alertOvalViewWidth/2.0, alertMaskView.center.y - alertOvalViewHeight/2.0, alertOvalViewWidth, alertOvalViewHeight)];
    
    // 设置提示框的背景色和透明度
    [alertOvalView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    
    // 设置圆角
    alertOvalView.layer.cornerRadius = 7.5;
    alertOvalView.layer.masksToBounds = YES;
    
    // 活动指针器
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = CGPointMake(alertOvalView.bounds.size.width/2.0,  (alertOvalView.bounds.size.height/2.0 - (sizeTitleString.height + 8)/2));//CGPointMake(alertOvalView.bounds.size.width/2.0, 35);
    [activityIndicatorView startAnimating];
    //NSLog(@"DEBUG: indicator.frame = %@", NSStringFromCGRect(indicator.frame));
    
    // 文本提示Label
   UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake((alertOvalViewWidth - sizeTitleString.width) / 2.0, CGRectGetMaxY(activityIndicatorView.frame) + 8, sizeTitleString.width, sizeTitleString.height)];
    promptLabel.numberOfLines = 0;
    promptLabel.text = title;
    [promptLabel setBackgroundColor:[UIColor clearColor]];
    [promptLabel setTextAlignment:NSTextAlignmentCenter];
    [promptLabel setTextColor:[UIColor whiteColor]];
    promptLabel.font = fontPromptText;
    
    // 将提示文本的Label增加到alert上
    [alertOvalView addSubview:promptLabel];
    
    // 将活动指针器增加到alert上
    [alertOvalView addSubview:activityIndicatorView];
    [alertMaskView addSubview:alertOvalView];
    
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    [window addSubview:alertMaskView];
    
    NSLog(@"TOOLS: Show Waiting Mask View...");
}

// 隐藏模态的等待框
+ (void)hideWaitingMaskView
{
    // 先从主窗口上获取alertView的指针
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    if (window)
    {
        UIView *alertView = [window viewWithTag:ALERT_PROMPT_WAITING_TAG];
        if (alertView)
        {
            [alertView removeFromSuperview];
            
            NSLog(@"TOOLS: Hide Waiting Mask View...");
        }
    }
}

#pragma mark - Show Auto Hide Prompt View

// 只是提示文字，默认为2秒的停留并自动消失
+ (void)showAutoHidePromptView:(NSString *)message
{
    [UIAlertView showAutoHidePromptView:message background:nil showTime:DURATION_TIME];
}

// 显示自动隐藏的提示窗口(图片+文字)
+ (void)showAutoHidePromptView:(NSString *)string
                    background:(UIImage *)image
                      showTime:(int)duration
{
    /* Jacky.Chen:2016.02.02判断当前窗口中是否已经添加了提醒控件，若添加直接返回，防止多次重复添加;
     其次将提醒控件添加的窗口变为顶部Window */
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    UIView *alertView = [window viewWithTag:PROMPT_WAITING_VIEW_TAG];
    if (alertView != nil) {
        return;
    }
    
    NSLog(@"TOOLS: showAutoHidePromptView: string = %@, image = %@, duration = %d", string, image, duration);
    
    // 获取所要显示的字需要占据的空间大小
    UIFont *font = [UIFont systemFontOfSize:18];
    //设定绘制字符串高和宽
    CGSize sizeString = [ToolsFunction getSizeFromString:string withFont:font constrainedToSize:CGSizeMake(200, UISCREEN_BOUNDS_SIZE.height)];
    
    float width = sizeString.width;
    float height = sizeString.height;
    // 创建要显示的View
    UIImageView *imageView = nil;
    UILabel *label = nil;
    
    // Gray.Wang:2015.04.10: Fix Warning For Xcode 6.3
    UIDeviceOrientation faceOrientation = [[UIDevice currentDevice] orientation];
    
    //是否有图片显示
    if (image != nil) {
        //获取图文混排的高度和宽度
        float imageWidth = CGImageGetWidth(image.CGImage)/2;
        float imageHeight = CGImageGetHeight(image.CGImage)/2;
        //40是字图片和背景的间距X2
        float alertVieWidth = (width > imageWidth ? width : imageWidth) + 40;
        //20是字和图片的间距 40是字图片和背景的间距X2
        float alertVieHeight = height + imageHeight + 30 + 40;
        
        alertView = [[UIView alloc] initWithFrame:CGRectMake((UISCREEN_BOUNDS_SIZE.width-alertVieWidth)/2.0, (UISCREEN_BOUNDS_SIZE.height-alertVieHeight)/2.0, alertVieWidth, alertVieHeight)];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake((alertVieWidth - imageWidth)/2.0, 20, imageWidth, imageHeight)];
        [imageView setImage:image];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake((alertVieWidth - sizeString.width)/2, 10 + imageHeight + 30, sizeString.width, sizeString.height)];
        
        if ([ToolsFunction getCurrentiOSMajorVersion] < 8) {
            // 若是横屏则旋转90度。
            if (UIDeviceOrientationIsLandscape(faceOrientation)) {
                [alertView setTransform: CGAffineTransformMakeRotation(-M_PI / 2)];
            }
        }
    }
    else
    {
        alertView = [[UIView alloc] initWithFrame:CGRectMake((UISCREEN_BOUNDS_SIZE.width-width)/2.0 - 20, (UISCREEN_BOUNDS_SIZE.height-height)/2.0 - 20, width+40, height+40)];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake((alertView.frame.size.width - width)/2.0, (alertView.frame.size.height - height)/2.0, width, height)];
        
        if ([ToolsFunction getCurrentiOSMajorVersion] < 8) {
            // 若是横屏则旋转90度。
            if (UIDeviceOrientationIsLandscape(faceOrientation)) {
                [alertView setTransform: CGAffineTransformMakeRotation(-M_PI / 2)];
            }
        }
    }
    //设置文字对齐方式
    [label setTextAlignment:NSTextAlignmentCenter];
    //设置文字大小
    [label setFont:font];
    //设置文本
    [label setText:string];
    //设置文字颜色
    [label setTextColor:[UIColor whiteColor]];
    //设置label背景色为透明
    [label setBackgroundColor:[UIColor clearColor]];
    //设置label可以换行
    label.numberOfLines = 0;
    //设置label换行方式
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    
    [alertView setBackgroundColor:[UIColor blackColor]];
    //设定圆角
    alertView.layer.cornerRadius = 7.5;
    alertView.layer.masksToBounds = YES;
    //设定此view透明度
    [alertView setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]];
    [alertView addSubview:label];
    if (imageView != nil) {
        [alertView addSubview:imageView];
    }
    
    //获取当前window
    [window addSubview:alertView];
    alertView.tag = PROMPT_WAITING_VIEW_TAG;
    //开始动画设置
    [UIView animateWithDuration:duration animations:^{
        alertView.alpha = 0.79;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            alertView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (alertView != nil) {
                // 将遮罩层去掉
                [alertView removeFromSuperview];
            }
        }];
    }];
    
}

// 设置提示等待窗口的淡出效果
+ (void)fadeOutMaskView {
    // Jacky.Chen:2016.02.03 :将提醒控件添加的窗口变为顶部Window
    UIWindow *window = [[[UIApplication sharedApplication]windows] lastObject];
    UIView *newView = [window viewWithTag:PROMPT_WAITING_VIEW_TAG];
    if (newView != nil) {
        // 整个遮罩层淡出效果，开始动画设置
        [UIView animateWithDuration:0.5f animations:^{
            newView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [UIAlertView hidePromptView];
        }];
    }
}

// Jacky.Chen:2016.02.03:将hidePromptView方法加为公有方法
// 去除等待提示窗口遮罩层
+ (void)hidePromptView
{
    // Jacky.Chen:2016.02.03 :将提醒控件添加的窗口变为顶部Window
    UIWindow *window = [[[UIApplication sharedApplication]windows] lastObject];
    UIView *newView = [window viewWithTag:PROMPT_WAITING_VIEW_TAG];
    if (newView != nil) {
        // 将遮罩层去掉
        [newView removeFromSuperview];
    }
    
    NSLog(@"TOOLS: hidePromptView");
}

// 提示系统错误
+ (void)showSystemError
{
    [UIAlertView showAutoHidePromptView:@"系统错误，请稍候再试" background:nil showTime:DURATION_TIME];
}


#pragma mark - Show UIAlertView

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 */
+ (void)showSimpleAlert:(NSString*)message
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles: nil];
    [alert show];
}

/**
 *  构建一个简易alertView
 *
 *  @param message  alertView携带消息
 *  @param title    alertView的表填
 *  @param text     button的文字
 *  @param delegate 代理对象
 */
+ (void)showSimpleAlert:(NSString*)message
              withTitle:(NSString*)title
             withButton:(NSString*)text
               toTarget:(id)delegate
                    tag:(int)tag
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:title
                          message:message
                          delegate:delegate
                          cancelButtonTitle:text
                          otherButtonTitles: nil];
    alert.tag = tag;
    [alert show];
}

// 显示带有输入框的alertView
+ (void)showAlertViewWithInputText:(NSString *)alertTitle
                  withCancelButton:(NSString *)cancelButtonTitle
                    withDoneButton:(NSString *)doneButtonTitle
                          delegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:alertTitle
                          message:nil
                          delegate:delegate
                          cancelButtonTitle:nil
                          otherButtonTitles: cancelButtonTitle, doneButtonTitle, nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

// 显示两个按钮的alertView
+ (void)showAlertViewTitle:(NSString *)alertTitle
                   message:(NSString *)message
          withCancelButton:(NSString *)cancelButtonTitle
            withDoneButton:(NSString *)doneButtonTitle
                  delegate:(id)delegate
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:alertTitle
                          message:message
                          delegate:delegate
                          cancelButtonTitle:nil
                          otherButtonTitles: cancelButtonTitle, doneButtonTitle, nil];
    [alert show];
}

// 显示两个按钮的alertView
+ (void)showAlertViewTitle:(NSString *)alertTitle
                   message:(NSString *)message
          withCancelButton:(NSString *)cancelButtonTitle
            withDoneButton:(NSString *)doneButtonTitle
                  delegate:(id)delegate
                       tag:(int)tag
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:alertTitle
                          message:message
                          delegate:delegate
                          cancelButtonTitle:nil
                          otherButtonTitles: cancelButtonTitle, doneButtonTitle, nil];
    [alert show];
    alert.tag = tag;
}

@end
