//
//  NSData+AESCryptoExtensions.h
//  AppMobile
//
//  Created by Gray on 13-8-9.
//  Copyright (c) 2013年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (AESCryptoExtensions)

/*!
 * AES256 Encrypt - AES256/CBC/PKCS7Padding
 * @param key 加密使用的密钥
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256EncryptWithKey:(NSString*)key withIV:(NSString *)iv;

/*!
 * AES 256 bit Decrypt - AES256/CBC/PKCS7Padding
 * @param key 解密使用的密钥
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256DecryptWithKey:(NSString*)key withIV:(NSString *)iv;

/*!
 * AES256 Encrypt - AES256/CBC/PKCS7Padding
 * @param key 加密使用的密钥，使用字节char *
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256EncryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv;

/*!
 * AES 256 bit Decrypt - AES256/CBC/PKCS7Padding
 * @param key 解密使用的密钥，使用字节char *
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256DecryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv;

/*!
 * AES 128 bit Encrypt - AES128/CBC/PKCS7Padding
 * @param key 加密使用的密钥
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128EncryptWithKey:(NSString*)key withIV:(NSString *)iv;

/*!
 * AES 128 bit Decrypt - AES128/CBC/PKCS7Padding
 * @param key 解密使用的密钥
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128DecryptWithKey:(NSString*)key withIV:(NSString *)iv;

/*!
 * AES 128 bit Encrypt - AES128/CBC/PKCS7Padding
 * @param key 加密使用的密钥，使用字节char *
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128EncryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv;

/*!
 * AES 128 bit Decrypt - AES128/CBC/PKCS7Padding
 * @param key 解密使用的密钥，使用字节char *
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128DecryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv;

@end
