//
//  TextMessageContentView.m
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import "TextMessageContentView.h"
#import "MessageBubbleTableCell.h"
#import "HyperlinkData.h"
#import "RKCloudChat.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

// URL的开始关键字
#define URL_SCHEME_KEY_HTTP           @"http://"
#define URL_SCHEME_KEY_HTTPS          @"https://"
#define URL_SCHEME_KEY_FTP            @"ftp://"
#define URL_SCHEME_KEY_WWW            @"www."

// URL的结束关键字
#define URL_SCHEME_END_COM            @".com"
#define URL_SCHEME_END_SPACE          @" "

@implementation TextMessageContentView

@synthesize textContent;
@synthesize selectedUrl;
@synthesize urlSchemeArray;
@synthesize textColor;
@synthesize linkTextColor;
@synthesize highlightHyperLinkBGColor;
@synthesize backgroundImage;
@synthesize bgImageTopStretchCap;
@synthesize bgImageLeftStretchCap;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.bgImageTopStretchCap = 0.0;
        self.bgImageLeftStretchCap = 0.0;
        
        UIColor *blackColor = [[UIColor alloc] initWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.textColor = blackColor;
        
        UIColor *blueColor = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        self.linkTextColor = blueColor;
        
        UIColor *grayColor = [[UIColor alloc] initWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
        self.highlightHyperLinkBGColor = grayColor;
        
        self.backgroundImage = nil;
        
        // 加载Url搜索方案字段到数组中
        NSArray * arrayUrlScheme = [[NSArray alloc] initWithObjects:
                                    URL_SCHEME_KEY_HTTP,
                                    URL_SCHEME_KEY_HTTPS,
                                    URL_SCHEME_KEY_FTP,
                                    URL_SCHEME_KEY_WWW,
                                    nil];
        self.urlSchemeArray = arrayUrlScheme;
        
        if (hyperlinkDataMutabeArray == nil)
        {
            hyperlinkDataMutabeArray = [[NSMutableArray alloc] init];
        }

        if (drawHyperlinkRectMutableArray == nil)
        {
            drawHyperlinkRectMutableArray = [[NSMutableArray alloc] init];
        }
        
        self.selectedUrl = nil;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	[super drawRect: rect];
	if (self.textContent == nil || [self.textContent isEqualToString:@""]) {
		return;
	}
    
    // 绘制选中的URL链接背景色
	if (self.selectedUrl) {
        [self drawSelectedHyperlinksBackgroundColor];
    }
    
    // debug test
    //self.backgroundColor = [UIColor redColor];
    
	if (self.backgroundImage)
	{
		UIImage *bg = self.backgroundImage;
		
		if (self.bgImageTopStretchCap > 0 || self.bgImageLeftStretchCap > 0)
		{
			bg = [self.backgroundImage stretchableImageWithLeftCapWidth:self.bgImageLeftStretchCap
                                                           topCapHeight:self.bgImageTopStretchCap];
		}
		
		[bg drawInRect:rect]; // Using 'bounds' here causes the bubble to be drawn with a white line near the stretching point.
        // Using 'rect' fixes it... no idea why.
	}
    
	// 定义使用的变量
    NSString *stringText = nil;
	NSString *stringRemainText = self.textContent;
	NSInteger textContentLength = 0;
	NSInteger deletePos = 0;
    
	CGRect contentRect = CGRectMake(0, 0, 0, 0);
    // 先计算文本字符串的Size
	CGSize textMaxSize = [ToolsFunction getTextCellSizeFromString:self.textContent
                                                 withMaxWidth:MESSAGE_TEXT_CONTENT_WIDTH];
	
	//NSLog(@"self.textContent = %@", self.textContent);
	
	// 定义文字的颜色
	[self.textColor set];
	
	// 先将字符串按照换行符截断为每一段落，再对每段进行绘制
	NSArray *arraySection = [stringRemainText componentsSeparatedByString:@"\n"];
	for (int section = 0; section < [arraySection count]; section++) 
	{
		// 得到字符串的第一个回车行
		stringRemainText = [arraySection objectAtIndex:section];
		//NSLog(@"stringRemainText = %@", stringRemainText);
		
		// 找文本字符串中是否有表情的开始
		NSRange rangeStart = [stringRemainText rangeOfString:@"~"];
		
		if (rangeStart.length > 0) 
		{
			// 继续找下去
			while (rangeStart.length > 0) 
			{
				//NSLog(@"stringRemainText = %@", stringRemainText);
				textContentLength = [stringRemainText length];
				
				NSRange rangeEnd = [stringRemainText rangeOfString:@"~"
												   options:NSCaseInsensitiveSearch 
													 range:NSMakeRange(rangeStart.location+1, 
																	   textContentLength-(rangeStart.location+1))];
				
				// 判断是否有表情符号存在（增加表情符号之间必须等于4则才是一个真正的表情符号的判断）
				if (rangeEnd.length > 0 && (rangeEnd.location - rangeStart.location) == 4) 
				{
					// 如果表情符号之前还有文本字符串则先绘制字符串
					if (rangeStart.location > 0) 
					{
						// 如果找到表情图标则将表情图标之前的文本绘制出来
						stringText = [stringRemainText substringToIndex:rangeStart.location];
						
                        // 绘制文本字符串
                        contentRect = [self drawStringText:stringText currentPosition:contentRect maxSize:textMaxSize];
					}
					
					// 开始绘制表情图标，得到图标的转义字符串
					NSString *stringRange = [stringRemainText substringWithRange:
                                             NSMakeRange(rangeStart.location, rangeEnd.location-rangeStart.location+1)];
					if (stringRange) 
					{
						// 转换为图标的名称
						NSString *stringImage = [[AppDelegate appDelegate].chatManager.emotionESCToFileNameDict objectForKey:stringRange];
						if (stringImage) 
						{
                            // 绘制文本中的表情图标
                            contentRect = [self drawEmoticonImage:stringImage currentPosition:contentRect maxSize:textMaxSize];
						}
						else {
							// 找到配对的“~”，但不是表情转移字符则绘制文本
							// 如果没有找到表情图标则将表情图标最后一个“~”的之前文本绘制出来
							stringText = stringRange;
                            
                            // 绘制文本字符串
                            contentRect = [self drawStringText:stringText currentPosition:contentRect maxSize:textMaxSize];
						}
					}
					
					deletePos = rangeEnd.location+1;
				}
				else {
					// 如果找不到到表情图标的后标识则将表情图标前标识之前的文本绘制出来
					stringText = [stringRemainText substringToIndex:rangeStart.location+1];
                
					// 绘制文本字符串
                    contentRect = [self drawStringText:stringText currentPosition:contentRect maxSize:textMaxSize];
					
					deletePos = rangeStart.location+1;
				}
				
				// 将绘制好的字符串删除
				stringRemainText = [stringRemainText substringFromIndex:deletePos];
				
				// 查找后面的是否存在表情符号的开始
				rangeStart = [stringRemainText rangeOfString:@"~"];
				if (rangeStart.length <= 0) {
					
					// 得到末尾最后的字符串
					stringText = stringRemainText;
					
                    // 绘制文本字符串
                    contentRect = [self drawStringText:stringText currentPosition:contentRect maxSize:textMaxSize];
				}
			}
		}
		else
        {
			// 如果文本字符串中不存在表情符号则只绘制文本字符串
			stringText = stringRemainText;
			if (stringText && ![stringText isEqualToString:@""]) 
			{                
                // 判断字符串中有没有URL连接
                if ([ToolsFunction isExistUrlInString: stringText] == NO)
                {
                    // 字符串中没有URL连接
                    contentRect = [self drawSubString:stringText currentPosition:&contentRect stringMaxSize:textMaxSize isDrawHyperlinks: NO];
                    contentRect = CGRectMake(contentRect.origin.x, contentRect.origin.y + contentRect.size.height - MESSAGE_LINE_HEIGHT, contentRect.size.width, contentRect.size.height);
                }
                else
                {
                    // 绘制出文本字符串
                    contentRect  = [self drawStringText:stringText currentPosition:contentRect maxSize:textMaxSize];
                }
			}
			else if (stringText && [stringText isEqualToString:@""]) {
				// 如果出现空行或换行则重新定位下一行的文本位置
				contentRect = CGRectMake(0, contentRect.origin.y, 0, MESSAGE_LINE_HEIGHT);
			}
		}
		
		// 换行重新定位下一行的文本位置
		contentRect = CGRectMake(0, 
								 contentRect.origin.y + MESSAGE_LINE_HEIGHT, 
								 0, MESSAGE_LINE_HEIGHT);
	}
}

- (void)dealloc {
    
	self.textContent = nil;
    self.urlSchemeArray = nil;
    self.selectedUrl = nil;
    self.textColor = nil;
    self.linkTextColor = nil;
    self.highlightHyperLinkBGColor = nil;
    self.backgroundImage = nil;
    
//	[hyperlinkDataMutabeArray removeAllObjects];
//    [hyperlinkDataMutabeArray release];
//    hyperlinkDataMutabeArray = nil;
//    
//    [drawHyperlinkRectMutableArray removeAllObjects];
//    [drawHyperlinkRectMutableArray release];
//    drawHyperlinkRectMutableArray = nil;
//    
//    [super dealloc];
}


#pragma mark -
#pragma mark Draw Text & Emoticon Image Method

/*
// 绘制字符串文本
- (CGRect)drawStringText:(NSString *)stringText currentPosition:(CGRect)contentRect maxSize:(CGSize)textMaxSize
{
    //CGSize textSize = CGSizeMake(0, 0);
    
    if (stringText && ![stringText isEqualToString:@""]) 
    {
        // 绘制表情图标之前的文本
        NSString * stringSubText = nil;
        for (int i = 1; i <= [stringText length]; i++) 
        {
            // 为了不断开固定的单词，所以以空格为间隔查找一个一个的单词
            NSRange rangeSeperateWord = [stringText rangeOfString:@" "];
            if (rangeSeperateWord.length > 0) {
                i = rangeSeperateWord.location + 1;
            }
            
            // 得到一个单词或者一个单字
            stringSubText = [stringText substringToIndex:i];
            // 剩余的文本
            stringText = [stringText substringFromIndex:i];
            
            // 计算单词或单个字的长度
            //textSize = [stringSubText sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:textMaxSize];
            //NSLog(@"drawStringText stringSubText=%@, stringSubTextSize=%@, stringText=%@, [stringText length]=%d, i=%d", stringSubText, NSStringFromCGSize(textSize), stringText, [stringText length], i);
            
            // 绘制当行文本
            contentRect = [self drawLineText:stringSubText currentPosition:contentRect maxSize:textMaxSize];
            
            i = 0;
        }
    }
    
    return contentRect;
}

// 绘制一行文本
- (CGRect)drawLineText:(NSString *)stringSubText currentPosition:(CGRect)contentRect maxSize:(CGSize)textMaxSize
{
    NSString * stringLineText = nil;
    CGSize textSize = CGSizeMake(0, 0);
    
    // 计算单词或单个字的长度
    //CGSize textSubSize = [stringSubText sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:textMaxSize];
    //NSLog(@"########stringSubText = %@, textSubSize = %@", stringSubText, NSStringFromCGSize(textSubSize));
    
    // 否则重新计算一行需要会在多少文本，并手动断行
    for (int j = 1; j <= [stringSubText length]; j++) 
    {
        stringLineText = [stringSubText substringToIndex:j];
        
        // 计算单词或单个字的长度
        textSize = [stringLineText sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:textMaxSize];
        
        // 计算绘制当前文本需要的矩形局域
        contentRect = CGRectMake(contentRect.origin.x,
                                 contentRect.origin.y,
                                 textSize.width,
                                 textSize.height);

        // 计算当前文本是否已经到达最大行宽度
        if (ceilf(contentRect.origin.x + contentRect.size.width) >= textMaxSize.width-CELL_OFFSET_DISTANCE)
        {
            // 绘制一行文本
            [stringLineText drawInRect:contentRect withFont:MESSAGE_TEXT_FONT];
            //NSLog(@"drawLineText01 stringLineText=%@, contentRect = %@", stringLineText, NSStringFromCGRect(contentRect));
            
            // 将已经绘制的文本删除
            stringSubText = [stringSubText substringFromIndex:j];
            // 从头开始
            j = 0;
            
            // 换行重新定位下一行的文本位置
            contentRect = CGRectMake(0, 
                                     contentRect.origin.y + MESSAGE_LINE_HEIGHT, 
                                     textSize.width, textSize.height);
        }
        else if (j == [stringSubText length]) {
            
            // 绘制一行文本
            [stringLineText drawInRect:contentRect withFont:MESSAGE_TEXT_FONT];
            //NSLog(@"drawLineText02 stringLineText=%@, contentRect = %@", stringLineText, NSStringFromCGRect(contentRect));
            
            // 向右定位下一个文本的文本X位置
            contentRect = CGRectMake(contentRect.origin.x + contentRect.size.width, 
                                     contentRect.origin.y, 
                                     0, 0);
        }
    }
    
    return contentRect;
}
*/

// 绘制字符串文本
- (CGRect)drawStringText:(NSString *)stringText currentPosition:(CGRect)contentRect maxSize:(CGSize)textMaxSize
{
    NSString *tempString = stringText;
    CGSize maxSize = CGSizeMake(999999, 20);
    BOOL isHaveLastUrlString = NO;
    NSString *subString = nil;
    CGSize subStringSize = CGSizeZero;
    NSString *oneCharacter = nil;
    unichar character;
    
    // 把字串进行分行
    for (int i = (int)[tempString length]; i > 0;)
    {
        /*range的最后一个字符的range，一个emoji表情字符是一个unicode编码 length是1或2*/
        NSRange range = [tempString rangeOfComposedCharacterSequencesForRange:NSMakeRange(i-1, 1)];
        /*截取字串 范围是从开始到计算的最后一个截取字符；
         *subString是tempString截断的前一段
         */
        subString = [tempString substringWithRange:NSMakeRange(0, range.location+range.length)];
        // 获取该字串的size
        subStringSize = [ToolsFunction getSizeFromString:subString withFont:MESSAGE_TEXT_FONT constrainedToSize:maxSize];//[subString sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:maxSize];
        
        // 判断获取的字串是否小于最大行
        if (subStringSize.width + contentRect.origin.x + contentRect.size.width <= textMaxSize.width)
        {         
            /* 获取subString的最后一个字串(符)
             *
             */
            NSRange lastStringRange = [subString rangeOfComposedCharacterSequencesForRange:NSMakeRange([subString length]-1, 1)];
            oneCharacter = [subString substringWithRange:lastStringRange];
            /*判断最后一个字符是否是空格
             *判断tempString切断的后半段字串长是否>1
             */
            if (([oneCharacter isEqualToString:URL_SCHEME_END_SPACE]==NO)&&[tempString substringFromIndex:i].length>1)
            {
                // 取的后半段字串第一个字串(符)
                NSUInteger x = range.location+range.length;
                NSString *afterRangeString = [tempString substringFromIndex:x];
                NSString *firstString = [afterRangeString substringWithRange:[afterRangeString rangeOfComposedCharacterSequenceAtIndex:0]];
                /*
                  取字串(符)的unichar编码
                  emoji表情的字符length在1-2
                  126(~)  -- 27(ESC)用来判断是否是汉字
                 */
                character = [firstString characterAtIndex:0];
                
                if ([firstString isEqualToString:URL_SCHEME_END_SPACE]==NO&&(character>26&&character<127))
                {
                    // 判断后面字串第一个字符是否是汉字或者是空格，如果都不满足，则说明该行是字母，那么对前面一行从后向前查找第一个空格来标识上一行的结束
                    for (int j = (int)[subString length]; j > 0; j--)
                    {
                        NSRange spaceSubStringRange = [subString rangeOfComposedCharacterSequencesForRange:NSMakeRange(j-1, 1)];
                        NSString *spaceSubString = [subString substringWithRange:spaceSubStringRange];
                        if ([spaceSubString isEqualToString:URL_SCHEME_END_SPACE])
                        {
                            i = j;
                            
                            // 获取空格前面的字串
                            subString = [subString substringToIndex: j];
                            break;
                        }
                    }
                }
            }
            
            // 获取后面的字串
            tempString = [tempString substringFromIndex:i];
            
            // 分析当前一行的文本字符串中是否有超链接，如果存在，则按照超链接的方法绘制，以及保存超链接的URL和相应的Rect，还有判断该URL是否分行
            contentRect = [self analysisLineText:subString
                                 currentPosition:&contentRect
                                         maxSize:textMaxSize
                                     lastLineUrl:&isHaveLastUrlString
                                  withBackString:tempString];
            
            // 获取查找字串的位置
            i = (int)[tempString length];
            
            //  如果后面还有字串的话，再回行
            if ([tempString length] > 0) {
                contentRect = CGRectMake(0, contentRect.origin.y + MESSAGE_LINE_HEIGHT, 0, 0);
            }
            continue;
        }
        else
        {
            BOOL isChangeLine = NO;
            
            // 算到最后一个字符，还大于最大宽度，则回行绘制
            if ([subString length]==2)
            {
                // 以下针对emoji表情判断
                const unichar hs = [subString characterAtIndex:0];
                if (0xd800 <= hs && hs <= 0xdbff)
                {
                    const unichar ls = [subString characterAtIndex:1];
                    const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                    if (0x1d000 <= uc && uc <= 0x1f77f)
                    {
                        isChangeLine = YES;
                    }
                }
                else
                {
                    const unichar ls = [subString characterAtIndex:1];
                    if (ls == 0x20e3)
                    {
                        isChangeLine = YES;
                    }
                }
            }
            else if([subString length] == 1)
            {
                // 包含一个字符长为1的字符或emoji表情
                // non surrogate
                const unichar hs = [subString characterAtIndex:0];
                if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b)
                {
                    isChangeLine = YES;
                }
                else if (0x2B05 <= hs && hs <= 0x2b07)
                {
                    isChangeLine = YES;
                }
                else if (0x2934 <= hs && hs <= 0x2935)
                {
                    isChangeLine = YES;
                }
                else if (0x3297 <= hs && hs <= 0x3299)
                {
                    isChangeLine = YES;
                }
                else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a )
                {
                    isChangeLine = YES;
                }
                else
                {
                    isChangeLine = YES;
                }
            }
            
            // 是否需要换行
            if (isChangeLine)
            {
                contentRect = CGRectMake(0, contentRect.origin.y + MESSAGE_LINE_HEIGHT, 0, 0);
                i = (int)[tempString length];
                continue;
            }
        }
        i = (int)range.location;
    }
    
    return contentRect;
}

// 绘制文本中的表情图标
- (CGRect)drawEmoticonImage:(NSString *)stringImage currentPosition:(CGRect)contentRect maxSize:(CGSize)textMaxSize
{
    UIImage *imageEmoticon = [UIImage imageNamed:stringImage];
    CGSize imageSize = CGSizeMake(imageEmoticon.size.width/imageEmoticon.scale, imageEmoticon.size.height/imageEmoticon.scale);
    
    // 判断表情图标宽度是否超过(<=)最大尺寸的宽度，如果超过则换行绘制
    if ((contentRect.origin.x + contentRect.size.width + imageSize.height) <= textMaxSize.width) {
        contentRect = CGRectMake(contentRect.origin.x + contentRect.size.width,
                                 contentRect.origin.y,
                                 imageSize.width,
                                 imageSize.height);
    }
    else {
        contentRect = CGRectMake(0,
                                 contentRect.origin.y + MESSAGE_LINE_HEIGHT,
                                 imageSize.width,
                                 imageSize.height);
    }
    //NSLog(@"drawEmoticonImage stringImage = %@, contentRect = %@", stringImage, NSStringFromCGRect(contentRect));
    
    // 绘制表情图标
    [imageEmoticon drawInRect:contentRect];
    
    // 向右定位下一个文本的文本X位置
    contentRect = CGRectMake(contentRect.origin.x + contentRect.size.width,
                             contentRect.origin.y,
                             0, 0);
    
    return contentRect;
}


#pragma mark -
#pragma mark Detector HyperLinks & Draw Sub Text Method

// 分析当前一行的文本字符串中是否有超链接，如果存在，则按照超链接的方法绘制，以及保存超链接的URL和相应的Rect，还有判断该URL是否分行
- (CGRect)analysisLineText:(NSString *)lineString
           currentPosition:(CGRect *)contentRect
                   maxSize:(CGSize)textMaxSize
               lastLineUrl:(BOOL *)isHaveLastLineUrlString
            withBackString:(NSString *)backString
{
    // 当前行有上一行的url字串
    if (*isHaveLastLineUrlString)
    {
        HyperlinkData *hyperlinkData = [[HyperlinkData alloc] init];
        if (hyperlinkDataMutabeArray && [hyperlinkDataMutabeArray count] > 0) {
            HyperlinkData *lastHyperlinkData = [hyperlinkDataMutabeArray lastObject];
            hyperlinkData.wholeUrlString = lastHyperlinkData.wholeUrlString;
            hyperlinkData.urlID = lastHyperlinkData.urlID;
        }
        
        NSRange range;
        // 查找当前行中的第一个空格
        range = [lineString rangeOfString:URL_SCHEME_END_SPACE];
        if (range.length > 0)
        {
            // 找到空格，有可能还存在其它的字串
            // 获取上一行没有绘制完的url
            NSString *lastLineUrl = [lineString substringToIndex: range.location];
            
            // 绘制字串
            *contentRect = [self drawSubString:lastLineUrl currentPosition:contentRect stringMaxSize:textMaxSize isDrawHyperlinks:YES];
            *isHaveLastLineUrlString = NO;
            
            //  保存当前rect的url字串
            hyperlinkData.currentRectUrlString = lastLineUrl;
            hyperlinkData.urlRect = *contentRect;
            [hyperlinkDataMutabeArray addObject: hyperlinkData];
            
            // 获取剩下的url
            lineString = [lineString substringFromIndex: range.location];
        }
        else
        {
            // 没有找到空格，说明当前行都是url
            // 绘制上一行没有绘制完的url
            *contentRect = [self drawSubString:lineString currentPosition:contentRect stringMaxSize:textMaxSize isDrawHyperlinks:YES];
            *isHaveLastLineUrlString = YES;
            
            //  保存当前rect的url字串
            hyperlinkData.currentRectUrlString = lineString;
            hyperlinkData.urlRect = *contentRect;
            [hyperlinkDataMutabeArray addObject: hyperlinkData];
            
            return (*contentRect);
        }        
    }
    
    // 绘制超链接文本字符串
    *contentRect = [self detectorHyperLinksInString:lineString
                                    currentPosition:contentRect
                                            maxSize:textMaxSize
                                        lastLineUrl:isHaveLastLineUrlString
                                     withBackString:backString];
    
    return (*contentRect);
}

// 检测超链接文本字符串
- (CGRect)detectorHyperLinksInString:(NSString *)lineString
                     currentPosition:(CGRect *)contentRect
                             maxSize:(CGSize)textMaxSize
                         lastLineUrl:(BOOL *)isHaveLastLineUrlString
                      withBackString:(NSString *)backString
{
    BOOL isExistUrl = NO;
    NSString * urlKeyString = nil;
    
    // 找一行中是否存在URL链接
    for (int keyIndex = 0; keyIndex < [self.urlSchemeArray count]; keyIndex++)
    {
        urlKeyString = [self.urlSchemeArray objectAtIndex:keyIndex];
        // 判断一行中字串是否有指定的url，并且把该字符串绘制出来
        isExistUrl = [self searchUrlInOneLineString:lineString
                                   isContainUrlType:urlKeyString
                                      andDrawInRect:contentRect
                                      stringMaxSize:textMaxSize
                                        lastLineUrl:isHaveLastLineUrlString
                                     withBackString:backString];
        
        if (isExistUrl == YES) {
            break;
        }
    }
    
    // 上面的循环没有找到URL则继续找第二行的
    if (isExistUrl == NO && backString && [backString length] > 0)
    {
        for (int keyIndex = 0; keyIndex < [self.urlSchemeArray count]; keyIndex++) {
            
            urlKeyString = [self.urlSchemeArray objectAtIndex:keyIndex];
            
            // 判断两行中字串中否有指定的url，即（当前行的尾部和下一行的开始部分组成一个url头）并且把该字符串绘制出来
            isExistUrl = [self searchUrlInTwoLineString:lineString
                                       isContainUrlType:urlKeyString
                                          andDrawInRect:contentRect
                                          stringMaxSize:textMaxSize
                                            lastLineUrl:isHaveLastLineUrlString
                                         withBackString:backString];
            
            if (isExistUrl == YES) {
                break;
            }
        }
    }
    
    if (isExistUrl == NO)
    {
        // 在一行中没有http也没有www
        *contentRect = [self drawSubString:lineString currentPosition:contentRect stringMaxSize:textMaxSize isDrawHyperlinks:NO];
    }
    
    return *contentRect;
}

// 判断一行中字串是否有指定的url，并且把该字符串绘制出来
- (BOOL)searchUrlInOneLineString:(NSString *)stringText
                isContainUrlType:(NSString *)urlType
                   andDrawInRect:(CGRect *)drawRect
                   stringMaxSize:(CGSize)stringMaxSize
                     lastLineUrl:(BOOL *)isHaveLastLineUrlString
                  withBackString:(NSString *)backString
{
    BOOL flag = NO;
    
    NSRange rulRange;
    rulRange = [[stringText lowercaseString] rangeOfString:urlType];
    if (rulRange.length > 0)
    {
        // 获取整个url地址
        NSString *wholeString = [[NSString alloc] initWithFormat:@"%@%@", stringText, backString];
        NSString *wholeUrlStirng = [self getUrlStringFromString:wholeString withUrlType:urlType];
        
        HyperlinkData *hyperlinkData = [[HyperlinkData alloc] init];
        hyperlinkData.wholeUrlString = wholeUrlStirng;
        
        // url
        NSString *urlString = [stringText substringFromIndex:rulRange.location];
        
        // 判断检测到的url是否能够检测到空格
        NSRange spaceRange = [urlString rangeOfString:URL_SCHEME_END_SPACE];
        NSString *footerString = nil;
        if (spaceRange.length > 0)
        {
            footerString = [urlString substringFromIndex: spaceRange.location];
            urlString = [urlString substringToIndex: spaceRange.location];
        }
        NSString *headerString = [stringText substringToIndex: rulRange.location];
        
        // 绘制URL前面的字串（如果存在）
        if (headerString && [headerString length] > 0)
        {
            // 绘制字串
            *drawRect = [self drawSubString:headerString currentPosition:drawRect stringMaxSize:stringMaxSize isDrawHyperlinks:NO];
        }
        
        // 绘制URL字串
        if (urlString && [urlString length] > 0)
        {
            // 绘制字串
            *drawRect = [self drawSubString:urlString currentPosition:drawRect stringMaxSize:stringMaxSize isDrawHyperlinks:YES];
            
            //  保存当前rect的url字串
            hyperlinkData.currentRectUrlString = urlString;
            hyperlinkData.urlRect = *drawRect;
        }
        
        // 绘制URL后面的字串（如果存在）
        if (footerString && [footerString length] > 0)
        {
            // 绘制字串
            *drawRect = [self drawSubString:footerString currentPosition:drawRect stringMaxSize:stringMaxSize isDrawHyperlinks:NO];
        }
        else
        {
            // 获取截取字串的最后一个字串
            NSString *oneCharacter = [stringText substringFromIndex:[stringText length] - 1];
            if ([oneCharacter isEqualToString:URL_SCHEME_END_SPACE] == NO  && [backString length] > 0 && [[backString substringToIndex: 1] isEqualToString: URL_SCHEME_END_SPACE] == NO)
            {
                *isHaveLastLineUrlString = YES;
            }
        }        
        
        // 保存超链接数据
        [hyperlinkDataMutabeArray addObject: hyperlinkData];
        
        // 说明存在指定的url连接
        flag = YES;
    }
    return flag;
}

// 判断两行中字串中否有指定的url，即（当前行的尾部和下一行的开始部分组成一个url头）并且把该字符串绘制出来
- (BOOL)searchUrlInTwoLineString:(NSString *)stringText
                isContainUrlType:(NSString *)urlType
                   andDrawInRect:(CGRect *)drawRect
                   stringMaxSize:(CGSize)stringMaxSize
                     lastLineUrl:(BOOL *)isHaveLastLineUrlString
                  withBackString:(NSString *)backString
{
    BOOL flag = NO;
    NSMutableString *tempString = [NSMutableString stringWithString: stringText];
    [tempString appendString: backString];
    
    // 查找url
    NSRange httpRange = [[tempString lowercaseString] rangeOfString:urlType];
    if (httpRange.length > 0 && httpRange.location < [stringText length])
    {
        // 获取整个url地址
        NSString *wholeString = [[NSString alloc] initWithFormat:@"%@%@", stringText, backString];
        NSString *wholeUrlStirng = [self getUrlStringFromString:wholeString withUrlType:urlType];
        
        HyperlinkData *hyperlinkData = [[HyperlinkData alloc] init];
        hyperlinkData.wholeUrlString = wholeUrlStirng;
        
        // 在当前行中找到了url
        // url前面字串
        NSString *headerHttpUrlString = [stringText substringToIndex: httpRange.location];
        if (headerHttpUrlString && [headerHttpUrlString length] > 0)
        {
            // 绘制字串
            *drawRect = [self drawSubString:headerHttpUrlString currentPosition:drawRect stringMaxSize:stringMaxSize isDrawHyperlinks:NO];
        }
        
        // 获取url字串
        NSString *httpUrlString = [stringText substringFromIndex: httpRange.location];
        if (httpUrlString && [httpUrlString length] > 0)
        {
            // 绘制url字串
            *drawRect = [self drawSubString:httpUrlString currentPosition:drawRect stringMaxSize:stringMaxSize isDrawHyperlinks:YES];
            
            //  保存当前rect的url字串
            hyperlinkData.currentRectUrlString = httpUrlString;
            hyperlinkData.urlRect = *drawRect;
        }
        
        // 保存超链接数据
        [hyperlinkDataMutabeArray addObject: hyperlinkData];
        
        // 说明下一行还有url的字串
        *isHaveLastLineUrlString = YES;
        flag = YES;
    }
    return flag;
}

// 绘制字串文本
- (CGRect)drawSubString:(NSString *)stringText
        currentPosition:(CGRect *)drawRect
          stringMaxSize:(CGSize)stringMaxSize
       isDrawHyperlinks:(BOOL)isDrawHyperlinks
{
    CGSize textSize = [ToolsFunction getSizeFromString:stringText withFont:MESSAGE_TEXT_FONT constrainedToSize:stringMaxSize];//[stringText sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:stringMaxSize];
    (*drawRect) = CGRectMake((*drawRect).origin.x + (*drawRect).size.width, (*drawRect).origin.y, textSize.width, textSize.height);
    
    if (isDrawHyperlinks)
    {
        // 绘制url的下划线
        [self.linkTextColor set];
        [self drawUnderlineHyperlinks: (*drawRect)];
        // 设置url文本的颜色
        [self.linkTextColor set];
    }
    else
    {
        // 设置默认文本的颜色
        [self.textColor set];
    }
    
    // 绘制文本
    //[stringText drawInRect:(*drawRect) withFont:MESSAGE_TEXT_FONT];
    [ToolsFunction drawString:stringText inRect:(*drawRect) withFont: MESSAGE_TEXT_FONT];
    return (*drawRect);
}

// 绘制超链接的下划线
- (void)drawUnderlineHyperlinks:(CGRect)underlineRect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(contextRef, 1.2);
    CGContextSetFillColorWithColor(contextRef, self.linkTextColor.CGColor);
	CGContextMoveToPoint(contextRef, underlineRect.origin.x, underlineRect.origin.y + underlineRect.size.height - 1);
    CGContextAddLineToPoint(contextRef, underlineRect.origin.x + underlineRect.size.width, underlineRect.origin.y + underlineRect.size.height - 1);
    CGContextStrokePath(contextRef);
}

// 绘制选中超链接的背景颜色
- (void)drawSelectedHyperlinksBackgroundColor
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(contextRef, self.highlightHyperLinkBGColor.CGColor);
    if (drawHyperlinkRectMutableArray && [drawHyperlinkRectMutableArray count] > 0)
    {
        CGRect drawRect;
        for (int i = 0; i < [drawHyperlinkRectMutableArray count]; i++) {
            drawRect = [[drawHyperlinkRectMutableArray objectAtIndex:i] CGRectValue];
            CGPathRef pathRef = [self newPathForRoundedRect:drawRect radius:2.0];
            CGContextAddPath(contextRef, pathRef);
            CGContextFillPath(contextRef);
            CGPathRelease(pathRef);
        }
    }
}

- (CGPathRef)newPathForRoundedRect:(CGRect)rect radius:(CGFloat)radius
{
	CGMutablePathRef retPath = CGPathCreateMutable();
	
	CGRect innerRect = CGRectInset(rect, radius, radius);
	
	CGFloat inside_right = innerRect.origin.x + innerRect.size.width;
	CGFloat outside_right = rect.origin.x + rect.size.width;
	CGFloat inside_bottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outside_bottom = rect.origin.y + rect.size.height;
	
	CGFloat inside_top = innerRect.origin.y;
	CGFloat outside_top = rect.origin.y;
	CGFloat outside_left = rect.origin.x;
	
	CGPathMoveToPoint(retPath, NULL, innerRect.origin.x, outside_top);
	
	CGPathAddLineToPoint(retPath, NULL, inside_right, outside_top);
	CGPathAddArcToPoint(retPath, NULL, outside_right, outside_top, outside_right, inside_top, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_right, inside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_right, outside_bottom, inside_right, outside_bottom, radius);
	
	CGPathAddLineToPoint(retPath, NULL, innerRect.origin.x, outside_bottom);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_bottom, outside_left, inside_bottom, radius);
	CGPathAddLineToPoint(retPath, NULL, outside_left, inside_top);
	CGPathAddArcToPoint(retPath, NULL,  outside_left, outside_top, innerRect.origin.x, outside_top, radius);
	
	CGPathCloseSubpath(retPath);
	
	return retPath;
}


#pragma mark -
#pragma mark Custom Method

- (void)resetSelectHyperlinkArray {
    [drawHyperlinkRectMutableArray removeAllObjects];
    [hyperlinkDataMutabeArray removeAllObjects];
    
    self.selectedUrl = nil;
}

// 如果存在url，则查找整个url字串 在外面relase返回值
- (NSString *)getUrlStringFromString:(NSString *)textString withUrlType:(NSString *)urlType
{
    NSString *urlString = nil;
    NSRange urlRange = [[textString lowercaseString] rangeOfString:urlType];
    if (urlRange.length > 0)
    {
        NSString *tempUrlString = [textString substringFromIndex: urlRange.location];
        // 查找空格结束的url
        NSRange spaceRange = [tempUrlString rangeOfString: URL_SCHEME_END_SPACE];
        if (spaceRange.length > 0)
        {
            urlString = [[NSString alloc] initWithFormat:@"%@", [tempUrlString substringToIndex: spaceRange.location]];
        }
        else
        {
            // 如果既没有空格结束，则直接赋值
            urlString = [[NSString alloc] initWithFormat:@"%@", tempUrlString];
        }
    }
    return urlString;
}

// 查找是否选中了url，如果选中则需要获取该url的rect
- (void)detectUrlSelectedInPoint:(CGPoint)selectPoint
{
    self.selectedUrl = nil;
    
    if (drawHyperlinkRectMutableArray) {
        [drawHyperlinkRectMutableArray removeAllObjects];
    }
    
    if (hyperlinkDataMutabeArray && [hyperlinkDataMutabeArray count] > 0)
    {
        HyperlinkData *hyperlindData = nil;
        NSString *urlID = nil;
        // 通过点击的坐标点，查找该区域有没有url
        for (int i = 0; i < [hyperlinkDataMutabeArray count]; i++)
        {
            hyperlindData = [hyperlinkDataMutabeArray objectAtIndex: i];
            if (CGRectContainsPoint(hyperlindData.urlRect, selectPoint))
            {
                self.selectedUrl =  hyperlindData.wholeUrlString;
                urlID = hyperlindData.urlID;
                break;
            }
        }
        
        if (self.selectedUrl)
        {
            // 点中了URL链接，则将全部URL对象的背景变为选中状态
            NSValue *urlRectValue = nil;
            for (int i = 0; i < [hyperlinkDataMutabeArray count]; i++)
            {
                hyperlindData = [hyperlinkDataMutabeArray objectAtIndex: i];
                if ([urlID isEqualToString: hyperlindData.urlID])
                {
                    urlRectValue = [NSValue valueWithCGRect: hyperlindData.urlRect];
                    [drawHyperlinkRectMutableArray addObject: urlRectValue];
                    // NSLog(@" ***** hyperlindData.urlRect = %@ ***** ", NSStringFromCGRect(hyperlindData.urlRect));
                }
            }
            [self setNeedsDisplay];
        }
    }
}


#pragma mark -
#pragma mark Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    
    // 检测有没有选中url
    [self detectUrlSelectedInPoint:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
    
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
    
    // 检测有没有选中url
    [self detectUrlSelectedInPoint:location];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.selectedUrl = nil;
    [drawHyperlinkRectMutableArray removeAllObjects];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 打开选中的URL超链接
    if (self.selectedUrl)
    {
        self.selectedUrl = [self.selectedUrl lowercaseString];
        
        // 如果URL开头是"www"，则添加"http://"头
        if ([[self.selectedUrl substringToIndex:[URL_SCHEME_KEY_WWW length]] isEqualToString:URL_SCHEME_KEY_WWW]) {
            self.selectedUrl = [URL_SCHEME_KEY_HTTP stringByAppendingString:self.selectedUrl];
        }
        
        // 将地址做UTF8-URL编码
        self.selectedUrl = [self.selectedUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSLog(@"MMS: touchesEnded - selectedUrl = %@", self.selectedUrl);
        
        NSURL * urlPath = [NSURL URLWithString:self.selectedUrl];
        NSLog(@"MMS: touchesEnded - urlPath = %@, canOpenURL = %d", urlPath, [[UIApplication sharedApplication] canOpenURL:urlPath]);
        
        // 是否能够打开URL地址
        if ([[UIApplication sharedApplication] canOpenURL:urlPath])
        {
            [[UIApplication sharedApplication] openURL:urlPath];
        }
    }
    
    self.selectedUrl = nil;
    [drawHyperlinkRectMutableArray removeAllObjects];
    
    [self setNeedsDisplay];
}

@end
