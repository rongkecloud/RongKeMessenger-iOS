//
//  CutOutPicturesViewController.h
//  RongKeMessenger
//
//  Created by WangGray on 13-3-21.
//  Copyright (c) 2013年 WangGray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCropperMaskView.h"

@class CutOutPicturesViewController;

@protocol CutOutPicturesDelegate <NSObject>

/**
 *	@brief	完成裁剪代理方法
 *
 *	@param 	cropper 	缩放裁剪对象
 *	@param 	image 	裁剪好的图像
 */
- (void)imageCropper:(CutOutPicturesViewController *)cropper didFinishCroppingWithImage:(UIImage *)image;

/**
 *	@brief	取消裁剪代理方法
 *
 *	@param 	cropper 	缩放裁剪对象
 */
- (void)imageCropperDidCancel:(CutOutPicturesViewController *)cropper;
@end

@interface CutOutPicturesViewController : UIViewController <UIScrollViewDelegate>
{
    UIEdgeInsets scrollEdgeInset; // scroll边界间隔区域
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ImageCropperMaskView *imageCropperMaskView;

@property (nonatomic, strong) UIImage *originImage; // 裁剪原始图

@property (nonatomic, assign) id <CutOutPicturesDelegate> delegate;

/**
 *	@brief	设置图像Method
 *
 *	@param 	image 	需要被处理的图像
 */
- (void)setImage:(UIImage*)image;

/**
 *	@brief	初始化方法
 *
 *	@param 	image 	被处理图像
 *
 *	@return	id 对象
 */
- (id)initWithImage:(UIImage*)image;


/**
 *	@brief	在父UIViewController上presentModally 其他ViewController
 *
 *	@param 	parent 	夫UIViewVController
 */
- (void)presentModallyOn:(UIViewController *)parent;

@end