//
//  RKChatSessionViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChatAudioToolsKit.h"
#import "Definition.h"
#import "RKCloudChat.h"
#import "ToolsControlView.h"
#import "MessageBubbleTableCell.h"
#import "InputContainerToolsView.h"

@class MessageVoiceTableCell;

@interface RKChatSessionViewController : UIViewController <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AudioToolsKitRecorderDelegate, HPGrowingTextViewDelegate,UIDocumentInteractionControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate, UIScrollViewDelegate, InputContainerToolsViewDelegate, RecordVoiceButtonDelegate, ToolsControlViewDelegate, RKCloudChatDelegate> {
}

@property (nonatomic, strong) UIButton *nMessagePromptButton;          // 新消息提醒button
@property (nonatomic) int addNewMessageCount;          // 累积的新消息个数(一般用于用户正翻看历史消息时)
@property (nonatomic, strong) UIButton *nMessageUnReadButton;          // 未读消息提醒button
@property (nonatomic, strong) NSArray  *unReadMessageArray;            // 未读消息数组(一般用于用户从list进入后，一屏显示的数据不够显示所有未读消息的情况)

@property (nonatomic, strong) ToolsControlView * toolsControlView;                // 工具控制窗口
@property (nonatomic, strong) RKCloudChatAudioToolsKit * audioToolsKit;                    // 录音播放工具类
@property (nonatomic, strong) RKCloudChatBaseChat * currentSessionObject;         // 当前的会话对象
@property (nonatomic) SessionListShowType sessionShowType;  // 会话显示模式：主要是搜索与Nomal的区别

@property (nonatomic, strong) NSMutableArray *arrayVoiceJustDownload; // 刚下载的语音文件，等待播放，如果播放了已经下载的语音，则清空这个数组

@property (nonatomic, assign) id parentChatSessionListViewController; // 父窗口列表指针
@property (nonatomic) BOOL isAppearFirstly; // 是否为初次显示

//############################ Custom Actions #################################

// 点击重发按钮事件
- (void)touchResendButton:(RKCloudChatBaseMessage *)messageObject;

// 点击播放音频文件
- (void)touchPlayButton:(MessageVoiceTableCell *)voiceCell;

//############################ Interface Methods #################################

#pragma mark -
#pragma mark Message Object Function Method

/// 收到多条消息之后的回调
- (void)didReceivedMessageArray:(NSArray *)arrayBatchChatMessages;

// 根据messageObject删除消息
- (void)deleteMMSWithMessageObject:(RKCloudChatBaseMessage *)messageObject;
// 根据messageObject转发消息
- (void)forwardMMSWithMessageObject:(RKCloudChatBaseMessage *)messageObject;
// 保存图片并发送
- (void)saveAndSendImage:(UIImage *)selectImage;

// 进入浏览照片的窗口
- (void)pushImageBrowseViewController:(RKCloudChatBaseMessage *)messageObject;
// 点击图片显示大图
- (void)pushImagePreviewViewController:(RKCloudChatBaseMessage *)messageObject isThumbnail:(BOOL) isThumbnail;

// 刷新大图
- (void)updateImagePreviewViewController:(RKCloudChatBaseMessage *)messageObject;
// 打开指定文件路径下的文件
- (void)openFilesWithFilePath:(NSString *)filePath withShowName:(NSString *)titleName;
// 根据消息对象记录判断是否滚动到列表最下端
- (void)scrollTableViewPosition:(RKCloudChatBaseMessage *)chatMessage;

// 添加刚下载的语音到待播数组中
- (void)addVoiceJustDownload:(RKCloudChatBaseMessage *)messageObject;

// 播放刚下载的语音文件
- (void)playVoiceJustDownload;


#pragma mark -
#pragma mark Touch Avatar Action

// 点击用户image头像，应该显示用户详细信息，此处只弹出用户名称信息
- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount;

@end
