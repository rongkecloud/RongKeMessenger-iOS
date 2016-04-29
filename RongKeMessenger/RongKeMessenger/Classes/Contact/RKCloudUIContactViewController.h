//
//  ContactViewController.h
//  RongKeMessenger
//
//  Created by www.rongkecloud.com on 14/11/4.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RKCloudChat.h"

@interface RKCloudUIContactViewController : UIViewController <RKCloudChatDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDataSource,UITableViewDelegate>{
    
    BOOL isSearchContact;                             // 标志是否正在搜索
}

@property (nonatomic, strong) NSMutableArray *allContactSectionArray;
@property (nonatomic, strong) NSMutableArray *searchContactArray;
@property (nonatomic, strong) NSMutableArray *allSectionTitlesArray;
@property (nonatomic, strong) NSMutableArray *sectionArray;
@property (nonatomic, strong) NSMutableArray *allIndexArray;
@property (nonatomic, strong) NSArray        *allContactsArray;
@property (nonatomic, strong) NSMutableArray *allSelectedArray;

@property (nonatomic, strong) RKCloudChatBaseMessage *currentMessageObject;     // 多媒体短信(用于转发)


@end
