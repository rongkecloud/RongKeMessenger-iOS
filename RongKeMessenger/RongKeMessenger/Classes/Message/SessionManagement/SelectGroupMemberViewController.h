//
//  SelectGroupMemberViewController.h
//  RongKeMessenger
//
//  Created by ivan on 16/7/18.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectGroupMemberDelegate <NSObject>

- (void)selectedGroupMember:(NSArray *)selectedMemberArray;

- (void)atAllGroupMember;

@end

@interface SelectGroupMemberViewController : UIViewController

@property (nonatomic, assign) id<SelectGroupMemberDelegate> delegate;

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic) BOOL isAtGroupMember;

@end
