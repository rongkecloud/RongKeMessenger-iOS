//
//  ImageCropperMaskView.m
//  RongKeMessenger
//
//  Created by WangGray on 13-3-25.
//  Copyright (c) 2013年 WangGray. All rights reserved.
//

#import "ImageCropperMaskView.h"

#define kMaskViewBorderWidth 1.0f

@implementation ImageCropperMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/**
 *	@brief	设置裁剪作用显示大小
 *
 *	@param 	size 	CGSize 大小
 */
- (void)setCropSize:(CGSize)size
{
    //分别计算裁剪框起始x,y坐标
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    cropRect = CGRectMake(x+kMaskViewBorderWidth, y, size.width-2*kMaskViewBorderWidth, size.height);
    
    [self setNeedsDisplay];
}

/**
 *	@brief	获得裁剪作用显示大小
 *
 *	@return	CGSize
 */
- (CGSize)cropSize
{
    return cropRect.size;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.75);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:.75].CGColor);
    CGContextStrokeRectWithWidth(ctx, cropRect, kMaskViewBorderWidth);
    
    CGContextClearRect(ctx, cropRect);
}

@end
