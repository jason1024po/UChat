//
//  UIView+HUD.m
//  iOS-Base
//
//  Created by xusj on 15/12/1.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UIView+HUD.h"


@implementation UIView (HUD)

- (void)showError:(NSString *)error {
    [self showError:error duration:1.5];
}
- (void)showError:(NSString *)error duration:(NSTimeInterval)duration {
    [self show:error icon:@"hud_error" view:self duration:duration];
}

- (void)showSuccess:(NSString *)success {
    [self showSuccess:success duration:1.5];
}
- (void)showSuccess:(NSString *)success duration:(NSTimeInterval)duration {
     [self show:success icon:@"hud_success" view:self duration:duration];
}

- (MBProgressHUD *)showLoading {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.dimBackground = YES;
    return hud;
}
- (MBProgressHUD *)showLoading:(NSString *)loading {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.dimBackground = YES;
    hud.labelText = loading;
    return hud;
}
- (void)hideLoading {
    [MBProgressHUD hideHUDForView:self animated:YES];
}

- (MBProgressHUD *)showProgressWithTitle:(NSString *)title Type:(MBProgressHUDMode)type {
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    hud.mode = type;
    hud.labelText = title;
    return hud;
}



/** 显示信息 */
- (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view duration:(NSTimeInterval)duration {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 需要蒙版
    //hud.dimBackground = YES;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    //[hud hide:YES afterDelay:duration];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hide:YES];
    });
}


@end
