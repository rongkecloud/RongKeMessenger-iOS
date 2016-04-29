//
//  ProgressView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "ProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

#define PROGRESS_LABEL_HEIGHT 14 // 进度值label控件的高度

@implementation ProgressView

- (id)initWithFrame:(CGRect)frame withCallType:(CallProgressType)callType
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.callProgressViewType = callType;
        
        // 初始化进度图片
        [self initProgressImage];
        
        //添加显示的百分比Label
        [self initProgressLabel];
        
        // 添加相关通知
        [self addAllNotifications];
    }
    return self;
}

- (void)dealloc
{
    imageView = nil;
    self.progressLabel = nil;
    self.messageID = nil;
    
    [self removeAllNotifications];
}

#pragma mark -
#pragma mark init method

// 初始化进度背景图
- (void)initProgressImage
{
    UIImage *progressImage = [UIImage imageNamed:@"loading_progress"];
    if(self.callProgressViewType != FROM_MESSAGE_SESSION_LIST_BUBBLE)
    {
        //添加动画的imageView
        if (imageView == nil) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - progressImage.size.width)/2, (self.frame.size.height - progressImage.size.height)/2, progressImage.size.width, progressImage.size.height)];
        }
        imageView.image = progressImage;
        
        // 启动进度动画
        [self runSpinAnimationWithDuration];
    }
    [self addSubview:imageView];
}

// 添加进度label
- (void)initProgressLabel
{
    UIImage *progressImage = [UIImage imageNamed:@"loading_progress"];
    if (self.progressLabel == nil){
        UILabel *proLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - progressImage.size.width)/2, (self.frame.size.height - PROGRESS_LABEL_HEIGHT)/2, progressImage.size.width, PROGRESS_LABEL_HEIGHT)];
        self.progressLabel = proLabel;
    }
    self.progressLabel.font = [UIFont systemFontOfSize:10];
    self.progressLabel.textAlignment = NSTextAlignmentCenter;
    self.progressLabel.textColor = [UIColor whiteColor];
    self.progressLabel.backgroundColor = [UIColor clearColor];
    if (self.callProgressViewType == FROM_MESSAGE_SESSION_LIST_BUBBLE){
        self.progressLabel.textColor = COLOR_WITH_RGB(128.0, 128.0, 128.0);
        self.progressLabel.font = [UIFont systemFontOfSize:PROGRESS_LABEL_TEXT_FOUNT];
        
        // 由于消息泡泡进度字体增大，所以增加Label的宽度
        float progressLabelWidth = [ToolsFunction getSizeFromString:@"100%" withFont:[UIFont systemFontOfSize:PROGRESS_LABEL_TEXT_FOUNT]].width;
        self.progressLabel.frame = CGRectMake(0, (self.frame.size.height - PROGRESS_LABEL_HEIGHT)/2, progressLabelWidth, PROGRESS_LABEL_HEIGHT);
    }
    [self addSubview:self.progressLabel];
    [self.progressLabel becomeFirstResponder];
}

// 添加所有通知
- (void)addAllNotifications
{
    //注册进度信息的通知
    if (self.callProgressViewType == FROM_MESSAGE_SESSION_LIST_BUBBLE) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updataMmsProgressNotification:)
                                                     name:kRKCloudUpdateMMSProgressNotification
                                                   object:nil];
    }
    
    //注册从后台切换到前台的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(runSpinAnimationWithDuration)
                                                 name:NOTIFICATION_RUN_PROGRESS_ANIMATION
                                               object:nil];
}

// 移除所有通知
- (void)removeAllNotifications
{
    if (self.callProgressViewType == FROM_MESSAGE_SESSION_LIST_BUBBLE) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kRKCloudUpdateMMSProgressNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_RUN_PROGRESS_ANIMATION object:nil];
}

// 环形进度条动画
- (void)runSpinAnimationWithDuration
{
    if ([imageView.layer animationForKey:@"rotationAnimation"]){
        [imageView.layer removeAnimationForKey:@"rotationAnimation"];
    }
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"]; //"z"还可以是“x”“y”，表示沿z轴旋转
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.5 * 1 * 100000]; // 旋转角度
    rotationAnimation.duration = 100000; // 持续时间
    rotationAnimation.cumulative = NO;
    rotationAnimation.repeatCount = 1.0; // 持续循环
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]; //缓入缓出
    
    [imageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

#pragma mark -
#pragma mark NSNotificationCenter

// 进度信息的半分比通知
- (void)updataMmsProgressNotification:(NSNotification *)notification
{
    //NSLog(@"MMS: updataMmsProgressNotification: notification = %@", notification);
    
    if ([notification object] && [notification userInfo])
	{
        // 得到此消息的MessageID
        NSDictionary *progressMsidDict = [[NSDictionary alloc] initWithDictionary:[notification userInfo]];
        NSString *msgID = [progressMsidDict objectForKey:MSG_JSON_KEY_MESSAGEID];
        
        // 若通知消息的ID与当前消息的ID相同则修改百分比值
        if ([self.messageID isEqualToString:msgID])
        {
            // 得到的百分比值
            float progressValue = [[notification object] floatValue];
            
            AppDelegate *appDelegate = [AppDelegate appDelegate];
            
            // 保存进度值，当下载中退出该页面再进入该页面时读取progressDic中对应的进度数据
            if (appDelegate.rkChatSessionListViewController && appDelegate.rkChatSessionListViewController.progressDic)
            {
                [appDelegate.rkChatSessionListViewController.progressDic setObject:[NSString stringWithFormat:@"%0.f", progressValue*100] forKey:msgID];
            }
            
            NSLog(@"MMS: updataMmsProgressNotification: percent = %0.f%% ------", progressValue*100);
            
            // Gray.Wang:2014.07.24:因为上传和进度100%，但是还未收到200 ok的HTTP返回，所以只显示99%来欺骗下用户。
            self.progressLabel.text = [NSString stringWithFormat:@"%0.f%%", progressValue*99];
            [self setNeedsDisplay];
        }
    }
}

@end
