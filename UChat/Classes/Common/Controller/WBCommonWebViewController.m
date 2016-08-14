//
//  WBCommonWebViewController.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonWebViewController.h"

@interface WBCommonWebViewController()

@end


@implementation WBCommonWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

#pragma mark - life cycle


#pragma mark - getters and setters
- (UIWebView *)webView {
    if (_webView==nil) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.view = webView;
        webView.backgroundColor = [UIColor whiteColor];
        _webView = webView;
        _webView.opaque = NO;
    }
    return _webView;
}

@end
