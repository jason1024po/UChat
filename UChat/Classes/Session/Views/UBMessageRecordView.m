//
//  UBMessageRecordView.m
//  UChat
//
//  Created by xusj on 16/1/12.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageRecordView.h"
#import "UIView+Extension.h"


@interface UBMessageRecordView()

/** 秒数label */
@property (nonatomic, strong) UILabel *durationLabel;

@property (nonatomic, strong) UILabel *textLabel;

/** 时长 */
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation UBMessageRecordView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.duration = 0;
        self.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.747];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        [self durationLabel];
        [self textLabel];
        
    }
    return self;
}

- (void)recordButtonTouchUpInside {
    self.textLabel.text = @"手指上滑，取消发送";
    self.textLabel.backgroundColor = [UIColor clearColor];
    [self removeTimer];
}
- (void)recordButtonTouchUpOutside {
    self.textLabel.text = @"手指上滑，取消发送";
    self.textLabel.backgroundColor = [UIColor clearColor];
    [self removeTimer];
}
- (void)recordButtonDragInside {
    self.textLabel.text = @"手指上滑，取消发送";
    self.textLabel.backgroundColor = [UIColor clearColor];
}
- (void)recordButtonDragOutside {
    self.textLabel.text = @"松开手指，取消发送";
    self.textLabel.backgroundColor = [UIColor colorWithRed:1.000 green:0.308 blue:0.183 alpha:0.934];
}

- (void)recordButtonTouchDown {
    self.duration = 0;
    [self countdown];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)countdown {
    NSString *minute = [NSString stringWithFormat:@"%ld", self.duration/60];
    if (minute.length<2) {
        minute = [NSString stringWithFormat:@"0%@", minute];
    }
    NSString *second = [NSString stringWithFormat:@"%ld", self.duration%60];
    if (second.length<2) {
        second = [NSString stringWithFormat:@"0%@", second];
    }
    NSString *txt = [NSString stringWithFormat:@"%@:%@", minute, second];
    self.durationLabel.text = txt;
    self.duration ++ ;
}

/** 移除定时器 */
- (void)removeTimer {
    // 停止定时器
    [self.timer invalidate];
    self.timer = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.durationLabel.frame = CGRectMake(0, self.height / 2-20, self.width, 30);
    self.textLabel.frame = CGRectMake(0, self.height-30, self.width, 30);
    
}

- (UILabel *)durationLabel {
    if (!_durationLabel) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.textColor = [UIColor whiteColor];
        _durationLabel.font = [UIFont systemFontOfSize:28];
        _durationLabel.text = @"00:00";
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_durationLabel];
    }
    return _durationLabel;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.text = @"手指上滑，取消发送";
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_textLabel];
    }
    return _textLabel;
}

@end
