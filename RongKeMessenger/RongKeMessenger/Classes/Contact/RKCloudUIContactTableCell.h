//
//  RKCloudUIContactTableCell.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKTableViewCell.h"
#import "CustomAvatarImageView.h"

@interface RKCloudUIContactTableCell : RKTableViewCell{
    BOOL isChecked;
    UIImageView *checkImageView;
    CustomAvatarImageView *checkAvatarImageView;
    UILabel *checkLabel;
    UIImageView *newFriendNoticeImageView;
}

- (void)setChecked:(BOOL)checked;                        // 设置通讯录选中状态
- (void)setCheckedImageHide:(BOOL)isHide;                // 设置通讯录cell是否有选中图片
- (void)setCheckedImageDisable:(BOOL)isDisable;          // 设置通讯录cell选中图片是否可用
- (void)setAvatarHide:(BOOL)isHide;                      // 设置头像是否隐藏
- (void)setCellImage:(UIImage *)cellImage;               // 设置通讯录头像
- (void)setLabelText:(NSString *)labelString;            // 设置通讯录名称
- (void)setNewFriendNoticeImageViewHidden:(BOOL)isShow;  // 设置新好友提示的红色图标
- (void)setCellAvatarImageWithFriendAccount:(NSString *)friendAccount; // 通过好友名称设置头像
// Jacky.Chen:2016.02.22:add 为创建cell封装一个外部调用的类方法
+ (instancetype)creatCellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle )style reuseIdentifier:(NSString *)reuseIdentifier fromType:(CellFromType) fromType;

@end
