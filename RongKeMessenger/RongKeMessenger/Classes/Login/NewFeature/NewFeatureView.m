//
//  NewFeatureView.m
//  RongKeMessenger
//
//  Created by 陈朝阳 on 16/2/24.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "NewFeatureView.h"
#import "Definition.h"
#import "AppDelegate.h"

static const NSInteger newfeatureImageCount = 4;
@interface NewFeatureView ()<UIScrollViewDelegate>

// 页面控制
@property(nonatomic ,weak)UIPageControl *pageControl;

@end

@implementation NewFeatureView
#pragma mark
#pragma mark - 初始化

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self =[super initWithFrame:frame]) {
        //1.创建scrollView
        [self setupScrollView];
        //2.创建pagecontrol
        [self setupPageControl];
    }
    return self;
}

// 创建scrollView
- (void)setupScrollView
{
    //1.创建
    UIScrollView *scrollV = [[UIScrollView alloc]init];
    
    //设置frame
    scrollV.frame = self.bounds;
    //代理
    scrollV.delegate = self;
    [self addSubview:scrollV];
    //2.添加新特性图片
    CGFloat imgW = scrollV.frame.size.width;
    CGFloat imgH = scrollV.frame.size.height;
    for (int i =0; i< newfeatureImageCount; i++) {
        //创建UIImageView
        UIImageView *imgView = [[UIImageView alloc]init];
        
        // 加载引导页图片资源
        NSString *imgName = nil;
        // TODO:等有引导页图片时只需替换图片总数和图片即可
        if (UISCREEN_BOUNDS_SIZE.height < 1024) {
            // iphone设备
            imgName = [NSString stringWithFormat:@"new_feature_%02d@2208.jpg",i+1];
        }else
        {
            // ipad设备
            imgName = [NSString stringWithFormat:@"new_feature_%02d@2048.jpg",i+1];
        }
        
        imgView.image = [UIImage imageNamed:imgName];
        [scrollV addSubview:imgView];
        //设置imgview的frame
        imgView.frame = CGRectMake(i*imgW, 0, imgW, imgH);
        //最后一个imageView，添加开始微博和分享按钮
        if (i== newfeatureImageCount - 1) {
            [self setupLastImageView:imgView];
        }
    }
    //3.设置scrollv的其他属性
    //3.1滑动的宽度
    scrollV.contentSize = CGSizeMake(newfeatureImageCount*imgW, 0);
    //3.2分页
    scrollV.pagingEnabled = YES;
    scrollV.backgroundColor = COLOR_WITH_RGB(246, 246, 246);
    //3.3隐藏水平滑动条
    scrollV.showsHorizontalScrollIndicator = NO;
    
}

// 创建pagecontrol
- (void)setupPageControl
{
    //1.创建
    UIPageControl *pageControl = [[UIPageControl alloc]init];
    //frame
    pageControl.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height - 30);
    
    //设置计数总页数
    pageControl.numberOfPages = newfeatureImageCount;
    [self addSubview:pageControl];
    //2.设置pagecontrol显示小圆点的颜色
    //2.1当前页
    pageControl.currentPageIndicatorTintColor = COLOR_WITH_RGB(253, 98, 42);
    //2.2非当前页
    pageControl.pageIndicatorTintColor = COLOR_WITH_RGB(183, 183, 183);
    self.pageControl = pageControl;
}

#pragma mark
#pragma mark- uiscrollViewDelegate方法，设置滚动的页码

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 获取滑动页码
    CGFloat page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    // 获取四舍五入后的新页码
    int newPage = (int)(page + 0.5);
    
    // 最后一页隐藏pageControl，放开始按钮，当从最后一页滑动到倒数第二夜则应显示pageControl
    if (newPage == 2 && self.pageControl.currentPage == 3) {
        self.pageControl.hidden = NO;
    }else if(newPage == 3)
    {
        // 第四页隐藏
        self.pageControl.hidden = YES;
    }
    
    // 设置pagecontrol的当前页码
    self.pageControl.currentPage = newPage;
}

// 最后一个imageView，添加开始微博和分享按钮
- (void)setupLastImageView:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    
    // 添加开始按钮
    [self addStartButton:imageView];
}

// 添加开始按钮
- (void)addStartButton:(UIImageView *)imageView
{
    //1.创建
    UIButton *startBtn = [[UIButton alloc]init];
    
    // 圆角3pt
    startBtn.layer.cornerRadius = 5;
    startBtn.layer.masksToBounds = YES;
    [imageView addSubview:startBtn];
    
    //1.2背景图片
    [startBtn setBackgroundColor:COLOR_BUTTON_BACKGROUND];
    
    //1.3frame
    CGRect frame = startBtn.frame;
    frame.size = CGSizeMake(110, 38);
    startBtn.frame = frame;
    startBtn.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height - 30);
    
    //1.4文字，字体17加粗
    [startBtn setTitle:@"立即开始" forState:UIControlStateNormal];
    [startBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startLogin) forControlEvents:UIControlEventTouchUpInside];
}

// 开始
- (void)startLogin
{
    [self removeFromSuperview];
    
}

// 展示引导页
+ (void)show
{
    UIWindow *window = [AppDelegate appDelegate].window;
    NewFeatureView *newFeature = [[NewFeatureView alloc] initWithFrame:window.bounds];
    [window.rootViewController.view addSubview:newFeature];
}

@end
