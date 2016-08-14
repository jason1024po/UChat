//
//  WBCommonNoDataView.h
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WBCommonNoDataView : UIView

/** 没有数据view */
+ (instancetype)noDataView;

/** 描述文字 */
@property (copy, nonatomic) IBInspectable NSString *text;

@end
