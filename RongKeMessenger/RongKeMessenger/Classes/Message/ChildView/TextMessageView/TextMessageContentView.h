//
//  TextMessageContentView.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextMessageContentView : UIView {
    
@private
    NSMutableArray *hyperlinkDataMutabeArray;      // 保存url数据的array
    NSMutableArray *drawHyperlinkRectMutableArray; // 保存需要绘制url背景色的rect 
}

@property (nonatomic, retain) NSString *textContent;       // 文本内容

@property (nonatomic, retain) NSArray * urlSchemeArray;    // 保存所有链接的数组
@property (nonatomic, copy) NSString * selectedUrl;        // 保存选择的url连接

@property (nonatomic, retain) UIColor * textColor;         // 纯文本的颜色值
@property (nonatomic, retain) UIColor * linkTextColor;     // 超链接的文本颜色值
@property (nonatomic, retain) UIColor * highlightHyperLinkBGColor; // 超链接选中后背景颜色
@property (nonatomic, retain) UIImage * backgroundImage;    // 文本区域图片背景颜色
@property (nonatomic, assign) CGFloat bgImageTopStretchCap;
@property (nonatomic, assign) CGFloat bgImageLeftStretchCap;

// 初始化属性的方法
- (void)resetSelectHyperlinkArray;

@end
