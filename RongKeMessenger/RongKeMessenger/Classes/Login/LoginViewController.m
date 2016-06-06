//
//  LoginViewController.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/4.
//  Copyright (c) 2015年 rongke. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "UIAlertView+CustomAlertView.h"
#import "ThreadsManager.h"
#import "RegularCheckTools.h"
#import "Definition.h"
#import "DatabaseManager+FriendGroupsTable.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTextField; // 输入账号的文字区域
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField; // 输入密码的文字区域

@property (weak, nonatomic) IBOutlet UIBorderButton *loginButton; // 登录按钮
@property (weak, nonatomic) IBOutlet UIBorderButton *registerButton; // 注册按钮

@property (strong, nonatomic) IBOutlet UIView *inputLoginParentView; // 输入框view
@property (weak, nonatomic) IBOutlet UIView *textAndPwdBackgroundView; // 背景view

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 导航栏标题设置
    self.title = NSLocalizedString(@"TITLE_LOGIN", "登录");
    
    // loginButton 设置
    [ToolsFunction setBorderColorAndBlueBackGroundColorFor:self.loginButton];
    self.loginButton.enabled = YES;
    
    // 如果存在帐号则赋值
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    if (appDelegate.userProfilesInfo.userAccount) {
        self.accountTextField.text = appDelegate.userProfilesInfo.userAccount;
    }

    // textField 设置
    [self setTextFieldAppearanceMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置状态栏样式
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [AppDelegate appDelegate].mainTabController.tabBar.hidden = YES;

    // 显示导航栏
    self.navigationController.navigationBarHidden = YES;
    
    // 调整添加全局通知位置，防止非本页面键盘show/hide导致本页面通知响应。
    // 注册键盘显示事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    // 注册键盘隐藏事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    if (appDelegate.userProfilesInfo.userAccount)
    {
        [self.passwordTextField becomeFirstResponder];
    }
    else {
        [self.accountTextField becomeFirstResponder];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    // 调整添加全局通知位置，防止非本页面键盘show/hide导致本页面通知响应。
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

// 设置 textField
- (void)setTextFieldAppearanceMode
{
    // 代理
    self.accountTextField.delegate = self;
    self.passwordTextField.delegate = self;

    // 键盘模式
    self.accountTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    
    // return 键模式
    self.accountTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
}

// 跳转找寻主视图
- (IBAction)touchLoginButton:(id)sender
{
    // 去除空格和转换帐号为纯小写字母
    NSString *stringUserAccount = [[self.accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSString *stringUserPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // 没有网络则提示没有连接
    if ([ToolsFunction checkInternetReachability] == NO)
    {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    // 验证帐号是否由6-20位字母与数字组成，并以字母开头
    if (![RegularCheckTools isCheckAccount:stringUserAccount]) {

        [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_INPUT_PASSWORD_ERROR", "用户名或密码不匹配，请重新输入")
                           withTitle:NSLocalizedString(@"TITLE_LOGIN_ERROR", "登录失败")
                          withButton:NSLocalizedString(@"STR_CLOSE", "关闭")
                            toTarget:nil];
        return;
    }
    
    if (![RegularCheckTools checkPwd:stringUserPassword]) {
        
        [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_REGISTER_PWD_CHECK", nil)
                           withTitle:NSLocalizedString(@"TITLE_LOGIN_ERROR", "登录失败")
                          withButton:NSLocalizedString(@"STR_CLOSE", "关闭")
                            toTarget:nil];
        return;
    }
    
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    // 注册APNS Push通知
    [ToolsFunction registerAPNSNotifications];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    // 暂时记录登录的帐号
    appDelegate.userProfilesInfo.userAccount = stringUserAccount;
    
    // 提示等待窗口
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    // 调用login接口进行CS登录
    [appDelegate.threadsManager loginServer:stringUserPassword];
}

// 跳转注册界面
- (IBAction)touchRegisterButton:(id)sender
{
    // 取消响应 避免页面通过代理进行高度变化时 出现错误
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    // 弹出注册页面
    RegisterViewController *vwcRegister = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    [self.navigationController pushViewController:vwcRegister animated:YES];
}

#pragma mark - UITextFieldDelegate

// Gray.Wang:2015.03.23:输入帐号的UITextField有改变时的响应函数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.accountTextField) // 手机号码输入框
    {
        NSMutableString *newValue = [textField.text mutableCopy];
        [newValue replaceCharactersInRange:range withString:string];
        
        if ([newValue length] > USER_ACCOUNT_MAX_LENGTH) {
            return NO; // 限制超过帐号长度则不能输入
        }
        
        // 限制登录按钮可用
        self.loginButton.enabled = ([newValue length] > 5 && [self.passwordTextField.text length] >= USER_PASSWORD_MIN_LENGTH);
        
    }
    else if (textField == self.passwordTextField)
    {
        // 判断是否为空，空则disable Button
        NSMutableString *newValue = [self.passwordTextField.text mutableCopy];
        [newValue replaceCharactersInRange:range withString:string];
        
        if ([newValue length] > USER_PASSWORD_MAX_LENGTH) {
            return NO; // 限制超过密码长度不能输入
        }
        
        // 限制登录按钮可用
        self.loginButton.enabled = ([newValue length] >= USER_PASSWORD_MIN_LENGTH && [self.accountTextField.text length] > 5);
    }
    return YES;
}


// Disable "continue" button when the user clear the phone number
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField == self.accountTextField || textField == self.passwordTextField)
    {
        self.loginButton.enabled = NO;
    }
    return YES;
}

// 键盘的done操作
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.accountTextField.text length] > 0 && [self.passwordTextField.text length] > 0) {
        // 进行登录
        [self touchLoginButton:self.loginButton];
    }
    else {
        [self.accountTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
    }
    
    return YES;
}


#pragma mark - UIResponder

// 键盘的自动收回事件
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.accountTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}


// 屏蔽复制、粘贴的菜单
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    /*if (action == @selector(paste:))
     return NO;
     if (action == @selector(select:))
     return NO;
     if (action == @selector(selectAll:))
     return NO;*/
    // return [super canPerformAction:action withSender:sender];
    
    return NO;
}


#pragma mark -
#pragma mark NotificationCenter

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    //NSLog(@"DEBUG: keyboardWillShowNotification");
    
    // 针对在ios7上，只要焦点在文本框上，都会触发keyboardWillShowNotification操作，进行兼容
    // 因通知在不同页面都可以收到，所以若当前界面不是可见界面，则不执行键盘操作
    if (self.navigationController.visibleViewController != self)
    {
        return;
    }
    
    // 若当前界面不是可见界面，则不执行下列操作
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    //keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    //     Restore the size of the text view (fill self's view).
    //     Animate the resize so that it's in sync with the disappearance of the keyboard.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = 0.0;
    [animationDurationValue getValue:&animationDuration];
    
    // Gray.Wang:如果输入框包含登录按钮的父窗口被键盘遮盖则修改view的Y坐标，以便窗口向上移动
    // Jacky.chen:2016.02.02:优化原有键盘弹出调整页面的方式，根据最下端文本输入框位置进行判断并调整
    if (CGRectGetMinY(self.inputLoginParentView.frame) + CGRectGetMaxY(self.loginButton.frame) > CGRectGetMinY(keyboardRect)) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.inputLoginParentView.transform = CGAffineTransformMakeTranslation(0, -(CGRectGetMinY(self.inputLoginParentView.frame) + CGRectGetMaxY(self.loginButton.frame) - CGRectGetMinY(keyboardRect)));
        }];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    //NSLog(@"DEBUG: keyboardWillHideNotification");
    
    // 因通知在不同页面都可以收到，所以若当前界面不是可见界面，则不执行键盘操作
    if (self.navigationController.visibleViewController != self) {
        //DebugLog(@"keyboardWillHideNotification return");
        return ;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    
    //     Restore the size of the text view (fill self's view).
    //     Animate the resize so that it's in sync with the disappearance of the keyboard.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = 0.0;
    [animationDurationValue getValue:&animationDuration];
    
    // 复位还原
    [UIView animateWithDuration:animationDuration animations:^{
        self.inputLoginParentView.transform = CGAffineTransformIdentity;
    }];
}

@end
