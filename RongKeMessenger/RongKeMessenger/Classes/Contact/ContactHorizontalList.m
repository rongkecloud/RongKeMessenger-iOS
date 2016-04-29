//
//  ContactHorizontalList.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "ContactHorizontalList.h"
#import "ContactListItem.h"
#import "RKCloudUIContactViewController.h"
#import "SelectFriendsViewController.h"

@implementation ContactHorizontalList

- (id)initWithFrame:(CGRect)frame title:(NSString *)title items:(NSMutableArray *)items
{
    self = [super initWithFrame:frame];

    if (self) {
        
        // scrollView
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 20, self.frame.size.width, 60)];
        CGSize pageSize = CGSizeMake(ITEM_WIDTH, 60);
        NSUInteger page = 0;
        
        for(ContactListItem *item in items) {
            [item setFrame:CGRectMake(15 + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * page++, 8, pageSize.width, pageSize.height)];
            
            UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapped:)];
            [item addGestureRecognizer:singleFingerTap];
            
            [self.scrollView addSubview:item];
        }
        
        self.scrollView.contentSize = CGSizeMake(15 + (pageSize.width + DISTANCE_BETWEEN_ITEMS) * [items count], 60);
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        self.scrollView.backgroundColor = [UIColor colorWithRed:250.0/255.0 green:250.0/255.0 blue:250.0/255.0 alpha:1.0];
        [self addSubview:self.scrollView];
    }
    
    return self;
}


// 点击选中的成员
- (void)itemTapped:(UITapGestureRecognizer *)recognizer {
    ContactListItem *item = (ContactListItem *)recognizer.view;
    if (item != nil) {
        [self.parent touchDeleteMemberButton:item];
    }
}

@end
