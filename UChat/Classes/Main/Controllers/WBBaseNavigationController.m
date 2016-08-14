//
//  WBBaseNavigationController.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBBaseNavigationController.h"
#import "WBCommonMacro.h"


@implementation WBBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}
+ (void)initialize {
    [super initialize];
    // 1.设置导航栏主题
    [self setupNavBarTheme];
}

// 1.设置导航栏主题
+ (void)setupNavBarTheme {
    // 取出appearnce对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    
    // 设置背景
//    [navBar setBackgroundImage:[UIImage imageNamed:@"nav_bg"] forBarMetrics:UIBarMetricsDefault];
    //[navBar setShadowImage:[UIImage imageNamed:@"nav_bg_shadow"]];
    [navBar setShadowImage:[[UIImage alloc] init]];
    navBar.tintColor= [UIColor whiteColor];
    // 设置标题属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[UITextAttributeTextColor] = [UIColor colorWithWhite:0.392 alpha:1.000];
    textAttrs[UITextAttributeTextShadowOffset] = [NSValue valueWithUIOffset:UIOffsetMake(0, 0)];
    textAttrs[UITextAttributeFont] = [UIFont boldSystemFontOfSize:18];
    [navBar setTitleTextAttributes:textAttrs];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0 ) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_back_normal"] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage imageNamed:@"icon_back_pressed"] forState:UIControlStateHighlighted];
        btn.frame = (CGRect){CGPointMake(15, 0), btn.currentBackgroundImage.size};
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
                      
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        if (IOS7) {
            self.interactivePopGestureRecognizer.enabled = YES;
            self.interactivePopGestureRecognizer.delegate = nil;
        }
    }
    [super pushViewController:viewController animated:animated];
}
- (void)back {
    [self popViewControllerAnimated:YES];
}


@end
