//
//  ContactListItem.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "ContactListItem.h"

@implementation ContactListItem

- (id)initWithFrame:(CGRect)frame image:(UIImage *)image text:(NSString *)imageTitle
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setUserInteractionEnabled:YES];
        
        self.imageTitle = imageTitle;
        if (image == nil){
            
            self.image = [UIImage imageNamed:@"default_icon_user_avatar"];
        }else{
            self.image = image;
        }
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        [imageView.layer setCornerRadius:6];
        [imageView.layer setMasksToBounds:YES];
        
//        UILabel *title = [[UILabel alloc] init];
//        title.textAlignment= NSTextAlignmentCenter;
//        [title setBackgroundColor:[UIColor clearColor]];
//        [title setFont:[UIFont boldSystemFontOfSize:8.0]];
//        [title setOpaque: NO];
//        [title setText:imageTitle];
        
        imageRect = CGRectMake(0.0, 3.0, 44, 44);
//        textRect = CGRectMake(-3, 33, 37, 10);
        
//        [title setFrame:textRect];
        [imageView setFrame:imageRect];
        
//        [self addSubview:title];
        [self addSubview:imageView];
    }
    return self;
}

@end
