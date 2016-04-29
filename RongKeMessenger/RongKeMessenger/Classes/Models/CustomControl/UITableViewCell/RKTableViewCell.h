//
//  RKTableViewCell.h
//  RongKeMessenger
//
//  Created by Jacob on 15/5/26.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CellPositionType)
{
    Cell_Position_Type_Single = 0, // 单个Cell
    Cell_Position_Type_Top = 1, // 顶部的Cell
    Cell_Position_Type_Middle = 2,  // 中部的Cell
    Cell_Position_Type_Bottom = 3    // 底部Cell
};
// Jacky.Chen:2016.02.22:添加cell来源类型
typedef NS_ENUM(NSUInteger, CellFromType)
{
    Cell_From_Type_Select_Contact = 0, // 位于选择联系人页面的cell
    Cell_From_Type_Other          = 1  // 位于其他页面
};
@interface RKTableViewCell : UITableViewCell

@property (nonatomic) CellPositionType cellPositionType;

// Jacky.Chen:2016.02.22:添加cell来源类型属性，根据不同页面的cell调整其分割线及内部控件位置
@property (nonatomic, assign) CellFromType cellFromType;

@property (nonatomic) CGFloat cellBottomSeparatorRightMargin; // cell右边距的距离

@end
