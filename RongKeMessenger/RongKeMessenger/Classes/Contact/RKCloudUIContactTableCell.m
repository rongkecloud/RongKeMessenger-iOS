//
//  RKCloudUIContactTableCell.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "RKCloudUIContactTableCell.h"
#import "Definition.h"

@implementation RKCloudUIContactTableCell

// 为外部调用封装cell的创建方法
+ (instancetype)creatCellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier fromType:(CellFromType)fromType
{
    RKCloudUIContactTableCell *contactCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (contactCell == nil) {
        contactCell = [[RKCloudUIContactTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        // 赋值来源类型
        contactCell.cellFromType = fromType;
    }
    
    return contactCell;
}
// 初始化方法
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self creat];
    }
    return self;
}
// Jacky.Chen:2016.02.22:add 更改内部子控件布局的位置
// 布局cell内部控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 布局子控件
    switch (self.cellFromType) {
        case Cell_From_Type_Select_Contact:
        {
            if (checkImageView.hidden) {
                //checkImageView.frame = CGRectMake(UISCREEN_BOUNDS_SIZE.width - 25 - 30, 14, 25, 25);
                checkAvatarImageView.frame = CGRectMake(15, 8.5f, 38, 38);
                checkLabel.frame = CGRectMake(62, 12.5, UISCREEN_BOUNDS_SIZE.width - 70, 30);
            }
            else
            {
                checkImageView.frame = CGRectMake(14, 15, 25, 25);
                checkAvatarImageView.frame = CGRectMake(53, 8.5f, 38, 38);
                checkLabel.frame = CGRectMake(100, 12.5, UISCREEN_BOUNDS_SIZE.width - 140, 30);
                newFriendNoticeImageView.frame = CGRectMake(130, 21, 8, 8);
                
            }
        }
            break;
        case Cell_From_Type_Other:
        {
            checkImageView.frame = CGRectMake(UISCREEN_BOUNDS_SIZE.width - 25 - 30, (self.frame.size.height - 25)/2, 25, 25);
            checkAvatarImageView.frame = CGRectMake(15, (self.frame.size.height - 38)/2, 38, 38);
            checkLabel.frame = CGRectMake(60,  (self.frame.size.height - 30)/2, UISCREEN_BOUNDS_SIZE.width - 70, 30);
            newFriendNoticeImageView.frame = CGRectMake(130, (self.frame.size.height - 8)/2, 8, 8);
        }
            break;
        default:
            break;
    }
}

// 构造通讯录cell
- (void)creat{
    if (checkImageView == nil)
    {
        checkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contact_cell_unselect"]];

        [self addSubview:checkImageView];
    }
    
    if (checkAvatarImageView == nil)
    {
        checkAvatarImageView = [[CustomAvatarImageView alloc] init];
        [self addSubview:checkAvatarImageView];
    }

    if (checkLabel == nil)
    {
        checkLabel = [[UILabel alloc] init];
        checkLabel.font = FONT_TEXT_SIZE_16;
        [checkLabel setBackgroundColor: [UIColor clearColor]];
        [self addSubview:checkLabel];
    }
    
    if (newFriendNoticeImageView == nil) {
        newFriendNoticeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"new_friend_icon"]];
        newFriendNoticeImageView.hidden = YES;
        [self addSubview:newFriendNoticeImageView];
    }
}

// 设置通讯录名称
- (void)setLabelText:(NSString *)labelString{
    if (labelString)
    {
        checkLabel.text = labelString;
    }
}

// 设置通讯录头像
- (void)setCellImage:(UIImage *)cellImage{
    if (cellImage)
    {
        checkAvatarImageView.image = cellImage;
    }
}

// 通过好友名称设置头像
- (void)setCellAvatarImageWithFriendAccount:(NSString *)friendAccount{
    if (friendAccount)
    {
        [checkAvatarImageView setUserAvatarImageByUserId:friendAccount];
    }
}

// 设置通讯录头像
- (void)setNewFriendNoticeImageViewHidden:(BOOL)isShow{
    if (isShow)
    {
        newFriendNoticeImageView.hidden = YES;
    }else{
        newFriendNoticeImageView.hidden = NO;
    }
}

// 设置通讯录头像
- (void)setCheckedImageHide:(BOOL)isHide{
    if (isHide)
    {
        checkImageView.hidden = YES;
    }else{
        checkImageView.hidden = NO;
    }
}

// 设置通讯录cell选中图片是否可用
- (void)setCheckedImageDisable:(BOOL)isDisable{
    if (isDisable)
    {
        checkImageView.image = [UIImage imageNamed:@"contact_cell_disabled"];
    }else{
        checkImageView.image = [UIImage imageNamed:@"contact_cell_unselect"];
    }
}

// 设置通讯录选中状态
- (void)setChecked:(BOOL)checked{
    
//    checkLabel.frame = CGRectMake(60, 10, CGRectGetMinX(checkImageView.frame) - 60 - 2, 30);
    checkLabel.frame =  CGRectMake(100, 12.5, UISCREEN_BOUNDS_SIZE.width - 140, 30);
    if (checked)
	{
		checkImageView.image = [UIImage imageNamed:@"contact_cell_select"];
		self.backgroundView.backgroundColor = [UIColor colorWithRed:223.0/255.0 green:230.0/255.0 blue:250.0/255.0 alpha:1.0];
	}
	else
	{
		checkImageView.image = [UIImage imageNamed:@"contact_cell_unselect"];
		self.backgroundView.backgroundColor = [UIColor whiteColor];
	}
	isChecked = checked;
    
}

// 设置通讯录选中状态(带动画)
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
