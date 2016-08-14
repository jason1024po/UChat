//
//  UBSessionViewController.h
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMob.h>

@interface UBSessionViewController : UIViewController

/** EM会话对象 */
@property (nonatomic, strong) EMConversation *conversation;

@end
