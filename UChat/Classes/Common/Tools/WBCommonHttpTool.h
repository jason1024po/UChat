//
//  WBCommonHttpTool.h
//  iOS-Base
//
//  Created by xusj on 15/12/2.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

// 超时时间
#define KHTTPTIMEOUT 20

@class WBformDataArray;

@interface WBCommonHttpTool : NSObject

/**
 *  发送GET请求-带头部参数
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param header  头部参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送POST请求-带头部参数
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param header  头部参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

/**
 *  发送Post请求 可以上传文件
 *
 *  @param url     请求url
 *  @param params  请求参数
 *  @param formData文件参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header formDataArray:(WBformDataArray *)formDataArray success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

@end

/** 上传的文件Array对象 */
@interface WBformDataArray : NSMutableArray
/** 
 * 添加文件对象
 *
 * @param data      文件data
 * @param name      文件参数名
 * @param fileName  文件名
 * @param mimeType  文件类型
 */
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;

@end

/** 上传用的数据对象 */
@interface WBFormData : NSObject
// 文件数据
@property (nonatomic, strong) NSData *data;
// 参数名
@property (nonatomic, copy) NSString *name;
// 文件名
@property (nonatomic, copy) NSString *fileName;
// 文件类型
@property (nonatomic, copy) NSString *mimeType;

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType;

@end
