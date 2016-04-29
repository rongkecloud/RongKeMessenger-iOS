//
//  RKSessionListSearchViewController.h
//  RongKeMessenger
//
//  Created by Jacob on 16/4/19.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RKSessionListSearchViewController : UIViewController

@property (nonatomic, strong) NSArray *sessionListSearchArray;  // 搜索到的Session对象数组
@property (nonatomic, copy) NSString *markColorStr;  // 需要别标记颜色的字符串

@end
