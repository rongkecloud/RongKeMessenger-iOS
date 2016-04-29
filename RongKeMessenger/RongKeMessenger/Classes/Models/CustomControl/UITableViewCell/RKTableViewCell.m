
//
//  RKTableViewCell.m
//  RongKeMessenger
//
//  Created by Jacob on 15/5/26.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKTableViewCell.h"
#import "Definition.h"

@interface RKTableViewCell()
{
    
    
}

@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIView *headLineView;

@end

@implementation RKTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.cellBottomSeparatorRightMargin = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if (self.bottomLineView == nil)
    {
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 0.5, CGRectGetWidth(self.frame), 0.5)];
        self.bottomLineView.backgroundColor = COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND;
        
        [self addSubview:self.bottomLineView];
    }
    else
    {
        CGRect bottomLineViewFrame = self.bottomLineView.frame;
        bottomLineViewFrame.origin.y = CGRectGetHeight(self.frame) - 0.5;
        self.bottomLineView.frame = bottomLineViewFrame;
    }
    
    switch (self.cellPositionType)
    {
        case Cell_Position_Type_Single:
        {
            if (self.headLineView == nil) {
                // 添加cell的顶部与底部的分割线
                self.headLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5)];
                self.headLineView.backgroundColor = COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND;
                [self addSubview:self.headLineView];
            }
            else{
                self.headLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5);
            }
            
            // 调整底部分割线的Frame
            [self setupBottomLineFrameWith:Cell_Position_Type_Single];
            
            self.headLineView.hidden = NO;
        }
            break;
            
        case Cell_Position_Type_Top:
        {
            if (self.headLineView == nil) {
                // 添加cell的顶部与底部的分割线
                self.headLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5)];
                self.headLineView.backgroundColor = COLOR_TABLE_VIEW_CELL_LINE_BACKGROUND;
                [self addSubview:self.headLineView];
            }
            else
            {
                self.headLineView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 0.5);
            }
            
            self.headLineView.hidden = NO;
            // 调整底部分割线的Frame
            [self setupBottomLineFrameWith:Cell_Position_Type_Top];
        }
            break;
            
        case Cell_Position_Type_Middle:
        {
            self.headLineView.hidden = YES;
            // 调整底部分割线的Frame
            [self setupBottomLineFrameWith:Cell_Position_Type_Middle];
        }
            break;
            
        case Cell_Position_Type_Bottom:
        {
            // 调整底部分割线的Frame
            [self setupBottomLineFrameWith:Cell_Position_Type_Bottom];
            
            self.headLineView.hidden = YES;
        }
            break;
            
        default:
            break;
    }
}

// Jacky.Chen:2016.02.22:add 封装底边线位置调整的方法
// 调整cell底部边线的位置
-(void)setupBottomLineFrameWith:(CellPositionType)positionType
{
    CGFloat lineX = 0;
    CGFloat lineW = 0;
    switch (positionType) {
        case Cell_Position_Type_Single:
        case Cell_Position_Type_Bottom:
        {
            lineX = 0;
            lineW = CGRectGetWidth(self.frame);
        }
            break;
        case Cell_Position_Type_Top:
        case Cell_Position_Type_Middle:
        {
            if (self.cellFromType == Cell_From_Type_Select_Contact) {
                lineX = 53;
                lineW = CGRectGetWidth(self.frame) - 53 - self.cellBottomSeparatorRightMargin;

            }
            else
            {
                lineX = 15;
                lineW = CGRectGetWidth(self.frame) - 15 - self.cellBottomSeparatorRightMargin;

            }
        }
            break;
        default:
            break;
    }
    CGRect bottomLineViewFrame = self.bottomLineView.frame;
    bottomLineViewFrame.origin.x = lineX;
    bottomLineViewFrame.size.width = lineW;
    self.bottomLineView.frame = bottomLineViewFrame;
}
@end
