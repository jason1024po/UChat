//
//  UBMessageCallViewController.h
//  UChat
//
//  Created by xusj on 16/1/15.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EMCallSession.h>

@interface UBMessageCallViewController : UIViewController


- (instancetype) initWithSession:(EMCallSession *)session;

/** 退出界面回调 */
@property (nonatomic, copy) dispatch_block_t dismiss;

/** 是否是主叫方 */
@property (nonatomic, assign, getter=isCaller) BOOL caller;
/** 是否是被叫方 */
@property (nonatomic, assign, getter=isCallee) BOOL callee;

@end
