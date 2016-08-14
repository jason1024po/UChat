//
//  WBCommonProgressWebViewController.m
//  iOS-Base
//
//  Created by xusj on 15/12/17.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonProgressWebViewController.h"

#import <NJKWebViewProgress.h>
#import <NJKWebViewProgressView.h>

@interface WBCommonProgressWebViewController()<UIWebViewDelegate, NJKWebViewProgressDelegate>

/** progressProxy */
@property (nonatomic, strong) NJKWebViewProgress *progressProxy;
/** 进度条 */
@property (nonatomic, strong) NJKWebViewProgressView *progressView;

@end


@implementation WBCommonProgressWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    }
}

#pragma mark - life cycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    
}
-(void)viewWillDisappear:(BOOL)animated  {
    [super viewWillDisappear:animated];
    [self.progressView removeFromSuperview];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if (progress<=0.1) {
        return;
    }
    [self.progressView setProgress:progress animated:YES];
}

#pragma mark - getters and setters
- (UIWebView *)webView {
    if (_webView==nil) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        self.view = webView;
        webView.backgroundColor = [UIColor whiteColor];
        webView.delegate = self.progressProxy;
        _webView = webView;
        _webView.opaque = NO;
    }
    return _webView;
}
- (NJKWebViewProgress *)progressProxy {
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = self;
        _progressProxy.progressDelegate = self;
    }
    return _progressProxy;
}
/** 进度条 */
- (NJKWebViewProgressView *)progressView {
    if (!_progressView) {
        CGFloat progressBarHeight = 3.f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight - .5, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        //_progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _progressView.progressBarView.layer.cornerRadius = progressBarHeight * .5;
        _progressView.progressBarView.layer.masksToBounds = YES;
        _progressView.progressBarView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.950];
        [self.navigationController.navigationBar addSubview:_progressView];
        _progressView.hidden = YES;
        [_progressView setProgress:0.0 animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.hidden = NO;
        });
    }
    return _progressView;
}

@end
