//
//  CameraAndPhotoAlbumFunction.m
//  
//
//  Created by Gray on 14-12-3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "CameraAndPhotoAlbumFunction.h"
#import "ToolsFunction.h"
#import "QBImagePickerController.h"
#import "RKNavigationController.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>


@implementation CameraAndPhotoAlbumFunction


#pragma mark -
#pragma mark Photo Album Function

// 相册权限检测与相册调用处理
+ (void)openiOSPhotoAlbum:(id)delegate withMaximumNumberOfSelection:(NSUInteger)maxNumber withPushController:(UIViewController *)pushController
{
    if ([ToolsFunction getCurrentiOSMajorVersion] >= 6)
    {
        switch ([ALAssetsLibrary authorizationStatus])
        {
            case ALAuthorizationStatusNotDetermined: // 用户尚未做出了选择这个应用程序的问候
            {
                ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
                
                [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
                {
                    if (*stop) {
                        // 打开照片相册选择控制器
                        [self openImagePickerController:delegate withMaximumNumberOfSelection:maxNumber withPushController:pushController];
                        
                        return;
                    }
                    *stop = TRUE;
                } failureBlock:^(NSError *error) {
                    return ;
                }];
            }
                break;
                
            case ALAuthorizationStatusRestricted: // 此应用程序没有被授权访问的照片数据
            {
                NSLog(@"WARNING: ALAuthorizationStatusRestricted");
            }
                break;
                
            case ALAuthorizationStatusDenied: // 表示已经明确拒绝这一照片数据的应用程序访问(用户在照片隐私中关闭了该程序的访问)
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_OPEN_PHOTO_GUIDE", "请在[设置]>[隐私]>[相册]中开启访问权限") background:nil showTime:1.0];
            }
                break;
                
            case ALAuthorizationStatusAuthorized: // 已授权应用访问照片数据
            {
                // 打开照片相册选择控制器
                [self openImagePickerController:delegate withMaximumNumberOfSelection:maxNumber withPushController:pushController];
            }
                break;
                
            default:
                break;
        }
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        // 打开照片相册选择控制器
        [self openImagePickerController:delegate withMaximumNumberOfSelection:maxNumber withPushController:pushController];
    }
}

// 打开照片相册选择控制器
+ (void)openImagePickerController:(id)delegate withMaximumNumberOfSelection:(NSUInteger)maxNumber withPushController:(UIViewController *)pushController
{
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = delegate;
    imagePickerController.filterType = QBImagePickerControllerFilterTypePhotos;
    imagePickerController.showsNumberOfSelectedAssets = NO;
    imagePickerController.allowsMultipleSelection = maxNumber > 1 ? YES : NO;
    imagePickerController.maximumNumberOfSelection = maxNumber;
    
    [pushController presentViewController:imagePickerController animated:YES completion:NULL];
}


#pragma mark -
#pragma mark Camera Function
#pragma mark -
#pragma mark Camera Function

// 相机权限检测与相机调用处理
+ (void)openiOSCamera:(id)delegate withCameraDevice:(NSInteger)cameraDevice
{
    if ([ToolsFunction getCurrentiOSMajorVersion] >= 7)
    {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        
        switch (authStatus)
        {
                // 用户尚未做出了选择这个应用程序的问候
            case AVAuthorizationStatusNotDetermined:
            {
                [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted)
                 {
                     if (granted)
                     {
                         // 打开系统相机准备拍照
                         [self openCameraPickerController:delegate withCameraDevice:cameraDevice];
                         // 点击允许访问时调用，用户明确许可与否，媒体需要捕获，但用户尚未授予或拒绝许可。
                         NSLog(@"DEBUG: Granted access to %@", mediaType);
                     }
                     else
                     {
                         NSLog(@"WARNING: Not granted access to %@", mediaType);
                     }
                 }];
            }
                break;
                
            case AVAuthorizationStatusRestricted: // 此应用程序没有被授权访问的照机数据
            {
                NSLog(@"WARNING: AVAuthorizationStatusRestricted");
            }
                break;
                
            case AVAuthorizationStatusDenied: // 表示已经明确拒绝应用程序访问相机(用户在相机隐私中关闭了该程序的访问)
            {
                [UIAlertView showAutoHidePromptView:NSLocalizedString(@"STR_OPEN_CAMERA_GUIDE", "请在[设置]>[隐私]>[相机]中开启融科通访问权限") background:nil showTime:4];
            }
                break;
                
            case AVAuthorizationStatusAuthorized: // 已授权应用访问相机
            {
                // 打开系统相机准备拍照
                [self openCameraPickerController:delegate withCameraDevice:cameraDevice];
            }
                break;
                
            default:
                break;
        }
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 打开系统相机准备拍照
        [self openCameraPickerController:delegate withCameraDevice:cameraDevice];
    }
}

// 打开系统相机准备拍照
+ (void)openCameraPickerController:(id)delegate withCameraDevice:(NSInteger)cameraDevice
{
    // 照相 设置各种参数，不能使用设备时提示
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = delegate;
    
    pickerController.allowsEditing = YES;
    
    // 当进入时，移除状态栏上提示，以避免同时执行两个动画
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (window.tag == MMSWINDOW_TAG) {
            [window setHidden:YES];
            break;
        }
    }
    
    // 判断当前设备是否支持摄像头
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 设置资源类型为摄像机
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        // 设置摄像机设备为前置还是后置
        pickerController.cameraDevice = cameraDevice;
        
        // 将拍照视图推入当前视图
        
        [[AppDelegate appDelegate].window.rootViewController presentViewController:pickerController animated:YES completion:nil];
    }
    else {
        [UIAlertView showSimpleAlert:NSLocalizedString(@"PROMPT_UNSUPPORT_CAMERA", "您的设备不支持摄像头")
                           withTitle:@""
                          withButton:NSLocalizedString(@"STR_OK", "好的")
                            toTarget:nil];
    }
}


@end
