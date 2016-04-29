//
//  LogManager.m
//  RongKeMessenger
//
//  Created by WangGray on 15/6/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "LogManager.h"
#import "Definition.h"
#import "ToolsFunction.h"

#define CLIENT_EXECUTION_LOG  1 // 客户端执行日志
#define CLIENT_CRASH_LOG      2 // Crash日志

@implementation LogManager

#pragma mark -
#pragma mark Log Manager Interface

// 重定向NSLog到文件中
+ (NSString *)redirectNSLogToFile
{
    // 获取FileManager对象
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    NSError *error = nil;
    
    // 根据当前时间的毫秒生成log文件名称，如：“20141215192145368.log”
    NSString *logName = [NSString stringWithFormat:@"%@.log", [ToolsFunction getCurrentSystemDateMillisecondString]];
    NSString *logPath = [NSString stringWithFormat:@"%@/%@", LIBRARY_DEBUG_LOG_PATH, logName];
    
    // 创建Library/Caches/DebugLog目录
    if (NO == [manager fileExistsAtPath:LIBRARY_DEBUG_LOG_PATH isDirectory:&isDirectory])
    {
        [manager createDirectoryAtPath:LIBRARY_DEBUG_LOG_PATH withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    // Create log file
    [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    id fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
    if (!fileHandle)
    {
        NSLog(@"ERROR: redirectNSLogToFile - Opening log failed");
        return nil;
    }
    
    // Redirect stderr
    int err = dup2([fileHandle fileDescriptor], STDERR_FILENO);
    if (!err)
    {
        NSLog(@"ERROR: redirectNSLogToFile - Couldn't redirect stderr");
        return nil;
    }
    
    return logName;
}

/*
// 保存log文件信息到数据库中
+ (void)saveLogInfoToDatabase:(NSString *)logName
{
    if (logName == nil || [logName isEqualToString:@""]) {
        RKCloudDebugLog(@"ERROR: saveLogInfoToDatabase: logName = %@, return", logName);
        return;
    }
    
    LogTable * logTable = [[LogTable alloc] init];
    logTable.logName = logName;
    // 得到当前的系统时间字符串(年月日) 如：“20141215”
    logTable.createDate = [ToolsFunction getCurrentSystemDateDayString];
    
    AppDelegate * appDelegate = [AppDelegate appDelegate];
    [appDelegate.databaseManager saveLogTable:logTable];
    [logTable release];
}
*/

/*
 API upload_log.php
 URL http://api-address/cs/2.0/upload_log.php
 描述 本接口主要是将客户端的日志上传到S3
 
 Param POST提交
 § session：session值 (非空参数)
 § type：日志类型，目前定义为  1->客户端执行日志  2->Crash日志（必填参数）
 § file：文件数据（文件名需要以保存日志时的客户端时间命名，例如：2014年12月18日18点30分30秒123毫秒保存的日志命名为“20141218183030123.log”）（必填参数）
 § version：脚本的版本号 （必填，string型，必须为2.1否则返回参数错误）
 
 Error Code(操作失败)
 1007：参数错误
 1011：非法session
 300001:无效的Session
 2010：文件上传失败
 9999：系统错误
 
 Return(操作成功)
 {
 "oper_result":0,            //int类型
 "oper_descr":"SUCCESS"     //string类型
 }
 
 服务器流程和功能
 1：参数检查(必填，非空，类型...)以及type的合法性
 2: 判断文件是否为空，不为空获取文件内容
 3：连接数据库
 4: session校验
 5: 判断type类型，根据不同type类型文件上传到S3服务器不同地址
 type为1时，为客户端执行日志，以用户号码建立文件夹，文件夹内以服务器端时间-客户端时间（精确到毫秒）作为文件名保存数据文件；
 type为2时，为Crash日志，以上传日期(服务器端日期)建立文件夹，以上传时间戳(号码-服务器端时间-客户端时间)（精确到毫秒）作为文件名保存数据文件。
 
 注：
 1. 客户端上传的日志文件名需要以保存日志时的客户端时间命名，例如：2014年12月18日18点30分30秒123毫秒保存的日志命名为“20141218183030123.log”
 2. S3存放用户日志的bucket为 s3-upload-log
 3. S3上目录结构示例如下：
 |-- 2014-12-18
 |   |-- 30033106-20141218180313123-20141218171012365.log
 |   `-- 30033107-20141218180314123-20141218171013365.log
 |-- 2014-12-19
 |   |-- 30033106-20141218190314123-20141219171013365.log
 |   `-- 30033107-20141218190313123-2014121171012365.log
 |-- 30033106
 |   |-- 20141219180312123-20141219171011365.log
 |   `-- 20141219180412123-20141219171111365.log
 `-- 30033107
 |-- 20141219180313123-20141219171012365.log
 `-- 20141219180314123-20141219171013365.log
 */
/*
// 上传当前时刻24小时内的日志
+ (void)uploadDebugLogToServer
{
}

// 删除过期的Debug日志
+ (void)deleteOverdueDebugLog
{
    AppDelegate * appDelegate = [AppDelegate appDelegate];
    
    // 得到当前过期的debug日志
    NSArray * arrayLogTable = [appDelegate.databaseManager getAllDeleteLogTable];
    
    // 遍历数据库中的过期的日志表
    for (LogTable * logTable in arrayLogTable) {
        NSString * logPath = [NSString stringWithFormat:@"%@/%@", LIBRARY_DEBUG_LOG_PATH, logTable.logName];
        
        // 删除本地日志文件
        [ToolsFunction deleteFileOrDirectoryForPath:logPath];
        
        // 删除数据库表
        [appDelegate.databaseManager deleteLogTableByLogName:logTable.logName];
    }
    
    RKCloudDebugLog(@"DEBUG-LOG: deleteOverdueDebugLog - Overdue log file count = %lu", (unsigned long)[arrayLogTable count]);
}


#pragma mark -
#pragma mark Log Manager Custom Function

// 删除Debug日志和数据库表记录
+ (void)removeDebugLogFileAndLogTableRecord:(NSArray *)arrayLogTable
{
    if (arrayLogTable == nil || [arrayLogTable count] == 0) {
        return;
    }
    
    RKCloudDebugLog(@"DEBUG-LOG: removeDebugLogFileAndLogTableRecord: arrayLogTable = %@", arrayLogTable);
    
    AppDelegate * appDelegate = [AppDelegate appDelegate];
    
    // 遍历数据库中要上传的日志表
    for (LogTable * logTable in arrayLogTable)
    {
        // 删除临时日志文件
        NSString * logCachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:logTable.logName];
        [ToolsFunction deleteFileOrDirectoryForPath:logCachePath];
        
        // 删除原始日志文件
        NSString * logPath = [NSString stringWithFormat:@"%@/%@", LIBRARY_DEBUG_LOG_PATH, logTable.logName];
        [ToolsFunction deleteFileOrDirectoryForPath:logPath];
        
        // 删除数据库表
        [appDelegate.databaseManager deleteLogTableByLogName:logTable.logName];
    }
}

// 处理和保存debug日志文件
+ (NSString *)dealAndSaveDebugLogFile:(LogTable *)logTable
{
    NSString * logCachePath = nil;
    NSString * logPath = [NSString stringWithFormat:@"%@/%@", LIBRARY_DEBUG_LOG_PATH, logTable.logName];
    
    // 压缩和加密Debug Log
    NSData * dataLog = [LogManager compressAndEncryptDebugLog:logPath];
    if (dataLog) {
        // 将压缩和加密后的日志文件保存到缓存中
        logCachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:logTable.logName];
        BOOL bSave = [dataLog writeToFile:logCachePath atomically:YES];
        RKCloudDebugLog(@"DEBUG-LOG: dealAndSaveDebugLogFile: logName = %@, bSave = %d", logTable.logName, bSave);
    }
    
    return logCachePath;
}

// 压缩和加密Debug Log
+ (NSData *)compressAndEncryptDebugLog:(NSString *)filePath
{
    RKCloudDebugLog(@"DEBUG-LOG: compressAndEncryptDebugLog");
    
    NSData * dataFile = [NSData dataWithContentsOfFile:filePath];
    
    // 使用gzip压缩
    NSData * compressDebugLogData = [dataFile gzippedData];
    //RKCloudDebugLog(@"DEBUG-LOG: compressDebugLogData length = %d bytes", [compressDebugLogData length]);
    
    // 通过AES加密
    NSData * encryptDebugLogData = [compressDebugLogData AES128EncryptWithKey:MOBILE_LOG_API_AES_PASSPHRASE
                                                                       withIV:MOBILE_API_AES_IV];
    //RKCloudDebugLog(@"DEBUG-LOG: encryptDebugLogData length = %d bytes", [encryptDebugLogData length]);
    return encryptDebugLogData;
}
 */

@end
