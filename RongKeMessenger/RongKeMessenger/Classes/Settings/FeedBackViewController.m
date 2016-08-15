//
//  FeedBackViewController.m
//  MicroMessage
//
//  Created by 倩倩 on 15/7/7.
//  Copyright (c) 2015年 RogerChen. All rights reserved.
//

#import "FeedBackViewController.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

#define FEEDBACK_QUESTION_SOFTWARE      @"1"
#define FEEDBACK_QUESTION_UI_DESIGN     @"2"
#define FEEDBACK_QUESTION_OTHERS        @"3"

@interface FeedBackViewController ()

@property (weak, nonatomic) IBOutlet UITableView *feedBackTableView;

@property (weak, nonatomic) IBOutlet UITextView *feedBackTextView;

@property (weak, nonatomic) IBOutlet UILabel *feedBackPalceHolderLabel;

@property (assign, nonatomic) AppDelegate *appDelegate;
@property (copy, nonatomic) NSString *selectedReasonString; // 用户选择的问题原因
@property (copy, nonatomic) NSString *selectedType; // 用户选择类型

@end

@implementation FeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"TITLE_FEEDBACK_ADVICE", "意见反馈");
    self.selectedType = FEEDBACK_QUESTION_SOFTWARE;
    self.appDelegate = [AppDelegate appDelegate];
    // 设置背景色
    self.view.backgroundColor = COLOR_VIEW_BACKGROUND;
    
    self.feedBackTextView.delegate = self;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"STR_OK", "确定")
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(touchRightButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.feedBackTextView becomeFirstResponder];
    
    // 注册TextView通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textViewDidChange:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 移除通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellInde = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellInde];;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellInde];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = NSLocalizedString(@"TITLE_FEEDBACK_CATEGORY", "反馈类型");
    cell.detailTextLabel.text = self.selectedReasonString;
    cell.textLabel.font = FONT_TEXT_SIZE_16;
    cell.detailTextLabel.font = FONT_TEXT_SIZE_14;
    
    if (self.selectedReasonString == nil)
    {
        cell.detailTextLabel.text = NSLocalizedString(@"TITLE_SOFTWARE_QUESTION", "软件问题");
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.feedBackTextView resignFirstResponder];
    [self.feedBackTableView deselectRowAtIndexPath:indexPath animated:YES];
    // 创建时仅指定取消按钮
    UIActionSheet *feedbackActionSheet = [[UIActionSheet alloc]
                                          initWithTitle:NSLocalizedString(@"TITLE_SELECT", "请选择")
                                          delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                          destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    
    feedbackActionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    
    [feedbackActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_SOFTWARE_QUESTION", "软件问题")];
    [feedbackActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_UIDESIGN_QUESTION", "界面问题")];
    [feedbackActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_OTHERS_QUESTION", "其他问题")];
    // 逐个添加按钮（比如可以是数组循环）
    [feedbackActionSheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 1:
        {
            self.selectedReasonString = NSLocalizedString(@"TITLE_SOFTWARE_QUESTION", "软件问题");
            self.selectedType = FEEDBACK_QUESTION_SOFTWARE;
            break;
        }
            
        case 2:
        {
            self.selectedReasonString = NSLocalizedString(@"TITLE_UIDESIGN_QUESTION", "界面问题");
            self.selectedType = FEEDBACK_QUESTION_UI_DESIGN;
            break;
        }
            
        case 3:
        {
            self.selectedReasonString =NSLocalizedString(@"TITLE_OTHERS_QUESTION", "其他问题");
            self.selectedType = FEEDBACK_QUESTION_OTHERS;
            break;
        }
            
        default:
            break;
    }
    
    [self.feedBackTableView reloadData];
}

#pragma mark - Custom Method

- (void)textViewDidChange:(NSNotification *)obj
{
    //    UITextView *textView = (UITextView *)obj.object;
    
    if (self.feedBackTextView.text.length == 0) {
        self.feedBackPalceHolderLabel.text = NSLocalizedString(@"PROMPT_INPUT_ADVICE", "请输入你的意见或建议，我们会努力改正...");
    }
    else
    {
        self.feedBackPalceHolderLabel.text = @"";
    }
    
    // 判断字符串 是否超出限制
    NSString *toBeString = self.feedBackTextView.text;
    // 键盘输入模式
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) // 简体中文输入，包括简体拼音，健体五笔，简体手写
    {
        UITextRange *selectedRange = [self.feedBackTextView markedTextRange];
        //获取高亮部分
        UITextPosition *position = [self.feedBackTextView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > FRIEND_SOURCE_DESCRIPTION_OR_ADVANTAGE_LENGTH) {
                self.feedBackTextView.text = [toBeString substringToIndex:FRIEND_SOURCE_DESCRIPTION_OR_ADVANTAGE_LENGTH];
            }
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > FRIEND_SOURCE_DESCRIPTION_OR_ADVANTAGE_LENGTH) {
            self.feedBackTextView.text = [toBeString substringToIndex:FRIEND_SOURCE_DESCRIPTION_OR_ADVANTAGE_LENGTH];
        }
    }
    // 这行代码是为了防止粘贴超长内容时，能粘贴上但什么都不显示的问题。
    [self.feedBackTextView scrollRangeToVisible:NSMakeRange(0, 0)];
}


- (void)touchRightButton:(id)sender
{
    [self.feedBackTextView resignFirstResponder];
    
    if ([self.feedBackTextView.text length] > 0)
    {
        [self asyncFeedBack];
    }else{
        [UIAlertView showAutoHidePromptView:@"反馈内容不能为空" background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
        return;
    }
}


- (void)asyncFeedBack
{
    /*
     用户登录手机客户端
     http://demo.rongkecloud.com/rkdemo/add_feedback.php
     POST提交。参数表：
     	ss： 账号（必填）
     	type:  问题类型(必填)
     	content:  问题内容（必填）
     oper_result=
     1001：session错误
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
        NSString *stringUserFeedBack = [self.feedBackTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        [request.params setValue:self.appDelegate.userProfilesInfo.userSession
                          forKey:MSG_JSON_KEY_SESSION];
        [request.params setValue:self.selectedType forKey:@"type"];
        [request.params setValue:stringUserFeedBack forKey:@"content"];
        
        NSLog(@"HTTPREQUEST: request.params = %@",request.params);
        
        request.apiUrl = [NSString stringWithFormat:HTTP_API_FEEDBACK, [AppDelegate appDelegate].userProfilesInfo.mobileAPIServer];
        
        // rkcloud base result
        HttpResult *httpResult = [HttpClientKit sendHTTPRequest:request];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [UIAlertView hideWaitingMaskView];
            
            if (httpResult.opCode == 0)
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"TITLE_COMMIT_SUCCESS", "提交成功") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
                
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                NSLog(@"HTTPREQUEST: fail ");
                
                [HttpClientKit errorCodePrompt:httpResult.opCode];
            }
        });
    });
}


#pragma mark - Respond

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.feedBackTextView resignFirstResponder];
}

@end
