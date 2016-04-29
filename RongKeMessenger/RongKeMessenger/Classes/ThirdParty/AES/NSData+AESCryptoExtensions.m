//
//  NSData+AESCryptoExtensions.m
//  AppMobile
//
//  Created by Gray on 13-8-9.
//  Copyright (c) 2013年 西安融科通信技术有限公司. All rights reserved.
//

#import "NSData+AESCryptoExtensions.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AESCryptoExtensions)

/*!
 * AES256 Encrypt - AES256/CBC/PKCS7Padding
 * @param key 加密使用的密钥
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256EncryptWithKey:(NSString*)key withIV:(NSString *)iv {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES 256 bit Decrypt - AES256/CBC/PKCS7Padding
 * @param key 解密使用的密钥
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256DecryptWithKey:(NSString *)key withIV:(NSString *)iv {
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES256 Encrypt - AES256/CBC/PKCS7Padding
 * @param key 加密使用的密钥，使用字节char *
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256EncryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    memcpy(&keyPtr, key, sizeof(keyPtr));
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES 256 bit Decrypt - AES256/CBC/PKCS7Padding
 * @param key 解密使用的密钥，使用字节char *
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES256DecryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv
{
    // 'key' should be 32 bytes for AES256, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES256 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    memcpy(&keyPtr, key, sizeof(keyPtr));
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES256,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}


/*!
 * AES 128 bit Encrypt - AES128/CBC/PKCS7Padding
 * @param key 加密使用的密钥
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128EncryptWithKey:(NSString*)key withIV:(NSString *)iv {
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES 128 bit Decrypt - AES128/CBC/PKCS7Padding
 * @param key 解密使用的密钥
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128DecryptWithKey:(NSString*)key withIV:(NSString *)iv {
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES 128 bit Encrypt - AES128/CBC/PKCS7Padding
 * @param key 加密使用的密钥，使用字节char *
 * @param iv 加密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128EncryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv
{
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    memcpy(&keyPtr, key, sizeof(keyPtr));
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

/*!
 * AES 128 bit Decrypt - AES128/CBC/PKCS7Padding
 * @param key 解密使用的密钥，使用字节char *
 * @param iv 解密初始化向量，optional initialization vector
 * @return NSData 加密后的数据
 */
- (NSData*)AES128DecryptWithKeyBytes:(unsigned char *)key withIV:(NSString *)iv
{
    // 'key' should be 16 bytes for AES128, will be null-padded otherwise
    char keyPtr[kCCKeySizeAES128 + 1]; // room for terminator (unused)
    bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
    
    char ivPtr[kCCBlockSizeAES128 + 1]; // room for terminator (unused)
    bzero(ivPtr, sizeof(ivPtr)); // fill with zeroes (for iv)
    
    // fetch key data
    memcpy(&keyPtr, key, sizeof(keyPtr));
    
    // fetch iv data
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [self length];
    
    //See the doc: For block ciphers, the output size will always be less than or
    //equal to the input size plus the size of one block.
    //That's why we need to add the size of one block here
    size_t bufferSize           = dataLength + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    NSData * dataAES = nil;
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr /* initialization vector (optional) */,
                                          [self bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess)
    {
        //the returned NSData takes ownership of the buffer and will free it on deallocation
        dataAES = [NSData dataWithBytes:buffer length:numBytesDecrypted];
    }
    
    free(buffer); //free the buffer;
    return dataAES;
}

@end
