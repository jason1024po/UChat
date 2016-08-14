//
//  UBInputToolBarVoiceButton.m
//  UChat
//
//  Created by xusj on 15/12/31.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UBInputToolBarVoiceButton.h"

@implementation UBInputToolBarVoiceButton


- (instancetype)init {
    self = [super init];
    if (self) {
        [self setImage:[UIImage imageNamed:@"icon_toolview_voice_normal"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"icon_toolview_voice_pressed"] forState:UIControlStateHighlighted];
        self.layer.masksToBounds = YES;
        self.imageView.contentMode = UIViewContentModeCenter;
//        self.layer.cornerRadius = 15;
    }
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = floor(self.frame.size.width * .5);
}


@end
