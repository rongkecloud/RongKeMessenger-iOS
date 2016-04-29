//
//  CompletePersonalInfoViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/8/7.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "CompletePersonalAddressViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

#define SETTING_PERSONAL_KEY_ADDRESS            @"address"

@interface CompletePersonalAddressViewController ()

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (assign, nonatomic) AppDelegate *appDelegate;


@end

@implementation CompletePersonalAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = COLOR_VIEW_BACKGROUND;
    self.title = NSLocalizedString(@"TITLE_ADDRESS", "地址");
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_OK", "确定")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.appDelegate = [AppDelegate appDelegate];
    self.contentTextView.text = self.appDelegate.userProfilesInfo.userAddress;
    
    if (self.contentTextView.text.length == 0) {
        self.placeholderLabel.text = NSLocalizedString(@"PROMPT_INPUT_ADDRESS", "请输入你的地址...");
    }
    else
    {
        self.placeholderLabel.text = @"";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.contentTextView becomeFirstResponder];
    // 注册TextView通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];

}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // 注册TextView通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];

    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Custom Method

- (void)textViewDidChange:(NSNotification *)obj
{
    //    UITextView *textView = (UITextView *)obj.object;
    
    if (self.contentTextView.text.length == 0) {
        self.placeholderLabel.text = NSLocalizedString(@"PROMPT_INPUT_ADVICE", "请输入你的意见或建议，我们会努力改正...");
    }
    else
    {
        self.placeholderLabel.text = @"";
    }
    
    // 判断字符串 是否超出限制
    NSString *toBeString = self.contentTextView.text;
    // 键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [self.contentTextView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.contentTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > FRIEND_ADDRESS_TEXT_LENGTH) {
                self.contentTextView.text = [toBeString substringToIndex:FRIEND_ADDRESS_TEXT_LENGTH];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > FRIEND_ADDRESS_TEXT_LENGTH) {
            self.contentTextView.text = [toBeString substringToIndex:FRIEND_ADDRESS_TEXT_LENGTH];
        }
    }
}


- (void)touchRightButton:(id)sender
{
    // 未修改 不做处理
    if ([self.contentTextView.text isEqualToString:self.appDelegate.userProfilesInfo.userAddress])
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_CHANGE_NONE", "未修改") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
        return;
    }
    
    // 内容为空 不做处理
    if ([self.contentTextView.text length] == 0)
    {
        [UIAlertView showAutoHidePromptView:NSLocalizedString(@"PROMPT_NULL_ADDRESS", "地址不能为空") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
        return;
    }
    
    [self.contentTextView resignFirstResponder];

    self.appDelegate.userProfilesInfo.userAddress = self.contentTextView.text;
    [self.appDelegate.userProfilesInfo saveUserProfiles];
    [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_ADDRESS andContent:self.contentTextView.text];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end
