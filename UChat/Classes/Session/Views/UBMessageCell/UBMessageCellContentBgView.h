//
//  UBMessageCellContentBgView.h
//  UChat
//
//  Created by xusj on 16/1/7.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBMessageMacro.h"

@interface UBMessageCellContentBgView : UIImageView

+ (instancetype)contentBgView;

/**
 *  消息位置
 */
@property (nonatomic, assign) UBMessagePosition positon;

@end
