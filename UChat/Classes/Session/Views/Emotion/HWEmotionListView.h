//
//  HWEmotionListView.h
//  黑马微博2期
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//  表情键盘顶部的内容:scrollView + pageControl

#import <UIKit/UIKit.h>

@interface HWEmotionListView : UIView
/** 表情(里面存放的HWEmotion模型) */
@property (nonatomic, strong) NSArray *emotions;
@end
