//
//  AboutSoftWareViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/5/21.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "AboutSoftWareViewController.h"
#import "Definition.h"

@interface AboutSoftWareViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView; // 整个页面的 scrollView
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView; // logo 图片
@property (nonatomic, weak) IBOutlet UILabel *labelVersion; // 版本号显示
@property (weak, nonatomic) IBOutlet UILabel *rightsLabel; // 权利声明 label

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenConnectAndCompany; // 联系方式 textView 的底部和公司名 label 的顶部之间的高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewWidth; // 应用详情 textView 的宽度

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceOfLeftEdge; // 左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceOfRightEdge; // 右边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceOfBottomEdge; // 底边距

@end

@implementation AboutSoftWareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.logoImageView.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
    self.logoImageView.layer.masksToBounds = YES;
    
    self.title = NSLocalizedString(@"TITLE_ABOUT", "关于融科通");
    [self.view setBackgroundColor:COLOR_VIEW_BACKGROUND];
    
    self.labelVersion.text = [NSString stringWithFormat:@"%@(V%@)", APP_DISPLAY_NAME, APP_WHOLE_VERSION];
    
    self.detailTextViewWidth.constant = UISCREEN_BOUNDS_SIZE.width - (self.spaceOfLeftEdge.constant + self.spaceOfBottomEdge.constant);
}

// 在较大屏幕设备上让最下面两个 label 能接近底部显示
// 用 viewDidLayoutSubviews 而不用 viewWillAppear 或 viewDidLoad 的原因是后两者并没有开始 layout，所以 scrollView 的高度并没有适配当前设备
- (void)viewDidLayoutSubviews
{
    // 此处使用 scrollView 的高而不是其 contentSize 的高的原因是后者的高为 0
    CGFloat heightWillAdd = self.scrollView.frame.size.height - CGRectGetMaxY(self.rightsLabel.frame) - self.spaceOfBottomEdge.constant;
    
    if (heightWillAdd > 0)
    {
        self.spaceBetweenConnectAndCompany.constant += heightWillAdd;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
