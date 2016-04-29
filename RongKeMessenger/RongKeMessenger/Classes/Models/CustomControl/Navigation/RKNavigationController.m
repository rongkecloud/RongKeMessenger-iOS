//
//  NavigationViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/5/4.
//  Copyright (c) 2015年 rongke. All rights reserved.
//

#import "RKNavigationController.h"
#import "UIControlTagMacroDefinition.h"
#import "UIAlertView+CustomAlertView.h"
#import "Definition.h"

@interface RKNavigationController ()

@end

@implementation RKNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationBar.barTintColor = COLOR_NAVIGATIONBAR_TINT;
        self.navigationBar.tintColor = [UIColor colorWithRed:128.0/255.0 green:128.0/255.0 blue:128.0/255.0 alpha:1.0];
    
    }
    else {
        self.navigationBar.tintColor = [UIColor colorWithRed:33.0/255.0 green:41.0/255.0 blue:44.0/255.0 alpha:1.0];
    }
    
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor colorWithRed:52.0/255.0 green:52.0/255.0 blue:52.0/255.0 alpha:1.0]};
    self.navigationBar.translucent = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// Jacky.Chen:2016.02.03:重写Push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    
    // 在push过程中若窗口上存在提示窗口则移除
    [UIAlertView hidePromptView];
    
}
// Jacky.Chen:2016.02.03:重写Push方法
- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    
    // 在push过程中若窗口上存在提示窗口则移除
    [UIAlertView hidePromptView];
    
    return viewController;
}


@end
