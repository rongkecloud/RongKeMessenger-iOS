//
//  SearchContactTableViewCell.h
//  RongKeMessenger
//
//  Created by Jacob on 15/7/29.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendsNotifyTable.h"

@protocol SearchContactTableViewCellDelegate <NSObject>

- (void)sendFriendApplySuccessDelegate:(FriendsNotifyTable *)friendsNotifyTable;

@end

@interface SearchFriendTableViewCell : UITableViewCell

@property (nonatomic) id<SearchContactTableViewCellDelegate>delegate;
@property (nonatomic, strong) FriendsNotifyTable *friendsNotifyTable;

@end
