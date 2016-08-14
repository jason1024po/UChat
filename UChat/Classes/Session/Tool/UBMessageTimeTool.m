//
//  UBMessageTimeTool.m
//  UChat
//
//  Created by xsj on 16/1/25.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageTimeTool.h"
#import <NSDate+DateTools.h>

@implementation UBMessageTimeTool

+(NSString *)timeStr:(NSTimeInterval)timestamp {
    
    NSDate *messageDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)timestamp];
    if ([messageDate isToday]) { // 今天
        return [messageDate formattedDateWithFormat:@"今天 ah:mm"];
    } else if([messageDate isYesterday]) { // 昨天
        return [messageDate formattedDateWithFormat:@"昨天 ah:mm"];
    } else if ([messageDate isWeekend]) { // 本周
        return [messageDate formattedDateWithFormat:@"EEEE ah:mm"];
    }else { // 一周以前
        return [messageDate formattedDateWithFormat:@"yyyy-MM-dd ah:mm"];
    }
}

@end
