//
//  PersonalDetailViewController.m
//  RongKeMessenger
//
//  Created by 程荣刚 on 15/7/30.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import "PersonalDetailViewController.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "QBImagePickerController.h"
#import "CameraAndPhotoAlbumFunction.h"
#import "ToolsFunction.h"
#import "HttpClientKit.h"
#import "RegularCheckTools.h"
#import "PersonalInfos.h"
#import "CompletePersonalAddressViewController.h"
#import "CompleteOtherInfoViewController.h"
#import "PersonalInfos.h"

#define SETTING_PERSONAL_PERMISSION_ENABLE      @"1" // 需要好友验证
#define SETTING_PERSONAL_PERMISSION_DISABLE     @"2" // 不需要好友验证

#define SETTING_PERSONAL_SEX_MAN                @"1" // 男
#define SETTING_PERSONAL_SEX_WOMAN              @"2" // 女

#define SETTING_PERSONAL_KEY_PERMISSION         @"permission"
#define SETTING_PERSONAL_KEY_SEX                @"sex"

#define PERSONALINFO_SWITCH_PERMISSION_PROMPT_TAG    605

@interface PersonalDetailViewController ()<QBImagePickerControllerDelegate, HttpClientKitDelegate>

@property (weak, nonatomic) IBOutlet UITableView *personalDetailTableView;

@property (assign, nonatomic) AppDelegate *appDelegate;

@property (strong, nonatomic) UIImageView *avatarImageView; // 用户头像
@property (strong, nonatomic) UISwitch *permissionAddSwitch; // 是否允许添加好友开关

@property (assign, nonatomic) CGRect firstFrame; // 图片起初的frame
@property (strong, nonatomic) UIImageView *fullImageView; // 全屏视图

@end

@implementation PersonalDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotification];

    self.title = NSLocalizedString(@"TITLE_PERSONAL_DETAIL", "个人详情");
    self.personalDetailTableView.backgroundColor = COLOR_VIEW_BACKGROUND;
    
    self.appDelegate = [AppDelegate appDelegate];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_UPLOAD_AVATAR_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNum = 0;
    
    switch (section)
    {
        case 3:
        {
            rowNum = 2;
        }
            break;
            
        case 4:
        {
            rowNum = 3;
        }
            break;
            
        default:
            rowNum = 1;
            break;
    }
    
    return rowNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch ([indexPath section])
    {
        case 0:
        {
            static NSString *cellIdenAvatar = @"cellAvatar";
            
            UITableViewCell *cellAvatar = [tableView dequeueReusableCellWithIdentifier:cellIdenAvatar];
            
            if (cellAvatar == nil)
            {
                cellAvatar = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenAvatar];
            }
            
            cellAvatar.textLabel.text = NSLocalizedString(@"TITLE_PERSONAL_AVATAR", "头像");
            
            cellAvatar.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            // 添加显示头像的UIImageView
            
            int floatX = UISCREEN_BOUNDS_SIZE.width - 100;
            
            self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(floatX, 10, 70, 70)];
            self.avatarImageView.tag = SETTING_PERSONAL_DETAIL_IMAGEVIEW;
            self.avatarImageView.layer.cornerRadius = DEFAULT_IMAGE_CORNER_RADIUS;
            self.avatarImageView.layer.masksToBounds = YES;
            
            // 添加图片点击手势
            [self.avatarImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewToZoomingBig:)]];
            
            NSString *stringUserAvatarThumbnailImagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, self.appDelegate.userProfilesInfo.userAccount]];
            
            // 显示小图
            if (![ToolsFunction isFileExistsAtPath:stringUserAvatarThumbnailImagePath])
            {
                self.avatarImageView.image = [UIImage imageNamed:@"default_icon_user_avatar"];
                self.avatarImageView.userInteractionEnabled = NO;
            }else{
                self.avatarImageView.userInteractionEnabled = YES;
                self.avatarImageView.image = [UIImage imageWithContentsOfFile:stringUserAvatarThumbnailImagePath];
            }
            
            UIView *subView = [cell viewWithTag:SETTING_PERSONAL_DETAIL_IMAGEVIEW];
            if (!subView)
            {
                [cellAvatar addSubview:self.avatarImageView];
            }
            
            cell = cellAvatar;
        }
            break;
            
        case 1:
        {
            static NSString *cellIdenAccount = @"cellAccount";
            
            UITableViewCell *cellAccount = [tableView dequeueReusableCellWithIdentifier:cellIdenAccount];
            
            if (cellAccount == nil)
            {
                cellAccount = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenAccount];
            }
            
            cellAccount.textLabel.text = NSLocalizedString(@"TITLE_LOGIN_ACCOUNT", "登录账号");
            cellAccount.detailTextLabel.text = self.appDelegate.userProfilesInfo.userAccount;
            cellAccount.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell = cellAccount;
            
        }
            break;
            
        case 2:
        {
            static NSString *cellIdenAdd = @"cellAdd";
            
            UITableViewCell *cellAdd = [tableView dequeueReusableCellWithIdentifier:cellIdenAdd];
            
            if (cellAdd == nil)
            {
                cellAdd = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdenAdd];
            }
            
            cellAdd.textLabel.text = NSLocalizedString(@"TITLE_ADD_FRIEND_POWER", nil);
            cellAdd.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cellAdd.userInteractionEnabled = YES;
            
            int floatX = UISCREEN_BOUNDS_SIZE.width - 70;
            
            self.permissionAddSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(floatX, 8.5, 70, 27)];
            self.permissionAddSwitch.tag = PERSONALINFO_SWITCH_PERMISSION_PROMPT_TAG;
            self.permissionAddSwitch.on = YES;
            
            if ([self.appDelegate.userProfilesInfo.friendPermission isEqualToString:SETTING_PERSONAL_PERMISSION_ENABLE])
            {
                self.permissionAddSwitch.on = YES;
            }else{
                self.permissionAddSwitch.on = NO;
            }
            
            [self.permissionAddSwitch addTarget:self action:@selector(touchChangeSwitch:) forControlEvents:UIControlEventValueChanged];
            
            // 手动添加的控件 防止多次添加UI重影
            UIView *subView = [cell viewWithTag:PERSONALINFO_SWITCH_PERMISSION_PROMPT_TAG];
            if (!subView) {
                [cellAdd addSubview:self.permissionAddSwitch];
            }
    
            cell = cellAdd;
        }
            break;
            
        case 3:
        {
            static NSString *cellIdenMobileAndEmail = @"cellMobileAndEmail";
            
            UITableViewCell *cellMobileAndEmail = [tableView dequeueReusableCellWithIdentifier:cellIdenMobileAndEmail];
            
            if (cellMobileAndEmail == nil)
            {
                cellMobileAndEmail = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenMobileAndEmail];
            }
            
            cellMobileAndEmail.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch ([indexPath row])
            {
                case 0:
                {
                    cellMobileAndEmail.textLabel.text = NSLocalizedString(@"TITLE_MOBILE_NUM", "手机号码");
                    cellMobileAndEmail.detailTextLabel.text = self.appDelegate.userProfilesInfo.userMobile;
                }
                    break;
                    
                case 1:
                {
                    cellMobileAndEmail.textLabel.text = NSLocalizedString(@"TITLE_EMAIL_ADDRESS", "邮箱");
                    cellMobileAndEmail.detailTextLabel.text = self.appDelegate.userProfilesInfo.userEmail;
                }
                    break;
                    
                default:
                    break;
            }
            
            cell = cellMobileAndEmail;
            break;
        }
            
        case 4:
        {
            static NSString *cellIdenPersonalDetail = @"cellPersonalDetail";
            
            UITableViewCell *cellPersonalDetail = [tableView dequeueReusableCellWithIdentifier:cellIdenPersonalDetail];
            
            if (cellPersonalDetail == nil)
            {
                cellPersonalDetail = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdenPersonalDetail];
            }
            
            cellPersonalDetail.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            switch ([indexPath row])
            {
                case 0:
                {
                    cellPersonalDetail.textLabel.text = NSLocalizedString(@"TITLE_NAME", "姓名");
                    cellPersonalDetail.detailTextLabel.text = self.appDelegate.userProfilesInfo.userName;
                }
                    break;
                    
                case 1:
                {
                    cellPersonalDetail.textLabel.text = NSLocalizedString(@"TITLE_SEX", "性别");
                    
                    if ([self.appDelegate.userProfilesInfo.userSex isEqualToString:SETTING_PERSONAL_SEX_MAN])
                    {
                        cellPersonalDetail.detailTextLabel.text = NSLocalizedString(@"TITLE_MAN", "男");
                    }else if ([self.appDelegate.userProfilesInfo.userSex isEqualToString:SETTING_PERSONAL_SEX_WOMAN]){
                        cellPersonalDetail.detailTextLabel.text = NSLocalizedString(@"TITLE_WOMAN", "女");
                    }
                }
                    break;
                    
                case 2:
                {
                    cellPersonalDetail.textLabel.text = NSLocalizedString(@"TITLE_ADDRESS", "地址");
                    cellPersonalDetail.detailTextLabel.text = self.appDelegate.userProfilesInfo.userAddress;
                }
                    break;
                    
                default:
                    break;
            }
            
            cell = cellPersonalDetail;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    
    switch ([indexPath section])
    {
        case 0:
        {
            cellHeight = 90.0;
        }
            break;
        default:
            cellHeight = 44.0;
            break;
    }
    
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CompleteOtherInfoViewController *vwcOtherInfo = [[CompleteOtherInfoViewController alloc] init];
    
    switch ([indexPath section])
    {
        case 0:
        {
            // 创建时仅指定取消按钮
            UIActionSheet *avatarActionSheet = [[UIActionSheet alloc]
                                                  initWithTitle:NSLocalizedString(@"TITLE_SELECT", "请选择")
                                                  delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                  destructiveButtonTitle:nil
                                                  otherButtonTitles:nil];
            
            [avatarActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_CAMERA", "相机")];
            [avatarActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_ALBUM", "相册")];
            
            avatarActionSheet.tag = SETTING_PERSONAL_DETAIL_AVATAR_ACTIONSHEET_TAG;

            // 逐个添加按钮（比如可以是数组循环）
            [avatarActionSheet showInView:self.view];
        }
            break;
            
        case 3:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    // mobile
                    vwcOtherInfo.personalInfoType = PersonalInfoTypeMobile;
                    [self.navigationController pushViewController:vwcOtherInfo animated:YES];
                }
                    break;
                  
                case 1:
                {
                    // email
                    vwcOtherInfo.personalInfoType = PersonalInfoTypeEmail;
                    [self.navigationController pushViewController:vwcOtherInfo animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        case 4:
        {
            switch ([indexPath row])
            {
                case 0:
                {
                    // name
                    vwcOtherInfo.personalInfoType = PersonalInfoTypeName;
                    [self.navigationController pushViewController:vwcOtherInfo animated:YES];
                }
                    break;
                    
                case 1:
                {
                    // sex
                    
                    // 创建时仅指定取消按钮
                    UIActionSheet *sexActionSheet = [[UIActionSheet alloc]
                                                        initWithTitle:NSLocalizedString(@"TITLE_SELECT", "请选择")
                                                        delegate:self
                                                        cancelButtonTitle:NSLocalizedString(@"STR_CANCEL", "取消")
                                                        destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
                    
                    [sexActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_MAN", "男")];
                    [sexActionSheet addButtonWithTitle:NSLocalizedString(@"TITLE_WOMAN", "女")];
                    
                    sexActionSheet.tag = SETTING_PERSONAL_DETAIL_SEX_ACTIONSHEET_TAG;
                    
                    // 逐个添加按钮（比如可以是数组循环）
                    [sexActionSheet showInView:self.view];
                }
                    break;
                    
                case 2:
                {
                    // address
                    CompletePersonalAddressViewController *vwcComplete = [[CompletePersonalAddressViewController alloc] init];
                    [self.navigationController pushViewController:vwcComplete animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    
    return headerView;
    
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case SETTING_PERSONAL_DETAIL_AVATAR_ACTIONSHEET_TAG:
        {
            if ([ToolsFunction getCurrentiOSVersion].floatValue >= 8.0 && [ToolsFunction getCurrentiOSVersion].floatValue < 9.0 )
            {
                break;
            }
            
            // 头像选择拍照or相册
            switch (buttonIndex)
            {
                case 1: // 相机
                {
                    // 相机权限检测与相机调用处理
                    [CameraAndPhotoAlbumFunction openiOSCamera:self withCameraDevice:UIImagePickerControllerCameraDeviceRear];
                }
                    break;
                    
                case 2: // 相册
                {
                    // 相册
                    [CameraAndPhotoAlbumFunction openiOSPhotoAlbum:self withMaximumNumberOfSelection:1 withPushController:self];
                }
                    break;
                    
                    
                default:
                    break;
            }
        }
            break;
            
        case SETTING_PERSONAL_DETAIL_SEX_ACTIONSHEET_TAG:
        {
            // 性别
            switch (buttonIndex)
            {
                case 1:
                {
                    // 男
                    self.appDelegate.userProfilesInfo.userSex = SETTING_PERSONAL_SEX_MAN;
                    [self.appDelegate.userProfilesInfo saveUserProfiles];
                    
                    [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_SEX andContent:SETTING_PERSONAL_SEX_MAN];
                }
                    break;
                    
                case 2:
                {
                    // 女
                    self.appDelegate.userProfilesInfo.userSex = SETTING_PERSONAL_SEX_WOMAN;
                    [self.appDelegate.userProfilesInfo saveUserProfiles];
                    
                    [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_SEX andContent:SETTING_PERSONAL_SEX_WOMAN];
                }
                    break;
                    
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    
    [self.personalDetailTableView reloadData];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (actionSheet.tag)
    {
        case SETTING_PERSONAL_DETAIL_AVATAR_ACTIONSHEET_TAG:
        {
            if ([ToolsFunction getCurrentiOSVersion].floatValue >= 8.0 && [ToolsFunction getCurrentiOSVersion].floatValue < 9.0 )
            {
                // 头像选择拍照or相册
                switch (buttonIndex)
                {
                    case 1: // 相机
                    {
                        // 相机权限检测与相机调用处理
                        [CameraAndPhotoAlbumFunction openiOSCamera:self withCameraDevice:UIImagePickerControllerCameraDeviceRear];
                    }
                        break;
                        
                    case 2: // 相册
                    {
                        // 相册
                        [CameraAndPhotoAlbumFunction openiOSPhotoAlbum:self withMaximumNumberOfSelection:1 withPushController:self];
                    }
                        break;
                        
                        
                    default:
                        break;
                }
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Custom Method

/**
 *  注册通知
 */
- (void)addNotification
{
    // 上传图片成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatarSuccess:) name:NOTIFICATION_UPLOAD_AVATAR_SUCCESS object:nil];
    // 上传图片失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatarFail:) name:NOTIFICATION_UPLOAD_AVATAR_FAIL object:nil];
    // 下载图片成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadAvatarSuccessNotification:) name:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
    // 完善个人信息成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(completePersonalInfoSuccess:) name:NOTIFICATION_COMPLETE_PERSONAL_INFO_SUCCESS object:nil];
}

/**
 *  点击是否允许添加好友switch
 *
 *  @param sender self.permissionAddSwitch
 */
- (void)touchChangeSwitch:(id)sender
{
    UISwitch *switchChange = sender;
    
    if (switchChange.on == NO)
    {
        self.appDelegate.userProfilesInfo.friendPermission = SETTING_PERSONAL_PERMISSION_DISABLE;
        [self.appDelegate.userProfilesInfo saveUserProfiles];
        
        [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_PERMISSION andContent:SETTING_PERSONAL_PERMISSION_DISABLE];
    }else if (switchChange.on == YES){
        self.appDelegate.userProfilesInfo.friendPermission = SETTING_PERSONAL_PERMISSION_ENABLE;
        [self.appDelegate.userProfilesInfo saveUserProfiles];
        [self.appDelegate.userInfoManager syncOperationPersonalInfoWithKey:SETTING_PERSONAL_KEY_PERMISSION andContent:SETTING_PERSONAL_PERMISSION_ENABLE];
    }
}

// 解析相册返回的对象ALAsset
- (NSDictionary *)mediaInfoFromAsset:(ALAsset *)asset
{
    NSString *selectAssetUrl = [((NSURL *)[asset valueForProperty:ALAssetPropertyAssetURL]) absoluteString];
    if (selectAssetUrl == nil) {
        return nil;
    }
    
    NSMutableDictionary *mediaInfo = [NSMutableDictionary dictionary];
    [mediaInfo setObject:[asset valueForProperty:ALAssetPropertyType] forKey:@"UIImagePickerControllerMediaType"];
    
    if ([UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]]) {
        [mediaInfo setObject:[UIImage imageWithCGImage:[[asset defaultRepresentation] fullScreenImage]] forKey:@"UIImagePickerControllerOriginalImage"];
    }
    [mediaInfo setObject:[[asset valueForProperty:ALAssetPropertyURLs] valueForKey:[[[asset valueForProperty:ALAssetPropertyURLs] allKeys] objectAtIndex:0]] forKey:@"UIImagePickerControllerReferenceURL"];
    
    return mediaInfo;
}

// operate result image
- (void)operateResultImage:(UIImage *)assetImage
{
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",self.appDelegate.userProfilesInfo.userAccount];
    
    NSString *imagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:imageName];
    
    // 将图片保存到本地目录中
    [ToolsFunction dynamicCompressImageAndWriteToFile:assetImage withFilePath:imagePath];
    
    // 制作缩略图
    UIImage *thumbnailImage = [ToolsFunction thumbnailScaleForMomentImage:assetImage];
    
    NSString *thumbnailImageName = [NSString stringWithFormat:@"%@%@", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, imageName];
    
    NSString *thumbnailImagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:thumbnailImageName];
    // 并将缩略图保存到本地
    [ToolsFunction saveThumbnailToFileForMomentImage:thumbnailImage withFilePath:thumbnailImagePath];
    
    [self.appDelegate.userInfoManager asyncUploadPersonalOriginalAvatarWithLocalImagePath:imagePath];
}

// 上传图片成功通知方法
- (void)uploadAvatarSuccess:(NSNotification *)notification
{
    NSDictionary *dicResult = [[notification.object objectForKey:@"result"] JSONValue];
    
    // 图版本号
    self.appDelegate.userProfilesInfo.userThumbnailAvatarVersion = [dicResult objectForKey:@"avatar_version"];
    self.appDelegate.userProfilesInfo.userOriginalAvatarVersion = [dicResult objectForKey:@"avatar_version"];
    self.appDelegate.userProfilesInfo.userServerAvatarVersion = [dicResult objectForKey:@"avatar_version"];

    // 上传图片成功 在进行保存
    [self.appDelegate.userProfilesInfo saveUserProfiles];
    [self.personalDetailTableView reloadData];
    
    // 借用下载头像成功通知  刷新其他页面
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DOWNLOAD_AVATAR_SUCCESS object:nil];
}

// 上传图片失败通知方法
- (void)uploadAvatarFail:(NSNotification *)notification
{
    [UIAlertView showAutoHidePromptView:NSLocalizedString(@"TITLE_UPLOAD_AVATAR_FAIL", "上传失败") background:nil showTime:DEFAULT_TIMER_WAITING_VIEW];
}

// 下载图片成功通知方法
- (void)downloadAvatarSuccessNotification:(NSNotification *)notification
{
    if (notification == nil || notification.object == nil) {
        return;
    }
    
    PersonalInfos *personalInfos = notification.object;
    // 如果下载的图片账号不符 不作处理
    if (![personalInfos.userAccount isEqualToString:self.appDelegate.userProfilesInfo.userAccount])
    {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch ([personalInfos.avatarType intValue])
        {
            case UploadAndDownloadRequestTypeDownloadBigAvatar:
            {
                // 下载大图
                self.fullImageView.image = [[UIImage alloc] initWithContentsOfFile:[self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", self.appDelegate.userProfilesInfo.userAccount]]];
            }
                break;
                
            case UploadAndDownloadRequestTypeDownloadThumbNailAvatar:
            {
                // 小图下载成功 保存版本号
                [self.personalDetailTableView reloadData];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)completePersonalInfoSuccess:(NSNotification *)notification
{
    [self.personalDetailTableView reloadData];
}

#pragma mark - Zooming Image

// 放大图片
-(void)tapImageViewToZoomingBig:(UITapGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.personalDetailTableView];
    NSIndexPath *indexPath  = [self.personalDetailTableView indexPathForRowAtPoint:location];
    
    UITableViewCell *cell = (UITableViewCell *)[self.personalDetailTableView  cellForRowAtIndexPath:indexPath];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:SETTING_PERSONAL_DETAIL_IMAGEVIEW];
    
    self.firstFrame = CGRectMake(cell.frame.origin.x + imageView.frame.origin.x,64.0 + cell.frame.origin.y + imageView.frame.origin.y - self.personalDetailTableView.contentOffset.y, imageView.frame.size.width, imageView.frame.size.height);
    
    self.fullImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height)];
    
    self.fullImageView.backgroundColor=[UIColor blackColor];
    
    self.fullImageView.userInteractionEnabled=YES;
    
    // 添加图片点击手势
    [self.fullImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewToZoomingSmall:)]];
    
    self.fullImageView.contentMode=UIViewContentModeScaleAspectFit;
    
    if (![self.fullImageView superview])
    {
        NSString *stringUserAvatarImagePath = [self.appDelegate.userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.appDelegate.userProfilesInfo.userAccount]];
        
        // avatar版本号小于服务器 或 文件不存在
        if (([self.appDelegate.userProfilesInfo.userOriginalAvatarVersion intValue] < [self.appDelegate.userProfilesInfo.userServerAvatarVersion intValue] || ![ToolsFunction isFileExistsAtPath:stringUserAvatarImagePath]) && [self.appDelegate.userProfilesInfo.userServerAvatarVersion intValue] > 0)
        {
            self.fullImageView.image = imageView.image;

            // 异步下载自己的原始头像
            [self.appDelegate.userInfoManager asyncDownloadOriginalAvatarWithAccount:self.appDelegate.userProfilesInfo.userAccount];
            
        } else {
            // 拼接大图路径
            self.fullImageView.image = [UIImage imageWithContentsOfFile:stringUserAvatarImagePath];
        }
        
        [self.view.window addSubview:self.fullImageView];
        self.fullImageView.frame = self.firstFrame;
        [UIView animateWithDuration:0.35 animations:^{
            self.fullImageView.frame = CGRectMake(0, 0, UISCREEN_BOUNDS_SIZE.width, UISCREEN_BOUNDS_SIZE.height);
        } completion:^(BOOL finished) {
            [UIApplication sharedApplication].statusBarHidden = YES;
        }];
    }
}

// 缩小图片
-(void)tapImageViewToZoomingSmall:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:0.35 animations:^{
        self.fullImageView.frame = self.firstFrame;
    } completion:^(BOOL finished) {
        
        [self.fullImageView removeFromSuperview];
    }];
    [UIApplication sharedApplication].statusBarHidden = NO;

}

#pragma mark - QBImagePickerControllerDelegate

// 选择单张照片代理
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    // 获取拍照后经过旋转的图片对象
    UIImage *assetImage = [ToolsFunction getPhotographRotateImage:[self mediaInfoFromAsset:asset]];
    
    if (assetImage) {
        CutOutPicturesViewController *vwcCutOutPic = [[CutOutPicturesViewController alloc] initWithImage:assetImage];
        
        vwcCutOutPic.delegate = self;
        
        [vwcCutOutPic presentModallyOn:imagePickerController];
    }
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIImagePickerControllerDelegate

// 照相代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 判断当前所获取媒体类型为图片
        NSDictionary *imageDic = [NSDictionary dictionaryWithDictionary:info];
        // 获取拍照后经过旋转的图片对象
        UIImage *assetImage = [ToolsFunction getPhotographRotateImage:imageDic];
        
        if (assetImage)
        {
            // 处理得到的图片
            [self operateResultImage:assetImage];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [picker dismissViewControllerAnimated:NO completion:nil];
        });
    });
}

#pragma mark - CutOutPicturesDelegate

/**
 *	@brief	完成裁剪代理方法
 *
 *	@param 	cropper 	缩放裁剪对象
 *	@param 	image 	裁剪好的图像
 */
- (void)imageCropper:(CutOutPicturesViewController *)cropper didFinishCroppingWithImage:(UIImage *)image
{
    // 处理得到的图片
    [self operateResultImage:image];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

/**
 *	@brief	取消裁剪代理方法
 *
 *	@param 	cropper 	缩放裁剪对象
 */
- (void)imageCropperDidCancel:(CutOutPicturesViewController *)cropper
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
