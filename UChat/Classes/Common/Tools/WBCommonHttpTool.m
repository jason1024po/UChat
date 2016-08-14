//
//  WBCommonHttpTool.m
//  iOS-Base
//
//  Created by xusj on 15/12/2.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonHttpTool.h"

@implementation WBCommonHttpTool

/**
 *  发送GET请求-带头部参数
 */
+ (AFHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    // 请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回数据类型JSON  AFJSONResponseSerializer
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    // 设置超时
    manager.requestSerializer.timeoutInterval = KHTTPTIMEOUT;
    // 设置header
    for (NSString *key in header) {
        [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
    }
    // 发送请求
    AFHTTPRequestOperation *request =
    [manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
}
/**
 *  发送POST请求-带头部参数
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    // 请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回数据类型JSON
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    // 设置超时
    manager.requestSerializer.timeoutInterval = KHTTPTIMEOUT;
    // 设置header
    for (NSString *key in header) {
        [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
    }
    // 发送请求
    AFHTTPRequestOperation *request =
    [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
}

/**
 * POST 上传文件方法
 */
+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params header:(NSDictionary *)header formDataArray:(WBformDataArray *)formDataArray success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    // 请求管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回数据类型JSON
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    // 设置超时
    manager.requestSerializer.timeoutInterval = KHTTPTIMEOUT * 3;
    // 设置header
    for (NSString *key in header) {
        [manager.requestSerializer setValue:header[key] forHTTPHeaderField:key];
    }
    // 发送请求
    AFHTTPRequestOperation *request =
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> totalFormData) {
        for (WBFormData *formData in formDataArray) {
            [totalFormData appendPartWithFileData:formData.data name:formData.name fileName:formData.fileName mimeType:formData.mimeType ];
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
}

@end

// 要上传的文件数据
@implementation WBformDataArray

- (void)appendPartWithFileData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    WBFormData *formData = [[WBFormData alloc] initWithData:data name:name fileName:fileName mimeType:mimeType];
    [self addObject:formData];
}

@end

@implementation WBFormData

- (instancetype)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName mimeType:(NSString *)mimeType {
    self = [super init];
    if (self) {
        self.data = data;
        self.name = [name copy];
        self.fileName = [fileName copy];
        self.mimeType = [mimeType copy];
    }
    return self;
    
}
@end
