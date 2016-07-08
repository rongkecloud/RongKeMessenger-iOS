//
//  ChatManager.m
//  RKCloudDemo
//
//  Created by WangGray on 15/6/2.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "ChatManager.h"
#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

@implementation ChatManager

- (id)init
{
    self = [super init];
    if (self) {
        // 初始化全部的表情转义字符串对应的图标名称字典
        self.emotionESCToFileNameDict = [ToolsFunction loadPropertyList:@"Emoticon"];
    }
    
    return self;
}

#pragma mark -
#pragma mark Messages Operate Function

// 拼装邀请或者离开消息
+ (NSString *)getGroupTipStringWithMessageObject:(RKCloudChatBaseMessage *)messageObject
{
    if (messageObject == nil)
    {
        return nil;
    }
    
    NSArray *arraySessionMember = [messageObject.textContent componentsSeparatedByString:@","];
    // 如果contactArray为空则不拼装字符串
    if (arraySessionMember == nil && [arraySessionMember count] == 0) {
        return nil;
    }
    
    // 获取相关联系人并拼装成相应字串 如 @"楚中天",@"楚中天和李青龙",@"楚中天、李青龙和赵大刀",@"楚中天、李青龙、赵大刀和王小虎"等
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    NSMutableString *contactNameList = [[NSMutableString alloc] init];
    
    //获取该数组最后一个索引
    int contactCount = (int)[arraySessionMember count] - 1;
    
    for (int i = contactCount; i >= 0; i--)
    {
        NSString *contactName = [arraySessionMember objectAtIndex:i];
        
        if ([contactName isEqualToString:appDelegate.userProfilesInfo.userAccount]) {
            contactName = NSLocalizedString(@"STR_YOU", nil);
        }
        else {
            contactName = [appDelegate.contactManager displayFriendHighGradeName:contactName];
        }
        
        //最后一个联系人，只有名字
        if (i == contactCount) {
            [contactNameList insertString:contactName atIndex:0];
        }
        else if (i == (contactCount-1)) {
            //倒数第二个联系人，名字后面加 “和”
            [contactNameList insertString:[NSString stringWithFormat:@"%@%@",contactName,NSLocalizedString(@"STR_AND", nil)]
                                  atIndex:0];
        }
        else {
            //除上面的,其余后面皆跟@"、" @","
            [contactNameList insertString:[NSString stringWithFormat:@"%@%@",contactName,NSLocalizedString(@"STR_COMMA", nil)]
                                  atIndex:0];
        }
    }
    
    // 将刚才获得的字串和字串拼接，获取完整的邀请消息并返回
    NSString *groupMessage = nil;
    
    // 获取消息类型
    switch (messageObject.messageType)
    {
        case MESSAGE_TYPE_GROUP_JOIN: // 加入群消息
        {
            //获取邀请人姓名
            NSString *contactName = messageObject.senderName;
            if ([contactName isEqualToString:appDelegate.userProfilesInfo.userAccount]) {
                contactName = NSLocalizedString(@"STR_YOU", nil);
            }
            else {
                contactName = [appDelegate.contactManager displayFriendHighGradeName:contactName];
            }
            
            groupMessage = [NSString stringWithFormat:NSLocalizedString(@"STR_INVITER_MESSAGE", nil), contactName, contactNameList];
        }
            break;
            
        case MESSAGE_TYPE_GROUP_LEAVE: // 离开群消息
        {
            groupMessage = [NSString stringWithFormat:NSLocalizedString(@"STR_LEAVE_MESSAGE", nil), contactNameList];
        }
            break;
            
        default:
            break;
    }
    
    return groupMessage;
}

// 拼装会议的提示消息
+ (NSString *)getMeetingTipStringWithMessageObject:(RKCloudChatBaseMessage *)messageObject
{
    NSString *tipMessageString = nil;
    
    tipMessageString = NSLocalizedString(messageObject.textContent, nil);
    
    return tipMessageString;
}

// 根据消息内容获取cell高度
+ (float)heightForMessage:(RKCloudChatBaseMessage *)messageObject {
    
    float cellHeight = 0.0;
    
    // 判断对象是否存在
    if (messageObject == nil)
    {
        return cellHeight;
    }
    
    // 获取当前消息类型
    switch (messageObject.messageType)
    {
        case MESSAGE_TYPE_TEXT: // 文本消息
        {
            if (messageObject.textContent)
            {
                // 统一增加：Cell上端高度+Cell下端高度+头像高度间距
                cellHeight = CELL_MESSAGE_BUBBLE_TOP_DISTANCE + CELL_MESSAGE_BUTTOM_DISTANCE;
                
                CGSize textCellSize = CGSizeZero;
                // 如果是iOS7系统
                if ([ToolsFunction iSiOS7Earlier] == NO)
                {
                    // 针对ios7，使用UITextView的属性来计算文本cell的高度 add by WangGray 2014.03.12
                    textCellSize = [ChatManager getTextCellSizeFromStringInTextView:messageObject.textContent withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
                }
                else
                {
                    // iOS7之前的系统
                    textCellSize = [ChatManager getTextCellSizeFromStringInView:messageObject.textContent
                                                                   withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
                    // 增加：ios6下多行文本Cell的中间间距高度
                    if (textCellSize.height >= TEXT_BUBBLE_MIN_HEIGHT)
                    {
                        cellHeight += CELL_TEXT_MIDDLE_SPACE_IOS7_EARLIER;
                    }
                }
                
                // 当文本框高度小于泡泡的最小高度时，加上泡泡的最小高度
                if (textCellSize.height < TEXT_BUBBLE_MIN_HEIGHT)
                {
                    cellHeight += TEXT_BUBBLE_MIN_HEIGHT;
                }
                else
                {
                    // 此时说明文本框的高度和泡泡的高度相同，此时则添加文本框的高度即可
                    cellHeight += textCellSize.height;
                }
            }
        }
            break;
            
        case MESSAGE_TYPE_IMAGE: // 图片消息
        {
            // 转换图片消息对象
            ImageMessage *imageMessage = (ImageMessage *)messageObject;
            
            // 加载图片缩略图的路径
            UIImage *imageThumbnail = [[UIImage alloc] initWithContentsOfFile:imageMessage.thumbnailPath];
            
            // 如果缩略不存在则使用默认图片
            if (imageThumbnail == nil) {
                imageThumbnail = [UIImage imageNamed:@"default_image_bg"];
            }
            
            // 获取当前图片宽高
            CGSize imageSize = [ToolsFunction sizeScaleFixedThumbnailImageSize:imageThumbnail.size];
            
            cellHeight = imageSize.height + CELL_MESSAGE_BUTTOM_DISTANCE + CELL_MESSAGE_BUBBLE_TOP_DISTANCE;
            // 如果小于最小的固定高度，则等于最小固定高度
            if (cellHeight < IMAGE_BUBBLE_HEIGHT + CELL_MESSAGE_BUTTOM_DISTANCE + CELL_MESSAGE_BUBBLE_TOP_DISTANCE)
            {
                cellHeight = IMAGE_BUBBLE_HEIGHT + CELL_MESSAGE_BUTTOM_DISTANCE + CELL_MESSAGE_BUBBLE_TOP_DISTANCE;
            }
        }
            break;
            
        case MESSAGE_TYPE_VOICE: // 语音消息
        {
            cellHeight = VOICE_BUBBLE_HEIGHT + CELL_MESSAGE_BUBBLE_TOP_DISTANCE + CELL_MESSAGE_BUTTOM_DISTANCE;
        }
            break;
            
        case MESSAGE_TYPE_FILE: // 文件类型
        {
            //Jacky.Chen:2016.03.16 Add 根据文件名确定文件消息高度
            FileMessage *fileMessage = (FileMessage *)messageObject;
            // 得到文件大小
            NSString *strFileSize = [ToolsFunction stringFileSizeWithBytes:fileMessage.fileSize];
            
            // 设置文件名字符串
            NSString *fileNameText = [NSString stringWithFormat:@"%@  %@", fileMessage.fileName, strFileSize];
            CGFloat fileNameLabelHeight =[fileNameText boundingRectWithSize:CGSizeMake(MESSAGE_FILE_CONTENT_WIDTH, CGFLOAT_MAX)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                                 attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:16],NSFontAttributeName, nil] context:nil].size.height;
            cellHeight = (int)(CELL_MESSAGE_FILETEXT_TOP*2 + fileNameLabelHeight + CELL_MESSAGE_BUBBLE_TOP_DISTANCE + CELL_MESSAGE_BUTTOM_DISTANCE);
        }
            break;
            
        case MESSAGE_TYPE_GROUP_JOIN: // 加入群消息
        case MESSAGE_TYPE_GROUP_LEAVE: // 离开群消息
        {
            // 获取所要显示的字需要占据的空间大小
            NSString *tipMessageString = [ChatManager getGroupTipStringWithMessageObject:messageObject];
            CGSize sizeString = [ToolsFunction getSizeFromString:tipMessageString withFont:TIP_MESSAGE_TEXT_FONT constrainedToSize:CGSizeMake(270, 200)];
            
            cellHeight = sizeString.height + CELL_MESSAGE_TOP_DISTANCE + CELL_MESSAGE_BUTTOM_DISTANCE;
        }
            break;
            
        case MESSAGE_TYPE_LOCAL: // 本地消息
        {
            if ([messageObject.mimeType isEqualToString:kMessageMimeTypeTip]) {
                // 获取所要显示的字需要占据的空间大小
                NSString *tipMessageString = [ChatManager getMeetingTipStringWithMessageObject:messageObject];
                CGSize sizeString = [ToolsFunction getSizeFromString:tipMessageString withFont:TIP_MESSAGE_TEXT_FONT constrainedToSize:CGSizeMake(270, 200)];
                
                cellHeight = sizeString.height + CELL_MESSAGE_TOP_DISTANCE + CELL_MESSAGE_BUTTOM_DISTANCE;
            }
            else if ([messageObject.mimeType isEqualToString:kMessageMimeTypeLocal])
            {
                NSString *strTextContent = [ChatManager getLocalMesssageTextContent:messageObject];
                if (strTextContent) {
                    // 根据文本计算文本显示的高度
                    CGSize textContentSize = [ChatManager getTextCellSizeFromStringInTextView:strTextContent withMaxWidth:MESSAGE_LOCAL_CONTENT_WIDTH withFontSize:MESSAGE_TEXT_FONT];
                    
                    // 行高+顶部和底部的距离
                    cellHeight = CELL_MESSAGE_BUBBLE_TOP_DISTANCE + MESSAGE_LINE_HEIGHT * textContentSize.height/MESSAGE_LINE_HEIGHT + CELL_MESSAGE_BUTTOM_DISTANCE;
                }
            }
        }
            break;
        case MESSAGE_TYPE_VIDEO:
        {
            cellHeight = 160;
        }
            break;
        default:
            cellHeight = 120;
            break;
    }
    
    return cellHeight;
}

// 通过UITextView获取文本字串的size add by WangGray 2014.03.12
+ (CGSize)getTextCellSizeFromStringInTextView:(NSString *)stringText
                                 withMaxWidth:(float)contentWidth
                                 withFontSize:(UIFont *)currentTextFontSize
{
    CGSize textCellSize;
    // 通过文本字串创建属性化字串
    NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString:stringText attributes:nil];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    NSString * stringKey = nil;
    NSString * emotionName = nil;
    NSArray *arrayKeys = [appDelegate.chatManager.emotionESCToFileNameDict allKeys];
    NSRange emotionRange;
    
    // 发送时将文本中的表情描述转换为表情转义字符串
    for (int i = 0; i < [arrayKeys count]; i++)
    {
        // 表情转移字符
        stringKey = [arrayKeys objectAtIndex:i];
        emotionRange = [[textAttributedString string] rangeOfString: stringKey];
        
        // 查找是否存在表情符号
        if (emotionRange.length > 0)
        {
            // 表情符号对应的图标名称
            emotionName = [appDelegate.chatManager.emotionESCToFileNameDict objectForKey:stringKey];
            
            // 属性化表情符号
            NSTextAttachment *imageAttachment=[[NSTextAttachment alloc] initWithData:nil ofType:nil];
            UIImage *imageEmoticon = [UIImage imageNamed:emotionName];
            imageAttachment.image = imageEmoticon;
            imageAttachment.bounds = CGRectMake(0, -5, MESSAGE_EMOTICON_WIDTH, MESSAGE_EMOTICON_HEIGHT);
            NSAttributedString *imageAttributedString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
            
            // 将文本字符串中的表情转义字符替换为表情字符串
            if (stringKey && emotionName)
            {
                // 通过循环替换字串中所有的表情符号
                while ([[textAttributedString string] rangeOfString:stringKey].length > 0)
                {
                    [textAttributedString replaceCharactersInRange:[[textAttributedString string] rangeOfString:stringKey]
                                              withAttributedString: imageAttributedString];
                }
            }
        }
    }
    
    // 计算该文本在UITextView中显示需要的size
    UITextView *textView = [[UITextView alloc] init];
    
    // 设置字体
    [textAttributedString addAttribute:NSFontAttributeName value:currentTextFontSize range:NSMakeRange(0, [[textAttributedString string] length])];
    
    // 为UITextView的属性化字串赋值
    textView.attributedText = textAttributedString;
    textCellSize = [textView sizeThatFits:CGSizeMake(contentWidth, MESSAGE_LINE_HEIGHT * MESSAGE_TEXT_MAX_LINE)];
    
    // 宽度增加5px的原因是：在测试的过程中，针对只有3-4个字符时，UITextView绘制两列，导致第二列的字符绘制不全的问题  add by WangGray 2014.03.12
    textCellSize = CGSizeMake(textCellSize.width + 5, textCellSize.height+0.5);
    return textCellSize;
}

+ (CGSize)getTextCellSizeFromStringInView:(NSString *)stringText
                             withMaxWidth:(float)contentWidth
                             withFontSize:(UIFont *)currentFontSize
{
    NSString * stringKey = nil;
    NSArray *arrayKeys = [[AppDelegate appDelegate].chatManager.emotionESCToFileNameDict allKeys];
    float textContentLineNumber = 0.0;
    
    // 计算文本字符串高度
    CGSize textMaxSize = CGSizeMake(contentWidth, MESSAGE_LINE_HEIGHT * MESSAGE_TEXT_MAX_LINE);
    CGSize textBlockSize = CGSizeZero;
    CGSize textCellSize = CGSizeZero;
    CGFloat textMaxWidth = 0;
    
    NSMutableString *stringLineText = nil;
    NSArray *arrayText = [stringText componentsSeparatedByString:@"\n"];
    if (arrayText)
    {
        for (int i=0; i<[arrayText count]; i++)
        {
            // 得到每行的字符串
            stringLineText = [NSMutableString stringWithString:[arrayText objectAtIndex:i]];
            if (stringLineText && ![stringLineText isEqualToString:@""])
            {
                // 查找每行中有多少个图标的转义字符串
                for (int i = 0; i < [arrayKeys count]; i++)
                {
                    stringKey = [arrayKeys objectAtIndex:i];
                    if (stringKey)
                    {
                        NSRange range = NSMakeRange(0, [stringLineText length]);
                        [stringLineText replaceOccurrencesOfString:stringKey
                                                        withString:@"[:::]"
                                                           options:NSCaseInsensitiveSearch
                                                             range:range];
                    }
                }
                
                // @"[[[[[" size.width = 21
                // @"[:::]" size.width = 22(ios5)/23(ios4)
                // 得到文本字符串的size
                textBlockSize = [ToolsFunction getSizeFromString:stringLineText
                                                        withFont:currentFontSize
                                               constrainedToSize:textMaxSize];
                
                // 如果一断文本字符串的总宽度小于最大的宽度则计算实际宽度
                if (textBlockSize.width < contentWidth)
                {
                    // 如果已经保存的最大行宽度小于断的宽度则重新赋值
                    if (textMaxWidth < textBlockSize.width)
                    {
                        textMaxWidth = textBlockSize.width;
                    }
                }
                else {
                    textMaxWidth = contentWidth;
                }
                
                // 计算本段文本的行数
                float nLine = textBlockSize.height / MESSAGE_LINE_HEIGHT;
                textContentLineNumber += nLine;
            }
            else if (stringLineText && [stringLineText isEqualToString:@""]) {
                // 如果出现换行则累加行数
                textContentLineNumber++;
            }
        }
    }
    
    // 解决阿拉伯语言文本在 iOS5.0 下，带图标显示不完整问题（因阿拉伯语言显示的字符和使用sizeWithFont得到的字符串尺寸不一致，
    // 所以导致算出来的尺寸无法完整显示阿拉伯语言后面的一个图标）
    if ([[ToolsFunction getLocaliOSLanguage] isEqualToString:@"ar"]) {
        // 如果文本的宽度大于泡泡最大宽度的一半则增加一行
        if (textMaxWidth > contentWidth/2) {
            textContentLineNumber += 1;
        }
        else if (textMaxWidth >= contentWidth/4) {
            // 如果文本的宽度大于泡泡最大宽度的四分之一则自身增加三分之一的宽度
            textMaxWidth += textMaxWidth/3;
        }
    }
    
    // 文本Cell的最大宽度
    textCellSize.width = textMaxWidth;
    // 文本Cell的最大高度
    textCellSize.height = textContentLineNumber * MESSAGE_LINE_HEIGHT;
    
    /*
     NSLog(@"stringText = %@, textContentLineNumber = %d, textCellSize = %@",
     stringText, textContentLineNumber, NSStringFromCGSize(textCellSize));
     */
    return textCellSize;
}


#pragma mark -
#pragma mark MMS – Custom Function

// 获取联系人的名字
+ (NSString *)getFullName:(NSString *)firstName withLastName:(NSString *)lastName
{
    // 获取当前系统的语言
    NSString* language = [ToolsFunction getLocaliOSLanguage];
    NSString *name = nil;
    if (firstName && lastName)
    {
        // 如果是中文
        if ([language hasPrefix:@"zh"]) {
            name = [NSString stringWithFormat:@"%@%@", lastName, firstName];
        }
        else {
            name = [NSString stringWithFormat:@"%@%@", firstName, lastName];
        }
    }
    else if(firstName && lastName == nil)
    {
        // 连接firstName
        name = [NSString stringWithFormat:@"%@", firstName];
    }
    else if(firstName == nil && lastName)
    {
        // 连接firstName
        name = [NSString stringWithFormat:@"%@", lastName];
    }
    else {
        return nil;
    }
    return [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

// 获取消息在消息会话列表上最后一条的描述信息
+ (NSString *)getMessageDescription:(RKCloudChatBaseMessage *)messageObject
{
    if (messageObject == nil) {
        return nil;
    }
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    
    //声明所要显示的字符串
    NSString *descriptionString = nil;
    
    //确定消息文字
    switch (messageObject.messageType)
    {
        case MESSAGE_TYPE_TEXT: //文字消息显示内容
        {
            // 文本短信
            descriptionString = [ToolsFunction translateEmotionString:messageObject.textContent
                                                       withDictionary:appDelegate.chatManager.emotionESCToFileNameDict];
            if (descriptionString == nil)
            {
                descriptionString = messageObject.textContent;
            }
        }
            break;
            
        case MESSAGE_TYPE_IMAGE: //[图片]
            descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"STR_IMAGE_DESCRIBE", "图片")];
            break;
            
        case MESSAGE_TYPE_VOICE: //[声音]
            descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"STR_VOICE_DESCRIBE", "语音")];
            break;
            
        case MESSAGE_TYPE_FILE: //[文件]
            descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"STR_FILE_DESCRIBE", "文件")];
            break;
            
        case MESSAGE_TYPE_VIDEO: //[视频]
            descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"STR_TAKE_VIDEO", "视频")];
            break;
            
        case MESSAGE_TYPE_LOCAL: // [语音通话]/[视频通话]
        {
            if ([messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话")]) {
                descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话")];
            }
            else if ([messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话")])
            {
                descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话")];
            }
            else if ([messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音")])
            {
                descriptionString = [NSString stringWithFormat:@"[%@]", NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音")];
            }
            else {
                if ([messageObject.mimeType isEqualToString:kMessageMimeTypeLocal]) {
                    descriptionString = messageObject.textContent;
                }
                else if ([messageObject.mimeType isEqualToString:kMessageMimeTypeTip])
                {
                    descriptionString = NSLocalizedString(messageObject.textContent, nil);
                }
            }
        }
            break;
            
        case MESSAGE_TYPE_GROUP_JOIN:  // 加入群消息
        case MESSAGE_TYPE_GROUP_LEAVE: // 离开群信息
        {
            descriptionString = [ChatManager getGroupTipStringWithMessageObject:messageObject];
        }
            break;

            
        default:
            break;
    }
    return descriptionString;
}

// 获取本地消息的内容  
+ (NSString *)getLocalMesssageTextContent:(RKCloudChatBaseMessage *)messageObject
{
    NSString *strTextContent = messageObject.textContent;
    
    if ([messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_AUDIO_CALL", "语音通话")] || [messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_AV_MSG_VIDEO_CALL", "视频通话")])
    {
        strTextContent = messageObject.textContent;
    }
    else if ([messageObject.extension isEqualToString:NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", "多人语音")])
    {
        strTextContent = NSLocalizedString(@"PROMPT_CREATE_MEETING_MYSELF", "我发起了多人语音");
    }
    
    return strTextContent;
}

@end
