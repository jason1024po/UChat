//
//  MBProgressHUD+Extension.h
//  iOS-Base
//
//  Created by xusj on 15/12/1.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (Extension)

/** 转为显示成功 */
- (void)convertToSuccess;
- (void)convertToSuccess:(NSString *)success;
/** 转为显示失败 */
- (void)convertToError;
- (void)convertToError:(NSString *)error;

@end
