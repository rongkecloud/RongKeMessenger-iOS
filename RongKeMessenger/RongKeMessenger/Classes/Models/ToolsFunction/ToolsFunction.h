//
//  RKCloudChatToolsFunction.h
//  云视互动即时通讯SDK
//
//  Created by www.rongkecloud.com on 14/12/11.
//  Copyright (c) 2014年 西安融科通信技术有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "Definition.h"
#import <AVFoundation/AVAsset.h>

#define AES_128_BIT  128 // 128位的AES加密
#define AES_256_BIT  256 // 256位的AES加密

// 音频输出设备模式
enum _outputs_device_mode {
    IPHONE_OUTPUT_DEFAULT = 0,
    IPHONE_OUTPUT_HEADPHONES = 1,    // iPhone听筒或有线耳机（如果即没有连接耳机，有没有蓝牙耳机，则默认iPhone输出的 route = ReceiverAndMicrophone）
    IPHONE_OUTPUT_SPEAKER = 2,       // iPhone外置扬声器
    IPHONE_OUTPUT_BLUETOOTH_HFP = 3  // iPhone已连接蓝牙耳机
};

@interface ToolsFunction : NSObject

#pragma mark -
#pragma mark Sound & Device & iOS Local Info

// play sound to Speaker/Handset
+ (AVAudioPlayer *)playSound:(NSString*)soundFilePath
           withNumberOfLoops:(NSInteger)number
             outputToSpeaker:(BOOL)isSpeaker;

// open or close speaker
+ (void)enableSpeaker:(BOOL)enable;
// set Audio Route Type Of Output Device
+ (void)setAudioRouteTypeOfOutputDevice:(NSInteger)outputType;
// 获取设备状态，是否插入耳机，如果插入耳机或者添加蓝牙耳机，则返回“YES"
+ (NSInteger)getAudioRouteTypeOfOutputDevice;
// Get Current Bluetooth Device Name
+ (NSString *)getCurrentBluetoothDeviceName;

/// 检测视频设备是否可用.
+ (BOOL)checkVideoDeviceIsAvailable;
// 检测音频设备是否可用
+ (BOOL)checkAudioDeviceIsAvailable;

/// 是否是iPhone设备
+ (BOOL)isiPhoneDevice;
// 获取iOS设备硬件类型，返回枚举型（iPhone3GS、iPhone4、iPhone4S、iPhone5）
+ (IOSMachineType)iOSMachineHardwareType;

// Get Local iOS language
+ (NSString *)getLocaliOSLanguage;

/// 返回iOS系统的主版本号.
+ (NSInteger)getCurrentiOSMajorVersion;
// 返回iOS系统的全版本号
+ (NSString *)getCurrentiOSVersion;

// 判断是否是ios7之前的版本
+ (BOOL)iSiOS7Earlier;


#pragma mark -
#pragma mark Network

// Check the reachability of internet
+ (BOOL)checkInternetReachability;
// 判断当前网络是否是wifi
+ (BOOL)checkWifiInternet;
// 判断当前网络是否是WWAN
+ (BOOL)checkWWANInternet;


#pragma mark -
#pragma mark File Operation Function

// 判断文件是否存在
+ (BOOL)isFileExistsAtPath:(NSString *)filePath;
// 判断目录是否存在
+ (BOOL)isFileExistsAtPath:(NSString *)filePath isDirectory:(BOOL *)isDirectory;

// 通过文件路径获取文件大小
+ (NSString *)getFileSizeByPath:(NSString *)filePath;

// 删除临时文件夹中所有的文件
+ (void)deleteAllFilesOfTempDirectory;
// 删除本地存储的文件或文件夹
+ (void)deleteFileOrDirectoryForPath:(NSString *)pathString;

#pragma mark -
#pragma mark URL Encoding/Decoding Function

// 只针对特殊符号进行处理的URL编码方法
+ (NSString *)encodeURL:(NSString *)str;
// 对文本进行URL一次编码，stringText: 编码的文本字符串
+ (NSString *)urlEncodeUTF8String:(NSString *)stringText;
// 对文本进行URL一次解码，stringText: 解码的文本字符串
+ (NSString *)urlDecodeUTF8String:(NSString *)stringText;


#pragma mark -
#pragma mark Common Function
// 判断时候是小秘书账号
+ (BOOL)isRongKeServiceAccount:(NSString *)friendAccount;
// 注册APNS Push通知
+ (void)registerAPNSNotifications;
// 是否关闭了系统的APNS通知（YES-关闭了，NO-没有关闭）
+ (BOOL)isDisableApnsNotifications;

// 使用原生的电话切换到GSM呼叫
+ (void)callToGSM:(NSString *)phoneNumber;


#pragma mark -
#pragma mark StatusBar Prompt

//显示或隐藏状态栏新消息提示窗口
+ (void)showStatusBarPrompt:(NSString *)promptString
               withDuration:(NSInteger)duration
                       type:(NSInteger)promptType;
// 采用淡出效果（2秒钟）隐藏状态栏提示信息
+ (void)hideStatusBarPrompt;
// 移除已经消失的状态栏提示窗口
+ (void)removeStatusBarPrompt;
//程序退出时调用此函数释放消息提示窗口所占用的资源
+ (void)destroyStatusBarPrompt;


#pragma mark -
#pragma mark Button Function

// 设置自定义button
+ (void)setBorderColorAndBlueBackGroundColorFor:(UIBorderButton *)button;
// 设置自定义button
+ (void)setBorderColorAndRedBackGroundColorFor:(UIBorderButton *)button;


#pragma mark -
#pragma mark String Method

// 获取每通电话的CallID（格式：user id -unix epoch time(s)-2 digits random number，如：24000001-1307516199-83）
+ (NSString *)getCurrentCallID:(NSString *)userID;

// 从字串中查找是否存在URL
+ (BOOL)isExistUrlInString:(NSString *)textString;

// 计算文件大小为带单位的字符串（B、KB、M、G）
+ (NSString *)stringFileSizeWithBytes:(unsigned long)fileSizeBytes;
// 比较所有版本号是否大（任意版本号格式：5.0/6.0.1/6.1.4/7.0...）
+ (BOOL)compareAllVersions:(NSString *)highVersion withCompare:(NSString *)lowVersion;

// 获取字符串的长度
+ (CGSize)getSizeFromString:(NSString *)stringText withFont:(UIFont *)font;
// 获取字符串的长度
+ (CGSize)getSizeFromString:(NSString *)stringText withFont:(UIFont *)font constrainedToSize:(CGSize)maxSize;
// 绘制字符串
+ (void)drawString:(NSString *)textString inRect:(CGRect)textRect withFont:(UIFont *)font;

// Jacky.Chen:2016.03.05: 判断字符串是否全为空格
+ (BOOL) isEmptySpace:(NSString *) stringText;

#pragma mark -
#pragma mark label Method

// 计算文本字符串包含表情符号的文本Cell的Size(按照最大的高度和最大的宽度来计算)
// 解决了全部都是图标的泡泡行数不正确的问题，使用了将文本中所有的表情图标，
// 每个图标都换成五个"[[[[["（21个宽度，图标宽度是20.75），这样计算出来的文本的行数误差几乎为0
+ (CGSize)getTextCellSizeFromString:(NSString *)stringText withMaxWidth:(float)contentWidth;

#pragma mark - String Size Calculate

// 通过UITextView获取文本字串的size
+ (CGSize)getTextCellSizeByUITextView:(NSString *)stringText
                         withFontSize:(UIFont *)currentTextFontSize
                    withTextShowWidth:(CGFloat)cgfTextWidth
                   withTextLineHeight:(CGFloat)cgfTextLineHeight
                      withTextMaxLine:(NSInteger)nTextMaxLine;
// 通过UIView获取文本字串的size
+ (CGSize)getTextCellSizeByUIView:(NSString *)stringText
                     withFontSize:(UIFont *)currentFontSize
                     withMaxWidth:(CGFloat)contentWidth
               withTextLineHeight:(CGFloat)cgfTextLineHeight
                  withTextMaxLine:(NSInteger)nTextMaxLine;

#pragma mark -
#pragma mark Vedio Method

+ (NSURL *)videoConvertToMp4:(AVURLAsset *)avAsset;

#pragma mark -
#pragma mark UI & Animation Setting
// Animation
+ (void)moveUpTransition:(BOOL)bUp forLayer:(CALayer*)layer;
+ (void)setKeyboardHidden: (BOOL)isHidden;
// Load Table Cell from NIB file
+ (id)loadTableCellFromNib:(NSString*)nib;
// Load Image from Resource (NOTE: release image manually)
+ (UIImage*)loadImageFromResource:(NSString*)imagename;



#pragma mark -
#pragma mark Property List

/* Read a property list from resource file
 plistName - name of property list in resource
 */
+ (NSDictionary *)loadPropertyList:(NSString *)plistName;

/// 读取plist资源数据
+ (NSMutableDictionary *)loadResourceFromPlist:(NSString *)fileName
                            withDictionaryPath:(NSString *)dictionaryPath;
/// 删除plist资源数据.
+ (BOOL)deleteResourceFromPlist:(NSString *)fileName
             withDictionaryPath:(NSString *)dictionaryPath;
/// 保存plist文件数据.
+ (void)saveResourceToPlist:(NSMutableDictionary *)contactPhoneDic
               withFileName:(NSString *)fileName
         withDictionaryPath:(NSString *)dictionaryPath;

// 采用字典将表情的转义字符转化为自定义的短语表示
+ (NSString *)translateEmotionString:(NSString *)content withDictionary:(NSDictionary*)dict;


#pragma mark -
#pragma mark Image Operate Function

// 旋转拍照后的图片
+ (UIImage *)rotateImage:(UIImage *)sourceImage;
// 将图片旋转为正确的方向
+ (UIImage *)fixOrientation:(UIImage *)aImage;

// 接收和发送的图片在保存缩略图时，最长边不超过120，若有超过的均压缩至最长边为120。但显示时，最长边大小为120，此方法用来将缩略图的图片长宽，换算成显示的长和宽。
+ (CGSize)sizeScaleFixedThumbnailImageSize:(CGSize)sourceImageSize;
// 把image缩放到给定的size
+ (UIImage *)scaleImageSize:(UIImage *)sourceImage toSize:(CGSize)imageSize;
// 切割图片为圆角
+ (id)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger) radius;

// 根据颜色生成纯色的图片
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

// 拍照后获取旋转后的照片
+ (UIImage *)getPhotographRotateImage:(id)finishQBPickingMediaWithInfo;

// 根据最大边的尺寸进行等比例缩放原图
+ (UIImage *)scaleFixedSizeForImage:(UIImage *)sourceImage;
// 动态压缩图片并写入文件（MMS和Moment统一算法方法）
+ (void)dynamicCompressImageAndWriteToFile:(UIImage *)imageSource withFilePath:(NSString *)filePath;
// 生成缩略图并进行等比例缩放，使其最大边均小于
+ (UIImage *)thumbnailScaleForMomentImage:(UIImage *)sourceImage;
// 保存缩略图到本地文件中（默认宽度为0，返回值大于0则认为缩略图保存成功）
+ (BOOL)saveThumbnailToFileForMomentImage:(UIImage *)imageSource withFilePath:(NSString *)thumbnailImagePath;
// 获取当前profile的头像
+ (UIImage *)getFriendAvatarWithFriendAccount:(NSString *)account andIsThumbnail:(BOOL)bThumbnail;
// 根据好友的名称获取对应的头像存储路径
+ (NSString *)getFriendThumbnailAvatarPath:(NSString *)friendAccount;


#pragma mark -
#pragma mark Date Method

// 得到当前的系统时间Unix时间戳(毫秒)
+ (long)getCurrentSystemDateSecond;
// 得到当前的系统Unix时间戳(毫秒)
+ (double)getCurrentSystemDateMillisecond;

/// 得到当前的系统时间Unix时间戳(秒)字符串
+ (NSString *)getCurrentSystemDateSecondString;
/// 得到当前的系统Unix时间戳(毫秒)字符串
+ (NSString *)getCurrentSystemDateMillisecondString;
// 得到当前的系统UINX时间戳(微妙)字符串
+ (NSString *)getCurrentSystemDateMicrosecondString;

// 得到当前的系统时间格式化字符串(年月日) 如：“20141215”
+ (NSString *)getCurrentSystemDateDayFormatString;
// 得到当前的系统时间格式化字符串(年月日时分秒) 如：“20141215192145”
+ (NSString *)getCurrentSystemDateSecondFormatString;
// 得到当前的系统时间格式化字符串(年月日时分秒毫秒) 如：“20141215192145368”
+ (NSString *)getCurrentSystemDateMillisecondFormatString;

// 格式化通话时长为字符串格式
+ (NSString *)stringFormatCallDuration:(long)callDuration;

// 格式化时间显示格式，仅是一天之内的格式化，一天之后显示日期和时间（用于消息的时间判断）
+ (NSString *)getDateString:(NSDate *)date withDateFormatter:(NSDateFormatter*)dataFormatter;
// 获取英文12月简写
+ (NSString *)getMonthOfEnglish:(NSInteger)month;
// 格式化时间显示格式
+ (NSString *)formatDateString:(NSDate *)date;
// 获取历史纪录的日期描述，英文日期方式：月：日：年，中文日期方式：年：月：日
+ (NSString *)getDateString:(NSDate *)date;
// 获取时间描述，显示“时:分” -> "H:M"
+ (NSString *)getTimeString:(NSDate *)date;
// 获取两个日期是否在同一天
+ (BOOL)sameDayDate:(NSDate *)oneDate andAnotherDate:(NSDate *)otherDate;
// 判断指定的时间是否在两个时间之间
+ (BOOL)isMiddleCurrentDate:(NSDate *)currentDate bettwenStartDate:(NSDate *)startDate inEndDate:(NSDate *)endDate;
// 获取两个日期是否在同一时刻 timeBlank是时间误差（单位：分钟），误差以内都算是同一时刻
// 返回：4种情况 ：1，同一时刻  2，不是同一时刻，但是当天 3，不是当天，但是同一周 4，其他情况
+ (BOOL)sameDayWithNewDate:(NSDate *)newDate andOldDate:(NSDate *)oldDate withTimeBlank:(int)timeBlank;


#pragma mark -
#pragma mark AES Crypto Extensions Method
/*!
 * AES字符串加密接口，支持128/256 bit|CBC|PKCS7Padding解密
 * @param sourceString 加密前的原字符串
 * @param passphrase 加密的密钥
 * @param iv 加密初始化向量，可以为nil
 * @param nBits 整型-128/256位
 * @return NSString 加密后的经过base64编码的字符串
 */
+ (NSString *)AESEncryptString:(NSString *)sourceString
                       withKey:(NSString *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits;

/*!
 * AES字符串解密接口，支持128/256 bit|CBC|PKCS7Padding解密
 * @param decryptString 解密前的加密过的字符串
 * @param passphrase 加密的密钥
 * @param iv 加密初始化向量，可以为nil
 * @param nBits 整型-128/256位
 * @return NSString 解密后的明文字符串
 */
+ (NSString *)AESDecryptString:(NSString *)decryptString
                       withKey:(NSString *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits;

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
                        useBit:(NSInteger)nBits;

/*!
 * AES字符串解密接口，支持128/256 bit|CBC|PKCS7Padding解密
 * @param decryptString 解密前的加密过的字符串
 * @param passphrase 加密的密钥，使用字节char*
 * @param iv 加密初始化向量，可以为nil
 * @param nBits 整型-128/256位
 * @return NSString 解密后的明文字符串
 */
+ (NSString *)AESDecryptString:(NSString *)decryptString
                  withKeyBytes:(unsigned char *)passphrase
                        withIV:(NSString *)iv
                        useBit:(NSInteger)nBits;
#pragma mark -
#pragma mark 根据版本号判断判断是否展示引导页
// Jacky.Chen:2016.02.24,添加是否展示引导页外部调用方法
+ (void)showNewFeatureView;
@end
