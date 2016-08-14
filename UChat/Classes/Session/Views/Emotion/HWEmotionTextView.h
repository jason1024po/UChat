//
//  HWEmotionTextView.h
//  黑马微博2期
//
//  Created by apple on 14-10-23.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWTextView.h"
@class HWEmotion;

@interface HWEmotionTextView : HWTextView
- (void)insertEmotion:(HWEmotion *)emotion;

- (NSString *)fullText;
@end
