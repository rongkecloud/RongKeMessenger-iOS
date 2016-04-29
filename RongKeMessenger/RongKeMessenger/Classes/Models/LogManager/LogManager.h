//
//  LogManager.h
//  RongKeMessenger
//
//  Created by WangGray on 15/6/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LogManager : NSObject

// 重定向NSLog到文件中
+ (NSString *)redirectNSLogToFile;

/*
// 保存log文件信息到数据库中
+ (void)saveLogInfoToDatabase:(NSString *)logName;

// 上传当前时刻24小时内的日志
+ (void)uploadDebugLogToServer;

// 删除过期的Debug日志
+ (void)deleteOverdueDebugLog;
*/

@end
