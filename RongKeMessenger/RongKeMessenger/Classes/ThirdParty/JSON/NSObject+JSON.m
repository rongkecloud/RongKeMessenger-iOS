//
//  NSObject+JSON.m
//  RongKeMessenger
//
//  Created by Gray on 15/1/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "NSObject+JSON.h"
#import "JSONKit.h"

@implementation NSObject (JSON)

- (NSString *)JSONRepresentation {
    
    // Gray.Wang:2015.01.13:不再使用SBJson，因其导致解析Moment返回的JSON中Emoji不能识别为图标，因此将SBJSON库源码从工程中移除；
    // Gray.Wang:2015.01.13:使用iOS自带的JSON库也不行，因其导致读取消息存储的带Emoji的Content会导致无法解析。
    //NSError * error = nil;
    //NSData * dataJSON = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    //NSString *json = [NSString stringWithCString:[dataJSON bytes] encoding:NSUTF8StringEncoding];
    
    // 使用JSONKit来做为序列化JSON字符串
    NSString *json = nil;
    NSError * error = nil;
    @try {
        if ([self isKindOfClass:[NSArray class]]) {
            json = [(NSArray *)self JSONStringWithOptions:JKSerializeOptionNone error:&error];
        }
        else if ([self isKindOfClass:[NSString class]]) {
            json = [(NSString *)self JSONStringWithOptions:JKSerializeOptionNone includeQuotes:YES error:&error];
        }
        else if ([self isKindOfClass:[NSDictionary class]])
        {
            json = [(NSDictionary *)self JSONStringWithOptions:JKSerializeOptionNone error:&error];
        }
        
        if (json == nil || error) {
            NSLog(@"ERROR: JSON - JSONRepresentation failed. Error trace is: json = %@, error = %@", json, error);
            return nil;
        } 
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: JSON - JSONRepresentation failed. exception = %@", exception);
    }
    @finally {
    }
    
    return json;
}

@end
