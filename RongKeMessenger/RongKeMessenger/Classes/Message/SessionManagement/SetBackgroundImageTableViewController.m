//
//  RKChatSessionSetBackgroundImage.m
//  RKCloudDemo
//
//  Created by www.rongkecloud.com on 15/1/22.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "SetBackgroundImageTableViewController.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "ImagePreviewViewController.h"
#import "ToolsFunction.h"

@interface SetBackgroundImageTableViewController ()

@end

@implementation SetBackgroundImageTableViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"TITLE_SETTING_CHAT_BACKGROUND", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 设置状态栏默认风格
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"cell"];
    }
    UIView *subView = [cell viewWithTag: 100];
    if (subView) {
        [subView removeFromSuperview];
    }
    cell.userInteractionEnabled = YES;
    switch (indexPath.row)
    {
        case 0:
        {
            // 拍照
            cell.textLabel.text = NSLocalizedString(@"STR_TAKE_PHOTO", "拍照");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
            break;
        case 1:
        {
            // 相册
            cell.textLabel.text = NSLocalizedString(@"STR_ALUMB", "相册");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
        }
            break;
        case 2:
        {
            // 取消背景
            cell.textLabel.text = NSLocalizedString(@"TITLE_CANCEL_BACKGROUND", "取消背景");
        }
            break;
        default:
            break;            
    }
    
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate

// 设置cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];   //选中后的反显颜色即刻消失
    
    switch (indexPath.row) {
        case 0: // 打开系统相机准备拍照
            [self openSystemCameraPickerController];
            break;
            
        case 1: // 打开系统相册选择照片
            [self openSystemPhotoLibraryPickerController];
            break;
            
        case 2: // 清除背景图片
            [self cleanBgImage];
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

// 照相代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    @autoreleasepool {
        //移除当前模态视图
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        // 判断当前所获取媒体类型为图片
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
        {
            // 获取当前摄像图片
            UIImage *selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            selectImage = [ToolsFunction rotateImage:selectImage];
            
            // 若是拍照就不再显示预览页面
            if (picker.sourceType == UIImagePickerControllerSourceTypeCamera)
            {
                [self saveImage:selectImage];
            }
            else
            {
                // 加载图片预览页面
                [self performSelector:@selector(delayPushImagePreviewController:) withObject:selectImage afterDelay:0.5];
            }
        }
    }
}


// 打开系统相机准备拍照
- (void)openSystemCameraPickerController
{
    
    // 照相 设置各种参数，不能使用设备时提示
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    
    // 当进入时，移除状态栏上提示，以避免同时执行两个动画
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (window.tag == MMSWINDOW_TAG) {
            [window setHidden:YES];
            break;
        }
    }
    
    //判断当前设备是否支持摄像头
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        //设置资源类型为摄像机
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        //将拍照视图推入当前视图
        [self presentViewController:pickerController animated:YES completion:nil];
    }
    else {
        [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_UNSUPPORT_CAMERA", "您的设备不支持摄像头")
                                        withTitle:nil
                                       withButton:NSLocalizedString(@"STR_OK",nil)
                                         toTarget:nil];
    }
}

// 打开系统相册选择照片
- (void)openSystemPhotoLibraryPickerController
{
    // 照相 设置各种参数，不能使用设备时提示
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    
    //判断当前设备是否支持照片库
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        //设置资源类型为照片库
        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        //将相册视图推入当前视图
        [self presentViewController:pickerController animated:YES completion:^{
            // 设置状态栏默认风格
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    }
}

// 清除背景图片
- (void)cleanBgImage
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"确认清除聊天背景吗"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定",nil];
    [alert show];
}

// 保存图片
- (void)saveImage:(UIImage *)selectImage
{
    if (selectImage == nil)
    {
        return;
    }
    
    // 显示导航栏
    [self.navigationController setNavigationBarHidden:NO];
    
    NSString *sessionId = self.rkChatSessionViewController.currentSessionObject.sessionID;
    // 保存图片
    NSString *strFilePath = [RKCloudChatMessageManager getBackgroundImagePathInChat:sessionId];
    
    // 判断文件是否存在，如存在删除文件
    if ([ToolsFunction isFileExistsAtPath:strFilePath])
    {
        [ToolsFunction deleteFileOrDirectoryForPath:strFilePath];
    }
    
    NSData * fileData = UIImagePNGRepresentation(selectImage);
    if (fileData) {
        // 保存下载的数据文件（图片、图片缩略图、声音）
        BOOL bSaveFile = [fileData writeToFile:strFilePath atomically:NO];
        NSLog(@"DEBUG: UIImagePNGRepresentation bSaveFile = %d", bSaveFile);
        
        // 保存会话背景图片路径
        self.rkChatSessionViewController.currentSessionObject.backgroundImagePath = strFilePath;
        
        // 保存更新后的背景图片
        [RKCloudChatMessageManager updateBackgroundImageInChat:self.rkChatSessionViewController.currentSessionObject.sessionID withImagePath:self.rkChatSessionViewController.currentSessionObject.backgroundImagePath];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"聊天背景设置成功"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        NSLog(@"ERROR: UIImagePNGRepresentation fileData == nil");
    }
}

//加载图片预览页面
- (void)delayPushImagePreviewController:(UIImage *)selectImage
{
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    //加载图片预览页面（使用查看原图的页面）
    ImagePreviewViewController *imagePreviewCtr = [[ImagePreviewViewController alloc] initWithNibName:@"ImagePreviewViewController" bundle:nil];
    imagePreviewCtr.displayImage = selectImage;
    imagePreviewCtr.parent = self;
    imagePreviewCtr.isImagePreview = YES;
    
    [ToolsFunction moveUpTransition:YES forLayer:appDelegate.window.layer];
    
    [self.navigationController pushViewController:imagePreviewCtr animated:NO];
}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    // 图片路径
    NSString *strFilePath = self.rkChatSessionViewController.currentSessionObject.backgroundImagePath;
    
    // 判断文件是否存在，如存在删除文件
    if ([ToolsFunction isFileExistsAtPath:strFilePath])
    {
        [ToolsFunction deleteFileOrDirectoryForPath:strFilePath];
        
        // 清空背景图片
        self.rkChatSessionViewController.currentSessionObject.backgroundImagePath = nil;
        
        // 保存更新后的背景图片
        [RKCloudChatMessageManager updateBackgroundImageInChat:self.rkChatSessionViewController.currentSessionObject.sessionID withImagePath:self.rkChatSessionViewController.currentSessionObject.backgroundImagePath];
    }
}


@end
