//
//  UBMessageCellContentBgView.m
//  UChat
//
//  Created by xusj on 16/1/7.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCellContentBgView.h"
#import "UBMessageMacro.h"
@implementation UBMessageCellContentBgView


- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

+ (instancetype)contentBgView {
    return [[self alloc] init];
}

- (void)setPositon:(UBMessagePosition)positon {
    _positon = positon;
    if (positon==UBMessagePositionLeft) { // 消息在左边样式
        self.image = [UIImage imageNamed:@"icon_receiver_node_normal"];
        self.highlightedImage = [UIImage imageNamed:@"icon_receiver_node_pressed"];
    } else { // 消息在右边样式
        self.image = [UIImage imageNamed:@"icon_sender_text_node_normal"];
        self.highlightedImage = [UIImage imageNamed:@"icon_sender_text_node_pressed"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:UBMessageTouchesBeganNotification object:nil];
    self.highlighted = YES;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
}

@end
