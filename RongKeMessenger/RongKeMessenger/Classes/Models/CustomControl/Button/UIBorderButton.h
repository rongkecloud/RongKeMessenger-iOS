//
//  UIBorderButton.h
//  RongKeMessenger
//
//  Created by Gray on 15/4/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBorderButton : UIButton

@property (nonatomic) BOOL isNeedBorder; // 是否要边框
@property (nonatomic) BOOL isNoNeedCorner; // 是否不需要圆角
@property (nonatomic) float cornerRadius; // 圆角的弧度

@property (nonatomic, retain) UIColor *borderStateNormalColor; // 边框正常状态时的颜色
@property (nonatomic, retain) UIColor *borderStateHighlightedColor; // 边框高亮时的颜色
@property (nonatomic, retain) UIColor *borderStateDisabledColor; // 边框禁用时的颜色
@property (nonatomic, retain) UIColor *borderStateSelectedColor; // 边框选择时的颜色

@property (nonatomic, retain) UIColor *backgroundStateNormalColor; // 按钮正常状态时的背景颜色
@property (nonatomic, retain) UIColor *backgroundStateHighlightedColor; // 按钮高亮时的背景颜色
@property (nonatomic, retain) UIColor *backgroundStateDisabledColor; // 按钮禁用时的背景颜色
@property (nonatomic, retain) UIColor *backgroundStateSelectedColor; // 按钮选择时的背景颜色

@end
