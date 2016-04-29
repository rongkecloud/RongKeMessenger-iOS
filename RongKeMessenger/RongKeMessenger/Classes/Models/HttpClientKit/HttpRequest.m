//
//  HttpRequest.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 15/3/17.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "HttpRequest.h"
#import "HttpClientKit.h"


@implementation HttpRequest

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.requestMethod = RKCLOUD_HTTP_POST;
        self.params = [[NSMutableDictionary alloc] init];
        self.uploadFile = [[NSMutableDictionary alloc] init];
        self.requestType = RKCLOUD_HTTP_TYPE_VALUE;
        self.tryCount = 1;
        // 默认的超时时间
        self.timeoutInterval = 30;

    }
    return self;
}

- (NSString *)getStringParams
{
    NSMutableArray *arrayStrParam = [NSMutableArray array];
    if (self.params)
    {
        for (NSString *keyString in self.params)
        {
            NSString *strSeparator = [NSString stringWithFormat:@"%@=%@",
                                      keyString, [self.params objectForKey:keyString]];
            //NSLog(@"strSeparator: \n%@", strSeparator);
            [arrayStrParam addObject:strSeparator];
        }
    }
    
    NSString *strParam = [arrayStrParam componentsJoinedByString:@"&"];
    //NSLog(@"BASE-API: RKRequest->getStringParams: %@", strParam);
    
    return strParam;
}
@end
