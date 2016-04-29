//
//  HyperlinkData.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "HyperlinkData.h"
#import "ToolsFunction.h"

@implementation HyperlinkData
@synthesize wholeUrlString;
@synthesize currentRectUrlString;
@synthesize urlID;
@synthesize urlRect;
- (id)init
{
    self = [super init];
    if (self)
    {
        self.wholeUrlString = nil;
        self.currentRectUrlString = nil;
        
        NSString *string = [ToolsFunction getCurrentCallID: @"urlID"];
        self.urlID = string;
        
        urlRect = CGRectZero;
    }
    return self;
}

- (void)dealloc
{
    self.wholeUrlString = nil;
    self.currentRectUrlString = nil;
    self.urlID = nil;
    urlRect = CGRectZero;
}
@end
