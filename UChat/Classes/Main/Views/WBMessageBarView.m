//
//  WBMessageBarView.m
//  iOS-Base
//
//  Created by xusj on 15/12/7.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBMessageBarView.h"

@interface WBMessageBarView()

@property (strong, nonatomic) CALayer *topLayer;
@property (strong, nonatomic) CALayer *bottomLayer;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UIButton *closeBtn;

@end

@implementation WBMessageBarView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor colorWithRed:1.000 green:0.662 blue:0.082 alpha:0.858];
        
        [self.layer addSublayer:self.topLayer];
        [self.layer addSublayer:self.bottomLayer];
        [self addSubview:self.title];
        [self addSubview:self.closeBtn];
    }
    return self;
}

+ (instancetype)messageBar {
    return [[self alloc] init];
}
+ (instancetype)messageBarWithText:(NSString *)text andDid:(dispatch_block_t)viewDid {
    WBMessageBarView *bar = [[self alloc] init];
    bar.title.text = text;
    bar.viewDid = viewDid;
    return bar;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.viewDid) {
        self.viewDid();
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    // 上下边框
    self.topLayer.frame = CGRectMake(0, 0, self.frame.size.width, .5);
    self.bottomLayer.frame = CGRectMake(0, self.frame.size.height-self.bottomLayer.frame.size.height, self.frame.size.width, .5);
    // 标题
    self.title.frame = self.bounds;
    // 关闭按钮
    self.closeBtn.frame = CGRectMake(self.frame.size.width-30, 0, 30, self.frame.size.height);
}

#pragma mark event response
- (void)closeBtnDid {
    [UIView animateWithDuration:.6 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark getters and setters
- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.frame = self.bounds;
        _title.textColor = [UIColor colorWithWhite:1.000 alpha:0.953];
        _title.font = [UIFont systemFontOfSize:14];
        _title.textAlignment = NSTextAlignmentCenter;
    }
    return _title;
}

- (CALayer *)topLayer {
    if (!_topLayer) {
        _topLayer = [CALayer layer];
        _topLayer.backgroundColor = [UIColor colorWithRed:1.000 green:0.606 blue:0.151 alpha:0.900].CGColor;
    }
    return _topLayer;
}

- (CALayer *)bottomLayer {
    if (!_bottomLayer) {
        _bottomLayer = [CALayer layer];
        _bottomLayer.backgroundColor = [UIColor colorWithRed:0.876 green:0.533 blue:0.138 alpha:0.900].CGColor;
    }
    return _bottomLayer;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeBtn setImage:[UIImage imageNamed:@"iconfont-guanbi"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnDid) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.title.text = text;
}

@end
