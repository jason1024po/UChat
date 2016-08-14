//
//  UrlConfiguration.h
//  iOS-Base
//
//  Created by xusj on 15/12/9.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "APPConfiguration.h"

#ifndef UrlConfiguration_h
#define UrlConfiguration_h


#endif /* UrlConfiguration_h */


// 生产环境
#ifdef PRODUCT
const NSString *HOST_BASE = @"http://192.168.1.162";
const NSString *URL_BASE  = @"";

// 开发环境
#else
const NSString *HOST_BASE = @"http://192.168.1.160";
const NSString *URL_BASE  = @"";

#endif