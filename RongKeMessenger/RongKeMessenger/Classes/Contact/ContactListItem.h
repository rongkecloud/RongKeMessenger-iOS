//
//  ContactListItem.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ContactListItem : UIView {
    CGRect textRect;
    CGRect imageRect;
}

@property (nonatomic, retain) NSObject *objectTag;
@property (nonatomic, retain) NSString *imageTitle;
@property (nonatomic, retain) UIImage  *image;

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle;

@end
