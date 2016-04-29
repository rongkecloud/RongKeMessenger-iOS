//
//  RegularCheckTools.m
//  RKCloudDemo
//
//  Created by 程荣刚 on 15/4/29.
//  Copyright (c) 2015年 xarongke. All rights reserved.
//

#import "RegularCheckTools.h"

@implementation RegularCheckTools

// 校验密码的组成格式，密码只能由6-20位的数字和字母组成
+ (BOOL)checkPwd:(NSString *)pwd
{
    if (pwd.length == 0 || pwd.length < TEXTFIELD_STRING_MIN_LENGTH || pwd.length > TEXTFIELD_STRING_MAX_LENGTH)
    {
        return NO;
    }
    NSString *number= @"^[0-9a-zA-Z]*$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:pwd];
}

// 判断 是否是 email
+ (BOOL)isEmail:(NSString *)email
{
    NSString *number= @"^(([0-9a-zA-Z]+)|([0-9a-zA-Z]+[_.0-9a-zA-Z-]*[0-9a-zA-Z]+))@([a-zA-Z0-9-]+[.])+([a-zA-Z]{2}|net|NET|com|COM|gov|GOV|mil|MIL|org|ORG|edu|EDU|int|INT)$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:email];
}

// 判断 是否是 mobile
+ (BOOL)isMobile:(NSString *)mobile
{
    NSString *number = @"^1[34578][0-9]{9}$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:mobile];
}

// 判断 是否是 座机号码
+ (BOOL)isLandlineTelephone:(NSString *)telephone
{
    NSString *number = @"^(0[1-9]{2,3}-)?[1-9]\\d{6,7}$";
    NSPredicate *predicateNumber = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", number];
    return [predicateNumber evaluateWithObject:telephone];
}

// 判断 是否是 testCode
+ (BOOL)isPinCode:(NSString *)testCode
{
    NSString *number = @"^[0-9]{6}$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:testCode];
}

// 判断姓名字符串是否超过限定长度
+ (BOOL)isExceedUserNameLength:(NSString *)userName
{
    // 验证了姓名的长度不超过20位
    if (userName.length < TEXTFIELD_STRING_NAME_MAX_LENGTH && userName.length > 0)
    {
        return YES;
    }
    else {
        return NO;
    }
}

// 验证价格是否格式正确
+ (BOOL)isCheckPrice:(NSString *)price
{
    if (price == nil || [price isEqualToString:@""]){
        return NO;
    }
    
    NSString *exp1 = @"^[1-9][0-9]{0,7}";
    NSString *exp2 = @"^[1-9][0-9]{0,7}[.][0-9]{1,2}";
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", exp1];
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", exp2];
    
    if ([predicate1 evaluateWithObject:price] || [predicate2 evaluateWithObject:price])
    {
        return YES;
    }
    
    return NO;
}

// 验证帐号是否由6-20位字母与数字组成，并以字母开头
+ (BOOL)isCheckAccount:(NSString *)userName
{
    if (userName == nil || [userName isEqualToString:@""]){
        return NO;
    }
    
    // Gray.Wang:2016.03.18:修正正则表达式，验证注册和登录的帐号是否格式正确
    // "^[a-zA-Z][0-9a-zA-Z]{5,19}$"
    NSString *exp1 = @"^[a-zA-Z][0-9a-zA-Z]{5,19}$";
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", exp1];
    
    if ([predicate1 evaluateWithObject:userName])
    {
        return YES;
    }
    
    return NO;
}

// 验证搜索的用户名是否为：搜索条件由数字和字母组成，并以字母开头
+ (BOOL)isCheckSearchUserName:(NSString *)userName
{
    if (userName == nil || [userName isEqualToString:@""]){
        return NO;
    }
    
    // "^[a-zA-Z][0-9a-zA-Z]*$"
    NSString *exp1 = @"^[a-zA-Z][0-9a-zA-Z]*$";
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", exp1];
    
    if ([predicate1 evaluateWithObject:userName])
    {
        return YES;
    }
    
    return NO;
}

@end
