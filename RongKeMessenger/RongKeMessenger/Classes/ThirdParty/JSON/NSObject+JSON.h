//
//  NSObject+JSON.h
//  RongKeMessenger
//
//  Created by Gray on 15/1/13.
//  Copyright (c) 2015年 西安融科通信技术有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 @brief Adds JSON generation to Foundation classes
 
 This is a category on NSObject that adds methods for returning JSON representations
 of standard objects to the objects themselves. This means you can call the
 -JSONRepresentation method on an NSArray object and it'll do what you want.
 */
@interface NSObject (JSON)

/**
 @brief Returns a string containing the receiver encoded in JSON.
 
 This method is added as a category on NSObject but is only actually
 supported for the following objects:
 @li NSDictionary
 @li NSArray
 */
- (NSString *)JSONRepresentation;

@end
