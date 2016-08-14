//
//  UBMessageCellVoiceView.m
//  UChat
//
//  Created by xusj on 16/1/8.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCellVoiceView.h"
#import "UIView+Extension.h"
#import <Masonry.h>

@interface UBMessageCellVoiceView()


// 消息位置

@property (nonatomic, assign) UBMessagePosition positon;

// 消息时长

@property (nonatomic, assign) NSInteger duration;
// 音频图标
@property (nonatomic, strong) UIImageView *messageVoiceIcon;
// 时长label
@property (nonatomic, strong) UILabel *durationLabe;

@end

@implementation UBMessageCellVoiceView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        [self messageVoiceIcon];
        [self durationLabe];
    }
    return self;
}

+ (instancetype)voiceView {
    return [[self alloc] init];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.positon==UBMessagePositionLeft) { // 消息在左边
        [self.messageVoiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.centerY.equalTo(self.mas_centerY);
        }];
        [self.durationLabe mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
            make.centerY.equalTo(self.mas_centerY);
        }];
    } else {
        [self.messageVoiceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-5);
            make.centerY.equalTo(self.mas_centerY);
        }];
        [self.durationLabe mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.centerY.equalTo(self.mas_centerY);
        }];
    }
}

- (void)setPostion:(UBMessagePosition)postion andDuration:(NSInteger)duration {
    self.positon = postion;
    self.duration = duration;
    [self layoutIfNeeded];
}

#pragma mark - getters and setters
- (void)setPositon:(UBMessagePosition)positon {
    _positon = positon;
    if (positon==UBMessagePositionLeft) {
        self.durationLabe.textColor = [UIColor colorWithWhite:0.196 alpha:1.000];
    } else {
         self.durationLabe.textColor = [UIColor whiteColor];
    }
}

- (void)setDuration:(NSInteger)duration {
    _duration = duration;
    self.durationLabe.text = [NSString stringWithFormat:@"%ld\"", (long)duration];
}

- (void)setPlayVoiceAnimation:(BOOL)playVoiceAnimation {
    _playVoiceAnimation = playVoiceAnimation;
    if (playVoiceAnimation==YES) {
        [self.messageVoiceIcon startAnimating];
    }else {
        [self.messageVoiceIcon stopAnimating];
    }
}

- (UIImageView *)messageVoiceIcon {
    if (!_messageVoiceIcon) {
        _messageVoiceIcon = [[UIImageView alloc] init];
        _messageVoiceIcon.image = [UIImage imageNamed:@"icon_receiver_voice_playing"];
        _messageVoiceIcon.animationImages = @[[UIImage imageNamed:@"icon_receiver_voice_playing_001"],
                                              [UIImage imageNamed:@"icon_receiver_voice_playing_002"],
                                              [UIImage imageNamed:@"icon_receiver_voice_playing_003"]];
        _messageVoiceIcon.animationDuration = 1.0;
        [self addSubview:_messageVoiceIcon];
    }
    return _messageVoiceIcon;
}

- (UILabel *)durationLabe {
    if (!_durationLabe) {
        _durationLabe = [[UILabel alloc] init];
        _durationLabe.font = [UIFont systemFontOfSize:14];
        _durationLabe.textColor = [UIColor colorWithWhite:0.196 alpha:1.000];
        [self addSubview:_durationLabe];
    }
    return _durationLabe;
}

@end
