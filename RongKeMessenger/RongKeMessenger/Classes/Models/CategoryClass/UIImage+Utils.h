//
//  UIImage+Utils.h
//  ImageBubble
//
//  Created by Richard Kirby on 3/14/13.
//  Copyright (c) 2013 Kirby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utils)

/**
 *  进行图片缩放
 *
 *  @param size 需要缩放的尺寸
 *
 *  @return 返回的图片
 */
- (UIImage *)renderAtSize:(const CGSize) size;

/**
 *  进行图片掩码
 *
 *  @param maskImage 需要掩码的图片
 *
 *  @return 掩码图片
 */
- (UIImage *)maskWithImage:(const UIImage *) maskImage;
- (UIImage *)maskWithColor:(UIColor *) color;

@end
