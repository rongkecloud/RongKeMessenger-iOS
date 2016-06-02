//
//  RKCloudChatMessageManager.h
//  RKCloudChat
//
//  Created by WangGray on 15/6/3.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//
//  云视互动即时通信消息管理类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RKCloudChatBaseMessage.h"
#import "AudioMessage.h"
#import "CustomMessage.h"
#import "FileMessage.h"
#import "ImageMessage.h"
#import "LocalMessage.h"
#import "TextMessage.h"
#import "TipMessage.h"
#import "VideoMessage.h"


@interface RKCloudChatMessageManager : NSObject

#pragma mark -
#pragma mark RKCloudChat Message Send/Download Function

/**
 * @brief 发送消息
 *
 * @param messageObject 消息对象RKCloudChatBaseMessage子类指针
 *
 * @return
 */
+ (void)sendChatMsg:(RKCloudChatBaseMessage *)messageObject;

/**
 * @brief 重新发送失败的消息
 *
 * @param messageID 消息ID
 *
 * @return int 成功与否的错误码（参考：RKCloudChatErrorCode和RKCloudErrorCode定义）
 */
+ (int)reSendChatMsg:(NSString *)messageID;

/**
 * @brief 转发MMS消息记录
 *
 * @param messageTable 消息数据
 * @param dstUser      接收者
 *
 * @return NSString 新消息记录的ID
 */
+ (NSString *)forwardChatMsg:(NSString *)messageID toUserNameOrSessionID:(NSString *)dstSessionID;

/**
 *  @brief 撤回消息
 *
 *  @param messageId 撤回消息的Id
 *
 *  @return onSuccess onFailed
 */
+ (void)syncRevokeMessage:(NSString *)messageId
                onSuccess:(void (^)(NSString *messageId))onSuccess
                 onFailed:(void (^)(int errorCode))onFailed;

/**
 * @brief 向终端插入消息
 *
 * @param localMessage 消息LocalMessage对象数据
 *
 * @return int 成功与否的错误码（参考：RKCloudChatErrorCode和RKCloudErrorCode定义）
 */
+ (int)addLocalMsg:(LocalMessage *)localMessage withSessionType:(SessionType)sessionType;

/**
 * @brief 下载声音图片附件等媒体消息
 *
 * @param messageID 消息ID
 *
 * @return int 成功与否的错误码（参考：RKCloudChatErrorCode和RKCloudErrorCode定义）
 */
+ (int)downMediaFile:(NSString *)messageID;

/**
 * @brief 下载图片视频缩略图
 *
 * @param messageID 消息ID
 *
 * @return int 成功与否的错误码（参考：RKCloudChatErrorCode和RKCloudErrorCode定义）
 */
+ (int)downThumbImage:(NSString *)messageID;

/**
 * @brief 获取声音图片媒体文件保存路径
 *
 * @param messageType 消息类型
 * @param fileLocalName 消息的本地名称
 * @param isThumbnail 是否缩略图
 *
 * @return 文件路径
 */
+ (NSString *)getMMSFilePath:(MessageType)messageType
           withFileLocalName:(NSString *)fileLocalName
            isThumbnailImage:(BOOL)isThumbnail;

#pragma mark -
#pragma mark RKCloudChat Group Apply/Quit/Invite/KickOut/ModifyInfo Function

/**
 *  @brief获取群信息(API请求)
 *
 *  @param groupId 群Id
 *
 *  @return 返回操作成功或者失败错误码
 */
+ (void)syncGroupInfo:(NSString *)groupId
             onSuccess:(void (^)(RKCloudChatBaseChat *chatObject))onSuccess
              onFailed:(void (^)(int errorCode))onFailed;

/**
 * @brief 创建群(API请求)
 *
 * @param arrayUserName 联系人的userName数组，不包含自己的userName
 * @param onSuccess     接口调用成功
 * @param onFailed      接口调用失败，返回错误信息
 *
 * @return 返回操作成功或者失败错误码
 */
+ (void)applyGroup:(NSArray *)arrayUserName
     withGroupName:(NSString *)groupName
         onSuccess:(void (^)(NSString *groupID))onSuccess
          onFailed:(void (^)(int errorCode, NSArray <NSString *> *arrayFailUserName))onFailed;

/**
 * @brief 退出群(API请求)
 *
 * @param groupID       群聊ID
 * @param onSuccess     接口调用成功
 * @param onFailed      接口调用失败，返回错误信息
 *
 * @return 返回操作成功或者失败错误码
 */
+ (void)quitGroup:(NSString *)groupID
        onSuccess:(void (^)())onSuccess
         onFailed:(void (^)(int errorCode))onFailed;

/**
 * @brief 邀请成员(API请求)
 *
 * @param arrayUserName 联系人的userName数组，不包含自己的userName
 * @param groupID       群组ID
 * @param onSuccess     接口调用成功
 * @param onFailed      接口调用失败，返回错误信息
 *
 * @return 返回操作成功或者失败错误码
 */
+ (void)inviteUsers:(NSArray *)arrayUserName
         forGroupID:(NSString *)groupID
          onSuccess:(void (^)())onSuccess
           onFailed:(void (^)(int errorCode, NSArray <NSString *> *arrayFailUserName))onFailed;

/**
 * @brief 踢除某位用户(API请求)
 *
 * @param kickOutUserName 被踢出的联系人userName
 * @param groupID       群组ID
 * @param onSuccess     接口调用成功
 * @param onFailed      接口调用失败，返回错误信息
 *
 * @return 返回操作成功或者失败错误码
 */
+ (void)kickUser:(NSString *)kickOutUserName
      forGroupID:(NSString *)groupID
       onSuccess:(void (^)())onSuccess
        onFailed:(void (^)(int errorCode))onFailed;

/**
 * @brief 设置群聊中邀请成员的权限，该方法常用于群聊使用(API请求)
 * @attention 修改群邀请成员权限，主要群主可以执行此方法
 *
 * @param isEnableInviteAuth  是否开启邀请权限
 * @param groupID       群组ID
 * @param onSuccess     接口调用成功
 * @param onFailed      接口调用失败，返回错误信息
 *
 * @return 返回操作成功或者失败错误码
 */
+ (void)modifyGroupInviteAuth:(BOOL)isEnableInviteAuth
                   forGroupID:(NSString *)groupID
                    onSuccess:(void (^)())onSuccess
                     onFailed:(void (^)(int errorCode))onFailed;

/**
 * @brief 修改群名称备注信息，只在客户端显示，不保存到服务器端
 *
 * @param remarkName    是否开启邀请权限
 * @param groupID       群组ID
 *
 * @return 返回操作成功或者失败错误码
 */
+ (long)modifyGroupRemark:(NSString *)remarkName forGroupID:(NSString *)groupID;


#pragma mark -
#pragma mark RKCloudChat My All Group Function

/**
 * @brief 获取当前用户参与的群，按照群的创建时间降序排列(本地DB数据)
 *
 * @return NSArray RKCloudChatBaseChat对象数组
 */
+ (NSArray *)queryAllMyAttendedGroups;

/**
 * @brief 获取当前用户创建的所有群，按照群的创建时间降序排列(本地DB数据)
 *
 * @return NSArray RKCloudChatBaseChat对象数组
 */
+ (NSArray *)queryAllMyCreatedGroups;


#pragma mark -
#pragma mark RKCloudChat Tools Function

/**
 * @brief 获取草稿箱内容
 *
 * @param sessionID 会话ID
 *
 * @return 草稿文本内容
 */
+ (NSString *)getDraft:(NSString *)sessionID;

/**
 * @brief 保存草稿箱内容，只保存文本消息内容
 *
 * @param textContent 草稿文本内容
 * @param sessionID 会话ID
 * @param extension 扩展内容
 *
 * @return 成功或失败错误码
 */
+ (long)saveDraft:(NSString *)textContent
     forSessionID:(NSString *)sessionID
    withExtension:(NSString *)extension;

/**
 *  删除草稿
 *
 *  @param sessionID 会话ID
 *
 *  @return 成功或失败错误码
 */
+ (long)deleteDraft:(NSString *)sessionID;


#pragma mark -
#pragma mark RKCloudChat Config Interface

/**
 * @brief 获取创建群的最大个数
 *
 * @return int 创建群的最大个数或错误码
 */
+ (int)getMaxNumOfCreateGroups;

/**
 * @brief 获取群内成员的最大人数
 *
 * @return int 群内成员的最大人数或错误码
 */
+ (int)getMaxNumOfGroupUsers;

/**
 * @brief 获取文本内容的最大长度，单位：字符
 *
 * @return int 文本内容的最大长度或错误码
 */
+ (int)getTextMaxLength;

/**
 * @brief 获取媒体文件的最大尺寸，单位：字节
 *
 * @return long 媒体文件的最大尺寸或错误码
 */
+ (long)getMediaMmsMaxSize;

/**
 * @brief 获取录音文件的最大播放时长，单位：秒
 *
 * @return long 录音文件的最大播放时长或错误码
 */
+ (int)getAudioMaxDuration;

/**
 * @brief 获取视频的最大播放时长，单位：秒
 *
 * @return long 视频的最大播放时长或错误码
 */
+ (int)getVideoMaxDuration;


#pragma mark -
#pragma mark RKCloudChat Session Get/Query/Update Info Function

/**
 * @brief 获取所有会话信息，包含每个会话中的未读条数、每个会话的最后一条消息对象等
 *
 * @return NSArray RKCloudChatBaseChat对象数组，并且优先显示置顶会话(按照置顶时间降序排列)，非置顶会话时按照会话中最后一条消息产生时间降序排列。
 */
+ (NSArray <RKCloudChatBaseChat *> *)queryAllChats;

/**
 * @brief 获取用户所在的群，包含自己创建的和参与的群，按照群的创建时间降序排列(本地DB数据)
 *
 * @return NSArray RKCloudChatBaseChat对象数组
 */
+ (NSArray <RKCloudChatBaseChat *> *)queryAllGroups;

/**
 * @brief 获取群内所有成员信息(userName数组)
 *
 * @param groupID 群聊组号码
 *
 * @return NSArray 群成员帐号数组(userName数组)
 */
+ (NSArray <NSString *> *)queryGroupUsers:(NSString *)groupID;

/**
 * @brief 获取会话中的所有消息总数
 *
 * @param sessionID 会话ID
 *
 * @return 消息对象条数
 */
+ (int)queryChatMsgCountBySession:(NSString *)sessionID;

/**
 * @brief 获取未读消息条数总和
 *
 * @return int 未读消息条数总和
 */
+ (int)getAllUnReadMsgsCount;

/**
 * @brief 获取单个会话的基本信息，不包含会话的最后一条消息对象
 *
 * @param sessionID   会话ID
 *
 * @return RKCloudChatBaseChat对象指针
 */
+ (RKCloudChatBaseChat *)queryChat:(NSString *)sessionID;

/**
 * @brief 更新本地数据库会话信息对应最后一条消息对象
 *
 * @param chatSession  会话信息对象
 * @param chatMessage  消息对象
 *
 * @return
 */
+ (void)updateSessionInfoWithLastMessage:(RKCloudChatBaseChat *)chatSession
                         withLastMessage:(RKCloudChatBaseMessage *)chatMessage;

/**
 * @brief 设置会话是否置顶
 *
 * @param isTop      是否置顶 YES=置顶，NO=不置顶
 * @param sessionID  会话ID
 *
 * @return 成功或失败的错误码
 */
+ (long)setChatIsTop:(BOOL)isTop forSessionID:(NSString *)sessionID;

/**
 * @brief 设置会话是否提醒
 *
 * @param sessionID  会话ID
 * @param isRemind   是否提醒 YES=提醒，NO=不提醒
 *
 * @return 成功或失败的错误码
 */
+ (long)setRemindStatusInChat:(NSString *)sessionID withRemindStatu:(BOOL)isRemind;

/**
 * @brief 获取会话中的聊天背景的路径
 *
 * @param sessionID  会话ID
 *
 * @return 会话中的聊天背景的路径，用于保存背景图片使用
 */
+ (NSString *)getBackgroundImagePathInChat:(NSString *)sessionID;

/**
 * @brief 更新会话中的聊天背景
 *
 * @param sessionID  会话ID
 * @param imagePath  图片路径
 *
 * @return 成功或失败的错误码
 */
+ (long)updateBackgroundImageInChat:(NSString *)sessionID withImagePath:(NSString *)imagePath;

#pragma mark -
#pragma mark RKCloudChat Message Get/Query/UpdateStatus Function

/**
 * @brief 获取会话中指定类型的所有消息，并且按照消息在终端的入库时间升序排列
 *
 * @param messageType 消息对象子类型（枚举值：MessageType）
 * @param sessionID 会话ID
 *
 * @return NSArray RKCloudChatBaseMessage对象数组
 */
+ (NSArray <RKCloudChatBaseMessage *> *)queryAllMsgsByType:(MessageType)messageType
                                                forSession:(NSString *)sessionID;

/**
 * @brief 根据当前消息时间获取其之前的消息对象列表，倒序排序
 *
 * @param sessionID       会话ID
 * @param lastVisableDate 最后一条数据的创建时间，秒级UNIX时间戳
 * @param indexStorage    消息在客户端存储的自增索引值
 * @param messageCount    提取数据的条数
 *
 * @return NSArray RKCloudChatBaseMessage消息对象指针数组
 */
+ (NSArray <RKCloudChatBaseMessage *> *)queryLocalChatMsgs:(NSString *)sessionID
                                            withCreateDate:(long)lastVisableDate
                                          withStorageIndex:(long)indexStorage
                                              messageCount:(int)messageCount;

/**
  * @brief 根据当前消息时间获取其之后的消息对象列表，倒序排序
 *
 * @param sessionID       会话ID
 * @param lastVisableDate 最新一条创建时间，秒级UNIX时间戳
 * @param indexStorage    消息在客户端存储的自增索引值
 * @param messageCount    提取数据的条数
 *
 */
+ (NSArray <RKCloudChatBaseMessage *> *)queryNewChatMsgs:(NSString *)sessionID
                                          withCreateDate:(long)lastVisableDate
                                        withStorageIndex:(long)indexStorage
                                            messageCount:(int)messageCount;

/**
 * @brief 查询单条消息对象
 *
 * @param messageID  消息ID
 *
 * @return RKCloudChatBaseMessage消息对象指针
 */
+ (RKCloudChatBaseMessage *)queryChatMsg:(NSString *)messageID;

/**
 *  根据搜索的内容查询对应的消息
 *
 *  @param keyWord 搜索的参数关键字
 *
 *  @return onSuccess 返回包含搜索内容的消息对象数组
 *  @return messageObjectArray 数组中每个Item为NSDictionary对象，对象Key：sessionId value：包含RKCloudChatBaseMessage对象数组
 *
 *  @return onFailed 返回错误信息
 */
+ (void)queryMessageKeyword:(NSString *)keyWord
                  onSuccess:(void(^)(NSArray <NSDictionary *> *messageObjectArray))onSuccess
                   onFailed:(void(^)(int errorCode))onFailed;

/**
 *  根据当前消息对象id，查询此消息记录的前（总数量/2）条记录和后（总数量/2）条记录
 *
 *  @param sessionId 当前会话的sessionId
 *  @param messageId 当前消息的messageId
 *  @param mNum 查询的 数量
 *  @return onSuccess 返回RKCloudChatBaseMessage对象数组
 *  @return onFailed 返回错误信息
 */
+ (void)queryLocalChatMsgs:(NSString *)sessionId
      withCurrentMessageId:(NSString *)messageId
             messageCounts:(int)counts
                 onSuccess:(void(^)(NSArray <RKCloudChatBaseMessage *> *resultArray))onSuccess
                  onFailed:(void(^)(int errorCode))onFailed;

/**
 * @brief 更新指定的消息状态为已读
 *
 * @param messageID  会话ID
 *
 * @return 成功或失败的错误码
 */
+ (long)updateMsgStatusHasReaded:(NSString *)messageID;

/**
 * @brief 退出消息列表时更新消息全部为已读状态
 *
 * @param sessionID   会话ID
 *
 * @return 成功或失败的错误码
 */
+ (long)updateMsgsReadedInChat:(NSString *)sessionID;


#pragma mark - RKCloudChat Delete Session/Message Data Function

/**
 * @brief 删除指定消息ID单条消息
 *
 * @param messageId 消息ID
 *
 * @return
 */
+ (void)deleteChatMsg:(NSString *)messageId;

/**
 * @brief 删除会话中的所有消息
 *
 * @param sessionID 会话ID
 * @param isDeleteFile 是否删除消息对应的二进制文件
 *
 * @return
 */
+ (void)deleteAllMsgsInChat:(NSString *)sessionID withFile:(BOOL)isDeleteFile;

/**
 * @brief 删除群聊会话中的所有成员对象
 *
 * @param sessionID 会话ID
 *
 * @return
 */
+ (void)deleteAllMembersInChat:(NSString *)sessionID;

/**
 * @brief 删除一个会话
 *
 * @param sessionID 会话ID
 * @param isDeleteFile 是否删除消息对应的二进制文件
 *
 * @return
 */
+ (void)deleteChat:(NSString *)sessionID withFile:(BOOL)isDeleteFile;

/**
 * @brief 聊天结束后清理缓存数据，如果单聊消息会话中一条消息都不存在则删除此会话
 *
 * @param sessionID 会话ID
 *
 * @return
 */
+ (void)cleanupChatCacheData:(NSString *)sessionID;

/**
 * @brief 清除所有会话，包含聊天相关的内容
 *
 * @param isDeleteFile 是否删除消息对应的二进制文件
 *
 * @return
 */
+ (void)clearChatsAndMsgs:(BOOL)isDeleteFile;

@end
