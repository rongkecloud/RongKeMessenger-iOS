//
//  RKCloudChatToolsFunction.m
//  云视互动即时通讯SDK
//
//  Created by www.rongkecloud.com on 14/12/11.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>

#ifdef __IPHONE_8_0
#import <PushKit/PushKit.h>
#endif

#import "ToolsFunction.h"
#import "NSData+AESCryptoExtensions.h"
#import "Base64.h"
#import "Reachability.h"
#import "Definition.h"
#import "AppDelegate.h"
#import "NewFeatureView.h"
#import "RKCloudChatMessageManager.h"
#import "RKCloudChatBaseMessage.h"

#define IMAGE_SCALE_SHORTEST_LENGTH_720      720 // 普通图片缩放时最短边的长度

#define MMS_PROMPT_WINDOW_TAG 1101	// 状态栏新消息提醒中使用的window tag
// 程序状态栏字体颜色
#define COLOR_STATUSBAR_TEXT_RED		26/255.0f
#define COLOR_STATUSBAR_TEXT_GREEN	 100.0/255.0f
#define COLOR_STATUSBAR_TEXT_BLUE	   0.0/255.0f

static UIWindow *statusBarWindow = nil;  // 全局对象，用于在任何页面的状态栏中显示提示信息

@implementation ToolsFunction

#pragma mark -
#pragma mark Sound & Device & iOS Local Info

// play sound to speaker(由调用者释放返回对象的内存)
+ (AVAudioPlayer *)playSound:(NSString*)soundFilePath
           withNumberOfLoops:(NSInteger)number
             outputToSpeaker:(BOOL)isSpeaker
{
    //RKCloudDebugLog(@"TOOLS: playSound: soundFilePath = %@, number = %d", soundFilePath, number);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    
    //NSString * cateGory = [audioSession category];
    //RKCloudDebugLog(@"BASE-DEBUG: playSound - AVAudioSession cateGory = %@", cateGory);
    
    if (isSpeaker) {
        // 当前声音从扬声器播放，打开扬声器播放模式
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                 error:&setCategoryError]) {
            // handle error
        }
    }
    else
    {
        // 进行蓝牙模式设置，用于测试是否为蓝牙状态，如果是则执行蓝牙模式，如果否则为默认状态
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                 error:&setCategoryError]) {
            // handle error
        }
    }
    
    // 按照循环播放声音
    NSURL *soundURL = [[NSURL alloc] initFileURLWithPath:soundFilePath];
    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    
    [audioPlayer setNumberOfLoops:number-1];
    [audioPlayer play];
    return audioPlayer;
}

// open or close speaker
+ (void)enableSpeaker:(BOOL)enable{
    NSLog(@"TOOLS: enableSpeaker = %d", enable);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    
    if (enable)
    {
        // 启用扬声器播放声音
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                 error:&setCategoryError]) {
            // handle error
        }
    }
    else
    {
        // 进行蓝牙模式设置，用于测试是否为蓝牙状态，如果是则执行蓝牙模式，如果否则为默认状态
        if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                           withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                 error:&setCategoryError]) {
            // handle error
        }
    }
}

// set Audio Route Type Of Output Device
+ (void)setAudioRouteTypeOfOutputDevice:(NSInteger)outputType {
    NSLog(@"TOOLS: setAudioRouteTypeOfOutputDevice = %ld", (long)outputType);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    
    // 根据切换的输出设备类型选择
    switch (outputType) {
        case IPHONE_OUTPUT_HEADPHONES:
        {
            // 启用iPhone听筒或有线耳机（Headphones）
            if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                               withOptions:AVAudioSessionCategoryOptionMixWithOthers
                                     error:&setCategoryError]) {
                // handle error
            }
        }
            break;
            
        case IPHONE_OUTPUT_SPEAKER:
        {
            // 启用iPhone外置扬声器（Speaker）
            if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                               withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                                     error:&setCategoryError]) {
                // handle error
            }
        }
            break;
            
        case IPHONE_OUTPUT_BLUETOOTH_HFP:
        {
            // 启用iPhone已连接的蓝牙耳机（BluetoothHFPOutput）
            if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                               withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                                     error:&setCategoryError]) {
                // handle error
            }
        }
            break;
            
        default:
            break;
    }
}

// get Audio Route Type Of Output Device
+ (NSInteger)getAudioRouteTypeOfOutputDevice
{
    // 如果即没有连接耳机，有没有蓝牙耳机，则默认iPhone输出的 route = ReceiverAndMicrophone
    NSInteger nOutputDeviceType = IPHONE_OUTPUT_DEFAULT;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *setCategoryError = nil;
    
    // 根据状态判断是否为蓝牙耳机
    // set up for bluetooth microphone input
    if (![audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                       withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                             error:&setCategoryError]) {
        // handle error
    }
    
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    if ([currentRoute.outputs count] > 0)
    {
        AVAudioSessionPortDescription *route = [currentRoute.outputs objectAtIndex:0];
        
        // 判断iPhone音频输出设备
        if ([route.portType isEqualToString:AVAudioSessionPortHeadphones])
        {
            // 有线耳机
            nOutputDeviceType = IPHONE_OUTPUT_HEADPHONES;
        }
        else if([route.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
        {
            // 蓝牙耳机
            nOutputDeviceType = IPHONE_OUTPUT_BLUETOOTH_HFP;
        }
    }
    
    //NSLog(@"TOOLS: getAudioRouteTypeOfOutputDevice = %ld, route = %@", (long)nOutputDeviceType, route);
    
    return nOutputDeviceType;
}

// Get Current Bluetooth Device Name
+ (NSString *)getCurrentBluetoothDeviceName
{
    NSString * currentBluetoothName = nil;
    NSString * inputName = nil;
    NSString * outputName = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    AVAudioSessionRouteDescription *currentRoute = audioSession.currentRoute;
    
    NSArray * arrayInputs = currentRoute.inputs;
    //NSLog(@"arrayInputs = %@", arrayInputs);
    for (int i = 0; i < [arrayInputs count]; i++)
    {
        AVAudioSessionPortDescription *inputAudioDevice = [arrayInputs objectAtIndex:i];
        if ([inputAudioDevice.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
        {
            inputName = inputAudioDevice.portName;
            break;
        }
    }
    
    NSArray * arrayOutputs = currentRoute.outputs;
    //NSLog(@"arrayOutputs = %@", arrayOutputs);
    for (int i = 0; i < [arrayOutputs count]; i++) {
        
        AVAudioSessionPortDescription *outputAudioDevice = [arrayInputs objectAtIndex:i];
        if ([outputAudioDevice.portType isEqualToString:AVAudioSessionPortBluetoothHFP])
        {
            outputName = outputAudioDevice.portName;
            break;
        }
    }
    
    if ([inputName isEqualToString:outputName]) {
        currentBluetoothName = [NSString stringWithString:inputName];
    }
    
    NSLog(@"TOOLS: getCurrentBluetoothDeviceName = %@", currentBluetoothName);
    return currentBluetoothName;
}

// 检测视频设备是否可用
+ (BOOL)checkVideoDeviceIsAvailable
{
    NSArray * arrayDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    NSError * error = nil;
    AVCaptureDevice * currentDevice = nil;
    
    // 判断摄像头是否存在，1=前置摄像头，0=后置摄像头
    if([arrayDevice count] > 0)
    {
        currentDevice = [arrayDevice objectAtIndex:0];
        AVCaptureDeviceInput * inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:currentDevice
                                                                                   error:&error];
        NSLog(@"TOOLS: checkVideoDeviceIsAvailable - inputDevice = %@, error = %@", inputDevice, error);
        if (inputDevice == nil && error /*&& error.code == -11852*/) {
            return NO;
        }
    }
    
    return YES;
}

// 检测音频设备是否可用
+ (BOOL)checkAudioDeviceIsAvailable
{
    NSArray * arrayDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    NSError * error = nil;
    AVCaptureDevice * currentDevice = nil;
    
    // For device with no microphone
    if([arrayDevice count] > 0)
    {
        currentDevice = [arrayDevice objectAtIndex:0];
        AVCaptureDeviceInput * inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:currentDevice
                                                                                   error:&error];
        NSLog(@"TOOLS: checkAudioDeviceIsAvailable - inputDevice = %@, error = %@", inputDevice, error);
        if (inputDevice == nil && error /*&& error.code == -11852*/) {
            return NO;
        }
    }
    
    return YES;
}

// 是否是iPhone设备
+ (BOOL)isiPhoneDevice
{
    // 获取设备信息
    UIDevice* deviceInfo = [UIDevice currentDevice];
    NSLog(@"TOOLS: isIPhoneDevice = %d", [deviceInfo.model isEqualToString:@"iPhone"]);
    
    return [deviceInfo.model isEqualToString:@"iPhone"];
}

#pragma mark -
#pragma mark Sound & Device & iOS Local Info

// 获取iOS设备硬件类型，返回枚举型（iPhone3GS、iPhone4、iPhone4S、iPhone5）
+ (IOSMachineType)iOSMachineHardwareType
{
    // 获取设备信息
    struct utsname systemInfo = {0};
    uname(&systemInfo);
    
    IOSMachineType machineType = MACHINE_UNKNOWN;
    NSString * strMachine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    NSString * strMachineType = nil;
    
    // 判断设备类型
    if ([strMachine hasPrefix:@"iPhone1,1"]) {
        machineType = MACHINE_IPHONE_1G;
        strMachineType = @"iPhone";
    }
    else if ([strMachine hasPrefix:@"iPhone1,2"])
    {
        machineType = MACHINE_IPHONE_3G;
        strMachineType = @"iPhone3G";
    }
    else if ([strMachine hasPrefix:@"iPhone2,1"])
    {
        machineType = MACHINE_IPHONE_3GS;
        strMachineType = @"iPhone3GS";
    }
    else if ([strMachine hasPrefix:@"iPhone3"])
    {
        machineType = MACHINE_IPHONE_4;
        strMachineType = @"iPhone4";
    }
    else if ([strMachine hasPrefix:@"iPhone4"])
    {
        machineType = MACHINE_IPHONE_4S;
        strMachineType = @"iPhone4S";
    }
    else if ([strMachine hasPrefix:@"iPhone5,1"] ||
             [strMachine hasPrefix:@"iPhone5,2"])
    {
        machineType = MACHINE_IPHONE_5;
        strMachineType = @"iPhone5";
    }
    else if ([strMachine hasPrefix:@"iPhone5,3"] ||
             [strMachine hasPrefix:@"iPhone5,4"])
    {
        machineType = MACHINE_IPHONE_5C;
        strMachineType = @"iPhone5C";
    }
    else if ([strMachine hasPrefix:@"iPhone6,1"] ||
             [strMachine hasPrefix:@"iPhone6,2"])
    {
        machineType = MACHINE_IPHONE_5S;
        strMachineType = @"iPhone5S";
    }
    else if ([strMachine hasPrefix:@"iPhone7,1"])
    {
        machineType = MACHINE_IPHONE_6P;
        strMachineType = @"iPhone6 Plus";
    }
    else if ([strMachine hasPrefix:@"iPhone7,2"])
    {
        machineType = MACHINE_IPHONE_6;
        strMachineType = @"iPhone6";
    }
    else if ([strMachine hasPrefix:@"iPad1"])
    {
        machineType = MACHINE_IPAD_1G;
        strMachineType = @"iPad1";
    }
    else if ([strMachine hasPrefix:@"iPad2"])
    {
        machineType = MACHINE_IPAD_2G;
        strMachineType = @"iPad2";
    }
    else if ([strMachine isEqualToString:@"iPad3,1"] ||
             [strMachine isEqualToString:@"iPad3,2"] ||
             [strMachine isEqualToString:@"iPad3,3"])
    {
        machineType = MACHINE_IPAD_3G;
        strMachineType = @"iPad3";
    }
    else if ([strMachine hasPrefix:@"iPad3,4"])
    {
        machineType = MACHINE_IPAD_4G;
        strMachineType = @"iPad4";
    }
    else if ([strMachine hasPrefix:@"iPad2,5"])
    {
        machineType = MACHINE_IPAD_MINI;
        strMachineType = @"iPad Mini";
    }
    else if ([strMachine hasPrefix:@"iPod1,1"])
    {
        machineType = MACHINE_IPOD_1G;
        strMachineType = @"iPod1";
    }
    else if ([strMachine hasPrefix:@"iPod2,1"])
    {
        machineType = MACHINE_IPOD_2G;
        strMachineType = @"iPod2";
    }
    else if ([strMachine hasPrefix:@"iPod3,1"])
    {
        machineType = MACHINE_IPOD_3G;
        strMachineType = @"iPod3";
    }
    else if ([strMachine hasPrefix:@"iPod4,1"])
    {
        machineType = MACHINE_IPOD_4G;
        strMachineType = @"iPod4";
    }
    else if ([strMachine hasPrefix:@"iPod5,1"])
    {
        machineType = MACHINE_IPOD_5G;
        strMachineType = @"iPod5";
    }
    else if ([strMachine hasSuffix:@"86"] || [strMachine isEqual:@"x86_64"])
    {
        machineType = MACHINE_SIMULATOR;
        strMachineType = @"ios simulator";
    }
    
    NSLog(@"TOOLS: iOSMachineHardwareType - strMachine = %@, strMachineType = %@, machineType = %ld", strMachine, strMachineType, (long)machineType);
    
    return machineType;
}

/* Get Local iOS language
 zh-Hans = 简体中文
 zh-Hant = 繁体中文
 en = 英文（其他国家默认语言）
 ja = 日语
 ar = 阿拉伯语言
 */
+ (NSString *)getLocaliOSLanguage {
    NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *systemlanguage = nil;
    
    if (languages)
    {
        systemlanguage = [languages objectAtIndex:0];
    }
    
    return systemlanguage;
}

// 返回iOS系统的主版本(4/5/6)
+ (NSInteger)getCurrentiOSMajorVersion
{
    // 获取设备信息
    UIDevice* deviceInfo = [UIDevice currentDevice];
    //NSLog(@"TOOLS: getCurrentiOSMajorVersion = %@", deviceInfo.systemVersion);
    
    NSInteger nMaxVersion = [[deviceInfo.systemVersion substringToIndex:1] intValue];
    
    return nMaxVersion;
}

// 返回iOS系统的全版本号(如：6.1.4)
+ (NSString *)getCurrentiOSVersion
{
    // 获取设备信息
    UIDevice* deviceInfo = [UIDevice currentDevice];
    //NSLog(@"TOOLS: getCurrentiOSVersion = %@", deviceInfo.systemVersion);
    
    return deviceInfo.systemVersion;
}

// 判断是否是ios7之前的版本
+ (BOOL)iSiOS7Earlier
{
    BOOL isFlag = NO;
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
        // ios6.1 or earlier
        isFlag = YES;
    }
    else
    {
        // ios7 or later
        isFlag = NO;
    }
    return isFlag;
}


#pragma mark -
#pragma mark Network

/* Check the reachability of internet
	return: Wether the internet connection is available
 */
+ (BOOL)checkInternetReachability {
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    BOOL result = ([internetReach currentReachabilityStatus] != NotReachable);
    
    [internetReach stopNotifier];
    return result;
}

// 判断当前网络是否是wifi
+ (BOOL)checkWifiInternet
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    BOOL result = ([internetReach currentReachabilityStatus] == ReachableViaWiFi);
    
    [internetReach stopNotifier];
    return result;
}

// 判断当前网络是否是WWAN
+ (BOOL)checkWWANInternet
{
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    
    BOOL result = ([internetReach currentReachabilityStatus] == ReachableViaWWAN);
    
    [internetReach stopNotifier];
    return result;
}


#pragma mark -
#pragma mark File Operation Function

// 判断文件是否存在
+ (BOOL)isFileExistsAtPath:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath];
}

// 判断目录是否存在
+ (BOOL)isFileExistsAtPath:(NSString *)filePath isDirectory:(BOOL *)isDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:filePath isDirectory:isDirectory];
}

// 通过文件路径获取文件大小
+ (NSString *)getFileSizeByPath:(NSString *)filePath
{
    NSString * strFileSize = @"0";
    NSError *error = nil;
    
    // 文件是否存在
    if (filePath && [ToolsFunction isFileExistsAtPath:filePath])
    {
        // 获取文件大小属性
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        if (fileAttributes != nil)
        {
            float fileSize = [[fileAttributes objectForKey:NSFileSize] floatValue];
            
            strFileSize = [NSString stringWithFormat:@"%.0f", fileSize];
        }
    }
    
    return strFileSize;
}

// 删除临时文件夹中所有的文件
+ (void)deleteAllFilesOfTempDirectory
{
    NSLog(@"TOOLS: deleteAllFilesOfTempDirectory");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *filesArray = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    
    if ([filesArray count] > 0)
    {
        NSString *fileName = nil;
        for (int i = 0; i < [filesArray count]; i++)
        {
            fileName = [filesArray objectAtIndex: i];
            [fileManager removeItemAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent: fileName] error:nil];
        }
    }
}

// 删除本地存储的文件或文件夹
+ (void)deleteFileOrDirectoryForPath:(NSString *)pathString
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:pathString])
    {
        NSLog(@"TOOLS: deleteFileOrDirectoryForPath: pathString = %@", pathString);
        [fileManager removeItemAtPath:pathString error:nil];
    }
}


#pragma mark -
#pragma mark URL Encode/Decode Function

// Gray.Wang:补充url编码函数(此方法由ConCall保留过来的，目前只对API参数过滤特殊符号使用，url编码统一使用urlEncodeUTF8String)
// 只针对特殊符号进行处理的URL编码方法
+ (NSString *)encodeURL:(NSString *)str {
    if(str==nil)
        return @"";
    // Charaters mapping table
    NSArray* charSet = [NSArray arrayWithObjects:@"&",@"+",@",",@"/",@":",@";",@"=",@"?",@"@",@" ",@"\t",@"#",@"<",@">",@"\"",@"\n",nil];
    NSArray* codeSet = [NSArray arrayWithObjects:@"%26",@"%2B",@"%2C",@"%2F",@"%3A",@"%3B",@"%3D",@"%3F",@"%40",@"%20",@"%09",@"%23",@"%3C",@"%3E",@"%22",@"%0A",nil];
    
    NSMutableString* url = [NSMutableString stringWithString:str];
    assert([charSet count]==[codeSet count]);
    
    for(int i=0; i<[charSet count]; i++) {
        NSRange range = NSMakeRange(0, [url length]);
        [url replaceOccurrencesOfString:[charSet objectAtIndex:i]
                             withString:[codeSet objectAtIndex:i]
                                options:NSCaseInsensitiveSearch range:range];
    }
    return [NSString stringWithString:url];
}

// 对文本进行URL一次编码，stringText: 编码的文本字符串
+ (NSString *)urlEncodeUTF8String:(NSString *)stringText
{
    if (stringText == nil) {
        return @"";
    }
    
    // URL Encode，ios中http请求遇到汉字的时候，需要转化成UTF-8
    NSString * encodeText = [stringText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // 针对特殊符号进行编码（如"+、空格、&"等特殊符号）
    encodeText = [ToolsFunction encodeURL:encodeText];
    
    //NSLog(@"TOOLS: urlEncodeUTF8String: stringText = %@, return encodeText = %@", stringText, encodeText);
    
    return encodeText;
}

// 对文本进行URL一次解码，stringText: 解码的文本字符串
+ (NSString *)urlDecodeUTF8String:(NSString *)stringText
{
    if (stringText == nil) {
        return nil;
    }
    
    // URL Decoding，如果显示的是这样的格式：%3A%2F%2F，此时需要我们进行UTF-8解码
    NSString *msgDecodeText = [stringText stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //NSLog(@"TOOLS: urlDecodeUTF8String: stringText = %@, return msgDecodeText = %@", stringText, msgDecodeText);
    
    return msgDecodeText;
}


#pragma mark -
#pragma mark Common Function

// 判断时候是小秘书账号
+ (BOOL)isRongKeServiceAccount:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return NO;
    }
    
    return [RONG_KE_SERVICE isEqualToString:friendAccount];
}

// 注册APNS Push通知
+ (void)registerAPNSNotifications
{
    // Gray.Wang:2014.08.14:兼容iOS8系统注册APNS通知API
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerForRemoteNotifications)])
    {
        // iOS8之后注册系统Push Notification
        UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        // iOS8之前注册系统Push Notification
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert
                                                                               | UIRemoteNotificationTypeBadge
                                                                               | UIRemoteNotificationTypeSound)];
    }
}

// 是否关闭了系统的APNS通知（YES-关闭了，NO-没有关闭）
+ (BOOL)isDisableApnsNotifications
{
    BOOL bDisableApnsNotifications = NO;
    UIApplication *application = [UIApplication sharedApplication];
    
    // Gray.Wang:2014.08.14:兼容iOS8系统注册APNS通知API
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        UIUserNotificationSettings * notificationSettings = [application currentUserNotificationSettings];
        if ((notificationSettings.types & UIRemoteNotificationTypeAlert) == NO ||
            (notificationSettings.types & UIRemoteNotificationTypeBadge) == NO ||
            (notificationSettings.types & UIRemoteNotificationTypeSound) == NO)
        {
            bDisableApnsNotifications = YES;
        }
        
        // 判断Push推送功能是否开启
        NSLog(@"TOOLS: UIUserNotificationSettings notificationSettings.types = %lu", (long)notificationSettings.types);
    }
    else {
        UIRemoteNotificationType notifyType = [application enabledRemoteNotificationTypes];
        if ((notifyType & UIRemoteNotificationTypeAlert) == NO ||
            (notifyType & UIRemoteNotificationTypeBadge) == NO ||
            (notifyType & UIRemoteNotificationTypeSound) == NO)
        {
            bDisableApnsNotifications = YES;
        }
        
        // 判断Push推送功能是否开启
        NSLog(@"TOOLS: UIRemoteNotificationType notifyType = %lu", (long)notifyType);
    }
    
    return bDisableApnsNotifications;
}

// 使用原生的电话切换到GSM呼叫
+ (void)callToGSM:(NSString *)phoneNumber
{
    // 去掉号码中的空格/-/(/)/ (ios7)
    NSString * phone = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@")" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 使用原生的Phone打电话("tel"－电话结束后停留在原生电话页面
    // "telprompt"－电话结束后回到自己的程序(但是这种方法可能是私有的不能上app store))
    NSURL *phoneNumberURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
    
    // 跳转到其它应用执行GSM呼叫
    NSLog(@"TOOLS: callToGSM:%@", phoneNumberURL);
    [[UIApplication sharedApplication] openURL:phoneNumberURL];
}


#pragma mark -
#pragma mark StatusBar Prompt

// 显示状态栏提示信息
+ (void)showStatusBarPrompt:(NSString *)promptString
               withDuration:(NSInteger)duration
                       type:(NSInteger)promptType
{
    // 判断是否需要在状态栏上显示提示消息
    if (promptString == nil || duration <= 0) {
        return;
    }
    
    // 设定Window显示区域
    CGRect frame = {{0, 0}, {UISCREEN_BOUNDS_SIZE.width, [UIApplication sharedApplication].statusBarFrame.size.height}};
    
    // 初始化状态栏窗口
    if (statusBarWindow == nil)
    {
        UIWindow *windowStatusBar = [[UIWindow alloc] initWithFrame:frame];
        [windowStatusBar setBackgroundColor:[UIColor clearColor]];
        [windowStatusBar setWindowLevel:UIWindowLevelStatusBar];
        windowStatusBar.tag = MMS_PROMPT_WINDOW_TAG;
        statusBarWindow = windowStatusBar;
    }
    
    // 同时只显示一条消息
    if ([[statusBarWindow subviews] count] > 0) {
        return;
    }
    
    // 设置消息提示框背景填充图
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    //UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"backgroud_message_normal" ofType:@"png"]];
    //[imageView setImage:image];
    [imageView setBackgroundColor:[UIColor whiteColor]];
    
    //创建label
    UILabel *labelAppName = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 20)];
    //设置lebel背景色
    [labelAppName setBackgroundColor:[UIColor clearColor]];
    //设置label文字
    NSString * str = [NSString stringWithFormat:@"%@：", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [labelAppName setText:str];
    //设置label字体大小
    [labelAppName setFont:[UIFont systemFontOfSize:13]];
    //设置label文字颜色
    labelAppName.textColor = COLOR_WITH_RGB(26, 100, 0);
    //根据label文字内容改变label的宽度
    CGSize textSize = [self getSizeFromString:labelAppName.text withFont:labelAppName.font];
    labelAppName.frame = CGRectMake(5, 0, textSize.width, 20);
    [imageView addSubview:labelAppName];
    
    //创建label
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(labelAppName.bounds)+5, 0, UISCREEN_BOUNDS_SIZE.width-(CGRectGetMaxX(labelAppName.bounds)+5), 20)];
    //设置lebel背景色
    [messageLabel setBackgroundColor:[UIColor clearColor]];
    //设置label文字
    [messageLabel setText:promptString];
    //设置label字体大小
    [messageLabel setFont:[UIFont systemFontOfSize:13]];
    
    // 判断提示的类型
    switch (promptType)
    {
        case NORMAL_PROMPT: // 普通消息提示
        {
            // 设置label文字颜色
            messageLabel.textColor = COLOR_WITH_RGB(26, 100, 0);
        }
            break;
            
        case ERROR_PROMPT: // 错误消息提示
        {
            // 设置label文字颜色
            messageLabel.textColor = [UIColor redColor];
        }
            break;
            
        default:
            break;
    }
    
    // 将显示的label加入图片背景中
    [imageView addSubview:messageLabel];
    
    // 将背景图片加入window
    [statusBarWindow addSubview:imageView];
    
    // 令statusBarWindow显示
    [statusBarWindow setHidden:NO];
    statusBarWindow.alpha = 1.0;
    
    // 显示动画，首先是显示消息duration时长
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    
    // 设置下一步骤
    [UIView setAnimationDidStopSelector:@selector(hideStatusBarPrompt)];
    [UIView setAnimationDuration:duration];
    statusBarWindow.alpha = 0.99;
    [UIView commitAnimations];
}

// 采用淡出效果（2秒钟）隐藏状态栏提示信息
+ (void)hideStatusBarPrompt
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeStatusBarPrompt)];
    [UIView setAnimationDuration:2.0];
    
    statusBarWindow.alpha = 0.0;
    [UIView commitAnimations];
}

// 移除已经消失的状态栏提示窗口
+ (void)removeStatusBarPrompt
{
    if (statusBarWindow) {
        for (UIView *view in [statusBarWindow subviews])
        {
            //如果是UIImageView则移除，但只移除一个，即最前面的，保证后面来得消息也能够显示
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
                break;
            }
        }
        
        // 移除window上的View
        if ([[statusBarWindow subviews] count] == 0) {
            [statusBarWindow removeFromSuperview];
        }
    }
}

// 程序退出时调用此函数释放消息提示窗口所占用的资源
+ (void)destroyStatusBarPrompt
{
    if (statusBarWindow) {
        //[statusBarWindow release];
        statusBarWindow = nil;
    }
}


#pragma mark -
#pragma mark Button Function

// 设置自定义button
+ (void)setBorderColorAndBlueBackGroundColorFor:(UIBorderButton *) button
{
    // 需要边框
    // button.isNeedBorder = YES;
    // 按钮正常时颜色
    button.backgroundStateNormalColor = COLOR_BUTTON_BACKGROUND;
    // 按钮高亮时颜色
    button.backgroundStateHighlightedColor = COLOR_OK_BUTTON_HIGHLIGHTED;
    // 按钮不可点击时颜色
    button.backgroundStateDisabledColor = COLOR_BUTTON_DISABLE;
    // 边框正常时的颜色
    button.borderStateNormalColor = [UIColor whiteColor];
    // 边框高亮时的颜色
    button.borderStateHighlightedColor = [UIColor yellowColor];
}

// 设置自定义button
+ (void)setBorderColorAndRedBackGroundColorFor:(UIBorderButton *)button
{
    // 需要边框
    // button.isNeedBorder = YES;
    // 按钮正常时颜色
    button.backgroundStateNormalColor = [UIColor redColor];
    // 按钮高亮时颜色
    button.backgroundStateHighlightedColor = [UIColor colorWithRed:255.0/255.0 green:102.0/255.0 blue:51.0/255.0 alpha:1.0];
    // 按钮不可点击时颜色
    button.backgroundStateDisabledColor = [UIColor colorWithRed:165.0/255.0 green:165.0/255.0 blue:165.0/255.0 alpha:1.0];
    // 边框正常时的颜色
    button.borderStateNormalColor = [UIColor whiteColor];
    // 边框高亮时的颜色
    button.borderStateHighlightedColor = [UIColor yellowColor];
}


#pragma mark -
#pragma mark String Method

+ (NSString *)getCurrentCallID:(NSString *)userID
{
    // 得到当前的系统时间(秒)
    NSString *strTimeInterval = [NSString stringWithFormat:@"%lf", [ToolsFunction getCurrentSystemDateMillisecond]];
    
    // 得到两位的随机数
    NSString *strRandom = [NSString stringWithFormat:@"%02ld", random()%99 + 1];
    //NSLog(@"TOOLS: getCurrentCallID: timeInterval=%@, strRandom=%@", strTimeInterval, strRandom);
    
    NSString *stringCallID = [NSString stringWithFormat:@"%@-%@-%@", userID, strTimeInterval, strRandom];
    // NSLog(@"TOOLS: getCurrentCallID: stringCallID = %@", stringCallID);
    
    return stringCallID;
}

// 从字串中查找是否存在URL
+ (BOOL)isExistUrlInString:(NSString *)textString
{
    if (textString == nil) {
        return NO;
    }
    
    BOOL flag = NO;
    NSError *error = nil;
    // NSString *textString = @"hTtp://aaa   HTTps://ddd   wWw.sss.com/sdfasd   fTP://wwww ";
    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(?=http://)|(?=https://)|(?=www.)|(?=ftp://)" options:0 error:&error];
    // NSLog(@"regex = %@", regex);
    //NSArray *array = [regex matchesInString:textString  options:0 range:NSMakeRange(0, [textString length])];
    // NSLog(@"array = %@", array);
    
    NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSArray *matches = [dataDetector matchesInString:textString options:0 range:NSMakeRange(0, [textString length])];
    if (matches && [matches count] > 0) {
        flag = YES;
    }
    return flag;
}

// 计算文件大小为带单位的字符串（B、KB、M、G）
+ (NSString *)stringFileSizeWithBytes:(unsigned long)fileSizeBytes
{
    NSString *fileSizeString = @"0 B";
    
    if (fileSizeBytes > 0 && fileSizeBytes < pow(1024, 2))
    {
        fileSizeString = [NSString stringWithFormat:@"%.2fKB", (fileSizeBytes / 1024.)];
    }
    else if (fileSizeBytes >= pow(1024, 2) && fileSizeBytes < pow(1024, 3))
    {
        fileSizeString = [NSString stringWithFormat:@"%.2fMB", (fileSizeBytes / pow(1024, 2))];
    }
    else if (fileSizeBytes >= pow(1024, 3))
    {
        fileSizeString = [NSString stringWithFormat:@"%.3fGB", (fileSizeBytes / pow(1024, 3))];
    }
    
    return fileSizeString;
}

// 比较所有版本号是否大（任意版本号格式：5.0/6.0.1/6.1.4/7.0/7.1/...）
+ (BOOL)compareAllVersions:(NSString *)highVersion withCompare:(NSString *)lowVersion
{
    BOOL bHigh = NO;
    
    NSArray * arrayHighVersion = [highVersion componentsSeparatedByString:@"."];
    NSArray * arrayLowVersion = [lowVersion componentsSeparatedByString:@"."];
    
    // 比较每个字符串中从左边开始的版本号
    for (int i = 0; i < [arrayHighVersion count] || i < [arrayLowVersion count]; i++)
    {
        NSInteger nHigh = 0;
        NSInteger nLow = 0;
        
        // 获取高版本字符串的每个版本
        if (i < [arrayHighVersion count]) {
            nHigh = [[arrayHighVersion objectAtIndex:i] integerValue];
        }
        //NSLog(@"DEBUG: arrayHighVersion i = %d, nHigh = %d", i, nHigh);
        
        // 获取低版本字符串的每个版本
        if (i < [arrayLowVersion count]) {
            nLow = [[arrayLowVersion objectAtIndex:i] integerValue];
        }
        //NSLog(@"DEBUG: arrayLowVersion i = %d, nLow = %d", i, nLow);
        
        // 如果大则返回
        if (nHigh > nLow) {
            bHigh = YES;
            break;
        }
        else if (nLow > nHigh)
        {
            bHigh = NO;
            break;
        }
    }
    
    //NSLog(@"TOOLS: compareAllVersions - highVersion = %@, lowVersion = %@, return bHigh = %d", highVersion, lowVersion, bHigh);
    
    return bHigh;
}

// 获取字符串的长度
+ (CGSize)getSizeFromString:(NSString *)stringText withFont:(UIFont *)font
{
    if (stringText == nil || font == nil)
    {
        return CGSizeZero;
    }
    CGSize size = CGSizeZero;
    
    if ([stringText respondsToSelector:@selector(sizeWithAttributes:)])
    {
        size = [stringText sizeWithAttributes: [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName]];
    }
    else
    {
        size = [stringText sizeWithFont: font];
    }
    
    return size;
}

// 获取字符串的长度
+ (CGSize)getSizeFromString:(NSString *)stringText withFont:(UIFont *)font constrainedToSize:(CGSize)maxSize
{
    if (stringText == nil || font == nil)
    {
        return CGSizeZero;
    }
    CGSize size = CGSizeZero;
    
    if ([stringText respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        CGRect rect = [stringText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName] context:nil];
        size = CGSizeMake(rect.size.width, rect.size.height);
    }
    else
    {
        size = [stringText sizeWithFont:font constrainedToSize:maxSize];
    }
    
    return size;
}

// 绘制字符串
+ (void)drawString:(NSString *)textString inRect:(CGRect)textRect withFont:(UIFont *)font
{
    if (textString == nil || font == nil)
    {
        return;
    }
    if ([textString respondsToSelector:@selector(drawInRect:withFont:)])
    {
        [textString drawInRect:textRect withFont:font];
    }
    else
    {
        [textString drawInRect:textRect withAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    }
}

//判断一段字符串是否全部为空格
+ (BOOL) isEmptySpace:(NSString *)stringText {
    
    if (!stringText) {
        return YES;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [stringText stringByTrimmingCharactersInSet:set];
        
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

#pragma mark -
#pragma mark label Method

// 计算文本字符串包含表情符号的文本Cell的Size(按照最大的高度和最大的宽度来计算)
// 解决了全部都是图标的泡泡行数不正确的问题，使用了将文本中所有的表情图标，
// 每个图标都换成五个"[[[[["（21个宽度，图标宽度是20.75），这样计算出来的文本的行数误差几乎为0
+ (CGSize)getTextCellSizeFromString:(NSString *)stringText withMaxWidth:(float)contentWidth
{
    NSArray *arrayKeys = [[AppDelegate appDelegate].chatManager.emotionESCToFileNameDict allKeys];
    NSInteger textContentLineNumber = 0;
    
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
                    NSString *stringKey = [arrayKeys objectAtIndex:i];
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
                //textBlockSize = [@"[:::]" sizeWithFont:MESSAGE_TEXT_FONT constrainedToSize:textMaxSize];
                // 得到文本字符串的size
                textBlockSize = [ToolsFunction getSizeFromString:stringLineText withFont:MESSAGE_TEXT_FONT constrainedToSize:textMaxSize];/*[stringLineText sizeWithFont:MESSAGE_TEXT_FONT
                                                                                                                                             constrainedToSize:textMaxSize];*/
                
                // 如果一断文本字符串的总宽度小于最大的宽度则计算实际宽度
                if (textBlockSize.width < contentWidth) {
                    // 如果已经保存的最大行宽度小于断的宽度则重新赋值
                    if (textMaxWidth < textBlockSize.width) {
                        textMaxWidth = textBlockSize.width;
                    }
                }
                else {
                    textMaxWidth = contentWidth;
                }
                
                // 计算本段文本的行数
                NSInteger nLine = textBlockSize.height / MESSAGE_LINE_HEIGHT;
                
                if ([ToolsFunction iSiOS7Earlier] == NO)
                {
                    
                    nLine = (textBlockSize.height * 1.0) / (MESSAGE_LINE_HEIGHT - 1);
                    if (nLine != 1)
                    {
                        //nLine = ceil((textBlockSize.height * 1.0) / (MESSAGE_LINE_HEIGHT - 1));
                    }
                }
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

// 通过UITextView获取文本字串的size
+ (CGSize)getTextCellSizeByUITextView:(NSString *)stringText
                         withFontSize:(UIFont *)currentTextFontSize
                    withTextShowWidth:(CGFloat)cgfTextWidth
                   withTextLineHeight:(CGFloat)cgfTextLineHeight
                      withTextMaxLine:(NSInteger)nTextMaxLine
{
    CGSize textCellSize = CGSizeMake(0, 0);
    if (stringText == nil || [stringText isEqualToString:@""]) {
        return textCellSize;
    }
    
    // 通过文本字串创建属性化字串
    NSMutableAttributedString *textAttributedString = [[NSMutableAttributedString alloc] initWithString:stringText attributes:nil];
    
    // 计算该文本在UITextView中显示需要的size
    UITextView *textView = [[UITextView alloc] init];
    
    // 设置字体
    [textAttributedString addAttribute:NSFontAttributeName value:currentTextFontSize range:NSMakeRange(0, [[textAttributedString string] length])];
    
    // 为UITextView的属性化字串赋值
    textView.attributedText = textAttributedString;
    textCellSize = [textView sizeThatFits:CGSizeMake(cgfTextWidth, cgfTextLineHeight * nTextMaxLine)];
    
    // 宽度增加5px的原因是：在测试的过程中，针对只有3-4个字符时，UITextView绘制两列，导致第二列的字符绘制不全的问题
    // 高度增加0.5px的原因是：消息里如果全是表情时获取的高度不够，导致表情显示少一列
    textCellSize = CGSizeMake(textCellSize.width + 5, textCellSize.height);
    
    return textCellSize;
}

// 通过UIView获取文本字串的size
+ (CGSize)getTextCellSizeByUIView:(NSString *)stringText
                     withFontSize:(UIFont *)currentFontSize
                     withMaxWidth:(CGFloat)contentWidth
               withTextLineHeight:(CGFloat)cgfTextLineHeight
                  withTextMaxLine:(NSInteger)nTextMaxLine
{
    float textContentLineNumber = 0.0;
    
    // 计算文本字符串高度
    CGSize textMaxSize = CGSizeMake(contentWidth, cgfTextLineHeight * nTextMaxLine);
    CGSize textCellSize = CGSizeMake(0, 0);
    CGFloat textMaxWidth = 0;
    
    if (stringText == nil || [stringText isEqualToString:@""]) {
        return textCellSize;
    }
    
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
                // 得到文本字符串的size
                CGSize textBlockSize = [ToolsFunction getSizeFromString:stringLineText
                                                               withFont:currentFontSize
                                                      constrainedToSize:textMaxSize];
                
                // 如果一断文本字符串的总宽度小于最大的宽度则计算实际宽度
                if (textBlockSize.width < contentWidth){
                    // 如果已经保存的最大行宽度小于断的宽度则重新赋值
                    if (textMaxWidth < textBlockSize.width){
                        textMaxWidth = textBlockSize.width;
                    }
                }
                else {
                    textMaxWidth = contentWidth;
                }
                
                // 计算本段文本的行数
                float nLine = textBlockSize.height / cgfTextLineHeight;
                textContentLineNumber += nLine;
            }
            else if (stringLineText && [stringLineText isEqualToString:@""]) {
                // 如果出现换行则累加行数
                textContentLineNumber ++;
            }
        }
    }
    
    // 文本Cell的最大宽度
    textCellSize.width = textMaxWidth;
    // 文本Cell的最大高度
    textCellSize.height = textContentLineNumber * cgfTextLineHeight;
    
    return textCellSize;
}



#pragma mark -
#pragma mark UI & Animation Setting

// Animation
+ (void)moveUpTransition:(BOOL)bUp forLayer:(CALayer*)layer {
    CATransition *transition = [CATransition animation];
    if (bUp) {
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
    } else {
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
    }
    [layer addAnimation:transition forKey:nil];
}


// 来电话的时候，如果键盘存在，则隐藏该键盘
+ (void)setKeyboardHidden:(BOOL)isHidden
{
    NSArray *windowArray = [[UIApplication sharedApplication] windows];
    BOOL isFind = NO;
    if ([windowArray count] <= 0)
    return;
    
    for (int i = 0; i < [windowArray count] && !isFind; i++)
    {
        // 判断是否有UITextEffectsWindow
        NSRange textEffectsRange = [[[windowArray objectAtIndex: i] description] rangeOfString: @"UITextEffectsWindow"];
        if (textEffectsRange.length <= 0)
        continue;
        
        if ([[[windowArray objectAtIndex: i] subviews] count] <= 0)
        continue;
        
        // 判断是否有keyboardView
        NSArray *array = [[[[windowArray objectAtIndex: i] subviews] objectAtIndex: 0] subviews];
        if ([array count] <= 0)
        continue;
        
        for (int j = 0; j < [array count]; j++)
        {
            NSRange range = [[[array objectAtIndex: j] description] rangeOfString:@"UIKeyboardAutomatic"];
            
            // 如果找到keyboardView，设置该view的hidden属性
            if (range.length > 0)
            {
                UIView *keyboardView = (UIView *)[array objectAtIndex: 0];
                [keyboardView setHidden: isHidden];
                
                if (isHidden)
                {
                    keyboardView.frame = CGRectMake(0, 460, keyboardView.frame.size.width, keyboardView.frame.size.height);
                }
                else
                {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationCurve: UIViewAnimationCurveEaseIn];
                    [UIView setAnimationDuration: 0.5];
                    keyboardView.frame = CGRectMake(0, 0, keyboardView.frame.size.width, keyboardView.frame.size.height);
                    [UIView commitAnimations];
                }
                isFind = YES;
                break;
            }
        }
    }
}

// 从资源文件中载入指定表格单元的资源
// 注意表格单元的重用标识符与表格单元的资源名称相同！
+ (id)loadTableCellFromNib:(NSString*)nib
{
    //NSLog(@"TOOLS: >>> loadTableCellFromNib : %@", nib);
    
    id cell = nil;
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:nib owner:nil options:nil];
    for (id currentObject in topLevelObjects) {
        if ([currentObject isKindOfClass:[UITableViewCell class]]) {
            cell = currentObject;
            break;
        }
    }
    return cell;
}

// Load Image from Resource
+ (UIImage*)loadImageFromResource:(NSString*)imagename
{
    NSString* path = [[NSBundle mainBundle] pathForResource:imagename ofType:@"png"];
    UIImage* image = [[UIImage alloc] initWithContentsOfFile:path];
    return image;
}

+ (NSURL *)videoConvertToMp4:(AVURLAsset *)avAsset
{
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    NSURL *vedioUrl = nil;
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetMediumQuality];
        // 将视频保存到SDK的Vedio目录夹下
        NSString *mp4Path = [RKCloudChatMessageManager getMMSFilePath:MESSAGE_TYPE_VIDEO withFileLocalName:[NSString stringWithFormat:@"video-%@.mp4",[ToolsFunction getCurrentSystemDateSecondString]] isThumbnailImage:NO];
        vedioUrl = [NSURL fileURLWithPath:mp4Path];
        
        exportSession.outputURL = vedioUrl;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"WARNGIN: videoConvertToMp4 failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                     NSLog(@"WARNGIN: videoConvertToMp4 cancelled");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"WARNGIN: videoConvertToMp4 completed");
                } break;
                default: {
                    NSLog(@"WARNGIN: videoConvertToMp4 other");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return vedioUrl;
}


#pragma mark -
#pragma mark Property List

/* Read a property list from resource file
 plistName - name of property list in resource
 */
+ (NSDictionary *)loadPropertyList:(NSString *)plistName {
    NSString *error = nil;
    NSPropertyListFormat format;
    
    NSString *plistpath = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    NSData *plist = [[NSFileManager defaultManager] contentsAtPath:plistpath];
    return (NSDictionary *) [NSPropertyListSerialization propertyListFromData:plist mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&error];
}

// 读取plist资源数据
+ (NSMutableDictionary *)loadResourceFromPlist:(NSString *)fileName
                            withDictionaryPath:(NSString *)dictionaryPath
{
    NSMutableDictionary *contactPhonePlist = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", dictionaryPath, fileName]];
    return contactPhonePlist;
}

// 删除plist资源数据
+ (BOOL)deleteResourceFromPlist:(NSString *)fileName
             withDictionaryPath:(NSString *)dictionaryPath
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", dictionaryPath, fileName] error:nil];
}

// 保存plist文件数据
+ (void)saveResourceToPlist:(NSMutableDictionary *)contactPhoneDic
               withFileName:(NSString *)fileName
         withDictionaryPath:(NSString *)dictionaryPath
{
    if(contactPhoneDic==nil)
        return;  // 异常保护
    
    NSMutableDictionary *contactDic = [[NSMutableDictionary alloc] initWithDictionary:contactPhoneDic];
    if (contactDic!=nil )
    {
        if([contactDic count] > 0)
        {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            BOOL isDirectory = NO;
            
            if(NO == [fileManager fileExistsAtPath:dictionaryPath isDirectory:&isDirectory])
            {
                [fileManager createDirectoryAtPath:dictionaryPath
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
            }
            
            [contactDic writeToFile:[NSString stringWithFormat:@"%@/%@", dictionaryPath, fileName] atomically:YES];
        }
    }
}

// 将表情的转义字符转化为自定义的短语表示
+ (NSString *)translateEmotionString:(NSString *)content withDictionary:(NSDictionary*)dict
{
    NSArray *allKeysArray = [dict allKeys];
    
    for (int i = 0; i < [allKeysArray count]; i++)
    {
        NSString *keyValueStr = [allKeysArray objectAtIndex: i];
        NSRange range = [content rangeOfString:keyValueStr];
        if (range.length > 0)
        {
            content = [content stringByReplacingOccurrencesOfString:keyValueStr
                                                         withString:NSLocalizedString(keyValueStr, nil)];
        }
    }
    return content;
}


#pragma mark -
#pragma mark Image Operate Function

// 旋转拍照后的图片
+ (UIImage *)rotateImage:(UIImage *)sourceImage
{
    CGImageRef imgRef = sourceImage.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    CGFloat scaleRatio = (CGFloat)bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef),
                                  CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    
    switch(sourceImage.imageOrientation) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width,
                                                         imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height,
                                                         imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (sourceImage.imageOrientation == UIImageOrientationRight ||
        sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

// 将图片旋转为正确的方向
+ (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// 接受和发送的图片在保存缩略图时，最长边不超过120，若有超过的均压缩至最长边为120。但显示时，最长边大小为120，此方法用来将缩略图的图片长宽，换算成显示的长和宽。
+ (CGSize)sizeScaleFixedThumbnailImageSize:(CGSize)sourceImageSize
{
    int imageHeight = sourceImageSize.height;
    int imageWidth = sourceImageSize.width;
    float rate = 0.0;
    
    float scaleSideLongestLength = MMS_THUMBNAIL_SCALE_LENGTH_120;
    float scaleSideShortestLength = MMS_THUMBNAIL_SHORTEST_LENGTH_43;
    
    if ((imageWidth > scaleSideLongestLength) || (imageHeight > scaleSideLongestLength))
    {
        if (imageWidth > imageHeight)
        {
            rate = scaleSideLongestLength / imageWidth;
            imageWidth = scaleSideLongestLength;
            imageHeight = imageHeight * rate;
        }
        else {
            rate = scaleSideLongestLength / imageHeight;
            imageHeight = scaleSideLongestLength;
            imageWidth = imageWidth * rate;
        }
    }
    
    imageHeight = (imageHeight < scaleSideShortestLength) ? scaleSideShortestLength : imageHeight;
    imageWidth = (imageWidth < scaleSideShortestLength) ? scaleSideShortestLength : imageWidth;
    
    return CGSizeMake(imageWidth, imageHeight);
}

// 把image缩放到给定的size
+ (UIImage *)scaleImageSize:(UIImage *)sourceImage toSize:(CGSize)imageSize
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 7.0之前kCGImageAlphaPremultipliedLast ＝ 1;
    // 7.0之后CGBitmapInfo 中没有了1 只能通过与CGBitmapInfo 中的kCGBitmapByteOrderDefault或出1
    CGBitmapInfo alphaInfo = kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault;
    
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   imageSize.width,
                                                   imageSize.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   alphaInfo);
    CGContextSetBlendMode(bmContext, kCGBlendModeCopy );
    
    CGContextDrawImage(bmContext,
                       CGRectMake(0.0, 0.0, imageSize.width, imageSize.height),
                       sourceImage.CGImage);
    CGImageRef cgImage = CGBitmapContextCreateImage( bmContext );
    
    CGColorSpaceRelease(colorSpace);
    CFRelease( bmContext );
    
    UIImage *desImage = [UIImage imageWithCGImage: cgImage];
    CGImageRelease(cgImage);
    cgImage = nil;
    
    return desImage;
}

//添加圆角路径
static void addRoundedRectToPath(CGContextRef context,
                                 CGRect rect,
                                 float ovalWidth,
                                 float ovalHeight) {
    
    float fw = 0.0, fh = 0.0;
    if ((int)ovalWidth == 0 || (int)ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

// 切割图片为圆角
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)radius {
    // the size of CGContextRef
    int w = size.width < 1 ? 1 : size.width;
    int h = size.height < 1 ? 1 : size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrderDefault);
    CGRect rect = CGRectMake(0, 0, w, h);
    
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, radius);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), image.CGImage);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIImage *roundedRectImage = [UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return roundedRectImage;
}

// 根据颜色生成纯色的图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// 获取拍照后经过旋转的图片对象
+ (UIImage *)getPhotographRotateImage:(id)finishQBPickingMediaWithInfo
{
    if (finishQBPickingMediaWithInfo == nil) {
        return nil;
    }
    
    BOOL bValid = NO;
    UIImage *rotateImage = nil;
    
    if ([[finishQBPickingMediaWithInfo objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"ALAssetTypePhoto"])
    {
        bValid = YES;
    }
    else if ([[finishQBPickingMediaWithInfo objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"])
    {
        bValid = NO;
    }
    
    UIImage *sourceImage = nil;
    
    if (bValid) {
        // 获取当前相册图片
        sourceImage = [finishQBPickingMediaWithInfo objectForKey:UIImagePickerControllerOriginalImage];
        
        
    }else{
        // 获取当前摄像图片
        sourceImage = [finishQBPickingMediaWithInfo objectForKey:UIImagePickerControllerEditedImage];
    }
    
    // Gray.Wang:2015.07.25: 将原始图片进行等比例缩放
    rotateImage = [ToolsFunction scaleFixedSizeForImage:sourceImage];
    
    // 旋转图片的方向
    rotateImage = [ToolsFunction rotateImage:rotateImage];
    //rotateImage = [ToolsFunction fixOrientation:rotateImage];
    
    return rotateImage;
}

// 根据最端边的尺寸进行等比例缩放原图
+ (UIImage *)scaleFixedSizeForImage:(UIImage *)sourceImage
{
    // 获取当前图片宽高
    float width = sourceImage.size.width;
    float height = sourceImage.size.height;
    float rate = 0.0;
    
    // 缩放时最短边的长度-720
    float scaleSideLength = IMAGE_SCALE_SHORTEST_LENGTH_720;
    
    BOOL bScale = NO;
    UIImage* scaledImage = sourceImage;
    
    // 根据最短边是否大于规定的最短边，如果大于等于则进行=规定的最短边，进行等比例缩放
    if (height > width && width >= scaleSideLength) {
        
        rate = scaleSideLength / width;
        
        width = scaleSideLength;
        height = height * rate;
        
        bScale = YES;
    }
    else if (width > height && height >= scaleSideLength) {
        
        rate = scaleSideLength / height;
        
        height = scaleSideLength;
        width = width * rate;
        
        bScale = YES;
    }
    
    // 如果需要做等比例缩放则执行屏幕绘制
    if (bScale)
    {
        // UIGraphicsBeginImageContextWithOptions(CGSize size: 图片尺寸,
        // BOOL opaque: 是否设置为透明,
        // CGFloat scale: 图片缩放比（0.0则为当前手机屏幕缩放比-iPhone4~6为2倍，iPhone6+为3倍，1.0原始图片不变，2.0为固定两倍的缩放比）)
        
        //We prepare a bitmap with the new size
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 1.0);
        
        //Draws a rect for the image
        [sourceImage drawInRect:CGRectMake(0, 0, width, height)];
        
        //We set the scaled image from the context
        scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSLog(@"DEBUG: scaleFixedSizeForImage - drawInRect(0, 0, width = %f, height = %f), scaleSideLength = %f", width, height, scaleSideLength);
    }
    
    return scaledImage;
}

// 动态压缩图片并写入文件（MMS和Moment统一算法方法）
+ (void)dynamicCompressImageAndWriteToFile:(UIImage *)imageSource withFilePath:(NSString *)filePath
{
    NSLog(@"TOOLS: -----dynamicCompressImageAndWriteToFile Algorithm Begin-----");
    @autoreleasepool {
        //NSData * dataImageSource = UIImageJPEGRepresentation(imageSource, 1.0);
        //NSLog(@"DEBUG: -----JPG - dataImageSource.length = %@, imageSource.size = %@-----", [ToolsFunction stringFileSizeWithBytes:(unsigned long)dataImageSource.length], NSStringFromCGSize(imageSource.size));
        
        // 1. 根据最端边大于720则进行720等比例缩放
        // 根据最大边的尺寸进行等比例缩放原图
        UIImage * scaleFixedImage = [ToolsFunction scaleFixedSizeForImage:imageSource];
        //NSData * imageJPEGData = UIImageJPEGRepresentation(scaleFixedImage, 1.0);
        //NSLog(@"DEBUG: -----scaleFixedSizeForImage dataScaleFixedImage.length = %@, scaleFixedImage.size = %@-----", [ToolsFunction stringFileSizeWithBytes:(unsigned long)imageJPEGData.length], NSStringFromCGSize(scaleFixedImage.size));
        
        // 2. 使用固定0.2比率降低JPEG质量来压缩图片
        float compressionQuality = 0.3;
        
        // 转换JPEG图片进行质量的压缩
        NSData * imageJPEGData = UIImageJPEGRepresentation(scaleFixedImage, compressionQuality);
        //scaleFixedImage = [UIImage imageWithData:imageJPEGData];
        NSLog(@"DEBUG: -----compressRatio = %f, imageJPEGData.length = %@, scaleFixedImage.size = %@-----", compressionQuality, [ToolsFunction stringFileSizeWithBytes:(unsigned long)imageJPEGData.length], NSStringFromCGSize(scaleFixedImage.size));
        
        [imageJPEGData writeToFile:filePath atomically:YES];
    }
    
    /*
     // ---------------
     // 二. 根据最大分辨率:960 * 640进行等比例缩放（算法为：图片分辨率除以最大分辨率 求平方根后 乘以2 得到系数，然后图片宽度和高度除以这个系数，并将图片绘制到此矩形中），然后进行0.9-0.1的动态循环压缩
     // 动态压缩
     NSString * compressedfilePath = [filePath stringByAppendingString:@"-compressedImage(0.9-0.1).jpg"];
     // compressed Image
     UIImage *compressedImage = [UIImage compressImage:imageSource compressRatio:0.9f];
     
     imageJPEGData = UIImageJPEGRepresentation(compressedImage, 1.0);
     NSLog(@"DEBUG: 2、compressRatio=0.1, imageJPEGData.length = %@, compressedImage.size = %@", [ToolsFunction stringFileSizeWithBytes:(unsigned long)imageJPEGData.length], NSStringFromCGSize(compressedImage.size));
     
     [imageJPEGData writeToFile:compressedfilePath atomically:YES];
     //[imageJPEGData writeToFile:filePath atomically:YES];
     // ---------------
     
     // 三. 根据最大分辨率:960 * 640进行等比例缩放（算法为：图片分辨率除以最大分辨率 求平方根后 乘以2 得到系数，然后图片宽度和高度除以这个系数，并将图片绘制到此矩形中），然后进行0.9-0.3的动态循环压缩
     compressedfilePath = [filePath stringByAppendingString:@"-compressedImage(0.9-0.3).jpg"];
     // compressed Image
     compressedImage = [UIImage compressImage:imageSource compressRatio:0.9f maxCompressRatio:0.3];
     
     imageJPEGData = UIImageJPEGRepresentation(compressedImage, 1.0);
     NSLog(@"DEBUG: 3、compressRatio=0.3, imageJPEGData.length = %@, compressedImage.size = %@", [ToolsFunction stringFileSizeWithBytes:(unsigned long)imageJPEGData.length], NSStringFromCGSize(compressedImage.size));
     
     [imageJPEGData writeToFile:compressedfilePath atomically:YES];
     //[imageJPEGData writeToFile:filePath atomically:YES];
     // ---------------
     */
    NSLog(@"TOOLS: -----dynamicCompressImageAndWriteToFile Algorithm End-----");
}

// 生成Moment缩略图并进行等比例缩放，使其最大边均小于MOMENT_THUMBNAIL_MIN_WIDTH
+ (UIImage *)thumbnailScaleForMomentImage:(UIImage *)sourceImage
{
    // 缩放时最短边的长度-MOMENT_THUMBNAIL_MIN_WIDTH
    CGFloat scaleSideLength = UISCREEN_BOUNDS_SIZE.width;
    
    CGFloat srcImageWidth = sourceImage.size.width;
    CGFloat srcImageHeight = sourceImage.size.height;
    
    if (srcImageWidth < scaleSideLength && srcImageHeight < scaleSideLength)
    {
        return sourceImage;
    }
    
    // 宽高比
    CGFloat aspectRatio = srcImageWidth/srcImageHeight;
    // 新截取的图
    UIImage* newSourceImage = nil;
    
    if (aspectRatio>(5.0/2.0) || aspectRatio <(2.0/5.0))
    {
        CGFloat coordinateX = 0;
        CGFloat coordinateY = 0;
        // aspectRatio > 1  宽图，否则是长图
        if(aspectRatio > 1)
        {
            srcImageWidth = srcImageHeight*(5.0/2.0);
            coordinateX = (sourceImage.size.width - srcImageWidth)/2.0;
        }
        else
        {
            // 长图
            srcImageHeight = srcImageWidth*(5.0/2.0);
            coordinateY = (sourceImage.size.height - srcImageHeight)/2.0;
        }
        
        // 原图中截取矩形框
        CGRect rect = CGRectMake(coordinateX, coordinateY, srcImageWidth, srcImageHeight);//创建矩形框
        CGImageRef cgImage = CGImageCreateWithImageInRect([sourceImage CGImage], rect);
        if (cgImage)
        {
            newSourceImage = [UIImage imageWithCGImage:cgImage];
            CFRelease(cgImage);
        }
    }
    else
    {
        // 原图
        newSourceImage = sourceImage;
    }
    
    // 按照高度进行缩放
    if (srcImageHeight > scaleSideLength)
    {
        aspectRatio = scaleSideLength / srcImageHeight;
        
        srcImageHeight = scaleSideLength;
        srcImageWidth = srcImageWidth * aspectRatio;
    }
    
    // 按照宽度进行缩放
    if (srcImageWidth > scaleSideLength)
    {
        aspectRatio = scaleSideLength / srcImageWidth;
        
        srcImageWidth = scaleSideLength;
        srcImageHeight = srcImageHeight * aspectRatio;
    }
    
    // 缩放图片
    UIGraphicsBeginImageContext(CGSizeMake(srcImageWidth, srcImageHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    UIRectFill(CGRectMake(0, 0, srcImageWidth, srcImageHeight));
    [newSourceImage drawInRect:CGRectMake(0, 0, srcImageWidth, srcImageHeight)];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

// 保存缩略图到本地文件中（默认宽度为0，返回值大于0则认为缩略图保存成功）
+ (BOOL)saveThumbnailToFileForMomentImage:(UIImage *)imageSource withFilePath:(NSString *)thumbnailImagePath
{
    UIImage *imageThumbnail = [ToolsFunction thumbnailScaleForMomentImage:imageSource];
    
    NSData *thumbnaiData = UIImageJPEGRepresentation(imageThumbnail, 0.1);
    BOOL bSaveFile = [thumbnaiData writeToFile:thumbnailImagePath atomically:YES];
    
    
    return bSaveFile;
}

// 获取当前profile的头像
+ (UIImage *)getFriendAvatarWithFriendAccount:(NSString *)account andIsThumbnail:(BOOL)bThumbnail
{
    if (account == nil) {
        return nil;
    }
    NSString *avatarPath = nil;
    if (bThumbnail)
    {
        // 获取缩略图
        avatarPath = [[AppDelegate appDelegate].userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, account]];
    }
    else
    {
        // 获取原图
        avatarPath = [[AppDelegate appDelegate].userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", account]];
    }
    
    UIImage *profileIdAvatar = [UIImage imageWithContentsOfFile:avatarPath];
    
    return profileIdAvatar;
}

// 根据好友的名称获取对应的头像存储路径
+ (NSString *)getFriendThumbnailAvatarPath:(NSString *)friendAccount
{
    if (friendAccount == nil) {
        return nil;
    }
    // 文件小图默认路径
    NSString *stringUserAvatarThumbnailImagePath = [[AppDelegate appDelegate].userProfilesInfo.userAvatarDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.jpg", USER_ACCOUNT_AVATAR_NAME_THUMBNAIL_NAME, friendAccount]];
    return stringUserAvatarThumbnailImagePath;
}


#pragma mark -
#pragma mark Date Method

// 得到当前的系统UINX时间戳(秒)
+ (long)getCurrentSystemDateSecond
{
    // 得到当前的系统时间(秒)
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    NSString *strTimeInterval = [NSString stringWithFormat:@"%ld", (long)timeInterval];
    
    long timeSecond = (long)[strTimeInterval longLongValue];
    
    return timeSecond;
}

// 得到当前的系统UINX时间戳(毫秒)
+ (double)getCurrentSystemDateMillisecond
{
    // 得到当前的系统时间(毫秒)
    //UInt64 timeMillisecond = [[NSDate date] timeIntervalSince1970]*1000;
    
    // 得到当前的系统时间(毫秒)
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    NSString *strTimeInterval = [NSString stringWithFormat:@"%.3lf", timeInterval];
    
    double timeMillisecond = [strTimeInterval doubleValue];
    
    return timeMillisecond;
}

// 得到当前的系统时间Unix时间戳(毫秒)
+ (NSString *)getCurrentSystemDateSecondString
{
    // 得到当前的系统时间(秒)
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    NSString *strTimeInterval = [NSString stringWithFormat:@"%lf", timeInterval];
    
    return strTimeInterval;
}

// 得到当前的系统Unix时间戳(毫秒)
+ (NSString *)getCurrentSystemDateMillisecondString
{
    // 得到当前的系统时间(毫秒)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMddhhmmssSSS";
    NSString *strTimeInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    return strTimeInterval;
}

// 得到当前的系统UINX时间戳(微妙)
+ (NSString *)getCurrentSystemDateMicrosecondString
{
    // 得到当前的系统时间(微妙)
    NSDate *currentDate = [[NSDate alloc] init];
    NSTimeInterval timeInterval = [currentDate timeIntervalSince1970];
    NSString *strTimeInterval = [NSString stringWithFormat:@"%.6lf", timeInterval];
    
    strTimeInterval = [strTimeInterval stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    return strTimeInterval;
}

// 得到当前的系统时间格式化字符串(年月日) 如：“20141215”
+ (NSString *)getCurrentSystemDateDayFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMdd";
    NSString *strTimeInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    return strTimeInterval;
}

// 得到当前的系统时间格式化字符串(年月日时分秒) 如：“20141215192145”
+ (NSString *)getCurrentSystemDateSecondFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMddHHmmss";
    NSString *strTimeInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    // 如果是ios8.1以上系统，则需要对字符串进行处理，移除格式化后，时分秒中的":"，秒与毫秒中的"."
    strTimeInterval = [strTimeInterval stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    return strTimeInterval;
}

// 得到当前的系统时间格式化字符串(年月日时分秒毫秒) 如：“20141215192145368”
+ (NSString *)getCurrentSystemDateMillisecondFormatString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"YYYYMMddHHmmssSSS";
    NSString *strTimeInterval = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
    
    // 如果是ios8.1以上系统，则需要对字符串进行处理，移除格式化后，时分秒中的":"，秒与毫秒中的"."
    strTimeInterval = [strTimeInterval stringByReplacingOccurrencesOfString:@":" withString:@""];
    strTimeInterval = [strTimeInterval stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    return strTimeInterval;
}

// 格式化通话时长为字符串格式
+ (NSString *)stringFormatCallDuration:(long)callDuration
{
    unsigned short minutes = 0;
    unsigned short seconds = 0;
    unsigned short hours = 0;
    NSString *strFromatTime = nil;
    
    // 格式化秒数为：“小时:分钟:秒数”
    if (callDuration >= 60) {
        minutes = callDuration/60;
        
        if (minutes >= 60) {
            hours = minutes/60;
        }
    }
    seconds = callDuration - minutes*60;
    
    // 格式化时间
    if (hours > 0) {
        // 大于一小时的时间格式为：01:12:56
        minutes -= hours*60;
        strFromatTime = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    }
    else {
        // 大于一小时的时间格式为：12:56
        strFromatTime = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    }
    
    return strFromatTime;
}

// 格式化时间显示格式，仅是一天之内的格式化，一天之后显示日期和时间（用于消息的时间判断）
+ (NSString *)getDateString:(NSDate *)date withDateFormatter:(NSDateFormatter*)dataFormatter
{
    if (date == nil || dataFormatter == nil) {
        NSLog(@"WARNING: getDateString date == nil || dataFormatter == nil");
        return nil;
    }
    
    NSString *famrtString = [[NSString alloc] initWithFormat:@"%@", [dataFormatter stringFromDate: date]];
    NSString *formatDate = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: date];
    
    // 获取weekDay
    NSInteger weekDay = [weekdayComponents weekday];
    NSString *weekStr = nil;
    switch (weekDay)
    {
        case 1:
            // 星期日
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_SUNDAY", nil)];
            break;
        case 2:
            // 星期一
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_MONDAY", nil)];
            break;
        case 3:
            // 星期二
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_TUESDAY", nil)];
            break;
        case 4:
            // 星期三
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_WEDNESDAY", nil)];
            break;
        case 5:
            // 星期四
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_THURSDAY", nil)];
            break;
        case 6:
            // 星期五
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_FRIDAY", nil)];
            break;
        case 7:
            // 星期六
            weekStr = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"STR_SATURDAY", nil)];
            break;
        default:
            break;
    }
    
    formatDate = [[NSString alloc] initWithFormat:@"%@ %@", famrtString, weekStr];
    //[famrtString release];
    //[weekStr release];
    
    //[gregorian release];
    
    return formatDate;
}

// 格式化时间显示格式
+ (NSString *)formatDateString:(NSDate *)date
{
    if (date == nil) {
        NSLog(@"WARNING: getDateString date == nil || dataFormatter == nil");
        return nil;
    }
    
    NSString *famrtString = nil;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: date];
    NSInteger month = [weekdayComponents month];
    NSInteger year = [weekdayComponents year];
    NSInteger day = [weekdayComponents day];
    NSInteger weekOfMonth = [weekdayComponents weekOfMonth];
    
    // 当前日期
    // 通过给定的日期和今天的日期，来判断给定的日期与今天的日期相差的天数
    NSDate *todayDate = [NSDate date];
    NSDateComponents *nowWeekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: todayDate];
    NSInteger nowYear = [nowWeekdayComponents year];
    NSInteger nowMonth = [nowWeekdayComponents month];
    NSInteger nowDay = [nowWeekdayComponents day];
    NSInteger nowWeekOfMonth = [nowWeekdayComponents weekOfMonth];
    
    // 昨天
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *yesterdayDate =  [[NSDate alloc] initWithTimeIntervalSinceNow:-secondsPerDay];
    NSDateComponents *yesterdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: yesterdayDate];
    NSInteger yesterdayYear = [yesterdayComponents year];
    NSInteger yesterdayMonth = [yesterdayComponents month];
    NSInteger yesterdayDay = [yesterdayComponents day];
    
    // 返回的时间格式类型有四种  1，当天 （HH:mm）；2，昨天 （昨天 HH:mm） 3，本周（星期三 HH:mm）；4，其它（yyyy年mm月dd日 HH:mm）
    // 今天  返回 时间格式:(HH:mm)
    if (year == nowYear && month == nowMonth && day == nowDay) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        famrtString =  [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:date]];
    }
    else {
        // 昨天  返回 时间格式:(昨天 HH:mm)
        if (year == yesterdayYear && month == yesterdayMonth && day == yesterdayDay) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            
            famrtString =  [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:date]];
        }
        else if (year == nowYear && month == nowMonth && weekOfMonth == nowWeekOfMonth){
            //    3，本周（星期三 HH:mm）
            NSInteger weekDay = [weekdayComponents weekday];
            NSString *weekStr = nil;
            switch (weekDay)
            {
                case 1:
                    // 星期日
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_SUNDAY", nil)];
                    break;
                case 2:
                    // 星期一
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_MONDAY", nil)];
                    break;
                case 3:
                    // 星期二
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_TUESDAY", nil)];
                    break;
                case 4:
                    // 星期三
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_WEDNESDAY", nil)];
                    break;
                case 5:
                    // 星期四
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_THURSDAY", nil)];
                    break;
                case 6:
                    // 星期五
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_FRIDAY", nil)];
                    break;
                case 7:
                    // 星期六
                    weekStr = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_SATURDAY", nil)];
                    break;
                default:
                    break;
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            famrtString = [NSString stringWithFormat:@"%@ %@", weekStr, [dateFormatter stringFromDate:date]];
            
        }
        else {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"HH:mm"];
            famrtString = [NSString stringWithFormat:@"%ld/%02ld/%02ld %@", (long)year, (long)month, (long)day, [dateFormatter stringFromDate:date]];
        }
    }
    
    return famrtString;
}

// 获取英文12月简写
+ (NSString *)getMonthOfEnglish:(NSInteger)month
{
    NSString *monthString = nil;
    switch (month)
    {
        case 1:
            monthString = @"Jan.";
            break;
        case 2:
            monthString = @"Feb.";
            break;
        case 3:
            monthString = @"Mar.";
            break;
        case 4:
            monthString = @"Apr.";
            break;
        case 5:
            monthString = @"May.";
            break;
        case 6:
            monthString = @"June.";
            break;
        case 7:
            monthString = @"July.";
            break;
        case 8:
            monthString = @"Aug.";
            break;
        case 9:
            monthString = @"Sept.";
            break;
        case 10:
            monthString = @"Oct.";
            break;
        case 11:
            monthString = @"Nov.";
            break;
        case 12:
            monthString = @"Dec.";
            break;
        default:
            break;
    }
    return monthString;
}

// 获取历史纪录的日期描述，英文日期方式：月：日：年，中文日期方式：年：月：日
+ (NSString *)getDateString:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    // 通过给定的日期和今天的日期，来判断给定的日期与今天的日期相差的天数
    NSDate *todayDate = [NSDate date];
    
    NSString *comingDate = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: date];
    NSInteger month = [weekdayComponents month];
    NSInteger year = [weekdayComponents year];
    NSInteger day = [weekdayComponents day];
    
    // 判断获取日期的方式是按照英文方式还是中文方式
    BOOL isEnOS = YES;
    if ([[ToolsFunction getLocaliOSLanguage] hasPrefix:@"zh"] || [[ToolsFunction getLocaliOSLanguage] isEqualToString:@"ja"]) {
        isEnOS = NO;
    }
    
    // 当前日期
    NSDateComponents *nowWeekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: todayDate];
    NSInteger nowYear = [nowWeekdayComponents year];
    NSInteger nowMonth = [nowWeekdayComponents month];
    NSInteger nowDay = [nowWeekdayComponents day];
    BOOL isShowMD = NO;
    // 一年之内的日期
    if (nowYear == year)
    {
        if (nowMonth == month)
        {
            switch (labs(nowDay - day)) {
                case 0:
                {
                    // 当天：显示“今天 时:分” -> "Today H:M"
                    comingDate = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_TODAY", nil)];
                }
                    break;
                case 1:
                {
                    if (nowDay > day) {
                        // 昨天：显示“昨天 时:分” -> "Yestoday H:M"
                        comingDate = [NSString stringWithFormat:@"%@", NSLocalizedString(@"STR_YESTERDAY", nil)];
                    }
                    else
                    {
                        isShowMD = YES;
                    }
                }
                    break;
                default:
                    isShowMD = YES;
                    break;
            }
        }
        else
        {
            isShowMD = YES;
        }
    }
    else
    {
        // 往年：显示“xx年x月x日” -> "Feb. 3 2001 H:M"
        if (isEnOS)
        {
            // 英文系统
            NSString *monthString = [ToolsFunction getMonthOfEnglish:month];
            comingDate = [NSString stringWithFormat: @"%@ %ld %ld", monthString, (long)day, (long)year];
        }
        else
        {
            comingDate = [NSString stringWithFormat:@"%ld/%ld/%02ld", (long)year, (long)month, (long)day];
        }
    }
    
    if (isShowMD)
    {
        // 当年：显示“x月x日 时:分 ” -> "Feb. 3 H:M"
        if (isEnOS)
        {
            // 英文系统
            NSString *monthString = [ToolsFunction getMonthOfEnglish: month];
            comingDate = [NSString stringWithFormat:@"%@ %ld", monthString, (long)day];
        }
        else
        {
            comingDate = [NSString stringWithFormat:@"%ld%@%02ld%@", (long)month, NSLocalizedString(@"STR_MONTH", nil), (long)day, NSLocalizedString(@"STR_DAY", nil)];
        }
    }
    return comingDate;
}

// 获取时间描述  在外面release返回值
// 显示“时:分” -> "H:M"
+ (NSString *)getTimeString:(NSDate *)date
{
    if (date == nil) {
        return nil;
    }
    
    NSString *comingDate = nil;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *weekdayComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: date];
    NSInteger hour = [weekdayComponents hour];
    NSInteger minute = [weekdayComponents minute];
    
    // 显示“时:分” -> "H:M"
    comingDate = [NSString stringWithFormat:@"%ld:%02ld", (long)hour, (long)minute];
    return comingDate;
}

// 获取两个日期是否在同一天
+ (BOOL)sameDayDate:(NSDate *)oneDate andAnotherDate:(NSDate *)otherDate
{
    if (oneDate == nil || otherDate == nil) {
        //NSLog(@"WARNING: sameDayDate oneDate == nil || otherDate == nil");
        return NO;
    }
    
    BOOL flag = NO;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *oneComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: oneDate];
    NSDateComponents *otherComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: otherDate];
    
    NSInteger oneYear = [oneComponents year];
    NSInteger oneMonth = [oneComponents month];
    NSInteger oneDay = [oneComponents day];
    NSInteger otherYear = [otherComponents year];
    NSInteger otherMonth = [otherComponents month];
    NSInteger otherDay = [otherComponents day];
    
    if (oneYear == otherYear && oneMonth == otherMonth && oneDay == otherDay) {
        flag =  YES;
    }
    
    return flag;
}

// 判断指定的时间是否在两个时间之间
+ (BOOL)isMiddleCurrentDate:(NSDate *)currentDate bettwenStartDate:(NSDate *)startDate inEndDate:(NSDate *)endDate
{
    BOOL isMiddle = NO;
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"HHmm"];
    NSInteger nStartTime = [[dateFormatter stringFromDate:startDate] integerValue];
    
    [dateFormatter setDateFormat:@"HHmm"];
    NSInteger nEndTime = [[dateFormatter stringFromDate:endDate] integerValue];
    
    [dateFormatter setDateFormat:@"HHmm"];
    NSInteger nCurrentTime = [[dateFormatter stringFromDate:currentDate] integerValue];
    //[dateFormatter release];
    // 判断是否为当天的时间
    if (nEndTime > nStartTime) {
        // 在当天时间内，判断当前时间是否在开始时间和结束时间之间
        if (nCurrentTime >= nStartTime && nCurrentTime <= nEndTime) {
            isMiddle = YES;
        }
    }
    else
    {
        // 不在当天时间内，判断当前时间是否比开始时间大，或者比结束时间小，则认为是在其之间
        if (nCurrentTime >= nStartTime || nCurrentTime <= nEndTime) {
            isMiddle = YES;
        }
    }
    return isMiddle;
}

// 获取两个日期是否在同一时刻 timeBlank是时间误差（单位：分钟）  误差以内都算是同一时刻
// 返回：4种情况 ：1，同一时刻  2，不是同一时刻，但是当天 3,昨天的 4，不是当天，也不是昨天，但是同一周 4，其他情况
+ (BOOL)sameDayWithNewDate:(NSDate *)newDate andOldDate:(NSDate *)oldDate withTimeBlank:(int)timeBlank
{
    if (newDate == nil || oldDate == nil) {
        
        return NO;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *oneComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: newDate];
    NSDateComponents *otherComponents = [gregorian components:(NSMonthCalendarUnit | NSYearCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate: oldDate];
    
    NSInteger newYear  = [oneComponents year];
    NSInteger newMonth = [oneComponents month];
    NSInteger newDay   = [oneComponents day];
    NSInteger newHour  = [oneComponents hour];
    NSInteger newMin   = [oneComponents minute];
    
    NSInteger oldYear  = [otherComponents year];
    NSInteger oldMonth = [otherComponents month];
    NSInteger oldDay   = [otherComponents day];
    NSInteger oldHour  = [otherComponents hour];
    NSInteger oldMin   = [otherComponents minute];
    
    if (newYear == oldYear && newMonth == oldMonth && newDay == oldDay && newHour == oldHour && newMin - oldMin <= timeBlank) {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark -
#pragma mark AES Crypto Extensions Method

// AES字符串加密接口，支持128/256 bit|CBC|PKCS7Padding解密
+ (NSString *)AESEncryptString:(NSString *)sourceString
                       withKey:(NSString *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits
{
    // 1) Encrypt
    NSData * sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSData * encryptedData = nil;
    NSString * encryptedStr = nil;
    
    switch (nBits) {
        case AES_128_BIT:
            // Encrypt 128 bit
            encryptedData = [sourceData AES128EncryptWithKey:passphrase withIV:iv];
            break;
            
        case AES_256_BIT:
            // Encrypt 256 bit
            encryptedData = [sourceData AES256EncryptWithKey:passphrase withIV:iv];
            break;
            
        default:
            break;
    }
    
    if (encryptedData) {
        // 2) Encode Base 64
        //[Base64 initialize];
        encryptedStr = [Base64 encode:encryptedData];
    }
    
    //NSLog(@"TOOLS: AESEncryptString: sourceString = %@, encryptedData = %@, encryptedStr = %@", sourceString, encryptedData, encryptedStr);
    
    return encryptedStr;
}

// AES字符串解密接口，支持128/256 bit|CBC|PKCS7Padding解密
+ (NSString *)AESDecryptString:(NSString *)decryptString
                       withKey:(NSString *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits
{
    NSString *sourceString = nil;
    
    // 1) Decode Base 64
    NSData *b64DecData = [Base64 decode:decryptString];
    if (b64DecData) {
        NSData *decryptedData = nil;
        
        // 2) Decrypt
        switch (nBits) {
            case AES_128_BIT:
                // Decrypt 128 bit
                decryptedData = [b64DecData AES128DecryptWithKey:passphrase withIV:iv];
                break;
                
            case AES_256_BIT:
                // Decrypt 256 bit
                decryptedData = [b64DecData AES256DecryptWithKey:passphrase withIV:iv];
                break;
                
            default:
                break;
        }
        
        if (decryptedData)
        {
            NSString *decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
            sourceString = [NSString stringWithString:[decryptedStr stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    }
    
    //NSLog(@"TOOLS: AESDecryptString: decryptString = %@, sourceString = %@", decryptString, sourceString);
    
    return sourceString;
}

/*!
 * AES字符串加密接口，支持128/256 bit|CBC|PKCS7Padding解密
 * @param sourceString 加密前的原字符串
 * @param passphrase 加密的密钥，使用字节char*
 * @param iv 加密初始化向量，可以为nil
 * @param nBits 整型-128/256位
 * @return NSString 加密后的经过base64编码的字符串
 */
+ (NSString *)AESEncryptString:(NSString *)sourceString
                  withKeyBytes:(unsigned char *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits
{
    // 1) Encrypt
    NSData * sourceData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
    NSData * encryptedData = nil;
    NSString * encryptedStr = nil;
    
    switch (nBits) {
        case AES_128_BIT:
            // Encrypt 128 bit
            encryptedData = [sourceData AES128EncryptWithKeyBytes:passphrase withIV:iv];
            break;
            
        case AES_256_BIT:
            // Encrypt 256 bit
            encryptedData = [sourceData AES256EncryptWithKeyBytes:passphrase withIV:iv];
            break;
            
        default:
            break;
    }
    
    if (encryptedData) {
        // 2) Encode Base 64
        //[Base64 initialize];
        encryptedStr = [Base64 encode:encryptedData];
    }
    
    //NSLog(@"TOOLS: AESEncryptString: sourceString = %@, encryptedData = %@, encryptedStr = %@", sourceString, encryptedData, encryptedStr);
    
    return encryptedStr;
}

/*!
 * AES字符串解密接口，支持128/256 bit|CBC|PKCS7Padding解密
 * @param decryptString 解密前的加密过的字符串
 * @param passphrase 加密的密钥，使用字节char*
 * @param iv 加密初始化向量，可以为nil
 * @param nBits 整型-128/256位
 * @return NSString 加密后的经过base64编码的字符串
 */
+ (NSString *)AESDecryptString:(NSString *)decryptString
                  withKeyBytes:(unsigned char *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits
{
    NSString *sourceString = nil;
    
    // 1) Decode Base 64
    NSData *b64DecData = [Base64 decode:decryptString];
    if (b64DecData) {
        NSData *decryptedData = nil;
        
        // 2) Decrypt
        switch (nBits) {
            case AES_128_BIT:
                // Decrypt 128 bit
                decryptedData = [b64DecData AES128DecryptWithKeyBytes:passphrase withIV:iv];
                break;
                
            case AES_256_BIT:
                // Decrypt 256 bit
                decryptedData = [b64DecData AES256DecryptWithKeyBytes:passphrase withIV:iv];
                break;
                
            default:
                break;
        }
        
        if (decryptedData)
        {
            NSString *decryptedStr = [[NSString alloc] initWithData:decryptedData encoding:NSUTF8StringEncoding];
            sourceString = [NSString stringWithString:[decryptedStr stringByReplacingOccurrencesOfString:@" " withString:@""]];
        }
    }
    
    //NSLog(@"TOOLS: AESDecryptString: decryptString = %@, sourceString = %@", decryptString, sourceString);
    
    return sourceString;
}

#pragma mark -
#pragma mark 根据版本号判断判断是否展示引导页

// Jacky.Chen:2016.02.24,添加是否展示引导页外部调用方法，新特性页面版本号在每一次更新新特性页面后需要更换versionKey
+ (void)showNewFeatureView
{
    //获取版本号键值
    NSString *versionKey = NEWFEATURE_VERSION;
    //取出版本号
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *version = [defaults objectForKey:NEWFEATURE_VERSION];
    
    // 判断该版本新特性是否被看过
    if ([version isEqualToString:@"True"]) {
        // 如果已经看过则直接返回
        return;
    }
        //没有看过则展示新特性
        [NewFeatureView show];
        //存储新版本
        [defaults setObject:@"True" forKey:versionKey];
        //强制立即存储
        [defaults synchronize];
    
}

@end
