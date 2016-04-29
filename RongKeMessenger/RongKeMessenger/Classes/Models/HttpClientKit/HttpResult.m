//
//  HttpResult.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 15/3/17.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "httpResult.h"

@implementation HttpResult


- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.values = [[NSMutableDictionary alloc] init];
        self.messages = [[NSMutableArray alloc] init];

    }
    return self;
}


@end
