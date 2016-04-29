//
//  NSString+JSON.m
//  RongKeMessenger
//
//  Created by Gray on 15/1/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "NSString+JSON.h"
#import "JSONKit.h"

@implementation NSString (JSON)

- (id)JSONValue
{
    // Gray.Wang:2015.01.13:不再使用SBJson，因其导致解析Moment返回的JSON中Emoji不能识别为图标，因此将SBJSON库源码从工程中移除；
    // Gray.Wang:2015.01.13:使用iOS自带的JSON库也不行，因其导致读取消息存储的带Emoji的Content会导致无法解析。
    //NSError * error = nil;
    //id dataJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[self UTF8String] length:[self length]] options:NSJSONReadingAllowFragments error:&error];
    
    NSError * error = nil;
    id dataJSON = nil;
    @try {
        // 使用JSONKit来做为反序列化JSON字符串
        dataJSON = [self objectFromJSONStringWithParseOptions:JKParseOptionStrict error:&error];
        if (dataJSON == nil || error) {
            NSLog(@"ERROR: JSON - JSONValue failed. Error trace is: dataJSON = %@, error = %@", dataJSON, error);
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: JSON - JSONValue failed. exception = %@", exception);
    }
    @finally {
    }
    
    return dataJSON;
}

- (id)JSONMutableValue
{
    // Gray.Wang:2015.01.13:不再使用SBJson，因其导致解析Moment返回的JSON中Emoji不能识别为图标，因此将SBJSON库源码从工程中移除；
    // Gray.Wang:2015.01.13:使用iOS自带的JSON库也不行，因其导致读取消息存储的带Emoji的Content会导致无法解析。
    //NSError * error = nil;
    //id dataJSON = [NSJSONSerialization JSONObjectWithData:[NSData dataWithBytes:[self UTF8String] length:[self length]] options:NSJSONReadingAllowFragments error:&error];
    
    NSError * error = nil;
    id dataJSON = nil;
    @try {
        // 使用JSONKit来做为反序列化JSON字符串
        dataJSON = [self mutableObjectFromJSONStringWithParseOptions:JKParseOptionStrict error:&error];
        if (dataJSON == nil || error) {
            NSLog(@"ERROR: JSON - JSONMutableValue failed. Error trace is: dataJSON = %@, error = %@", dataJSON, error);
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"EXCEPTION: JSON - JSONMutableValue failed. exception = %@", exception);
    }
    @finally {
    }
    
    return dataJSON;
}

@end
