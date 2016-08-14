//
//  MBProgressHUD+Extension.m
//  iOS-Base
//
//  Created by xusj on 15/12/1.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

// 转为成功
- (void)convertToSuccess {
    [self convertToSuccess:nil];
}
- (void)convertToSuccess:(NSString *)success {
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"MBProgressHUD.bundle/hud_success"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    self.customView = imageView;
    self.mode = MBProgressHUDModeCustomView;
    self.labelText = success;
    [self hide:YES afterDelay:2];
}

// 转为失败
- (void)convertToError {
    [self convertToError:nil];
}
- (void)convertToError:(NSString *)error {
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"MBProgressHUD.bundle/hud_error"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });    self.mode = MBProgressHUDModeCustomView;
    self.labelText = error;
    [self hide:YES afterDelay:2];
}

@end
