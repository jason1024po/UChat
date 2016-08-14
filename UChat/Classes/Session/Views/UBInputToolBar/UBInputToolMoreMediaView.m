//
//  UBInputToolMoreMediaView.m
//  UChat
//
//  Created by xusj on 16/1/13.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBInputToolMoreMediaView.h"

@interface UBInputToolMoreMediaView()

/** 相册 */
@property (nonatomic, strong) UIButton *photoButton;
/** 定位 */
@property (nonatomic, strong) UIButton *locationButton;
/** 相机 */
@property (nonatomic, strong) UIButton *cameraButton;
/** 电话　*/
@property (nonatomic, strong) UIButton *telButton;
/** 视频　*/
@property (nonatomic, strong) UIButton *faceButton;

@property (nonatomic, strong) NSMutableArray *subviewsArr;

@end

@implementation UBInputToolMoreMediaView


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        [self.subviewsArr addObject:self.photoButton];
        [self.subviewsArr addObject:self.locationButton];
        [self.subviewsArr addObject:self.cameraButton];
        [self.subviewsArr addObject:self.telButton];
        [self.subviewsArr addObject:self.faceButton];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 显示的列数
    int colCount = 4;
    int count = (int)self.subviewsArr.count;
    // 整体外边距
    UIEdgeInsets viewMargin = UIEdgeInsetsMake(5, 8, 5, 8);
    // 每个按钮间距
    CGFloat margin  = 9;
    CGFloat buttonW = (self.frame.size.width-viewMargin.left-viewMargin.right-margin*(colCount+1))/colCount;
    CGFloat buttonH = 65;
    
    for (int i=0; i<count; i++) {
        UIButton *btn = self.subviewsArr[i];
        btn.imageView.contentMode = UIViewContentModeCenter;
        int row = i / colCount; // 行
        int col = i % colCount; // 列
        CGFloat btnX = col * buttonW + margin*(col+1) + viewMargin.left;
        CGFloat btnY = row * buttonH + margin*(row+1) + viewMargin.top;
        btn.frame = CGRectMake(btnX, btnY, buttonW, buttonH);
    }
}
#pragma mark - event response
- (void)buttonDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(mediaButtonDidWithType:)]) {
        [self.delegate mediaButtonDidWithType:sender.tag];
    }
}

#pragma mark - getters ans setters
- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [[UIButton alloc] init];
        [_photoButton setImage:[UIImage imageNamed:@"bk_media_picture_normal"] forState:UIControlStateNormal];
        [_photoButton setImage:[UIImage imageNamed:@"bk_media_picture_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_photoButton];
        _photoButton.tag = UBMediaViewButtonTypePhoto;
        [_photoButton addTarget:self action:@selector(buttonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton *)locationButton {
    if (!_locationButton) {
        _locationButton = [[UIButton alloc] init];
        [_locationButton setImage:[UIImage imageNamed:@"bk_media_position_normal"] forState:UIControlStateNormal];
        [_locationButton setImage:[UIImage imageNamed:@"bk_media_position_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_locationButton];
        _locationButton.tag = UBMediaViewButtonTypeLocation;
        [_locationButton addTarget:self action:@selector(buttonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationButton;
}
- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [[UIButton alloc] init];
        [_cameraButton setImage:[UIImage imageNamed:@"bk_media_shoot_normal"] forState:UIControlStateNormal];
        [_cameraButton setImage:[UIImage imageNamed:@"bk_media_shoot_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_cameraButton];
        _cameraButton.tag = UBMediaViewButtonTypeCamera;
        [_cameraButton addTarget:self action:@selector(buttonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)telButton {
    if (!_telButton) {
        _telButton = [[UIButton alloc] init];
        [_telButton setImage:[UIImage imageNamed:@"btn_media_telphone_message_normal"] forState:UIControlStateNormal];
        [_telButton setImage:[UIImage imageNamed:@"btn_media_telphone_message_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_telButton];
        _telButton.tag = UBMediaViewButtonTypeVoiceCall;
        [_telButton addTarget:self action:@selector(buttonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _telButton;
}
- (UIButton *)faceButton {
    if (!_faceButton) {
        _faceButton = [[UIButton alloc] init];
        [_faceButton setImage:[UIImage imageNamed:@"btn_bk_media_video_chat_normal"] forState:UIControlStateNormal];
        [_faceButton setImage:[UIImage imageNamed:@"btn_bk_media_video_chat_pressed"] forState:UIControlStateHighlighted];
        [self addSubview:_faceButton];
        _faceButton.tag = UBMediaViewButtonTypeVideoCall;
        [_faceButton addTarget:self action:@selector(buttonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceButton;
}
- (NSMutableArray *)subviewsArr {
    if (!_subviewsArr) {
        _subviewsArr = [NSMutableArray array];
    }
    return _subviewsArr;
}


@end
