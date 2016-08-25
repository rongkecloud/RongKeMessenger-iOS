//
//  MessageTableCell.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "SessionListTableCell.h"
#import "AppDelegate.h"

#define COLOR_CELL_SUBTITLE_TEXT [UIColor colorWithRed:156.0/255.0 green:156.0/255.0 blue:156.0/255.0 alpha:1.0];

@implementation SessionListTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
        
        // 初始化所有UI控件
        [self initAllUIControl];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
    // 初始化所有UI控件
    [self initAllUIControl];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


#pragma mark - Custom Methods

// 初始化所有UI控件
- (void)initAllUIControl
{
    self.nameLabel.font = FONT_TEXT_SIZE_16;
    self.descriptionLabel.font = FONT_TEXT_SIZE_14;
    self.descriptionLabel.textColor = COLOR_CELL_SUBTITLE_TEXT;
    self.dateLabel.textColor = COLOR_CELL_SUBTITLE_TEXT;
    self.timeLabel.textColor = COLOR_CELL_SUBTITLE_TEXT;
    
    // 重置相关的控件
    [self resetControls];
}

// 重置相关的控件
- (void)resetControls
{
    // 重置相关的控件
    self.dateLabel.text = nil;
    self.timeLabel.text = nil;
    self.missReadLabel.text = nil;
    self.descriptionLabel.text = nil;
    self.missReadImageView.image = nil;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    for (UIView *subview in self.subviews) {
        
        for (UIView *subview2 in subview.subviews) {
            
            if ([NSStringFromClass([subview2 class]) isEqualToString:@"UITableViewCellDeleteConfirmationView"]) { // move delete confirmation view
                
                [subview bringSubviewToFront:subview2];
            }
        }
    }
    
    // 解决ios8之前，刚开始显示不出来的问题
    //self.lineView.frame = CGRectMake(self.lineView.frame.origin.x, self.frame.size.height - 0.5, UISCREEN_BOUNDS_SIZE.width, 0.5);
}


#pragma mark - Config Session List TableViewCell

// 配置会话列表Cell的相关会话的信息
- (void)configSessionListByChatSessionObject:(RKCloudChatBaseChat *)sessionObject
                                withListType:(SessionListShowType)sessionListType
                            withMarkColorStr:(NSString *)markColorStr
{
    if (sessionObject == nil) {
        return;
    }
    
    // 会话中没有消息，重置相关的控件
    [self resetControls];
    
    // 查找最新的messageObject
    RKCloudChatBaseMessage *messageObject = sessionObject.lastMessageObject;
    
    [self configSessionCellNameAndAvatarWithSessionObject:sessionObject withListType:sessionListType withMarkColorStr:markColorStr];
    
    if (messageObject == nil) {
        self.dateLabel.text = nil;
        self.timeLabel.text = nil;
        self.missReadLabel.text = nil;
        self.descriptionLabel.text = nil;
        self.missReadImageView.image = nil;
        return;
    }

    // 配置会话列表上的未读数量
    [self configSessionCellUnreadCountWithSessionObject:sessionObject];
    
    // 配置会话列表上的时间
    if (sessionListType != SessionListShowTypeSearchListMain) {
      [self configSessionCellDateWithSessionObject:sessionObject];
    }
    
    if (sessionObject.isTop == YES)
    {
        self.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:255.0/255.0 blue:241.0/255.0 alpha:1.0];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    // 显示消息Cell时间和详细内容
    [self configSessionCellDescriptionWithMessageObject:messageObject withSessionObject:sessionObject withListType:sessionListType withMarkColorStr:markColorStr];
    
    [self setNeedsDisplay];
}

// 配置会话列表上的名称
- (void)configSessionCellNameAndAvatarWithSessionObject:(RKCloudChatBaseChat *)sessionObject withListType:(SessionListShowType)sessionListType withMarkColorStr:(NSString *)markColorStr
{
    // 联系人名字
    NSString *sessionName = sessionObject.sessionShowName;
    // 重置头像view中的控件
    [self.headImageView resetCellConrol];
    
    // 根据会话类型加载头像
    if (sessionObject.sessionType == SESSION_SINGLE_TYPE)
    {
        // 单聊的的头像，使用用户的默认头像
        [self.headImageView setUserAvatarImageByUserId:sessionObject.sessionShowName];
        
        // 单聊使用好友名
        sessionName = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:sessionObject.sessionShowName];
    }
    else if (sessionObject.sessionType == SESSION_GROUP_TYPE)
    {
        if (sessionListType == SessionListShowTypeNomal) {
            // 如果该会话为群聊，则查找该会话中的人数
            sessionName = [NSString stringWithFormat:@"%@(%d)", sessionObject.sessionShowName, sessionObject.userCounts];
        }
        
        // 群组默认头像
        self.headImageView.image = [UIImage imageNamed:@"default_icon_group_avatar"];
    }
    
    
    // 当用户的名称中没有搜索的字符但id中有搜索的字符时，显示用户的名称，不高亮搜索的字符。
    self.nameLabel.text = sessionName;

    if (sessionListType == SessionListShowTypeSearchSessionName)
    {
        // 需要高亮显示
        if (sessionName.length > 0 && markColorStr.length > 0) {
            
            NSMutableAttributedString *textAttributedString = [self applyAttributedString:sessionName pattern:markColorStr];
            
            if (textAttributedString.length > 0) {
                // 使用属性化字符串
                self.nameLabel.attributedText = textAttributedString;
            }
        }
    }
}

// 配置会话列表上的未读数量
- (void)configSessionCellUnreadCountWithSessionObject:(RKCloudChatBaseChat *)sessionObject
{
    // 获取新增短信的个数
    if (sessionObject.unReadMsgCnt > 0)
    {
        self.missReadLabel.hidden = NO;
        self.missReadImageView.hidden = NO;
        
        // 如果是个位数的短信数量则显示数量
        NSString *newReadCountStr = [NSString stringWithFormat:@"%d", sessionObject.unReadMsgCnt];
        
        // 如果超过个位数的短信则显示“9+”
        if (sessionObject.unReadMsgCnt > 99) {
            newReadCountStr = [NSString stringWithFormat:@"99+"];
        }
        
        self.missReadLabel.text = newReadCountStr;
        
        if (sessionObject.unReadMsgCnt < 10)
        {
            // 显示新增短信个数的背景图
            self.missReadImageView.image = [UIImage imageNamed:@"icon_new_read_single"];
        }
        else {
            self.missReadImageView.image = [UIImage imageNamed:@"icon_new_read_double"];
        }
        
        /*
         // 获取名字的长度
         CGSize maximumSize = CGSizeMake(100000, 21);
         CGSize myStringSize = [ToolsFunction getSizeFromString:cell.nameLabel.text
         withFont:cell.nameLabel.font
         constrainedToSize:maximumSize];
         
         根据名字的长度设置新增短信数值的位置
         if (myStringSize.width > 145)
         {
         cell.missReadImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x + 145, 8, newMMSImageBG.size.width / 2, newMMSImageBG.size.height / 2);
         }
         else
         {
         cell.missReadImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x + myStringSize.width + 4, 8, newMMSImageBG.size.width / 2, newMMSImageBG.size.height / 2);
         }
         cell.missReadLabel.frame = CGRectMake(cell.missReadImageView.frame.origin.x, 8, newMMSImageBG.size.width / 2, newMMSImageBG.size.height / 2);
         */
    }
    else
    {
        self.missReadLabel.hidden = YES;
        self.missReadImageView.hidden = YES;
    }
}

// 配置会话列表上的时间
- (void)configSessionCellDateWithSessionObject:(RKCloudChatBaseChat *)sessionObject
{
    // 消息最后一条记录的创建时间
    NSDate *createTime = [NSDate dateWithTimeIntervalSince1970:sessionObject.lastMsgCreatedTime];
    
    // 短信的日期
    self.dateLabel.text = [ToolsFunction getDateString:createTime];
    
    // 短信的时间
    self.timeLabel.text = [ToolsFunction getTimeString:createTime];
}

// 配置会话列表上的描述信息
- (void)configSessionCellDescriptionWithMessageObject:(RKCloudChatBaseMessage *)messageObject
                                    withSessionObject:(RKCloudChatBaseChat *)sessionObject
                                         withListType:(SessionListShowType)sessionListType
                                     withMarkColorStr:(NSString *)markColorStr
{
    // 设置消息Cell时间和详细内容
    if (sessionObject)
    {
        // 如果有草稿存在则优先显示草稿内容
        NSString *textDraft = [RKCloudChatMessageManager getDraft:sessionObject.sessionID];
        if ([textDraft length] > 0)
        {
            // 通过文本字串创建属性化字串
            NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[%@] %@", NSLocalizedString(@"STR_DRAFT_DESCRIBE", "草稿"), textDraft] attributes:nil];
            
            // 设置字体颜色
            [textAttributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_RGB(183, 20, 20) range:NSMakeRange(0, [[NSString stringWithFormat:@"[%@]", NSLocalizedString(@"STR_DRAFT_DESCRIBE", "草稿")] length])];
            
            // 使用属性化字符串
            self.descriptionLabel.attributedText = textAttributedString;
        }
        else if (messageObject && [messageObject isKindOfClass:[RKCloudChatBaseMessage class]])
        {
            
            NSMutableString *strDescription = [NSMutableString string];
            
            switch (sessionListType)
            {
                case SessionListShowTypeNomal:
                case SessionListShowTypeSearchSessionName:
                {
                    NSString *messageInfo = nil;
                    
                    if (messageObject.messageType == MESSAGE_TYPE_REVOKE)
                    {
                        messageInfo = [ChatManager getRevokeStringWithMessageObject:messageObject];
                        self.descriptionLabel.text = messageInfo;
                    }
                    else
                    {
                        BOOL isAttributedString = NO;
                        // 如果是群聊会话则显示发送方的名字
                        if (sessionObject.sessionType == SESSION_GROUP_TYPE)
                        {
                            if (messageObject.messageStatus == MESSAGE_STATE_RECEIVE_RECEIVED
                                && messageObject.atUser && [messageObject.atUser length] > 0)
                            {
                                if ([messageObject.atUser isEqualToString: @"all"])
                                {
                                    isAttributedString = YES;
                                    [strDescription appendString:@"[有人@我]"];
                                }
                                else
                                {
                                    NSArray *atArray = [messageObject.atUser JSONValue];
                                    if (atArray && [atArray count] > 0)
                                    {
                                        if ([atArray containsObject: [AppDelegate appDelegate].userProfilesInfo.userAccount])
                                        {
                                            isAttributedString = YES;
                                            [strDescription appendString:@"[有人@我]"];
                                        }
                                    }
                                }
                            }
                            
                            NSString *nameSender = nil;
                            if ([messageObject.senderName isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
                            {
                                nameSender = NSLocalizedString(@"STR_ME", "我");
                            }
                            else {
                                nameSender = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:messageObject.senderName];
                            }
                            
                            if ([messageObject isKindOfClass: [TipMessage class]] == NO)
                            {
                                BOOL isAddName = YES;
                                if ([messageObject isKindOfClass: [LocalMessage class]])
                                {
                                    LocalMessage *localMessage = (LocalMessage *)messageObject;
                                    if ([localMessage.mimeType isEqualToString: kMessageMimeTypeTip])
                                    {
                                        isAddName = NO;
                                    }
                                }
                                if (isAddName) {
                                    [strDescription appendFormat:@"%@: ", nameSender];
                                }
                            }
                        }
                        
                        
                        messageInfo = [ChatManager getMessageDescription:messageObject];
                        if (messageInfo)
                        {
                            // 获取消息在消息会话列表上最后一条的描述信息
                            [strDescription appendString:messageInfo];
                        }
                        
                        if (isAttributedString)
                        {
                            NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString: strDescription];
                            
                            NSRange range = [strDescription rangeOfString: @"[有人@我]"];
                            // 设置字体颜色
                            [textAttributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_RGB(183, 20, 20) range:range];
                            
                            if (textAttributedString.length > 0) {
                                // 使用属性化字符串
                                self.descriptionLabel.attributedText = textAttributedString;
                            }
                        }
                        else
                        {
                            self.descriptionLabel.text = strDescription;
                        }
                    }
                }
                    break;
                case SessionListShowTypeSearchListMain:
                {
                    [strDescription appendString:sessionObject.lastMessageObject.textContent];
                     self.descriptionLabel.text = strDescription;
                }
                    break;
                    
                case SessionListShowTypeSearchListCategory:
                {
                    if (sessionObject.lastMessageObject.textContent.length > 0 && markColorStr.length > 0)
                    {
                        
                        NSMutableAttributedString *textAttributedString = [self applyAttributedString:sessionObject.lastMessageObject.textContent pattern:markColorStr];
                        
                        if (textAttributedString.length > 0) {
                            // 使用属性化字符串
                            self.descriptionLabel.attributedText = textAttributedString;
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    // 如描述的文字是空则显示为"[空]"
    if (self.descriptionLabel.text == nil || [self.descriptionLabel.text length] == 0)
    {
        // 会话中空消息时显示为“[空]”
        self.descriptionLabel.text = NSLocalizedString(@"STR_EMPTY", "[空]");
    }
}

- (NSMutableAttributedString *)applyAttributedString:(NSString *)text pattern:(NSString *)pattern
{
    NSMutableArray *rangeArrray = [self applyStylesToText:text pattern:pattern];
    
    if (rangeArrray.count == 0) {
        return nil;
    }
    
    NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:nil];
    
    for (NSTextCheckingResult *result in rangeArrray) {
        // 设置字体颜色
        [textAttributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_RGB(183, 20, 20) range:result.range];
    }
    
    return textAttributedString;
}

// 查找字段中包含所有关键字的Range
- (NSMutableArray *)applyStylesToText:(NSString *)text pattern:(NSString *)pattern
{
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0, text.length);
    NSRange paragaphRange = [text paragraphRangeForRange:searchRange];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    
    [regex enumerateMatchesInString:text options:0 range:paragaphRange usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        [rangeArray addObject:result];
    }];
    
    return rangeArray;
}

//- (NSRegularExpression *)expressionForDefinitionPattern:(NSString *)pattern
//{
//    NSRegularExpression *expression = nil;
//    expression = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
//    return expression;
//}
@end
