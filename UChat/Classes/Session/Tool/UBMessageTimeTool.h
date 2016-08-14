//
//  UBMessageTimeTool.h
//  UChat
//
//  Created by xsj on 16/1/25.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBMessageTimeTool : NSObject

/**
 *  格式化聊天时间
 *
 *  @param timestamp 时间戳
 */
+(NSString *)timeStr:(NSTimeInterval)timestamp;

@end
