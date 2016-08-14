//
//  HWEmotionTool.h
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HWEmotion;

@interface HWEmotionTool : NSObject
+ (void)addRecentEmotion:(HWEmotion *)emotion;
+ (NSArray *)recentEmotions;
@end
