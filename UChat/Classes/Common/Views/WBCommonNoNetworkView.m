//
//  WBCommonNoNetwork.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonNoNetworkView.h"

@implementation WBCommonNoNetworkView


+ (instancetype)noNetworkView {
    return [[[NSBundle mainBundle] loadNibNamed:@"WBCommonNoNetworkView" owner:nil options:nil] firstObject];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.didHandleBlock) {
        self.didHandleBlock();
    }
}


@end
