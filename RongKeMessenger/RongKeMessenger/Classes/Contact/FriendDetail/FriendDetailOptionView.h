//
//  FriendDetailOptionView.h
//  RongKeMessenger
//
//  Created by 陈朝阳 on 16/2/19.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FriendDetailOptionViewDelegate <NSObject>

- (void)touchUpInsideWithButtonTag:(NSUInteger)btnTag;

@end

@interface FriendDetailOptionView : UIView

// 代理
@property (nonatomic, weak) id <FriendDetailOptionViewDelegate> delegate;
// 加载好友/陌生人页面底部选项view
+(instancetype)creatFriendOptionMenu:(BOOL)isfriend frame:(CGRect)frame;

@end
