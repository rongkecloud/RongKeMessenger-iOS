//
//  DownloadIndicator.h
//  RongKeMessenger
//
//  Created by 陈朝阳 on 16/2/24.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kRMClosedIndicator=0,
    kRMFilledIndicator,
    kRMMixedIndictor,
}RMIndicatorType;

@interface DownloadIndicator : UIView

// used to fill the downloaded percent slice (default: (kRMFilledIndicator = white), (kRMMixedIndictor = white))
@property(nonatomic, strong) UIColor *fillColor;

// used to stroke the covering slice (default: (kRMClosedIndicator = white), (kRMMixedIndictor = white))
@property(nonatomic, strong) UIColor *strokeColor;

// used to stroke the background path the covering slice (default: (kRMClosedIndicator = gray))
@property(nonatomic, strong) UIColor *closedIndicatorBackgroundStrokeColor;
// this value should be 0 to 0.5 (default: (kRMFilledIndicator = 0.5), (kRMMixedIndictor = 0.4))
@property(nonatomic, assign) CGFloat radiusPercent;

@property(nonatomic, assign) CGFloat coverWidth; //圆弧初始的线条宽度
@property(nonatomic, assign) CGFloat radiusWidth; //圆弧填充时的线条宽度
@property(nonatomic, assign) BOOL isStickShop; //圆弧填充时的线条宽度


// init with frame and type
// if() - (id)initWithFrame:(CGRect)frame is used the default type = kRMFilledIndicator
- (id)initWithFrame:(CGRect)frame type:(RMIndicatorType)type;

// 初始化下载的view
- (void)initDownloadViewWithType:(int)indicatorType;

// prepare the download indicator
- (void)loadIndicator;

// update the downloadIndicator
- (void)setIndicatorAnimationDuration:(CGFloat)duration;

// update the downloadIndicator
- (void)updateWithTotalBytes:(CGFloat)bytes downloadedBytes:(CGFloat)downloadedBytes;

@end
