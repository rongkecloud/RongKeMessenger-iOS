//
//  ImagePreviewViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageScrollView;

// 子类化UIScrollView，以重新设置imageView的中心位置
@interface ImageScrollView : UIScrollView <UIScrollViewDelegate> {
    UIView *imageView;
    NSUInteger index;
}

@property (nonatomic,retain) UIView *imageView;
@property (nonatomic) BOOL navgationBarHidden;
@property (nonatomic) BOOL statusHidden;
@property (nonatomic) BOOL isImagePreview;
@end


@interface ImagePreviewViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate> {
	
    UIInterfaceOrientation currentOrientation;
    
    float screenWidth;
    float screenHeight;
    
    UIBarButtonItem *sendImageButton;  //发送图片的使用按钮
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;                  // 显示图片的view
@property (nonatomic, retain) IBOutlet ImageScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *downloadPrompt; // 下载图片的提示
@property (nonatomic, retain) IBOutlet UIToolbar *graffitiToolBar;              // 涂鸦工具栏

@property (nonatomic, retain) UIBarButtonItem *saveToAlbumButton;               // 保存到相册button
@property (nonatomic, retain) UIImage *displayImage;                            // 将要显示的图片
@property (nonatomic, assign) id parent;
@property (nonatomic) BOOL isShowNavgationAndStatusBar;
@property (nonatomic) BOOL isImagePreview;
@property (nonatomic) BOOL isProgressAnimating;
@property (nonatomic) BOOL isThumbnail;
@property (nonatomic, copy) NSString *messageID;                                // 当前图片对应的messageId

- (void)setImageScrollView;

//移除进度条信息
- (void)removeProgressView;

//添加进度条信息View
- (void)addPregressView;

@end
