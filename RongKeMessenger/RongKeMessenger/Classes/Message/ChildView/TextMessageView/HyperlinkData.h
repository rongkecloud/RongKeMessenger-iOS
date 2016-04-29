//
//  HyperlinkData.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface HyperlinkData : NSObject
{
    NSString *wholeUrlString;
    NSString *currentRectUrlString;
    NSString *urlID;
    CGRect urlRect;
}

@property (nonatomic, copy) NSString *wholeUrlString;
@property (nonatomic, copy) NSString *currentRectUrlString;
@property (nonatomic, retain) NSString *urlID;
@property (nonatomic) CGRect urlRect;

@end
