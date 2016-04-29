//
//  RegularCheckTools.h
//  RKCloudDemo
//
//  Created by 程荣刚 on 15/4/29.
//  Copyright (c) 2015年 xarongke. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *字符串的最短长度
 */
#define TEXTFIELD_STRING_MIN_LENGTH          6

/**
 *字符串的最大长度
 */
#define TEXTFIELD_STRING_MAX_LENGTH          20

/**
 *姓名的最大长度
 */
#define TEXTFIELD_STRING_NAME_MAX_LENGTH     31



@interface RegularCheckTools : NSObject

/**
 * 校验密码的组成格式，密码只能由6-20位的数字和字母组成
 */
+ (BOOL)checkPwd:(NSString *)pwd;

/**
 * 判断 是否是 email
 */
+ (BOOL)isEmail:(NSString *)email;

/**
 * 判断 是否是 mobile
 */
+ (BOOL)isMobile:(NSString *)mobile;

// 判断 是否是 座机号码
+ (BOOL)isLandlineTelephone:(NSString *)telephone;

/**
 * 判断 是否是 PinCode
 */
+ (BOOL)isPinCode:(NSString *)testCode;

/**
 * 判断姓名字符串是否超过限定长度
 */
+ (BOOL)isExceedUserNameLength:(NSString *)userName;

// 验证价格是否格式正确
+ (BOOL)isCheckPrice:(NSString *)price;

// 验证帐号是否由6-20位字母与数字组成，并以字母开头
+ (BOOL)isCheckAccount:(NSString *)userName;

// 验证搜索的用户名是否为：搜索条件由数字和字母组成，并以字母开头
+ (BOOL)isCheckSearchUserName:(NSString *)userName;

@end
