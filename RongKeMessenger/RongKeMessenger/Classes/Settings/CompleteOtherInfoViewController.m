//
//  CompleteOtherInfoViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/8/7.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "CompleteOtherInfoViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "RegularCheckTools.h"

#define SETTING_PERSONAL_KEY_MOBILE             @"mobile"
#define SETTING_PERSONAL_KEY_EMAIL              @"email"
#define SETTING_PERSONAL_KEY_NAME               @"name"

@interface CompleteOtherInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *contentTextField;
@property (assign, nonatomic) AppDelegate *appDelegate;

@end

@implementation CompleteOtherInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = COLOR_VIEW_BACKGROUND;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_OK", "确定")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self textFieldPlaceholderAndTitle];
    
    self.appDelegate = [AppDelegate appDelegate];
    [self setContentTextFieldContentText];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.contentTextField becomeFirstResponder];
    // 注册TextField通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 移除TextField通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)dealloc
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

- (void)textFieldPlaceholderAndTitle
{
    NSString *stringPlaceholder = nil;
    NSString *stringTitle = nil;
    switch (self.personalInfoType)
    {
        case PersonalInfoTypeMobile: {
            stringPlaceholder = NSLocalizedString(@"TITLE_MOBILE_NUM", nil);
            stringTitle = NSLocalizedString(@"TITLE_MOBILE_NUM", nil);
            self.contentTextField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case PersonalInfoTypeEmail: {
            stringPlaceholder = NSLocalizedString(@"TITLE_EMAIL_ADDRESS", nil);
            stringTitle = NSLocalizedString(@"TITLE_EMAIL_ADDRESS", nil);
            self.contentTextField.keyboardType = UIKeyboardTypeEmailAddress;
            break;
        }
        case PersonalInfoTypeName: {
            stringPlaceholder = NSLocalizedString(@"TITLE_NAME", nil);
            stringTitle = NSLocalizedString(@"TITLE_NAME", nil);
            self.contentTextField.keyboardType = UIKeyboardTypeDefault;
            break;
        }
        default: {
            break;
        }
    }
    self.title = stringTitle;
    self.contentTextField.placeholder = [NSString stringWithFormat:@"请输入你的%@", stringPlaceholder];
}

- (void)setContentTextFieldContentText
{
    NSString *stringTextFieldText = nil;
    switch (self.personalInfoType)
    {
        case PersonalInfoTypeMobile:
        {
            stringTextFieldText = self.appDelegate.userProfilesInfo.userMobile;
            break;
        }
            
        case PersonalInfoTypeEmail:
        {
            stringTextFieldText = self.appDelegate.userProfilesInfo.userEmail;
            break;
        }
            
        case PersonalInfoTypeName:
        {
            stringTextFieldText = self.appDelegate.userProfilesInfo.userName;
            break;
        }
            
        default:
            break;
    }
    
    self.contentTextField.text = stringTextFieldText;
}

- (void)touchRightButton:(id)sender
{
    switch (self.personalInfoType)
    {
        case PersonalInfoTypeMobile:
        {
            // 未修改 不做处理
            if ([self.contentTextField.text isEqualToString:self.appDelegate.userProfilesInfo.userMobile])
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CHANGE_NONE", "未修改") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
                return;
            }
            
            if ([RegularCheckTools isMobile:self.contentTextField.text])
            {
                [self.contentTextField resignFirstResponder];
                
                self.appDelegate.userProfilesInfo.userMobile = self.contentTextField.text;
                [self.appDelegate.userProfilesInfo saveUserProfiles];
                [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_MOBILE andContent:self.contentTextField.text];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_INPUT_CORRECT_CONTENT", "请输入正确的格式") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
            }
        }
            break;
            
        case PersonalInfoTypeEmail:
        {
            // 未修改 不做处理
            if ([self.contentTextField.text isEqualToString:self.appDelegate.userProfilesInfo.userEmail])
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CHANGE_NONE", "未修改") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
                return;
            }
            
            if ([RegularCheckTools isEmail:self.contentTextField.text])
            {
                [self.contentTextField resignFirstResponder];
                
                self.appDelegate.userProfilesInfo.userEmail = self.contentTextField.text;
                [self.appDelegate.userProfilesInfo saveUserProfiles];
                [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_EMAIL andContent:self.contentTextField.text];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_INPUT_CORRECT_CONTENT", "请输入正确的格式") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
            }
        }
            break;
            
        case PersonalInfoTypeName:
        {
            // 未修改 不做处理
            if ([self.contentTextField.text isEqualToString:self.appDelegate.userProfilesInfo.userName])
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CHANGE_NONE", "未修改") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
                return;
            }
            
            if ([RegularCheckTools isExceedUserNameLength:self.contentTextField.text])
            {
                [self.contentTextField resignFirstResponder];
                
                self.appDelegate.userProfilesInfo.userName = self.contentTextField.text;
                [self.appDelegate.userProfilesInfo saveUserProfiles];
                [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_NAME andContent:self.contentTextField.text];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_INPUT_CORRECT_CONTENT", "请输入正确的格式") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
            }
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -
#pragma mark TextFieldDelegate Method

- (void)textDidChange:(NSNotification *)obj{
    
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    // 键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > USER_NAME_MAX_LENGTH) {
                textField.text = [toBeString substringToIndex:USER_NAME_MAX_LENGTH];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > USER_NAME_MAX_LENGTH) {
            textField.text = [toBeString substringToIndex:USER_NAME_MAX_LENGTH];
        }
    }
}



@end
