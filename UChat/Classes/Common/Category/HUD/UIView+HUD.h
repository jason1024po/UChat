//
//  UIView+HUD.h
//  iOS-Base
//
//  Created by xusj on 15/12/1.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MBProgressHUD.h>
#import "MBProgressHUD+Extension.h"

@interface UIView (HUD)

/** 显示错误 */
- (void)showError:(NSString *)error;
/** 显示错误：时间 */
- (void)showError:(NSString *)error duration:(NSTimeInterval)duration;

/** 显示成功 */
- (void)showSuccess:(NSString *)success;
- (void)showSuccess:(NSString *)success duration:(NSTimeInterval)duration;

/** 显示Loading */
- (MBProgressHUD *)showLoading;
- (MBProgressHUD *)showLoading:(NSString *)loading;
/** 隐藏Loading */
- (void)hideLoading;

/** 进度条 */
- (MBProgressHUD *)showProgressWithTitle:(NSString *)title Type:(MBProgressHUDMode)type;

@end
