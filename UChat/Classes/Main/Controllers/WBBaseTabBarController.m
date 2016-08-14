//
//  WBBaseTabBarController.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBBaseTabBarController.h"
#import "WBCommonMacro.h"
#import "WBBaseTabBar.h"

#import "WBBaseNavigationController.h"

#import "WBCommonWebViewController.h"
#import "WBCommonProgressWebViewController.h"

#import "UBSessionViewController.h"
#import "UBMessageViewController.h"
#import "UBChatAddressBookViewController.h"
#import "UBChatSettingViewController.h"


@implementation WBBaseTabBarController

- (void)viewDidLoad {
    // 添加子控制器
    [self addChildVcs];
    
    // 自定义tabbar
    WBBaseTabBar *customTabBar = [[WBBaseTabBar alloc] init];
//    [self setValue:customTabBar forKey:@"tabBar"];
    
}

/**
 *  添加子控制器
 */
- (void)addChildVcs {
    // 消息
    WBBaseNavigationController *messageNavVc = [[WBBaseNavigationController alloc] init];
    UBMessageViewController *messageVc = [[UBMessageViewController alloc] init];
    [messageNavVc pushViewController:messageVc animated:NO];    
    [self addOneChildVc:messageNavVc title:@"消息" imageName:@"tabbar_icon_message_normal" selectedImageName:@"tabbar_icon_message_selected"];
    
    // 通讯录
    WBBaseNavigationController *contactNavVc = [[WBBaseNavigationController alloc] init];
    UBChatAddressBookViewController *contactVc = [[UBChatAddressBookViewController alloc] init];
    [contactNavVc pushViewController:contactVc animated:NO];
    [self addOneChildVc:contactNavVc title:@"通讯录" imageName:@"icon_contact_normal" selectedImageName:@"icon_contact_selected"];
    
    // 设置
    WBBaseNavigationController *settingNavVc = [[WBBaseNavigationController alloc] init];
    UBChatSettingViewController *settingVc = [[UBChatSettingViewController alloc] init];
    [settingNavVc pushViewController:settingVc animated:NO];
    [self addOneChildVc:settingNavVc title:@"设置" imageName:@"icon_setting_normal" selectedImageName:@"icon_setting_selected"];
}

/**
 *  添加一个子控制器
 *
 *  @param childVc           子控制器对象
 *  @param title             标题
 *  @param imageName         图标
 *  @param selectedImageName 选中时图标
 */
- (void)addOneChildVc:(UIViewController *)childVc title:(NSString *)title imageName:(NSString *)imageName selectedImageName:(NSString *)selectedImageName {
    childVc.title          = title;
    
    UIImage *image         = [UIImage imageNamed:imageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];
    if (IOS7) {
        // IOS7以后 图片不用渲染成蓝色的
        image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        selectedImage                = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    childVc.tabBarItem.image         = image;
    childVc.tabBarItem.selectedImage = selectedImage;
    
    // 设置tabBarItem的普通文字颜色
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[UITextAttributeTextColor] = [UIColor grayColor];
    textAttrs[UITextAttributeFont] = [UIFont boldSystemFontOfSize:10];
    [childVc.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 设置tabBarItem的选中文字颜色
    NSMutableDictionary *selectedTextAttrs = [NSMutableDictionary dictionary];
    selectedTextAttrs[UITextAttributeTextColor] = [UIColor colorWithRed:0.137 green:0.557 blue:0.980 alpha:1.000];
    [childVc.tabBarItem setTitleTextAttributes:selectedTextAttrs forState:UIControlStateSelected];
    
    [self addChildViewController:childVc];
}

@end
