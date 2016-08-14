//
//  WBBaseHttpTool.h
//  iOS-Base
//
//  Created by xusj on 15/12/3.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBCommonHttpTool.h"

@interface WBBaseHttpTool : NSObject

+ (instancetype)httpTool;

/**
 *  发送GET请求
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送POST请求
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送POST请求 可以上传文件
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param formData文件参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params formDataArray:(WBformDataArray *)formDataArray success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

@end
