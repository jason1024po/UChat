//
//  UBMessageCellModel.h
//  UChat
//
//  Created by xusj on 16/1/4.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <EMMessage.h>
#import <IEMMessageBody.h>
#import <EMTextMessageBody.h>
#import "UBMessageMacro.h"
#import <IEMMessageBody.h>

@class UBMessageCell;

@interface UBMessageCellModel : NSObject

/** 实例化 */
+ (instancetype)modelWithMessage:(EMMessage *)message;
+ (instancetype)modelWithMessage:(EMMessage *)message showUsername:(BOOL)showUsername;

/** cell对像 */
@property (nonatomic, weak) UBMessageCell *cell;

/** 是否加载中 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

/** 是否显示用户名 */
@property (nonatomic, assign) BOOL showUsername;

/** 环信消息对像 */
@property (nonatomic, strong) EMMessage *message;
/** 文本内容 */
@property (nonatomic, strong) NSString *text;
/** 聊天内容带表情 */
@property (nonatomic, strong) NSAttributedString *attributedText;
/** 是否已读 */
@property (nonatomic) BOOL isMessageRead;
/** 内容Size */
@property (nonatomic, assign) CGSize contentSize;
/** cell高度 */
@property (nonatomic, assign) CGFloat cellHeight;
/** 是否发送者 */
@property (nonatomic, assign, getter=isSender) BOOL sender;
/** 消息位置（左右） */
@property (nonatomic, assign) UBMessagePosition messagePositon;
/** 消息类型 */
@property (nonatomic, assign) UBMessageType messageType;
/** 消息body */
@property (nonatomic, strong) id<IEMMessageBody>messageBody;

/** 语音本地中路径 */
@property (nonatomic, strong) NSString *voiceLocaPath;
/** 语音是否存在 */
@property (nonatomic, assign) BOOL voiceIsExists;




@end
