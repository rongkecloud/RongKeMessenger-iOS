//
//  ChatManager.h
//  RKCloudDemo
//
//  Created by WangGray on 15/6/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "RKCloudChat.h"
#import "ChatMacroDefinition.h"

@interface ChatManager : NSObject

/// 表情转义字符串对应的图标文件名称字典(~:*0~ -> mms_face_01).
@property (nonatomic, strong) NSDictionary *emotionESCToFileNameDict;
/// 表情符号的图标文件名称对应的转义字符标识字典(mms_face_01 -> ~:*0~).
@property (nonatomic, strong) NSDictionary *emoticonFileNameToESCDict;
/// 表情符号的图标文件名称对应的转义字符标识字典([微笑] -> ~:*0~).
@property (nonatomic, strong) NSMutableDictionary *emoticonMultilingualStringToESCDict;


#pragma mark -
#pragma mark Messages Operate Function

// 拼装邀请或者离开消息
+ (NSString *)getGroupTipStringWithMessageObject:(RKCloudChatBaseMessage *)messageObject;

// 拼装会议的提示消息
+ (NSString *)getMeetingTipStringWithMessageObject:(RKCloudChatBaseMessage *)messageObject;

// 根据消息内容获取cell高度
+ (float)heightForMessage:(RKCloudChatBaseMessage *)messageObject;

// 通过UITextView获取文本字串的size add by WangGray 2014.03.12
+ (CGSize)getTextCellSizeFromStringInTextView:(NSString *)stringText
                                 withMaxWidth:(float)contentWidth
                                 withFontSize:(UIFont *)currentTextFontSize;
// Gray.Wang:2011.12.19:计算文本字符串包含表情符号的文本Cell的Size
+ (CGSize)getTextCellSizeFromStringInView:(NSString *)stringText
                             withMaxWidth:(float)contentWidth
                             withFontSize:(UIFont *)currentFontSize;

#pragma mark -
#pragma mark MMS – Custom Function

// 获取消息发送者或接受者的姓名
+ (NSString *)getFullName:(NSString *)firstName withLastName:(NSString *)lastName;
// 获取消息在消息会话列表上最后一条的描述信息
+ (NSString *)getMessageDescription:(RKCloudChatBaseMessage *)messageObject;
// 获取本地消息的内容
+ (NSString *)getLocalMesssageTextContent:(RKCloudChatBaseMessage *)messageObject;

@end
