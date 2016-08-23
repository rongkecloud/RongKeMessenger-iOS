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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UILabel *labelVersion; // 版本号显示
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UILabel *rightsLabel;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenConnectAndCompany;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailTextViewWidth;

@end

@implementation AboutSoftWareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.logoImageView.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
    self.logoImageView.layer.masksToBounds = YES;
    
    self.title = NSLocalizedString(@"TITLE_ABOUT", "关于融科通");
    [self.view setBackgroundColor:COLOR_VIEW_BACKGROUND];
    
    self.labelVersion.text = [NSString stringWithFormat:@"%@(V%@)", APP_DISPLAY_NAME, APP_WHOLE_VERSION];
    
    self.detailTextViewWidth.constant = UISCREEN_BOUNDS_SIZE.width - 2 * 8;
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"%f, %f ,%f",CGRectGetMaxY(self.rightsLabel.frame), self.scrollView.frame.size.height, self.scrollView.contentSize.height);
    if (self.scrollView.frame.size.height - CGRectGetMaxY(self.rightsLabel.frame) > 8)
    {
        self.spaceBetweenConnectAndCompany.constant += self.scrollView.frame.size.height - CGRectGetMaxY(self.rightsLabel.frame) - 8;
    }
    NSLog(@"%f, %f ,%f",CGRectGetMaxY(self.rightsLabel.frame), self.scrollView.frame.size.height, self.scrollView.contentSize.height);

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
