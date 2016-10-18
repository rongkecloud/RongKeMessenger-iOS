//
//  MeetingRoomViewController.m
//  RKCloudMeetingTest
//
//  Created by 程荣刚 on 15/8/7.
//  Copyright (c) 2015年 rongkecloud. All rights reserved.
//

#import "MeetingRoomViewController.h"
#import "MemberDetailCollectionViewCell.h"
#import "HeaderCollectionReusableView.h"

#import "Definition.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"
#import "CustomAvatarImageView.h"
#import "DatabaseManager+FriendInfoTable.h"
#import "FriendInfoTable.h"
#import "FriendDetailViewController.h"
#import "PersonalDetailViewController.h"

@interface MeetingRoomViewController ()<CustomAvatarImageViewDelegate>
{
    NSLock *meetingMembersLock;
}

@property (strong, nonatomic) NSDictionary *meetingMembersDic;

@property (weak, nonatomic) IBOutlet UICollectionView *meetingMembersCollectionView; // 多人会议集合视图

@property (weak, nonatomic) IBOutlet UIButton *handsFreeButton; // 免提按钮
@property (weak, nonatomic) IBOutlet UIButton *handUpButton; // 挂断按钮
@property (weak, nonatomic) IBOutlet UIButton *muteButton; // 静音按钮

@property (weak, nonatomic) IBOutlet UILabel *handFreeLabel; // 免提标签
@property (weak, nonatomic) IBOutlet UILabel *muteLabel; // 静音标签

@property (nonatomic, strong) NSMutableArray *meetingMembersArray; // 排好顺序的字典
@property (strong, nonatomic) UILabel *callDurationLabel; // 通话时长的label
@property (nonatomic, strong) UILabel *memberCountLabel; // 会议人数的label

@property (assign, nonatomic) float cellWeight; // collectionView中 单个cell宽度
@property (assign, nonatomic) float cellHeight; // collectionView中 单个cell高度
@property (strong, nonatomic) NSTimer *talkingTimeTimer; // 计时器对象
@property (copy, nonatomic) NSString *durationTime; // 持续时间


@end

@implementation MeetingRoomViewController
{
    BOOL isMute; // 静音
    BOOL isHandsFree; // 免提
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        // 对加入会议时间进行赋值
        if ([AppDelegate appDelegate].meetingManager.callSecondsTimeInterval != 0)
        {
            long callDuration = [[NSDate date] timeIntervalSince1970] - [AppDelegate appDelegate].meetingManager.callSecondsTimeInterval;
            self.durationTime = [ToolsFunction stringFormatCallDuration:callDuration];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Jacky.Chen.2016.02.29.Add,多人语音页面隐藏顶部 navigationBar
//    self.navigationController.navigationBarHidden = YES;
    // 如果不是首次进入会议 启动计时器 显示计时
    if ([AppDelegate appDelegate].meetingManager.isFirstInMeeting == NO)
    {
        // 启动计时
        [self startDetectTalkingTime];
    }
    
    self.title = NSLocalizedString(@"RKCLOUD_MEETING_MSG_AUDIO_CALL", nil);

    isMute = NO; // 默认不静音
    isHandsFree = NO; // 关闭免提
    
    meetingMembersLock = [[NSLock alloc] init];
    
    // 设置按钮类型
    [self setSelectButtonAppearenceMode];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.meetingMembersArray count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIndeMember = @"MemberDetailCollectionViewCell";
    
    //通过Nib生成cell，然后注册 Nib的view需要继承 UICollectionViewCell
    [self.meetingMembersCollectionView registerNib:[UINib nibWithNibName:@"MemberDetailCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellIndeMember];
    
    //重用cell
    MemberDetailCollectionViewCell *cellMember = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndeMember forIndexPath:indexPath];

    if ([self.meetingMembersArray count] > 0)
    {
        RKCloudMeetingUserObject *meetingUserObject = [self.meetingMembersArray objectAtIndex:indexPath.row];
        
        // 显示会议人员名字
        if ([meetingUserObject.attendeeAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
        {
            cellMember.memberNameLabel.text = [[AppDelegate appDelegate].userInfoManager displayPersonalHighGradeName];
        } else {
            cellMember.memberNameLabel.text = [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:meetingUserObject.attendeeAccount];
        }
        
        // 显示头像
        [cellMember.memberAvatarImageView setUserAvatarImageByUserId:meetingUserObject.attendeeAccount];
        cellMember.memberAvatarImageView.delegate = self;
        
        if (meetingUserObject.meetingConfMemberState == MEETING_USER_STATE_MUTE)
        {
            cellMember.avatarMuteImageView.image = [UIImage imageNamed:@"meeting_avatar_mute"];
            
            if ([meetingUserObject.attendeeAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
            {
                isMute = YES;
                self.muteLabel.text = NSLocalizedString(@"TITLE_MUTE", nil);
                self.muteLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:164.0/255.0 blue:220.0/255.0 alpha:1.0];
                [self.muteButton setImage:[UIImage imageNamed:@"call_opration_button_mute_pressed"] forState:UIControlStateNormal];
            }
        }
        else {
            cellMember.avatarMuteImageView.image = [UIImage imageNamed:@"meeting_avatar_unmute"];
            
            if ([meetingUserObject.attendeeAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
            {
                isMute = NO;
                self.muteLabel.text = NSLocalizedString(@"TITLE_MUTE", nil);
                self.muteLabel.textColor = [UIColor whiteColor];
                [self.muteButton setImage:[UIImage imageNamed:@"call_opration_button_mute_nor"] forState:UIControlStateNormal];
            }
        }
    }
    
    return cellMember;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath

{
    UICollectionReusableView *reusableView = nil;
    
    // 设置header
    if (kind == UICollectionElementKindSectionHeader){
        
        static NSString *cellIndeHeader = @"HeaderCollectionReusableView";
        
        [self.meetingMembersCollectionView registerNib:[UINib nibWithNibName:@"HeaderCollectionReusableView" bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellIndeHeader];
        
        HeaderCollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:cellIndeHeader forIndexPath:indexPath];
        
        // 设置时间 label
        self.callDurationLabel = (UILabel *)[headerView viewWithTag:MEETING_HEADER_LABEL_TAG];
        if (self.callDurationLabel == nil)
        {
            self.callDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 3, UISCREEN_BOUNDS_SIZE.width, 21)];
            self.callDurationLabel.textColor = [UIColor whiteColor];
            self.callDurationLabel.font = [UIFont systemFontOfSize:14];
            self.callDurationLabel.textAlignment = NSTextAlignmentCenter;
            self.callDurationLabel.tag = MEETING_HEADER_LABEL_TAG;
            [headerView addSubview:self.callDurationLabel];
        }
        
        // 设置人数 label
        self.memberCountLabel = (UILabel *)[headerView viewWithTag:MEETING_HEADER_COUNT_LABEL_TAG];
        if (self.memberCountLabel == nil)
        {
            self.memberCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.callDurationLabel.frame.origin.x, CGRectGetMaxY(self.callDurationLabel.frame)+2, self.callDurationLabel.frame.size.width, self.callDurationLabel.frame.size.height)];
            self.memberCountLabel.textColor = [UIColor whiteColor];
            self.memberCountLabel.textAlignment = NSTextAlignmentCenter;
            self.memberCountLabel.font = [UIFont systemFontOfSize:14];
            self.memberCountLabel.tag = MEETING_HEADER_COUNT_LABEL_TAG;
            [headerView addSubview:self.memberCountLabel];
        }
        
        if ([self.meetingMembersDic count] >= 2)
        {
            self.memberCountLabel.text = [NSString stringWithFormat:@"(%lu人)", (unsigned long)[self.meetingMembersDic count]];
        } else {
            self.memberCountLabel.text = @"";
        }
        
        reusableView = headerView;
    }
    return reusableView;
}


#pragma mark - UICollectionViewDelegateFlowLayout

//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.cellWeight = UISCREEN_BOUNDS_SIZE.width/5;
    self.cellHeight = UISCREEN_BOUNDS_SIZE.width/5;
    
    if (UISCREEN_BOUNDS_SIZE.width/5 < 70.0)
    {
        self.cellWeight = 70.0;
        self.cellHeight = 70.0;
    }
    
    return CGSizeMake(self.cellWeight, self.cellHeight);
}

//定义每个UICollectionView 的 margin
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    float upInsets = 5.0;
    float lefInsets = 10.0;
    float downInsets = 5.0;
    float rightInsets = 10.0;
    
    if (UISCREEN_BOUNDS_SIZE.width/5 < 70.0)
    {
        lefInsets = 5.0;
        rightInsets = 5.0;
    }
    
    return UIEdgeInsetsMake(upInsets, lefInsets, downInsets, rightInsets);
}


#pragma mark - UICollectionViewDelegate


//返回这个UICollectionView是否可以被选择
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}


#pragma mark - Custom Method

/**
 *  会议信息有同步，包括会议本身的信息和会议参与者信息
 */
- (void)updateUserMeetingInfo:(NSDictionary *)meetingUserAccountTomeetingUserObjectDict
{
    if ([meetingUserAccountTomeetingUserObjectDict count] == 0)
    {
        return;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // 本地的会议成员
        NSArray *arrayOriginalMembers = [self.meetingMembersDic allKeys];
        // 服务器最新成员
        NSArray *arrayUpdateMembers = [meetingUserAccountTomeetingUserObjectDict allKeys];
        
        // 本地数据小于服务器返回数据 有会议成员加入
        if ([arrayOriginalMembers count] < [arrayUpdateMembers count])
        {
            // 遍历服务器返回数据
            for (NSString *userAccount in arrayUpdateMembers)
            {
                
                // 若本地数据不包含服务器返回数据 提示有人加入会议室
                if ([arrayOriginalMembers containsObject:userAccount] == NO)
                {
                    if ([userAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
                    {
                        // 判断是否显示 “我加入会议” 的提示语
                        if ([AppDelegate appDelegate].meetingManager.isFirstInMeeting == YES)
                        {
                            [AppDelegate appDelegate].meetingManager.isFirstInMeeting = NO;
                            [UIAlertView showAutoHidePromptView:@"我加入会议" background:nil showTime:TIMER_PROMPT_MEETING_ROOM];
                        }
                    }
                    else
                    {
                        RKCloudMeetingUserObject *rkCloudMeetingmeetingUserObject = [meetingUserAccountTomeetingUserObjectDict objectForKey:userAccount];
                        
                        // 其他会议人员 根据加入状态 显示提示语
                        if (rkCloudMeetingmeetingUserObject.meetingConfMemberState == MEETING_USER_STATE_IN)
                        {
                            [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"%@加入会议", [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:userAccount]] background:nil showTime:TIMER_PROMPT_MEETING_ROOM];
                        }
                    }
                }
            }
        }
        // 本地数据大于服务器返回数据 有会议成员退出
        else if ([arrayOriginalMembers count] > [arrayUpdateMembers count])
        {
            
            // 遍历本地数据
            for (NSString *userAccount in arrayOriginalMembers)
            {
                // 若服务器返回数据不包含本地数据 提示有人退出会议室
                if (![arrayUpdateMembers containsObject:userAccount] && ![userAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"%@退出会议", [[AppDelegate appDelegate].contactManager displayFriendHighGradeName:userAccount]] background:nil showTime:TIMER_PROMPT_MEETING_ROOM];
                    });
                }
            }
        }
        
        // 参与者信息字典
        self.meetingMembersDic = [[NSDictionary alloc] initWithDictionary:meetingUserAccountTomeetingUserObjectDict];
        
        // 根据用户状态 进行数据筛选
        NSMutableArray *arraySiftMembers = [NSMutableArray arrayWithArray:[self.meetingMembersDic allValues]];
        NSMutableArray *arrayMembers = [NSMutableArray array];
        
        // 剔除已退出成员
        for (RKCloudMeetingUserObject *meetingUserObject in arraySiftMembers)
        {
            if (meetingUserObject.meetingConfMemberState != MEETING_USER_STATE_OUT)
            {
                [arrayMembers addObject:meetingUserObject];
            }
        }
        
        // 将自己放在会议首位
        for (RKCloudMeetingUserObject *meetingUserObject in arrayMembers)
        {
            if ([meetingUserObject.attendeeAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
            {
                [arrayMembers removeObject:meetingUserObject];
                [arrayMembers insertObject:meetingUserObject atIndex:0];
                break;
            }
        }
        
        self.meetingMembersArray = arrayMembers;
        
        [self.meetingMembersCollectionView reloadData];
    });
}

/**
 *  设置按钮类型
 */
- (void)setSelectButtonAppearenceMode
{
    self.handFreeLabel.text = NSLocalizedString(@"TITLE_HANDS_FREE", nil);
    [self.handsFreeButton setImage:[UIImage imageNamed:@"call_opration_button_hands_free_normal"] forState:UIControlStateNormal];
    
    [self.handsFreeButton addTarget:self action:@selector(touchAnswerOrHandsFreeButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.handUpButton addTarget:self action:@selector(touchHandUpButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.handUpButton setImage:[UIImage imageNamed:@"call_button_hangup_normal"] forState:UIControlStateNormal];
    
    self.muteLabel.text = NSLocalizedString(@"TITLE_MUTE", nil);
    [self.muteButton setImage:[UIImage imageNamed:@"call_opration_button_mute_nor"] forState:UIControlStateNormal];
    [self.muteButton addTarget:self action:@selector(touchMuteButton:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark - Touch Button Action

// 挂断
- (void)touchHandUpButton:(id)sender
{
    [self asyncHandUpMeeting];
}

- (void)asyncHandUpMeeting
{
    BOOL isHangUp = [[AppDelegate appDelegate].meetingManager asyncHandUpMeeting];
    
    if (isHangUp)
    {
        [self quitMeetingWithReason:MEETING_CONF_NO_REASON];
    }
}

/**
 *  退出会议
 */
- (void)quitMeetingWithReason:(NSInteger)reason
{
    if (self.durationTime == nil)
    {
        self.durationTime = @"00:00";
    }
    
    if (reason == MEETING_CONF_DIAL_TIMEOUT)
    {
        [UIAlertView showAutoHidePromptView:@"进入多人语音超时，请稍后再试" background:nil showTime:1.5];
    } else {
        [UIAlertView showAutoHidePromptView:[NSString stringWithFormat:@"我退出了多人语音，通话时长：%@", self.durationTime] background:nil showTime:1.5];
    }
    
    NSLog(@"MEETING－ROOM： quitMeeting success");
    
    // 添加本地消息
    LocalMessage *callLocalMessage = [LocalMessage buildTipMsg:[AppDelegate appDelegate].meetingManager.currentSessionObject.sessionID withMsgContent:nil forSenderName:[AppDelegate appDelegate].userProfilesInfo.userAccount];
    callLocalMessage.textContent = @"PROMPT_QUIT_MEETING_MYSELF";
    [RKCloudChatMessageManager addLocalMsg:callLocalMessage withSessionType:SESSION_GROUP_TYPE];
    
    // 给meetingManager的会话对象赋值 用于本地进出多人语音添加提示语
    [AppDelegate appDelegate].meetingManager.currentSessionObject = nil;
}

// 免提
- (void)touchAnswerOrHandsFreeButton:(id)sender
{
    if (isHandsFree == NO)
    {
        isHandsFree = YES;
        self.handFreeLabel.text = NSLocalizedString(@"TITLE_HANDS_FREE", nil);
        self.handFreeLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:164.0/255.0 blue:220.0/255.0 alpha:1.0];
        [self.handsFreeButton setImage:[UIImage imageNamed:@"call_opration_button_hands_free_pressed"] forState:UIControlStateNormal];
    }else{
        isHandsFree = NO;
        self.handFreeLabel.text = NSLocalizedString(@"TITLE_HANDS_FREE", nil);
        self.handFreeLabel.textColor = [UIColor whiteColor];
        [self.handsFreeButton setImage:[UIImage imageNamed:@"call_opration_button_hands_free_normal"] forState:UIControlStateNormal];
    }

    // 是否开启免提
    [ToolsFunction enableSpeaker:isHandsFree];
    [self.meetingMembersCollectionView reloadData];
}

// 静音
- (void)touchMuteButton:(id)sender
{
    if (isMute == NO)
    {
        isMute = YES;
        self.muteLabel.text = NSLocalizedString(@"TITLE_MUTE", nil);
        self.muteLabel.textColor = [UIColor colorWithRed:0.0/255.0 green:164.0/255.0 blue:220.0/255.0 alpha:1.0];
        [self.muteButton setImage:[UIImage imageNamed:@"call_opration_button_mute_pressed"] forState:UIControlStateNormal];
        
    }else{
        isMute = NO;
        self.muteLabel.text = NSLocalizedString(@"TITLE_MUTE", nil);
        self.muteLabel.textColor = [UIColor whiteColor];
        [self.muteButton setImage:[UIImage imageNamed:@"call_opration_button_mute_nor"] forState:UIControlStateNormal];
    }
    
    int setMute = [RKCloudMeeting mute:isMute];
    
    if (setMute == 0)
    {
        NSLog(@"MEETING－MUTE: mute sucsess");
    }else{
        NSLog(@"MEETING－MUTE: mute sucsess Reason: %d", setMute);
    }
    
    [self.meetingMembersCollectionView reloadData];
}

#pragma mark - Call Time Method

// 启动检测通话时间定时器定时器
- (void)startDetectTalkingTime
{
    // 停止检测通话时间定时器
    [self stopDetectTalkingTime];
    
    NSLog(@"MEETING——TIMER: startDetectTalkingTime");
    
    self.talkingTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                             target:self
                                                           selector:@selector(detectTalkingTime)
                                                           userInfo:nil
                                                            repeats:YES];
}

// 停止检测通话时间定时器定时器
- (void)stopDetectTalkingTime
{
    // 停止检测通话时间定时器
    if(self.talkingTimeTimer != nil)  {
        NSLog(@"MEETING——TIMER: stopDetectTalkingTime");
        
        [self.talkingTimeTimer invalidate];
        self.talkingTimeTimer = nil;
        //NSLog(@"DEBUG: +++++self.talkingTimeTimer invalidate+++++");
    }
}

// 检测通话后通话时间定
- (void)detectTalkingTime
{
    // 格式化通话时长显示格式
    long callDuration = [[NSDate date] timeIntervalSince1970] - [AppDelegate appDelegate].meetingManager.callSecondsTimeInterval;
    self.durationTime = [ToolsFunction stringFormatCallDuration:callDuration];
    self.callDurationLabel.text = self.durationTime;
}


#pragma mark - CustomAvatarImageViewDelegate

- (void)touchAvatarActionForUserAccount:(NSString *)avatarUserAccount
{
    PersonalDetailViewController *vwcPersonalDetail = [[PersonalDetailViewController alloc] initWithNibName:@"PersonalDetailViewController" bundle:nil];
    FriendDetailViewController *vwcFriendDetail = [[FriendDetailViewController alloc] initWithNibName:nil bundle:nil];
    
    // 判断点击头像的类型，个人
    if ([avatarUserAccount isEqualToString:[AppDelegate appDelegate].userProfilesInfo.userAccount])
    {
        [self.navigationController pushViewController:vwcPersonalDetail animated:YES];
    }
    else if ([[AppDelegate appDelegate].contactManager isOwnFriend:avatarUserAccount])
    {
        // 好友
        vwcFriendDetail.personalDetailType = PersonalDetailTypeFriend;
        vwcFriendDetail.userAccount = avatarUserAccount;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
    else
    {
        // 陌生人
        vwcFriendDetail.personalDetailType = PersonalDetailTypeStranger;
        vwcFriendDetail.userAccount = avatarUserAccount;
        
        [self.navigationController pushViewController:vwcFriendDetail animated:YES];
    }
}


@end
