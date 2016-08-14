//
//  WBCommonMacro.h
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBCommonMacro : NSObject

// 判断iOS版本
#define IOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
#define IOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
#define IOS9 ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0)

// 判断手机屏幕
#define Iphone4s     [UIScreen mainScreen].bounds.size.height == 480
#define Iphone5s     [UIScreen mainScreen].bounds.size.height == 568
#define Iphone6s     [UIScreen mainScreen].bounds.size.height == 667
#define Iphone6splus [UIScreen mainScreen].bounds.size.height == 736

// 屏幕尺寸
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

// GCD后台执行
#define __background dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@end
