//
//  WBCommonWebViewController.h
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//  

#import <UIKit/UIKit.h>

@interface WBCommonWebViewController : UIViewController

/** url */
@property (strong, nonatomic) NSURL *url;

@property (weak,   nonatomic) UIWebView *webView;

@end
