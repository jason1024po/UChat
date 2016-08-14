//
//  UBMessageCallVideoViewController.h
//  UChat
//
//  Created by xsj on 16/1/27.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EMCallSession.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

static CTCallCenter *g_callCenter;

@interface UBMessageCallVideoViewController : UIViewController

- (instancetype) initWithSession:(EMCallSession *)session;

/** 退出界面回调 */
@property (nonatomic, copy) dispatch_block_t dismiss;

/** 是否是主叫方 */
@property (nonatomic, assign, getter=isCaller) BOOL caller;
/** 是否是被叫方 */
@property (nonatomic, assign, getter=isCallee) BOOL callee;

@end
