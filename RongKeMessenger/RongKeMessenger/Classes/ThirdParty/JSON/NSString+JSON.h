//
//  NSString+JSON.h
//  RongKeMessenger
//
//  Created by Gray on 15/1/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Adds JSON parsing methods to NSString
 
 This is a category on NSString that adds methods for parsing the target string.
 */
@interface NSString (JSON)

/**
 @brief Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 
 Returns the dictionary or array represented in the receiver, or nil on error.
 
 Returns the NSDictionary or NSArray represented by the current string's JSON representation.
 */
- (id)JSONValue;

/**
 @brief Returns the NSMutableDictionary or NSMutableArray represented by the current string's JSON representation.
 
 Returns the dictionary or array represented in the receiver, or nil on error.
 
 Returns the NSMutableDictionary or NSMutableArray represented by the current string's JSON representation.
 */
- (id)JSONMutableValue;

@end
