//
//  ContactHorizontalList.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define DISTANCE_BETWEEN_ITEMS  15.0
#define LEFT_PADDING            15.0
#define ITEM_WIDTH              40

@interface ContactHorizontalList : UIView <UIScrollViewDelegate>{
    CGFloat scale;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) id parent;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSMutableArray *)items;

@end
