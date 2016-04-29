//
//  RKChatImagesBrowseViewController.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKChatImagesBrowseViewController.h"
#import "Definition.h"
#import "ImagePreviewViewController.h"
#import "RKCloudChat.h"
#import "ToolsFunction.h"

@interface RKChatImagesBrowseViewController ()<UIGestureRecognizerDelegate>

@property (nonatomic) BOOL isShowNavgationAndStatusBar;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation RKChatImagesBrowseViewController

- (id)initWithCurrentMessage:(RKCloudChatBaseMessage *)messageObject andLoadedMessage:(NSArray *)loadedMessageArray{
    self = [super init];
    if (self) {
        // Custom initialization

        // 1. 当前显示的图片消息
        self.currentMessage = messageObject;
        
        // 2. 先要筛选出当前已经加载的消息中的图片消息
        [self imageMessageFilter:loadedMessageArray];
        
    }
    return self;

}

- (void)imageMessageFilter:(NSArray *)loadedMessageArray{
    
    NSMutableArray *mutableArray = [NSMutableArray array];
    for (id message in loadedMessageArray) {
        
        if ([message isKindOfClass:[RKCloudChatBaseMessage class]]){
            
            RKCloudChatBaseMessage *messageObject = (RKCloudChatBaseMessage *)message;
            if (messageObject.messageType == MESSAGE_TYPE_IMAGE) {
                [mutableArray addObject:message]; // 如果是图片类型的消息则保留
            }
        }

    }
    
    // 得到需要显示的数据
    self.imageMessageArray = mutableArray;
    
    // 得到当前显示的Index
    self.currentIndex = (int)[self.imageMessageArray indexOfObject:self.currentMessage];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    // 左边按钮
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(touchSaveButton)];
    
    self.navigationItem.rightBarButtonItem  = saveButton;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.scrollView];
    
    NSUInteger numberPages = self.imageMessageArray.count;
    
    // view controllers are created lazily
    // in the meantime, load the array with placeholders which will be replaced on demand
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < numberPages; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    
    // a page is the width of the scroll view
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize =
    CGSizeMake(CGRectGetWidth(self.scrollView.frame) * numberPages, CGRectGetHeight(self.scrollView.frame));
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    int page = self.currentIndex;
    
    [self gotoPage:page];
    
    self.title = [NSString stringWithFormat:@"%d/%lu", page+1, (unsigned long)self.imageMessageArray.count];
}

- (void)touchSaveButton {
    
     ImagePreviewViewController *controller = [self.viewControllers objectAtIndex:self.currentIndex];
    
    if ((NSNull *)controller != [NSNull null]){
        // 保存图片
        UIImageWriteToSavedPhotosAlbum(controller.displayImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
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

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0) {
        return;
    }
    if (page >= self.imageMessageArray.count)
        return;
    
    // replace the placeholder if necessary
    ImagePreviewViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        RKCloudChatBaseMessage *messageObject = [self.imageMessageArray objectAtIndex:page];
        
        // 获取当前消息状态
        switch (messageObject.messageStatus)
        {
            case MESSAGE_STATE_SEND_SENDING:
            case MESSAGE_STATE_SEND_FAILED:
            case MESSAGE_STATE_SEND_SENDED:
            case MESSAGE_STATE_RECEIVE_DOWNED:
            case MESSAGE_STATE_SEND_ARRIVED:
            case MESSAGE_STATE_READED:
            {
                controller = [self imagePreviewViewController:messageObject isThumbnail:NO];
                break;
            }
                
            case MESSAGE_STATE_RECEIVE_RECEIVED:
            case MESSAGE_STATE_RECEIVE_DOWNFAILED:
                // 如果没下载就下载
                [RKCloudChatMessageManager downMediaFile:messageObject.messageID];
            case MESSAGE_STATE_RECEIVE_DOWNING:
                controller = [self imagePreviewViewController:messageObject isThumbnail:YES];
                break;
                
            default:
                break;
        }
        

        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = CGRectGetWidth(frame) * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        
        
        //[self addChildViewController:controller];
        [self.scrollView addSubview:controller.view];
        //[controller didMoveToParentViewController:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 进入图片显示的ViewController
- (ImagePreviewViewController *)imagePreviewViewController:(RKCloudChatBaseMessage *)messageObject isThumbnail:(BOOL)isThumbnail
{
    // 获取消息对象中完整的文件保存路径
    NSString *imagePath = nil;
    if (isThumbnail) {
        imagePath = ((ImageMessage *)messageObject).thumbnailPath;
    }
    else {
        imagePath = ((ImageMessage *)messageObject).fileLocalPath;
    }
    
    // 获取显示图片
    UIImage *displayImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    
    //创建显示大图视图
    ImagePreviewViewController * vwcImageDisplay =
    [[ImagePreviewViewController alloc] initWithNibName:@"ImagePreviewViewController" bundle:[NSBundle mainBundle]];
    
    // 设置显示图片
    vwcImageDisplay.displayImage = displayImage;
    vwcImageDisplay.isImagePreview = NO;
    vwcImageDisplay.messageID = messageObject.messageID;
    vwcImageDisplay.parent = self;
    vwcImageDisplay.isThumbnail = isThumbnail;
    
    return vwcImageDisplay;
}

// at the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = CGRectGetWidth(self.scrollView.frame);
    int page = (int)floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.currentIndex = page;
    
    self.title = [NSString stringWithFormat:@"%d/%lu", page+1, (unsigned long)self.imageMessageArray.count];
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // a possible optimization would be to unload the views+controllers which are no longer visible
}

- (void)gotoPage:(BOOL)animated
{
    int page = self.currentIndex;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect bounds = self.scrollView.bounds;
    bounds.origin.x = CGRectGetWidth(bounds) * page;
    bounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:bounds animated:animated];
}

- (void)updateImage:(RKCloudChatBaseMessage *)messageObject
{
    for (ImagePreviewViewController *vwcImageDisplay in self.viewControllers)
    {
        if ((NSNull *)vwcImageDisplay != [NSNull null])
        {
            if ([vwcImageDisplay.messageID isEqual:messageObject.messageID])
            {
                // 获取消息对象中完整的文件保存路径（非略缩图）
                NSString * imageFilePath = ((ImageMessage *)messageObject).fileLocalPath;
                // 获取显示图片
                UIImage *displayImage = [[UIImage alloc] initWithContentsOfFile:imageFilePath];
                // 设置显示图片
                vwcImageDisplay.displayImage = displayImage;
                
                [vwcImageDisplay setImageScrollView];
                
                // 停止下载旋转等待提示
                [vwcImageDisplay removeProgressView];
                vwcImageDisplay.isProgressAnimating = NO;
                
                // 启用“保存”按钮
                vwcImageDisplay.saveToAlbumButton.enabled = YES;
            }

        }
    }

}

@end
