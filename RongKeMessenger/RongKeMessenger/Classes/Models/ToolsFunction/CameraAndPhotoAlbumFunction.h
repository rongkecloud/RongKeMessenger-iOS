//
//  CameraAndPhotoAlbumFunction.h
//  
//
//  Created by Gray on 14-12-3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  -用于打开iOS系统下的相机和相册功能。

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface CameraAndPhotoAlbumFunction : NSObject


#pragma mark -
#pragma mark Photo Album Function
// 相册权限检测与相册调用处理
+ (void)openiOSPhotoAlbum:(id)delegate withMaximumNumberOfSelection:(NSUInteger)maxNumber withPushController:(UIViewController *)pushController;

// 相机权限检测与相机调用处理
+ (void)openiOSCamera:(id)delegate withCameraDevice:(NSInteger)cameraDevice;

@end
