//
//  EmoticonView.h
//  RongKeMessenger
//
//  Created by Gray on 14-1-21.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomPageControl.h"

// 表情和Sticker窗口的布局结构体
typedef struct _emoticon_sticker_view_layout
{
    int nImageRowCount;   // 一行存放图标的个数
    float fMarginWidth;   // 图标窗口左右两边居屏幕边框的边距
    float fSpacingWidth;  // 图标窗口中图标之间的间距
}
EmoticonStickerViewLayout;

@protocol EmoticonViewDelegate <NSObject>

- (void)didSelectedEmoticonKey:(NSString *)stringEmoticonKey;
- (void)sendEmotionButtonDelegateMethod;

@end

@interface EmoticonView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id <EmoticonViewDelegate> delegate; // 表情符号窗口的代理

// 初始化表情页面
- (void)initEmoticonViewWithFrame:(CGRect)frame;
// 加载表情符号的位置和图像
- (void)loadEmoticonResource;

// 动态计算表情或sticker在不同屏幕上的横向的：个数、边距、间距
+ (EmoticonStickerViewLayout)calculationEmotionAndStickerLayoutWithMargin:(CGFloat)fDefaultSingleMargin
                                                            forImageWidth:(CGFloat)fImageWidth
                                                         withImageSpacing:(CGFloat)fDefaultSpaceBetween;

@end
