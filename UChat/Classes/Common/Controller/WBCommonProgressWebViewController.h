//
//  WBCommonProgressWebViewController.h
//  iOS-Base
//
//  Created by xusj on 15/12/17.
//  Copyright © 2015年 xusj. All rights reserved.
//  带进度条的webview

#import <UIKit/UIKit.h>

@interface WBCommonProgressWebViewController : UIViewController

/** url */
@property (strong, nonatomic) NSURL *url;

@property (weak,   nonatomic) UIWebView *webView;

@end
