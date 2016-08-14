//
//  WBCommonNoNetwork.h
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WBCommonNoNetworkView : UIView

/** 点击回调 */
@property (nonatomic, copy) void(^didHandleBlock)();

+ (instancetype)noNetworkView;


@end
