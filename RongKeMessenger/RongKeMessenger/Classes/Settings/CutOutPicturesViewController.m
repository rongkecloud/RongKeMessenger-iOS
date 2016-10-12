//
//  CutOutPicturesViewController.m
//  RongKeMessenger
//
//  Created by WangGray on 13-3-21.
//  Copyright (c) 2013年 WangGray. All rights reserved.
//

#import "CutOutPicturesViewController.h"
#import "ImageCropperMaskView.h"
#import "ToolsFunction.h"

#define CROPPERSIZE 320.0
#define kRuleSize 800.0

@interface CutOutPicturesViewController ()
@end

@implementation CutOutPicturesViewController

@synthesize scrollView;
@synthesize imageView;
@synthesize imageCropperMaskView;
@synthesize delegate;

- (id)initWithImage:(UIImage*)image
{
    self = [super init];
	if (self)
    {
        [self.view setBackgroundColor:[UIColor blackColor]];
        
        if (image != self.originImage)
        {
            self.originImage = image;
        }
        
        float viewFrameOriginY = 0;
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.automaticallyAdjustsScrollViewInsets = NO;
            viewFrameOriginY = 20;
        }
        
        //设置遮罩
        [[self imageCropperMaskView] setFrame:CGRectMake(0.0, -20.0 + viewFrameOriginY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44)];
        
        
        //设置scorll
        [[self scrollView] setFrame:CGRectMake(0.0,-20.0 + viewFrameOriginY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44)];
        //更新缩放比
        [self updateZoomScale];
        
        //设置遮罩显示裁剪取景区域
        [[self imageCropperMaskView] setCropSize:CGSizeMake(CROPPERSIZE, CROPPERSIZE)];
        
        //计算scrollView 边界区域大小
        //计算上边界区域大小 如果图的高度 < CROPPERSIZE 则使用图高
        CGFloat x = (CGRectGetWidth([self scrollView].frame) - ((self.originImage.size.width < CROPPERSIZE) ? self.originImage.size.width : CROPPERSIZE)) / 2;
        CGFloat y = (CGRectGetHeight([self scrollView].frame) - ((self.originImage.size.height < CROPPERSIZE) ? self.originImage.size.height : CROPPERSIZE)) / 2;
        
        CGFloat top = y;//上边界
        CGFloat left = x;//左边界
        CGFloat right = CGRectGetWidth([self scrollView].frame)- CROPPERSIZE - left;//右边界大小
        CGFloat bottom = CGRectGetHeight([self scrollView].frame)- CROPPERSIZE - top;//下边界大小
        //设置scrollview的UIEdgeinset大小
        scrollEdgeInset = UIEdgeInsetsMake(top, left, bottom, right);
        
        [[self scrollView] setContentInset:scrollEdgeInset];
        
        CGFloat zoomScale = [self scrollView].zoomScale;
        
        CGFloat offSetX = [self scrollView].contentOffset.x;
        CGFloat offSetY = [self scrollView].contentOffset.y;
        
        //计算 imageView 在scrollview 中 Y 坐标的起始偏移 offSetY
        if (imageView.bounds.size.height*zoomScale >= [self scrollView].frame.size.height)
        {
            offSetY = 0.0;
        }
        else if(imageView.bounds.size.height*zoomScale > CROPPERSIZE
                &&imageView.bounds.size.height*zoomScale < [self scrollView].frame.size.height)
        {
            offSetY = (imageView.bounds.size.height*zoomScale - [self scrollView].frame.size.height)/2;
        }
        
        // 计算imageView 在scrollview 中 X 坐标的起始偏移 offSetX
        if (imageView.bounds.size.width*zoomScale >= [self scrollView].frame.size.width)
        {
            offSetX = 0.0;
        }
        else if(imageView.bounds.size.width*zoomScale > CROPPERSIZE
                &&imageView.bounds.size.width*zoomScale < [self scrollView].frame.size.width)
        {
            offSetX = (imageView.bounds.size.width*zoomScale - [self scrollView].frame.size.width)/2;
        }
        
        [[self scrollView] setContentOffset:CGPointMake(offSetX, offSetY)];
        
        //创建 toolbar
		UIToolbar* toolbar = [UIToolbar new];
		toolbar.barStyle = UIBarStyleBlackTranslucent;
		[toolbar sizeToFit];
		toolbar.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44 + (viewFrameOriginY - 20) , UISCREEN_BOUNDS_SIZE.width, 44);
        //创建toolbar button对象
		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_CANCEL",nil)
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(cancelCropping)];
        
		UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_USE",nil)
                                                                       style:UIBarButtonItemStyleDone
                                                                      target:self
                                                                      action:@selector(finishCropping)];
        UIBarButtonItem *descriptionButton =[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_MOVE_SCALE",@"缩放移动") style:UIBarButtonItemStylePlain target:nil action:nil];
        
        //toolbar 上的button控件之间空格对象
		UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
        //添加tools 上的控件对象到数组
		NSArray *items = [NSArray arrayWithObjects: cancelButton, flexItem,descriptionButton,flexItem,userButton, nil];
        
		//设置toolbar控件对像数组
        [toolbar setItems:items animated:NO];
		[self.view addSubview:toolbar];
	}
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO];
}

- (void)dealloc
{
    self.imageCropperMaskView = nil;
    self.imageView = nil;
    self.scrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

#pragma mark -
#pragma mark Customer Methods

/**
 *	@brief	更新缩放级别
 */
- (void)updateZoomScale
{
    CGFloat width = self.originImage.size.width;
    CGFloat height = self.originImage.size.height;
    
    [[self imageView] setFrame:CGRectMake(0, 0, width, height)];
    [[self imageView] setImage:self.originImage];
    
    CGFloat xScale = CROPPERSIZE / width;
    CGFloat yScale = CROPPERSIZE / height;
    
    CGFloat min = MAX(xScale, yScale);
    CGFloat max = 1.0;
    
    if (min > max)
    {
        min = max;
    }
    
    [[self scrollView] setMinimumZoomScale:min];
    [[self scrollView] setMaximumZoomScale:max];
    [[self scrollView] setContentSize:[imageView frame].size];
    
    [[self scrollView] setZoomScale:min animated:NO];
}

/**
 *	@brief	设置图片
 *
 *	@param 	image
 */
- (void)setImage:(UIImage *)image
{
    if (image != self.originImage)
    {
        self.originImage = image;
    }
    
    [[self imageView] setImage:self.originImage];
    
    [self updateZoomScale];
}

/**
 *	@brief	scrollView设置
 *
 *	@return	设置好的scrollView对象
 */
- (UIScrollView *)scrollView
{
    if (scrollView == nil)
    {
        scrollView = [[UIScrollView alloc] init];
        [scrollView setDelegate:self];
        [scrollView setBounces:NO];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setShowsVerticalScrollIndicator:NO];
        [self.view addSubview:scrollView];
    }
    return scrollView;
}

/**
 *	@brief	遮罩设置
 *
 *	@return	返回设置好的遮罩
 */
- (ImageCropperMaskView *)imageCropperMaskView
{
    if (imageCropperMaskView == nil)
    {
        imageCropperMaskView = [[ImageCropperMaskView alloc] init];
        [imageCropperMaskView setBackgroundColor:[UIColor clearColor]];
        [imageCropperMaskView setUserInteractionEnabled:NO];
        [self.view addSubview:imageCropperMaskView];
    }
    
    [self.view bringSubviewToFront:imageCropperMaskView];
    
    return imageCropperMaskView;
}

/**
 *	@brief	imageView设置
 *
 *	@return	设置好的ImageView
 */
- (UIImageView *)imageView
{
    if (imageView == nil)
    {
        imageView = [[UIImageView alloc] init];
        [[self scrollView] addSubview:imageView];
        
    }
    return imageView;
}

/**
 *	@brief	呈现一个controller在特定父viewController之上
 *          Present the navigation controller on the specified parent
 *
 *	@param 	parent  父controller
 */
- (void)presentModallyOn:(UIViewController *)parent
{
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    [parent presentViewController:self animated:YES completion:nil];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)aScrollView
{
    return [self imageView];
}


#pragma mark -
#pragma mark CutOutPicturesDelegate method

/**
 *	@brief	取消裁剪
 */
- (void)cancelCropping
{
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(imageCropperDidCancel:)])
    {
        [self.delegate imageCropperDidCancel:self];
    }
}

/**
 *	@brief	裁剪事件
 */
- (void)finishCropping
{
    CGFloat zoomScale = [self scrollView].zoomScale;
    
    CGFloat offsetX = [self scrollView].contentOffset.x;
    CGFloat offsetY = [self scrollView].contentOffset.y;
    
    //计算在ScrollView上x,y的坐标值，这是与图片相互映射坐标
    CGFloat aX = offsetX>=0 ? offsetX+scrollEdgeInset.left : (scrollEdgeInset.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY+scrollEdgeInset.top: (scrollEdgeInset.top - ABS(offsetY));
    //坐标使用比例转换
    aX = aX / zoomScale;
    aY = aY / zoomScale;

    //原图的上映射的宽高
    CGFloat aWidth = MAX(CROPPERSIZE / zoomScale, CROPPERSIZE);
    CGFloat aHeight = MAX(CROPPERSIZE / zoomScale, CROPPERSIZE);

    //原图边长 < 裁剪区时 取原图边长
    if (self.originImage.size.width < CROPPERSIZE ||
        self.originImage.size.height < CROPPERSIZE)
    {
        aWidth =  MIN(CROPPERSIZE / zoomScale, self.originImage.size.width);
        aHeight = MIN(CROPPERSIZE / zoomScale, self.originImage.size.height);
    }
    
    @autoreleasepool
    {
        CGRect rect = CGRectMake(aX, aY, aWidth, aHeight);
        CGImageRef imageRef = CGImageCreateWithImageInRect([self.originImage CGImage], rect);
        UIImage *imageCropping = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        
        // 裁剪图的边长超过规定图片最大边大小，进行图片规定最大边处理
        UIImage * scaleImage = [ToolsFunction scaleImageSize:imageCropping toSize:CGSizeMake(800, 800)];
        
        // 代理完成裁剪图
        if ((self.delegate != nil) &&
            [self.delegate respondsToSelector:@selector(imageCropper:didFinishCroppingWithImage:)])
        {
            NSLog(@"DEBUG: CutOutPicturesViewController Image aspectRatio = %f", scaleImage.size.width/scaleImage.size.height);
            [self.delegate imageCropper:self didFinishCroppingWithImage:scaleImage];
        }
    }
}
@end

