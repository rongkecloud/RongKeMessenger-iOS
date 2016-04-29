//
//  HttpProgress.h
//  云视互动SDK
//
//  Created by www.rongkecloud.com on 15-3-27.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpProgress : NSObject

@property(nonatomic, strong) NSString *requestId; // 请求的ID(Chat:messageID)
@property(nonatomic, assign) int uploadDownloadType; // 上传下载文件类型
@property(nonatomic, assign) float progress; // 上传下载进度值（0.0-1.0）
@end
