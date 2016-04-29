//
//  CustomPageControl.m
//  RongKeMessenger
//
//  Created by Jacob on 14-1-22.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "CustomPageControl.h"

@implementation CustomPageControl

@synthesize imagePageStateNormal;
@synthesize imagePageStateHighlighted;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // 重新绘制分页的背景图
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView* dotImageView = nil;
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIImageView class]])
        {
            dotImageView = [self.subviews objectAtIndex:i];
            [dotImageView setFrame:CGRectMake(i * self.imagePageStateNormal.size.width/2 + 10, 0,
                                              self.imagePageStateNormal.size.width/2, self.imagePageStateNormal.size.height/2)];
            dotImageView.image = self.currentPage == i ? self.imagePageStateHighlighted : self.imagePageStateNormal;
        }
    }
}

- (void)dealloc
{
    self.imagePageStateNormal = nil;
    self.imagePageStateHighlighted = nil;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    [self updateDotImage];
}

- (void)updateDotImage
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
         UIImageView* dotImageView = nil;
        if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIImageView class]])
        {
            dotImageView = [self.subviews objectAtIndex:i];
        }
        else if ([[self.subviews objectAtIndex:i] isKindOfClass:[UIView class]])
        {
            UIView* dotView = [self.subviews objectAtIndex:i];
            
            for (UIView* subview in dotView.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    dotImageView = (UIImageView*)subview;
                    break;
                }
            }
            
            // ios7下subviews为UIView 所以在此重新加载UIImageView
            if (dotImageView == nil)
            {
                dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dotView.frame.size.width, dotView.frame.size.height)];
                [dotView addSubview:dotImageView];
            }
        }
        
        dotImageView.image = self.currentPage == i ? self.imagePageStateHighlighted : self.imagePageStateNormal;
    }
}

@end
