//
//  ImageCropperMaskView.h
//  RongKeMessenger
//
//  Created by WangGray on 13-3-25.
//  Copyright (c) 2013年 WangGray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCropperMaskView : UIView
{
    CGRect cropRect; // 裁剪作用显示Rect
}

/**
 *	@brief	设置裁剪作用显示大小
 *
 *	@param 	size 	CGSize 大小
 */
- (void)setCropSize:(CGSize)size;

/**
 *	@brief	获得裁剪作用显示大小
 *
 *	@return	CGSize 
 */
- (CGSize)cropSize;

@end
