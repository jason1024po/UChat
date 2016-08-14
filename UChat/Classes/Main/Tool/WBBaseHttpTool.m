//
//  WBBaseHttpTool.m
//  iOS-Base
//
//  Created by xusj on 15/12/3.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBBaseHttpTool.h"

@interface WBBaseHttpTool()

/** httpHeader */
@property (strong, nonatomic) NSDictionary *httpHeader;

@end

@implementation WBBaseHttpTool
static id _instance;

+ (instancetype)httpTool {
    return [[self alloc] init];
}
- (instancetype)init {
    if (_instance) {
        self = _instance;
    }else {
        self = [super init];
        if (self) {
            _instance = self;
        }
    }
    return self;
}

+ (AFHTTPRequestOperation *)getWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    // HTTP-Header
    NSDictionary *headerDict = [[self httpTool] httpHeader];
    
    AFHTTPRequestOperation *request =
    [WBCommonHttpTool getWithURL:url params:params header:headerDict success:^(id json) {
        if (success) {
            success(json);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
}

+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    // HTTP-Header
    NSDictionary *headerDict = [[self httpTool] httpHeader];
    
    AFHTTPRequestOperation *request =
    [WBCommonHttpTool postWithURL:url params:params header:headerDict success:^(id json) {
        if (success) {
            success(json);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
}

+ (AFHTTPRequestOperation *)postWithURL:(NSString *)url params:(NSDictionary *)params formDataArray:(WBformDataArray *)formDataArray success:(void (^)(id))success failure:(void (^)(NSError *))failure {
    
    // HTTP-Header
    NSDictionary *headerDict = [[self httpTool] httpHeader];
    
    AFHTTPRequestOperation *request =
    [WBCommonHttpTool postWithURL:url params:params header:headerDict formDataArray:formDataArray success:^(id json) {
        if (success) {
            success(json);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    return request;
    
}

- (NSDictionary *)httpHeader {
    if (!_httpHeader) {
        _httpHeader = nil;//@{ @"token" : @"tokendesc" };
    }
    return _httpHeader;
}

@end
