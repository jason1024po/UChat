//
//  WBMessageBarView.h
//  iOS-Base
//
//  Created by xusj on 15/12/7.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBMessageBarView : UIView

// 标题文本
@property (copy, nonatomic) NSString *text;
// 点击回调
@property (copy, nonatomic) dispatch_block_t viewDid;

+ (instancetype)messageBar;
+ (instancetype)messageBarWithText:(NSString *)text andDid:(dispatch_block_t)viewDid;

@end
