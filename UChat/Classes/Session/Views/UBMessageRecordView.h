//
//  UBMessageRecordView.h
//  UChat
//
//  Created by xusj on 16/1/12.
//  Copyright © 2016年 xusj. All rights reserved.
//  录音状态显示view

#import <UIKit/UIKit.h>

@interface UBMessageRecordView : UIView

// 录音按钮按下
-(void)recordButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)recordButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)recordButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)recordButtonDragInside;
// 手指移动到录音按钮外部
-(void)recordButtonDragOutside;



@end
