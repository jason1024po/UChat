//
//  NSString+Extension.h
//  iOS-Base
//
//  Created by xusj on 15/12/1.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

/** 返回字符串MD5 */
- (NSString *)MD5;
/** 判断是滞中文 */
- (BOOL)isChinese;

@end
