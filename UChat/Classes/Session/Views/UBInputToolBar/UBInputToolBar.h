//
//  UBInputToolBar.h
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBInputTextView.h"
#import "UBMessageMacro.h"
#import "UBInputToolMoreMediaView.h"

@protocol UBInputToolBarDelegate <NSObject>

@required
/**
 *  更新高度
 *
 *  @param toHeight 高度
 */
- (void)inputViewSizeToHeight:(CGFloat)toHeight;

@optional
/**
 *  发送消息
 *
 *  @param type    消息类型
 *  @param message 消息体
 */
- (void)sendMessageWithType:(UBMessageType)type andMessageBody:(id)messageBody;

/** 按下录音按钮开始录音 */
- (void)didStartRecordingVoiceAction;

/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction;

/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction;

/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction;

/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction;

/** 更多按钮点击 */
- (void)moreMediaButtonDidWithType:(UBMediaViewButtonType)type;


@end

@interface UBInputToolBar : UIView

@property (nonatomic, strong) UBInputTextView *inputTextView;
@property (nonatomic, weak) id<UBInputToolBarDelegate>delegate;

/** 是否下在切换键盘（面板切换） */
@property (nonatomic, assign) BOOL switchingKeybaord;

@end
