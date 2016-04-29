//
//  RKChatSessionSetBackgroundImage.h
//  RKCloudDemo
//
//  Created by www.rongkecloud.com on 15/1/22.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKChatSessionViewController.h"

@interface SetBackgroundImageTableViewController : UITableViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic, assign) RKChatSessionViewController  *rkChatSessionViewController;  // 会话页面

// 保存图片
- (void)saveImage:(UIImage *)selectImage;

@end
