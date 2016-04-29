//
//  ChangePasswordViewController.m
//  RongKeMessenger
//
//  Created by Jacob on 15/6/23.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "RKTableViewCell.h"
#import "UIBorderButton.h"

@interface ChangePasswordViewController ()<UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *changePasswordTableView;
@property (nonatomic, strong) UITextField *oldPasswordTextField;
@property (nonatomic, strong) UITextField *presentPasswordTextField;
@property (nonatomic, strong) UITextField *repeadNewPasswordTextfield;
@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) UIBorderButton *submitButton;
@property (nonatomic, strong) UIView *maskingView;

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"STR_CHANGE_PASSWORD", @"修改密码");
    self.changePasswordTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.appDelegate = [AppDelegate appDelegate];
    
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
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_OK", "确定")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self addMaskingView];
    
//    [self addFinshButton];
    
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
/*
- (void)addFinshButton
{
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, 50)];
    // 添加确定按钮
    self.submitButton = [[UIBorderButton alloc] initWithFrame:CGRectMake(15, 10, UISCREEN_BOUNDS_SIZE.width - 30, 40)];
    [self.submitButton addTarget:self action:@selector(touchSubmitButtonMethod) forControlEvents:UIControlEventTouchUpInside];
    self.submitButton.backgroundStateNormalColor = COLOR_OK_BUTTON_NOMAL;
    self.submitButton.backgroundStateHighlightedColor = COLOR_OK_BUTTON_HIGHLIGHTED;
    
    [self.submitButton setTitle:NSLocalizedString(@"STR_SAVE", @"") forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [backgroundView addSubview:self.submitButton];
    
    [self.changePasswordTableView setTableFooterView:backgroundView];
}
*/
- (void)addMaskingView
{
    self.maskingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, CGRectGetHeight(self.view.frame))];
    self.maskingView.hidden = YES;
    self.maskingView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.maskingView];
}

#pragma mark -
#pragma mark UIScrollView Delegate Method

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // Jacky.Chen:2016.02.03:增加轻拖隐藏键盘
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UIView Delegate Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Jacky.Chen:2016.02.03:改变原有密码输入框响应逻辑，根据触摸点选择响应的TextField，修改原来三个修改密码文本输入框不能单次点击响应的问题
    UITouch *touch = [touches anyObject];
    CGPoint point  = [touch locationInView:self.changePasswordTableView];
    
    for (int i = 0; i<3 ; i++) {
        UITableViewCell *childCell = [self.changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        CGRect cellRect = childCell.frame;
        cellRect.size.width = cellRect.size.width*0.5;
        if (CGRectContainsPoint(childCell.frame, point)) {
            switch (i) {
                case 0:
                    if (CGRectContainsPoint(cellRect, point)) {
                        [self.oldPasswordTextField becomeFirstResponder];
                    }else
                    {
                         [self.view endEditing:YES];
                    }

                    break;
                case 1:
                    if (CGRectContainsPoint(cellRect, point)) {
                        [self.presentPasswordTextField becomeFirstResponder];
                    }else
                    {
                         [self.view endEditing:YES];
                    }

                    break;
                case 2:
                    if (CGRectContainsPoint(cellRect, point)) {
                        [self.repeadNewPasswordTextfield becomeFirstResponder];
                    }else
                    {
                        [self.view endEditing:YES];
                    }
                    
                    break;
                default:
                    break;
            }
        }
    }
//    CGPoint point1 = [touch locationInView:[self.changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
//    if (CGRectContainsPoint(self.oldPasswordTextField.frame, point1)) {
//        [self.oldPasswordTextField becomeFirstResponder];
//    }
//    else
//    {
//        [self.view endEditing:YES];
//    }
//    CGPoint point2 = [touch locationInView:[self.changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]]];
//    if (CGRectContainsPoint(self.presentPasswordTextField.frame, point2)) {
//        [self.presentPasswordTextField becomeFirstResponder];
//    }else
//    {
//        [self.view endEditing:YES];
//    }
//
//    CGPoint point3 = [touch locationInView:[self.changePasswordTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]]];
//    if (CGRectContainsPoint(self.repeadNewPasswordTextfield.frame, point3)) {
//        [self.repeadNewPasswordTextfield becomeFirstResponder];
//    }else
//    {
//        [self.view endEditing:YES];
//    }
    
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 加载定制的MessageTable Cell
    static NSString *cellIdentifier = @"ChangePasswordTableViewCell";
    
    RKTableViewCell *changePasswordTableViewCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (changePasswordTableViewCell == nil)
    {
        changePasswordTableViewCell = [[RKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        changePasswordTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
        changePasswordTableViewCell.cellFromType = Cell_From_Type_Other;
    }
    
    // 设置Cell中显示的图标与Title
    [self settingCellIconAndTitle:changePasswordTableViewCell cellIndexPath:indexPath];
    
    return changePasswordTableViewCell;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // 设置 cell相隔之间使用透明的sectionheadview
    UIView *headerView = [[UIView alloc] init];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}

#pragma mark -
#pragma mark Setting Cell Method

- (void)addTextFieldLeftView:(UITextField *)textField
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, 27, 50)];
    CGRect frame = CGRectMake(0, 16, 17, 17);
    UIImageView *leftview = [[UIImageView alloc] initWithFrame:frame];
    leftview.image = [UIImage imageNamed:@"icon_lock"];
    textField.leftViewMode = UITextFieldViewModeAlways;
    [bgView addSubview:leftview];
    textField.leftView = bgView;
    textField.delegate = self;
    textField.font = FONT_TEXT_SIZE_14;
    textField.keyboardType = UIKeyboardTypeASCIICapable;
}

- (void)settingCellIconAndTitle:(RKTableViewCell *)changePasswordTableViewCell  cellIndexPath:(NSIndexPath *)indexpath
{
    switch (indexpath.row) {
        case 0:
        {
            self.oldPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 3, UISCREEN_BOUNDS_SIZE.width - 50, TABLEVIEW_CELL_NOMAL_HEIGHT)];
            self.oldPasswordTextField.placeholder = NSLocalizedString(@"STR_ENTER_OLD_PASSWORD", @"");
            self.oldPasswordTextField.secureTextEntry = YES;
            [changePasswordTableViewCell addSubview:self.oldPasswordTextField];
            changePasswordTableViewCell.cellPositionType = Cell_Position_Type_Top;
            //[self addTextFieldLeftView:self.oldPasswordTextField];
            [self.oldPasswordTextField becomeFirstResponder];
        }
            break;
        case 1:
        {
            self.presentPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, 3, UISCREEN_BOUNDS_SIZE.width - 50, TABLEVIEW_CELL_NOMAL_HEIGHT)];
            self.presentPasswordTextField.secureTextEntry = YES;
            self.presentPasswordTextField.placeholder = NSLocalizedString(@"STR_ENTER_NEW_PASSWORD", @"");
            [changePasswordTableViewCell addSubview:self.presentPasswordTextField];
            changePasswordTableViewCell.cellPositionType = Cell_Position_Type_Middle;
           // [self addTextFieldLeftView:self.presentPasswordTextField];
        }
            break;
        case 2:
        {
            self.repeadNewPasswordTextfield = [[UITextField alloc] initWithFrame:CGRectMake(15, 3, UISCREEN_BOUNDS_SIZE.width - 50, TABLEVIEW_CELL_NOMAL_HEIGHT)];
            self.repeadNewPasswordTextfield.placeholder = NSLocalizedString(@"STR_ENTER_REPEAT_NEW_PASSWORD", @"");
            self.repeadNewPasswordTextfield.secureTextEntry = YES;
            [changePasswordTableViewCell addSubview:self.repeadNewPasswordTextfield];
            changePasswordTableViewCell.cellPositionType = Cell_Position_Type_Bottom;
            //[self addTextFieldLeftView:self.repeadNewPasswordTextfield];
        }
            break;
            
        default:
            break;
    }
}

// Gray.Wang:2015.03.23:输入帐号的UITextField有改变时的响应函数
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([NSString stringWithFormat:@"%@%@",textField.text,string].length > USER_PASSWORD_MAX_LENGTH && string.length > 0) {
        return NO; // 限制超过密码长度不能输入
    }
    else
    {
       return YES;
    }
}

#pragma mark -
#pragma mark UIKeyboard NotificationCenter

- (void)keyboardWillShowNotification:(NSNotification *)note
{
    // 针对在ios7上，只要焦点在文本框上，都会触发keyboardWillShowNotification操作，进行兼容
    // 因通知在不同页面都可以收到，所以若当前界面不是可见界面，则不执行键盘操作
    if (self.navigationController.visibleViewController != self)
    {
        return;
    }
    
    // 若当前界面不是可见界面，则不执行下列操作
    NSDictionary *userInfo = [note userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    self.maskingView.hidden = NO;
    
    if ([self.repeadNewPasswordTextfield isFirstResponder]) {
        CGRect rectInSuperview = [self.repeadNewPasswordTextfield convertRect:self.repeadNewPasswordTextfield.frame toView:self.view];
        
        if (CGRectGetMaxY(rectInSuperview) > CGRectGetMinY(keyboardRect)) {
            [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
                [self.changePasswordTableView setContentOffset:CGPointMake(0, CGRectGetMaxY(rectInSuperview) - CGRectGetMinY(keyboardRect) )];
            } completion:^(BOOL finished) {
                
                
            }];
        }
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)note
{
    // 若当前界面不是可见界面，则不执行下列操作
    NSDictionary *userInfo = [note userInfo];
    
    [UIView animateWithDuration:[[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        [self.changePasswordTableView setContentOffset:CGPointMake(0, 0)];
    } completion:^(BOOL finished) {
        
        self.maskingView.hidden = YES;
        
    }];
}

#pragma mark - Custom Method

- (void)touchRightButton:(id)sender
{
    // 先判断是否有未输入的密码
    if (self.oldPasswordTextField.text.length < USER_PASSWORD_MIN_LENGTH)
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_ENTER_OLD_PASSWORD_NOTICE", @"") background:nil showTime:1.0];
        [self.oldPasswordTextField becomeFirstResponder];
        return;
    }
    else if (self.presentPasswordTextField.text.length < USER_PASSWORD_MIN_LENGTH)
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_ENTER_NEW_PASSWORD_NOTICE", @"") background:nil showTime:1.0];
        [self.presentPasswordTextField becomeFirstResponder];
        return;
    }
    else if (self.repeadNewPasswordTextfield.text.length < USER_PASSWORD_MIN_LENGTH)
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_ENTER_NEW_PASSWORD_NOTICE", @"") background:nil showTime:1.0];
        [self.repeadNewPasswordTextfield becomeFirstResponder];
        return;
    }
    
    // 再判断两次输入密码是否一致
    if (![self.presentPasswordTextField.text isEqualToString:self.repeadNewPasswordTextfield.text])
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_ENTER_REPEAD_NOT_SAME", @"") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
        return;
    }
    
    [self asyncChangePwd];

}

- (void)asyncChangePwd
{
    /*
     用户登录手机客户端
     http://demo.rongkecloud.com/rkdemo/modify_pwd.php
     POST提交。参数表：
     	ss： 账号（必填）
     	oldpwd:  旧密码(必填)
     	newpwd:  新密码(必填)
     oper_result=
     1001：无效session
     1005: 旧密码错误
     9998：系统错误
     9999：参数错误
     oper_result=0
     
     */
    
    // 没有网络则提示没有连接
    if ([ToolsFunction checkInternetReachability] == NO)
    {
        // Gray.Wang:2012.11.10: 提供用户用好性，网络提示不用用户点击即可，一秒提示自动消失。
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NETWORK_ERROR", nil)
                                   background:nil
                                     showTime:TIMER_NETWORK_ERROR_PROMPT];
        return;
    }
    
    
    [UIAlertView showWaitingMaskView:@""];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // rkcloud base request
        HttpRequest *request = [[HttpRequest alloc] init];
        request.requestType = RKCLOUD_HTTP_TYPE_VALUE;
        
        // 去除空格
        NSString *stringUserOldPassword = [self.oldPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *stringUserPresentPassword = [self.presentPasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [request.params setValue:self.appDelegate.userProfilesInfo.userSession
                          forKey:MSG_JSON_KEY_SESSION];
        [request.params setValue:stringUserOldPassword forKey:@"oldpwd"];
        [request.params setValue:stringUserPresentPassword forKey:@"newpwd"];
        
        NSLog(@"HTTPREQUEST: request.params = %@",request.params);
        
        request.apiUrl = [NSString stringWithFormat:HTTP_API_MODIFY_PASSWORD, [AppDelegate appDelegate].userProfilesInfo.mobileAPIServer];
        
        // rkcloud base result
        HttpResult *httpResult = [HttpClientKit sendHTTPRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIAlertView hideWaitingMaskView];
            
            if (httpResult.opCode == 0)
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"TITLE_CHANGE_PWD_SUCCESS", "密码修改成功") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSLog(@"HTTPREQUEST: fail ");
                
                [HttpClientKit errorCodePrompt:httpResult.opCode];
            }
        });
    });

}

@end
