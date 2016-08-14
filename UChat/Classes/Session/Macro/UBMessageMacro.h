//
//  UBMessageMacro.h
//  UChat
//
//  Created by xusj on 16/1/5.
//  Copyright © 2016年 xusj. All rights reserved.
//

#ifndef UBMessageMacro_h
#define UBMessageMacro_h

#endif /* UBMessageMacro_h */

// 像头宽高及外边距
#define kMessageIconWH 40
#define kMessageIconMarginTop  8
#define kMessageIconMarginLeft 8

// 头像高度
#define kMessageUsernameLabelHeight 15

// 文字内容边距
#define kMessageContentMarginLeft    5
#define kMessageContentMarginRight   80

#define kMessageContentPaddingLeft   17
#define kMessageContentPaddingRight  12
#define kMessageContentPaddingTop    14
#define kMessageContentPaddingBottom 14

// Image内边距
#define kMessageContentImagePadding  3

// 字体大小
#define kMessageContentTextFont [UIFont systemFontOfSize:14]

/** 当前用户名 */
#define kMessageUsername [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] objectForKey:@"username"]
/** 当前用户密码 */
#define kMessagePassword [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] objectForKey:@"password"]

/** 消息类型 */
typedef NS_ENUM(NSInteger, UBMessageType) {
    UBMessageTypeText = 1,
    UBMessageTypeImage,
    UBMessageTypeVoice,
    UBMessageTypeVideo,
    UBMessageTypeLocation,
    UBMessageTypeUnknown
};

/** 消息位置 */
typedef NS_ENUM(NSInteger, UBMessagePosition){
    UBMessagePositionLeft = 1,
    UBMessagePositionRight
};

// 通知
/** 时实通话页面Presen通知 */
static NSString *UBMessageCallViewPresentNotification = @"UBMessageCallViewPresentNotification";
/** 时实通话页面dismiss通知 */
static NSString *UBMessageCallViewDismissNotification = @"UBMessageCallViewDismissNotification";


// 消息按下通知
static NSString *UBMessageTouchesBeganNotification = @"UBMessagetouchesBeganNotification";
// toolbar发送按钮
static NSString *UBToolBarSenderButtonDidNotification = @"UBToolBarSenderButtonDidNotification";
// 表情选中的通知
 static NSString *HWEmotionDidSelectNotification = @"HWEmotionDidSelectNotification";
 static NSString *HWSelectEmotionKey = @"HWSelectEmotionKey";

// 删除文字的通知
 static NSString *HWEmotionDidDeleteNotification = @"HWEmotionDidDeleteNotification";


