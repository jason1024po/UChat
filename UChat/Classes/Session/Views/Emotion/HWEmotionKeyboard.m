//
//  HWEmotionKeyboard.m
//  黑马微博2期
//
//  Created by apple on 14-10-22.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "HWEmotionKeyboard.h"
#import "HWEmotionListView.h"
#import "HWEmotionTabBar.h"
#import "HWEmotion.h"
#import "MJExtension.h"
#import "HWEmotionTool.h"
#import "UIView+Extension.h"
#import "UBMessageMacro.h"

@interface HWEmotionKeyboard() <HWEmotionTabBarDelegate>
/** 保存正在显示listView */
@property (nonatomic, weak) HWEmotionListView *showingListView;
/** 表情内容 */
@property (nonatomic, strong) HWEmotionListView *recentListView;
@property (nonatomic, strong) HWEmotionListView *defaultListView;
@property (nonatomic, strong) HWEmotionListView *emojiListView;
@property (nonatomic, strong) HWEmotionListView *lxhListView;
/** tabbar */
@property (nonatomic, weak) HWEmotionTabBar *tabBar;
@end

@implementation HWEmotionKeyboard

#pragma mark - 懒加载
- (HWEmotionListView *)recentListView
{
    if (!_recentListView) {
        self.recentListView = [[HWEmotionListView alloc] init];
        // 加载沙盒中的数据
        self.recentListView.emotions = [HWEmotionTool recentEmotions];
    }
    return _recentListView;
}

- (HWEmotionListView *)defaultListView
{
    if (!_defaultListView) {
        self.defaultListView = [[HWEmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/default/info.plist" ofType:nil];
        self.defaultListView.emotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _defaultListView;
}

- (HWEmotionListView *)emojiListView
{
    if (!_emojiListView) {
        self.emojiListView = [[HWEmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/emoji/info.plist" ofType:nil];
        self.emojiListView.emotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _emojiListView;
}

- (HWEmotionListView *)lxhListView
{
    if (!_lxhListView) {
        self.lxhListView = [[HWEmotionListView alloc] init];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EmotionIcons/lxh/info.plist" ofType:nil];
        self.lxhListView.emotions = [HWEmotion objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    }
    return _lxhListView;
}

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // tabbar
        HWEmotionTabBar *tabBar = [[HWEmotionTabBar alloc] init];
        tabBar.delegate = self;
        [self addSubview:tabBar];
        self.tabBar = tabBar;
        
        // 表情选中的通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionDidSelect) name:HWEmotionDidSelectNotification object:nil];
    }
    return self;
}

- (void)emotionDidSelect
{
    self.recentListView.emotions = [HWEmotionTool recentEmotions];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 1.tabbar
    self.tabBar.width = self.width;
    self.tabBar.height = 37;
    self.tabBar.x = 0;
    self.tabBar.y = self.height - self.tabBar.height;
    
    // 2.表情内容
    self.showingListView.x = self.showingListView.y = 0;
    self.showingListView.width = self.width;
    self.showingListView.height = self.tabBar.y;
}

#pragma mark - HWEmotionTabBarDelegate
- (void)emotionTabBar:(HWEmotionTabBar *)tabBar didSelectButton:(HWEmotionTabBarButtonType)buttonType
{
    // 移除正在显示的listView控件
    [self.showingListView removeFromSuperview];
    
    // 根据按钮类型，切换键盘上面的listview
    switch (buttonType) {
        case HWEmotionTabBarButtonTypeRecent: { // 最近
            // 加载沙盒中的数据
//            self.recentListView.emotions = [HWEmotionTool recentEmotions];
            [self addSubview:self.recentListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeDefault: { // 默认
            [self addSubview:self.defaultListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeEmoji: { // Emoji
            [self addSubview:self.emojiListView];
            break;
        }
            
        case HWEmotionTabBarButtonTypeLxh: { // Lxh
            [self addSubview:self.lxhListView];
            break;
        }
    }
    
    // 设置正在显示的listView
    self.showingListView = [self.subviews lastObject];
    
    // 设置frame
    [self setNeedsLayout];
}

@end
