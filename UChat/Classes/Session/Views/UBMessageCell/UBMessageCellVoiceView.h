//
//  UBMessageCellVoiceView.h
//  UChat
//
//  Created by xusj on 16/1/8.
//  Copyright © 2016年 xusj. All rights reserved.
//  语音视图view

#import <UIKit/UIKit.h>
#import "UBMessageMacro.h"

@interface UBMessageCellVoiceView : UIView

+ (instancetype)voiceView;

/**
 *  是否播放动画
 */
@property (nonatomic, assign) BOOL playVoiceAnimation;

/**
 *  设置位置及时长
 *
 *  @param postion  消息位置
 *  @param duration 时长
 */
- (void)setPostion:(UBMessagePosition)postion andDuration:(NSInteger)duration;

@end
