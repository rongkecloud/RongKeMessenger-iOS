//
//  RegisterViewController.m
//  RongKeMessenger
//
//  Created by WangGray on 15/5/5.
//  Copyright (c) 2015年 rongke. All rights reserved.
//

#import "RegisterViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "ThreadsManager.h"
#import "RegularCheckTools.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *accountTextField; // 注册用户名输入区域
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField; // 密码输入区域
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField; // 再次输入密码区域

@property (weak, nonatomic) IBOutlet UIBorderButton *registerButton; // 注册按钮

@property (strong, nonatomic) IBOutlet UIView *inputRegisterParentView; // 输入框view

@property (assign, nonatomic) BOOL isAccount; // 手机号
@property (assign, nonatomic) BOOL isPassword; // 密码
@property (assign, nonatomic) BOOL isRepeatPassword; // 再次输入密码

@property (nonatomic) AppDelegate *appDelegate;
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appDelegate = [AppDelegate appDelegate];
    
    // 导航栏标题设置
    self.title = NSLocalizedString(@"TITLE_REGISTER", "注册");

    // registerButton 设置
    [ToolsFunction setBorderColorAndBlueBackGroundColorFor:self.registerButton];
    self.registerButton.enabled = NO;
    
    // textField 设置
    [self setTextFieldAppearanceMode];
    
    // 如果独立弹出则增加左边导航按钮
    if (self.isAlonePush) {
        // 增加leftBarButtonItem为取消按钮
        UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchCancelButton:)];
        self.navigationItem.leftBarButtonItem = leftButtonItem;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置状态栏样式
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    // 显示导航栏
    self.navigationController.navigationBarHidden = NO;
    
    // 调整添加全局通知位置，防止非本页面键盘show/hide导致本页面通知响应。
    // 注册TextField通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
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
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 调整添加全局通知位置，防止非本页面键盘show/hide导致本页面通知响应。
    // 移除TextField通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.accountTextField becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

// 设置 TextField
- (void)setTextFieldAppearanceMode
{
    self.accountTextField.delegate = self;
    self.accountTextField.tag = TEXTFIELD_REGISTER_MOBILE_TAG;
    self.passwordTextField.delegate = self;
    self.passwordTextField.tag = TEXTFIELD_REGISTER_PASSWORD_TAG;
    self.repeatPasswordTextField.delegate = self;
    self.repeatPasswordTextField.tag = TEXTFIELD_REGISTER_REPEAT_PASSWORD_TAG;
    
    self.accountTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.repeatPasswordTextField.keyboardType = UIKeyboardTypeASCIICapable;
    
    self.accountTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.repeatPasswordTextField.returnKeyType = UIReturnKeyDone;
}


// 点击注册界面 下一步 按钮
- (IBAction)touchRegisterButton:(id)sender
{
    // 去除空格并转换为小写字母的帐号
    NSString *stringUserAccount = [[self.accountTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    NSString *stringUserPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *stringRepeatUserPassword = [self.repeatPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
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
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_LOGIN_USER_NAME_CHECK", @"用户名不能为空且由6-20位字母或数字组成，且第一位必须为字母") background:nil showTime:1.5];
        return;
    }
    
    // 判断用户名是否符合要求
    if (![RegularCheckTools checkPwd:stringUserPassword]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_REGISTER_PWD_CHECK", @"密码是由6-20位字母或数字组成") background:nil showTime:1.5];
        return;
    }
    
    // 判断两次输入用户名是否一致
    if (![stringUserPassword isEqualToString:stringRepeatUserPassword]) {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_PASSWORD_NOT_SAME", @"两次输入的密码不一致，请重新输入") background:nil showTime:1.5];
        return;
    }
    
    // Gray.Wang:2015.12.28: 注册APNS Push通知，修正防止帐号登出后再重新注册一个新账号而没有打开APNS通知的问题。
    [ToolsFunction registerAPNSNotifications];
    
    // 等待提示
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    // 注册帐号信息
    RegisterAccountInfo *registerAccountInfo = [[RegisterAccountInfo alloc] init];
    registerAccountInfo.userAccount = stringUserAccount;
    registerAccountInfo.userPassword = stringUserPassword;
    
    // 启动注册线程，进行注册+登录流程
    [NSThread detachNewThreadSelector:@selector(startRegisterThread:)
                             toTarget:self.appDelegate.threadsManager
                           withObject:registerAccountInfo];
}

// 按下NavigationBar上的“取消”按钮时触发的事件
- (void)touchCancelButton:(id)sender
{
    /*
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    // 收回注册页面
    [appDelegate popRegisterViewController];
     */
}


#pragma mark - Send Pincode Function

// 发送pincode到手机上
- (void)sendPincodeToMobilePhone
{
    [UIAlertView showWaitingMaskView:NSLocalizedString(@"STR_WAITING", "请稍候...")];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL bSendSuccess = [appDelegate.threadsManager syncSendPincode:self.accountTextField.text
                                                    withPincodeModeType:SEND_PINCODE_REGISTER_ACCOUNT];
        if (bSendSuccess) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                // 弹出验证手机号码页面
                [self pushVerifyMobileViewController];
            });
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                // hide the number pad
                [self.accountTextField resignFirstResponder];
                [self.passwordTextField resignFirstResponder];
                [self.repeatPasswordTextField resignFirstResponder];
            });
        }
    });
}

// 弹出验证手机号码页面
- (void)pushVerifyMobileViewController
{
    /*
    VerifyMobileViewController *vwcVerify = [[VerifyMobileViewController alloc] init];
    vwcVerify.registerAccountInfo = [[RegisterAccountInfo alloc] init];
    
    // 去除空格
    NSString *stringUserAccount = [self.mobileTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *stringUserPassword = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *stringUserName = [self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    vwcVerify.registerAccountInfo.mobile = stringUserAccount;
    vwcVerify.registerAccountInfo.password = stringUserPassword;
    vwcVerify.registerAccountInfo.username = stringUserName;
    
    [self.navigationController pushViewController:vwcVerify animated:YES];
     */
}


#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == ALERT_PROMPT_REGISTER_TAG)
    {
        if (buttonIndex == 1)
        {
            // 发送pincode到手机上
            [self sendPincodeToMobilePhone];
        }
    }
}


#pragma mark - UITextFieldDelegate

- (void)textDidChange:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    
    NSInteger maxStrLendth = ADDRESSL_MAX_LENGTH;
    switch (textField.tag) {
        case TEXTFIELD_REGISTER_MOBILE_TAG:   // 用户名
        {
            maxStrLendth = USER_ACCOUNT_MAX_LENGTH;
        }
            break;
        case TEXTFIELD_REGISTER_PASSWORD_TAG:   // 密码
        {
            maxStrLendth = USER_PASSWORD_MAX_LENGTH;
        }
            break;
        case TEXTFIELD_REGISTER_REPEAT_PASSWORD_TAG:   // 再次输入密码
        {
            maxStrLendth = USER_PASSWORD_MAX_LENGTH;
        }
            break;
            
        default:
            break;
    }
    
    NSString *toBeString = textField.text;
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    if (!position) {
        if (toBeString.length > maxStrLendth) {
            textField.text = [toBeString substringToIndex:maxStrLendth];
        }
    }
    
    if (textField.tag == TEXTFIELD_REGISTER_MOBILE_TAG)
    {
        self.isAccount = ([textField.text length] >= USER_ACCOUNT_MIN_LENGTH);
    }
    else if (textField.tag == TEXTFIELD_REGISTER_REPEAT_PASSWORD_TAG)
    {
        self.isRepeatPassword = ([textField.text length] > 0);
    }
    else if (textField.tag == TEXTFIELD_REGISTER_PASSWORD_TAG)
    {
        self.isPassword = ([textField.text length] > 0);
    }
    
    if (toBeString.length > maxStrLendth) {
        textField.text = [toBeString substringToIndex:maxStrLendth];
    }
    
    self.registerButton.enabled = (self.isAccount && self.isPassword && self.isRepeatPassword);
}

// Disable "continue" button when the user clear the phone number
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if (textField == self.accountTextField || textField == self.passwordTextField || textField == self.repeatPasswordTextField)
    {
        self.registerButton.enabled = NO;
    }
    return YES;
}

// 键盘的done操作
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self.accountTextField.text length] > 0 && [self.passwordTextField.text length] > 0 && [self.repeatPasswordTextField.text length] > 0)
    {
        [self.view endEditing:YES];
        // 进行登录
        [self touchRegisterButton:self.registerButton];
    }
    else
    {
        // hide the number pad
        [self.view endEditing:YES];
    }
    
    return YES;
}

#pragma mark - UIResponder

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 隐藏键盘
    [self.view endEditing:YES];
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
    
    // Jacky.chen:2016.02.02:优化原有键盘弹出调整页面的方式，根据最下端文本输入框位置进行判断并调整
    if (CGRectGetMaxY(self.registerButton.frame) + 64 > CGRectGetMinY(keyboardRect)) {
        [UIView animateWithDuration:animationDuration animations:^{
            self.view.transform = CGAffineTransformMakeTranslation(0, - CGRectGetMinY(self.inputRegisterParentView.frame));
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
    
    // Jacky.chen:2016.02.02:复位
    [UIView animateWithDuration:animationDuration animations:^{
        self.view.transform = CGAffineTransformIdentity;
    }];
}

@end
