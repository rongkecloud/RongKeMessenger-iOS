//
//  ImagePreviewViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "AppDelegate.h"
#import "Definition.h"
#import "ProgressView.h"
#import "ToolsFunction.h"
#import "RKChatSessionViewController.h"
#import "SetBackgroundImageTableViewController.h"
#import "RKChatImagesBrowseViewController.h"

#pragma mark -
#pragma mark ImageScrollView

@implementation ImageScrollView

@synthesize imageView;
@synthesize navgationBarHidden;
@synthesize statusHidden;
@synthesize isImagePreview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 不显示横向进度条
        self.showsVerticalScrollIndicator = NO;
        // 不显示纵向进度条
        self.showsHorizontalScrollIndicator = NO;
        // 允许边界缩放
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        self.navgationBarHidden = NO;
        self.statusHidden = NO;
        self.isImagePreview = NO;
    }
    return self;
}


#pragma mark -
#pragma mark Override layoutSubviews to center content

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = imageView.frame;
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
    {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else
    {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
    {
        if ([ToolsFunction iSiOS7Earlier])
        {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        }
        else
        {
            // ios7中由于navgation会影响页面布局(Y为0时从navgationBar下放开始)，所以需要调整imageView的origin.y
            // 64为navgationBar（44）与状态栏（20）的高度
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2 - STATU_NAVIGATIONBAR_HEIGHT;
            
            if (self.navgationBarHidden == YES)
            {
                // 当点击页面时隐藏navgationBar与状态栏后需要恢复最出计算出origin.y
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
                
                if (self.statusHidden == NO && self.isImagePreview == YES)
                {
                    // 发送图片预览页面有状态栏存在的时候也需要把imageView的origin.y向上移动- 20
                    frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2 - 20;
                }
            }
        }
    }
    else
    {
        if ([ToolsFunction iSiOS7Earlier])
        {
            frameToCenter.origin.y = 0;
        }
        else
        {
            // ios7中由于navgation会影响页面布局(Y为0时从navgationBar下放开始)，所以需要调整imageView的origin.y
            // 64为navgationBar（44）与状态栏（20）的高度
            frameToCenter.origin.y = -STATU_NAVIGATIONBAR_HEIGHT;
            
            if (self.navgationBarHidden == YES)
            {
                // 当点击页面时隐藏navgationBar与状态栏后需要恢复最出计算出origin.y
                frameToCenter.origin.y = 0;
                
                if (self.statusHidden == NO && self.isImagePreview == YES)
                {
                    // 发送图片预览页面有状态栏存在的时候也需要把imageView的origin.y向上移动- 20
                    frameToCenter.origin.y = -20;
                }
            }
        }
    }
    
    imageView.frame = frameToCenter;
}
@end


#pragma mark -
#pragma mark ImagePreviewViewController


@implementation ImagePreviewViewController

@synthesize imageView, displayImage, scrollView, isShowNavgationAndStatusBar, isProgressAnimating, isImagePreview, downloadPrompt, graffitiToolBar, saveToAlbumButton, messageID;
@synthesize parent;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
        currentOrientation = UIInterfaceOrientationPortrait;
    }
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
    
    // FIXME: 屏蔽iOS7废除接口
    if ([ToolsFunction iSiOS7Earlier])
    {
      self.wantsFullScreenLayout = YES;
    }
	[self.imageView setImage:self.displayImage];
	
	// 保存按钮初始化
	UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] 
									initWithTitle:NSLocalizedString(@"STR_SAVE_PHOTO",nil)
									style:UIBarButtonItemStylePlain 
									target:self
									action:@selector(touchSaveButton)];
	self.navigationItem.rightBarButtonItem = rightButton;
    self.saveToAlbumButton = rightButton;
	
	//后退按钮初始化
	UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] 
								   initWithTitle:NSLocalizedString(@"STR_RECOIL", nil)
								   style:UIBarButtonItemStylePlain 
								   target:self
								   action:@selector(touchBackButton)];
	self.navigationItem.leftBarButtonItem = leftButton;
    
    //图片预览页面时的UI调整
    [self initImagePreview];
    
    [self setImageScrollView];
    
    self.scrollView.delegate = self;
    
	if (self.displayImage == nil) {
        self.saveToAlbumButton.enabled = NO;
	}
    
    if (![self.parent isKindOfClass:[RKChatImagesBrowseViewController class]]) {
        // 设置单击手势
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
        [recognizer setNumberOfTapsRequired:1];
        [recognizer setNumberOfTouchesRequired:1];
        [self.scrollView addGestureRecognizer:recognizer];
        recognizer.delegate = self;
    }
    
	self.isShowNavgationAndStatusBar = YES;
    
    // 设置活动指示器
    if (self.isThumbnail) {
        [self addPregressView];
        self.isProgressAnimating = YES;
    }
}


/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 
 }
 */

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置状态栏默认风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 隐藏NavgationBar
    if (isImagePreview)
    {
        [[self navigationController] setNavigationBarHidden:YES];
    }
    
    ProgressView *progressView = (ProgressView *)[self.scrollView viewWithTag:PROGRESS_VIEW_TAG];
    if (progressView)
    {
        [progressView runSpinAnimationWithDuration];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 取消隐藏NavgationBar
    if (isImagePreview)
    {
        [[self navigationController] setNavigationBarHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self releaseOutlets];
}

// 释放IB资源
- (void)releaseOutlets {
	self.imageView = nil;
	self.scrollView = nil;
	self.downloadPrompt = nil;
    self.graffitiToolBar = nil;
    self.saveToAlbumButton = nil;
    self.messageID = nil;
    self.isThumbnail = NO;
}

- (void)dealloc {
	
	[self releaseOutlets];
}

#pragma mark -
#pragma mark Custom Method

- (void)initImagePreview
{
    //图片预览页面
    if (self.isImagePreview) {
        
        self.scrollView.navgationBarHidden = YES;
        self.scrollView.statusHidden = NO;
        self.scrollView.isImagePreview = YES;
        
        //自定义取消按钮
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchCancelButton)];
        
        //自定义使用按钮
        sendImageButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_USE",nil) style:UIBarButtonItemStyleDone target:self action:@selector(touchSendImageButton)];
        sendImageButton.enabled = YES;

        UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        //添加按钮
        [self.graffitiToolBar setItems:[NSArray arrayWithObjects: cancelButton, flexItem, sendImageButton, nil]];
    }
    else {
        self.graffitiToolBar.hidden = YES;
    }
}

- (void)setImageScrollView {
    
    // 如果缩略图为空，则不作任何操作
    if (self.displayImage == nil) {
        return;
    }
    
    [self.imageView setImage:self.displayImage];
    self.scrollView.imageView = self.imageView;
    
    // 根据屏幕当前方向，确定screenWidth和screenHeight的值
    if (currentOrientation == UIDeviceOrientationLandscapeRight ||
        currentOrientation == UIDeviceOrientationLandscapeLeft) {
        screenWidth = UISCREEN_BOUNDS_SIZE.height;
        screenHeight = UISCREEN_BOUNDS_SIZE.width;
    }
    else {
        screenWidth = UISCREEN_BOUNDS_SIZE.width;
        screenHeight = UISCREEN_BOUNDS_SIZE.height;
    }
    
    // 当其转动时，修正scrollView的contentSize和imageView的frame以使图片滑动后不致于消失不见
    if(self.displayImage.size.width > screenWidth)//宽大于屏幕当前宽度，以宽为基准修正
    {
        self.imageView.frame = CGRectMake(0, 0, screenWidth, self.displayImage.size.height*(screenWidth / self.displayImage.size.width));
        self.scrollView.contentSize = CGSizeMake(screenWidth, self.displayImage.size.height*(screenWidth / self.displayImage.size.width));
    }
    else if(self.displayImage.size.height > screenHeight)//高大于屏幕当前高度，以高为基准修正
    {
        self.imageView.frame = CGRectMake(0, 0, self.displayImage.size.width*(screenHeight / self.displayImage.size.height), screenHeight);
        self.scrollView.contentSize = CGSizeMake(self.displayImage.size.width*(screenHeight / self.displayImage.size.height), screenHeight);
    }
    else {
        self.scrollView.contentSize = self.displayImage.size;
        CGRect imageViewRect = self.imageView.frame;
        
        BOOL portraitHanldImage = YES;
        if (self.displayImage.size.width == self.displayImage.size.height){
            //设备处于横屏状态
            if (currentOrientation == UIDeviceOrientationLandscapeRight ||
                currentOrientation == UIDeviceOrientationLandscapeLeft) {
                portraitHanldImage = NO;
            }
        } 
        else if(self.displayImage.size.width > self.displayImage.size.height) {
            // 以宽为基准 使图片适应屏幕
            portraitHanldImage = YES;
        }
        else {
            // 以高为基准 使图片适应屏幕
            portraitHanldImage = NO;
        }
        
        if (portraitHanldImage) {
            // 以宽为基准 使图片适应屏幕
            imageViewRect.size.width = self.scrollView.frame.size.width;
            imageViewRect.size.height = self.displayImage.size.height * (self.scrollView.frame.size.width / self.displayImage.size.width);
        }
        else {
            // 以高为基准 使图片适应屏幕
            imageViewRect.size.height = self.scrollView.frame.size.height;
            imageViewRect.size.width = self.displayImage.size.width * (self.scrollView.frame.size.height / self.displayImage.size.height);
        }
        
        // 修正自适应后宽度超出
        if (imageViewRect.size.width > screenWidth) {
            imageViewRect.size.height = imageViewRect.size.height * (screenWidth / imageViewRect.size.width);
            imageViewRect.size.width = screenWidth;
        }
        // 修正自适应后高度超出
        if (imageViewRect.size.height > screenHeight) {
            imageViewRect.size.width = imageViewRect.size.width * (screenHeight / imageViewRect.size.height);
            imageViewRect.size.height = screenHeight;
        }
        
        self.imageView.frame = imageViewRect;
    }
    CGRect scrollViewRect = self.scrollView.frame;
    scrollViewRect.size = CGSizeMake(screenWidth, screenHeight);
    self.scrollView.frame = scrollViewRect;
    
    [self.scrollView layoutSubviews];
}

//添加进度条信息View
- (void)addPregressView
{
    float progressFrameHeight = (self.scrollView.frame.size.height - PROGRESS_IMAGE_HEIGHT)/2;
    if(![ToolsFunction iSiOS7Earlier]){
        progressFrameHeight -= 70;
    }
    
    ProgressView *progressView = [[ProgressView alloc] initWithFrame:CGRectMake((self.scrollView.frame.size.width - PROGRESS_IMAGE_WIDTH)/2, progressFrameHeight, PROGRESS_IMAGE_WIDTH, PROGRESS_IMAGE_HEIGHT)];
    progressView.tag = PROGRESS_VIEW_TAG;
    progressView.messageID = self.messageID;
    [progressView runSpinAnimationWithDuration];
    progressView.progressLabel.text = @"0%";
    
    [self.scrollView addSubview:progressView];
}

//移除进度条信息
- (void)removeProgressView
{
    ProgressView *progressView = (ProgressView *)[self.scrollView viewWithTag:PROGRESS_VIEW_TAG];
    progressView.progressLabel.text = @"0%";
    if (progressView)
    {
        [progressView removeFromSuperview];
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (isProgressAnimating == YES) {
        return nil;
    }
    return self.imageView;
}


#pragma mark -
#pragma mark UIViewControllerRotation

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    currentOrientation = toInterfaceOrientation;
   	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:duration];
	
    // 旋转时,缩放为原始大小
	self.scrollView.zoomScale = 1.0;

    [self setImageScrollView];
	[UIView commitAnimations];
    
	if (toInterfaceOrientation == UIDeviceOrientationPortrait) {
		if (self.graffitiToolBar.hidden && self.isShowNavgationAndStatusBar == YES) {
			[self.graffitiToolBar setHidden: NO];
		}
	}
	else if (self.graffitiToolBar.hidden == NO) {
        [self.graffitiToolBar setHidden:YES];
	}
}

#pragma mark -
#pragma mark Touch Button Action

- (void)touchSaveButton {
	// 保存图片
	UIImageWriteToSavedPhotosAlbum(self.displayImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

// 回退按钮响应
- (void)touchBackButton {
	[self.navigationController.navigationBar setTranslucent:NO];
    // 返回上一级
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)image:(UIImage *)saveImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error)
    {
        NSLog(@"DEBUG:PersonalBusinessCardsViewController->iamge:didFinishSavingWithError:contextInfo:->保存失败");
    }
	else
    {
        UIImage *comfirmImage = [UIImage imageNamed:@"image_comfirm_normal"];
        
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_SAVE_SUCCESS",nil)
                                   background:comfirmImage
                                     showTime:2];
        NSLog(@"DEBUG:PersonalBusinessCardsViewController->iamge:didFinishSavingWithError:contextInfo:->保存成功");
    }
}

// 取消使用图片按钮响应
- (void)touchCancelButton
{
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
	// 设置动画效果
	[ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
	
	// 将预览视图页面消除
	[self.navigationController popViewControllerAnimated:NO];
    
    //Detail页面tableview滑动到最底部
    if ([self.parent isKindOfClass: [RKChatSessionViewController class]]) {
        ((RKChatSessionViewController *)self.parent).isAppearFirstly = YES;
    }
    
}

// 使用图片按钮响应
- (void)touchSendImageButton
{
    sendImageButton.enabled = NO;
    
    AppDelegate *appDelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
	// 设置动画效果
	[ToolsFunction moveUpTransition:NO forLayer:appDelegate.window.layer];
	
	// 将预览视图页面消除
	[self.navigationController popViewControllerAnimated:NO];
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO];
    
    if ([self.parent isKindOfClass: [RKChatSessionViewController class]]) {
        //发送图片消息
        [(RKChatSessionViewController *)self.parent saveAndSendImage:self.displayImage];
        
        //Detail页面tableview滑动到最底部
        ((RKChatSessionViewController *)self.parent).isAppearFirstly = YES;
    }
    if ([self.parent isKindOfClass: [SetBackgroundImageTableViewController class]]) {
        //发送图片消息
        [(SetBackgroundImageTableViewController *)self.parent saveImage:self.displayImage];
    }
}


#pragma mark -
#pragma mark UIGestureRecognizerDelegate

/*
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    //ignore any touches from a UIToolbar
    if ([touch.view.superview isKindOfClass:[UIToolbar class]]) {
        return NO;
    }
    
    return YES;
}*/

- (void)handleTapFrom:(UITapGestureRecognizer*)TapGestureRecognizer {
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.isShowNavgationAndStatusBar
                                            withAnimation:UIStatusBarAnimationNone];
    
    if (self.isImagePreview == NO)
    {
        [self.navigationController setNavigationBarHidden:self.isShowNavgationAndStatusBar animated:NO];
        
        self.scrollView.navgationBarHidden = self.isShowNavgationAndStatusBar;
    }
    else
    {
        self.scrollView.statusHidden = self.isShowNavgationAndStatusBar;
        
        [self.graffitiToolBar setHidden:self.isShowNavgationAndStatusBar];
        
        if (self.interfaceOrientation != UIDeviceOrientationPortrait) {
            [self.graffitiToolBar setHidden: YES];
        }
    }
    
	self.isShowNavgationAndStatusBar = !self.isShowNavgationAndStatusBar;
}

@end
