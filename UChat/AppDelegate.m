//
//  AppDelegate.m
//  UChat
//
//  Created by xusj on 15/12/29.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "AppDelegate.h"
#import <EaseMob.h>
#import "WBBaseTabBarController.h"
#import <AVOSCloud.h>
#import "UBLoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 初始设置
    [self initSetupWithApplication:application Options:launchOptions];
    // 初始化pase服务
    [self setupLeanCloudWith:launchOptions];
    
    [self selectedRootViewController];
    
    return YES;
}

- (void)initSetupWithApplication:(UIApplication *)application Options:(NSDictionary *)launchOptions{
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"easemob-demo#chatdemoui" apnsCertName:@"chatdemoui_dev"];
    [[EaseMob sharedInstance] application:application
     
            didFinishLaunchingWithOptions:launchOptions];
}

/** 初始化pase服务 */
- (void)setupLeanCloudWith:(NSDictionary *)launchOptions {
    // 初始化 LeanCloud SDK
    [AVOSCloud setApplicationId:@"mAN7DYzA18IdlxmMMojolGpU-gzGzoHsz" clientKey:@"74dtaEqEJGmVvqQemWjJSkYp"];
#ifdef DEBUG
    [AVAnalytics setAnalyticsEnabled:NO];
    [AVOSCloud setVerbosePolicy:kAVVerboseShow];
    [AVLogger addLoggerDomain:AVLoggerDomainIM];
    [AVLogger addLoggerDomain:AVLoggerDomainCURL];
    [AVLogger setLoggerLevelMask:AVLoggerLevelAll];
#endif
}


- (void)selectedRootViewController {
    /*
    NSString *key = @"CFBundleVersion";
    // 上一次的使用版本（存储在沙盒中的版本号）
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    // 当前软件的版本号（从Info.plist中获得）
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[key];
    if ([currentVersion isEqualToString:lastVersion]) { // 版本号相同：这次打开和上次打开的是同一个版本
        //GYYLoginController *loginVc = [[GYYLoginController alloc] init];
        //self.window.rootViewController = loginVc;
    } else { // 这次打开的版本和上一次不一样，显示新特性
        //GYYNewFeatureViewController *vc = [[GYYNewFeatureViewController alloc] init];
        //self.window.rootViewController = vc;
        // 将当前的版本号存进沙盒
        //[[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:key];
        //[[NSUserDefaults standardUserDefaults] synchronize];
    }
     */
    
    NSDictionary *loginInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"];
    if (loginInfo.count<1) { // 没有登录过
        UBLoginViewController *loginVc = [[UBLoginViewController alloc] init];
        self.window.rootViewController = loginVc;
    }else {
        WBBaseTabBarController *vc = [[WBBaseTabBarController alloc] init];
        self.window.rootViewController = vc;
    }
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
