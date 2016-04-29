//
//  UploadAndDownloadCenter.h
//  RongKeMessenger
//
//  Created by WangGray on 15/5/27.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Definition.h"

@interface UploadAndDownloadCenter : NSObject

#pragma mark - Upload Avatar Interface

/**
*  上传自己的头像
*
*  @param fileLocalPath                要上传的本地头像路径
*  @param uploadAndDownloadRequestType 上传的文件的类型
*/
- (void)addUploadAvatarFileQueueFromLocalPath:(NSString *)fileLocalPath
                               withUploadType:(UploadAndDownloadRequestType)uploadAndDownloadRequestType;


#pragma mark - Download Avatar Interface

/**
 *  下载自己或好友的头像
 *
 *  @param localPath                    存储的本地路径
 *  @param type                         获取的图像大小：1.缩略图，2.大图
 *  @param account                      获取头像的账号
 *  @param uploadAndDownloadRequestType 下载文件的类型
 */
- (void)addDownloadAvatarQueueToLocalPath:(NSString *)localPath
                           andUserAccount:(NSString *)account
                        isAvatarThumbnail:(BOOL)isThumbnail
                         withDownloadType:(UploadAndDownloadRequestType)uploadAndDownloadRequestType;


@end
