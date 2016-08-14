//
//  WBBaseTabBar.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBBaseTabBar.h"

@implementation WBBaseTabBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 设置背景图片
        self.backgroundImage = [UIImage imageNamed:@"nav_bg"];
        self.barTintColor = [UIColor colorWithRed:0.961 green:0.961 blue:0.941 alpha:1.000];
        
    }
    return self;
}

@end
