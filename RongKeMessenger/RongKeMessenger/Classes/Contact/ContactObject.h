//
//  ContactObject.h
//  RKCloudDemo
//
//  Created by www.rongkecloud.com on 15/1/23.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactObject : NSObject

@property (nonatomic, strong) NSString *chatUserName;      // 成员名称
@property (nonatomic)           BOOL isChecked;            // 是否选中
@property (nonatomic)           BOOL isEnabled;            // 是否可用

@end
