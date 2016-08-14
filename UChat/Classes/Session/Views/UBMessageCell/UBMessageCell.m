//
//  UBMessageCell.m
//  UChat
//
//  Created by xusj on 16/1/4.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCell.h"
#import <Masonry.h>
#import <EMImageMessageBody.h>
#import "UIView+Extension.h"
#import <UIImageView+WebCache.h>
#import <EaseMob.h>
#import <IChatManagerDelegate.h>
#import <EMCallManagerDelegate.h>
#import "EMAudioPlayerUtil.h"
#import "EMVoiceConverter.h"
#import "UBMessageLocationViewController.h"
#import "UBMessageCellVoiceView.h"
#import "NSString+Emoji.h"

@interface UBMessageCell()

/** 头像 */
@property (nonatomic, strong) UIImageView *iconImageView;
/** 用户名 */
@property (nonatomic, strong) UILabel     *usernameLabel;
/** 文本消息 */
@property (nonatomic, strong) UILabel     *messageTextLabel;
/** 图片消息 */
@property (nonatomic, strong) UIImageView *messageImageImageView;
/** 语音消息 */
@property (nonatomic, strong) UBMessageCellVoiceView *voiceView;
/** 播放语音 */
@property (nonatomic, strong) UIImageView *messsageVideoPlayImageView;
/** 未读点 */
@property (nonatomic, strong) UIView *unreadDot;
/** 加载标识 */
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
/** 消息错误 */
@property (nonatomic, strong) UIButton *messageErrorBtn;

@end



@implementation UBMessageCell
- (void)initSetup {
    [self usernameLabel];
    [self iconImageView];
    [self contentBgView];
    [self messageImageImageView];
    [self messsageVideoPlayImageView];
    [self voiceView];
    [self messageTextLabel];
    [self indicatorView];
}

- (void)dealloc {
    NSLog(@"UBMessageCell--dealloc");
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initSetup];
    }
    return self;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *Identifier = @"chatcell";
    UBMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UBMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

#pragma mark - 第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - private method
// 消息点击
- (void)contentBgViewDid {
    if ([self.delegate respondsToSelector:@selector(messageCellDidWithModel:)]) {
        [self.delegate messageCellDidWithModel:self.model];
    }
}
// 消息长按
- (void)contentBgLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state==UIGestureRecognizerStateBegan) {
        if ([self.delegate respondsToSelector:@selector(messageCellLongPressWithModel:)]) {
            [self.delegate messageCellLongPressWithModel:self.model];
        }
    }
}

/** 隐藏子视图 */
- (void)hideSubviews {
    
    self.usernameLabel.hidden = YES;
    self.messageTextLabel.hidden = YES;
    self.messageImageImageView.hidden = YES;
    self.voiceView.hidden = YES;
    self.messsageVideoPlayImageView.hidden = YES;
    self.unreadDot.hidden = YES;
    self.messageErrorBtn.hidden = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.model.isSender) { // 对方消息
        
        self.contentBgView.positon = UBMessagePositionLeft;
        
        self.iconImageView.frame = CGRectMake(kMessageIconMarginLeft, kMessageIconMarginTop, kMessageIconWH, kMessageIconWH);
        
        // 显示用户名
        CGFloat contentBgViewY = kMessageContentPaddingTop;
        if (self.model.showUsername) {
            self.usernameLabel.hidden = NO;
            self.usernameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, CGRectGetMinY(self.iconImageView.frame)+1, self.contentView.width-kMessageContentMarginRight-kMessageIconWH-20, kMessageUsernameLabelHeight);
            contentBgViewY += kMessageUsernameLabelHeight;
        }
        
        if (self.model.messageType==UBMessageTypeText) {
            self.messageTextLabel.hidden = NO;
            self.messageTextLabel.textColor = [UIColor colorWithWhite:0.196 alpha:1.000];
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, self.model.contentSize.width + kMessageContentPaddingLeft + kMessageContentPaddingRight, self.height-contentBgViewY);
            self.messageTextLabel.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentPaddingLeft, CGRectGetMinY(self.contentBgView.frame)+kMessageContentPaddingTop, self.model.contentSize.width, self.model.contentSize.height);
        } else if (self.model.messageType==UBMessageTypeImage) {
            self.messageImageImageView.hidden = NO;
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding+5, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
        } else if (self.model.messageType==UBMessageTypeVoice) {
            self.voiceView.hidden = NO;
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, self.model.contentSize.width + kMessageContentPaddingLeft + kMessageContentPaddingRight, self.height-kMessageContentPaddingTop);
            self.unreadDot.frame = CGRectMake(CGRectGetMaxX(self.contentBgView.frame) + kMessageContentMarginLeft, kMessageContentPaddingTop, 8, 8);
            self.voiceView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding+5, 0, self.model.contentSize.width+10, self.model.contentSize.height);
            self.voiceView.centerY = self.contentBgView.centerY;            
        } else if (self.model.messageType==UBMessageTypeVideo) {
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding+5, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
            self.messsageVideoPlayImageView.center = self.messageImageImageView.center;
        } else if (self.model.messageType==UBMessageTypeLocation) {
            self.messageImageImageView.hidden = NO;
            self.messageTextLabel.hidden = NO;
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding+5, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
            self.messageTextLabel.frame = CGRectMake(CGRectGetMinX(self.messageImageImageView.frame)+kMessageContentImagePadding, CGRectGetMinY(self.messageImageImageView.frame)+kMessageContentImagePadding + 66, self.model.contentSize.width-kMessageContentImagePadding * 2, 30);
        
        } else {
            self.contentBgView.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame)+kMessageContentMarginLeft, contentBgViewY, 50 + kMessageContentPaddingLeft + kMessageContentPaddingRight, self.height-kMessageContentPaddingTop);
            self.messageTextLabel.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentPaddingLeft, CGRectGetMinY(self.contentBgView.frame)+kMessageContentPaddingTop, 50, 50);
        }
        // 加载标识
        if (self.model.messageType==UBMessageTypeImage) {
            self.indicatorView.center = self.messageImageImageView.center;
        }else if(self.model.messageType==UBMessageTypeVideo && !self.messageImageImageView.image ){
            self.indicatorView.center = self.messageImageImageView.center;
        } else {
            self.indicatorView.x = CGRectGetMaxX(self.contentBgView.frame) + kMessageContentMarginLeft;
            self.indicatorView.centerY = self.contentBgView.centerY;
        }
        
    } else { // 消息发送者（右边）
        
        
        self.contentBgView.positon = UBMessagePositionRight;
        self.messageTextLabel.textColor = [UIColor whiteColor];
        self.iconImageView.frame = CGRectMake(self.contentView.width -kMessageIconWH - kMessageIconMarginLeft, kMessageIconMarginTop, kMessageIconWH, kMessageIconWH);
        
        // 显示用户名
        CGFloat contentBgViewY = kMessageContentPaddingTop;
        if (self.model.showUsername) {
            contentBgViewY += kMessageUsernameLabelHeight;
        }
        
        if (self.model.messageType==UBMessageTypeText) {
            self.messageTextLabel.hidden = NO;
            self.messageTextLabel.textColor = [UIColor whiteColor];
            CGFloat bgImageViewX = self.contentView.width - self.model.contentSize.width - kMessageIconWH -kMessageContentMarginLeft-kMessageContentPaddingLeft -kMessageContentPaddingRight-kMessageIconMarginLeft;
            self.contentBgView.frame = CGRectMake(bgImageViewX, contentBgViewY, self.model.contentSize.width + kMessageContentPaddingLeft + kMessageContentPaddingRight, self.height-contentBgViewY);
            self.messageTextLabel.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentPaddingRight, CGRectGetMinY(self.contentBgView.frame)+kMessageContentPaddingTop, self.model.contentSize.width, self.model.contentSize.height);
        } else if (self.model.messageType==UBMessageTypeVoice) {
            self.voiceView.hidden = NO;
            CGFloat bgImageViewX = self.contentView.width - self.model.contentSize.width - kMessageIconWH -kMessageContentMarginLeft-kMessageContentPaddingLeft -kMessageContentPaddingRight-kMessageIconMarginLeft;
            self.contentBgView.frame = CGRectMake(bgImageViewX, contentBgViewY, self.model.contentSize.width + kMessageContentPaddingLeft + kMessageContentPaddingRight, self.height-contentBgViewY);
            self.unreadDot.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame) - kMessageContentMarginLeft - 8, kMessageContentPaddingTop, 8, 8);
            self.voiceView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding+5, 0, self.model.contentSize.width+10, self.model.contentSize.height);
            self.voiceView.centerY = self.contentBgView.centerY;
            
        }  else if (self.model.messageType==UBMessageTypeImage) {
            self.messageImageImageView.hidden = NO;
            CGFloat bgImageViewX = self.contentView.width - self.model.contentSize.width - kMessageIconWH - kMessageIconMarginLeft-kMessageContentMarginLeft-kMessageContentPaddingLeft;
            self.contentBgView.frame = CGRectMake(bgImageViewX, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
        } else if (self.model.messageType==UBMessageTypeLocation) {
            self.messageImageImageView.hidden = NO;
            self.messageTextLabel.hidden = NO;
            CGFloat bgImageViewX = self.contentView.width - self.model.contentSize.width - kMessageIconWH - kMessageIconMarginLeft-kMessageContentMarginLeft-kMessageContentPaddingLeft;
            self.contentBgView.frame = CGRectMake(bgImageViewX, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
            self.messageTextLabel.frame = CGRectMake(CGRectGetMinX(self.messageImageImageView.frame)+kMessageContentImagePadding, CGRectGetMinY(self.messageImageImageView.frame)+kMessageContentImagePadding + 66, self.model.contentSize.width-kMessageContentImagePadding * 2, 30);
            
        } else if (self.model.messageType==UBMessageTypeVideo) {
            CGFloat bgImageViewX = self.contentView.width - self.model.contentSize.width - kMessageIconWH - kMessageIconMarginLeft-kMessageContentMarginLeft-kMessageContentPaddingLeft;
            self.contentBgView.frame = CGRectMake(bgImageViewX, contentBgViewY, self.model.contentSize.width + kMessageContentImagePadding*2+5, self.model.contentSize.height+kMessageContentImagePadding*2);
            self.messageImageImageView.frame = CGRectMake(CGRectGetMinX(self.contentBgView.frame)+kMessageContentImagePadding, CGRectGetMinY(self.contentBgView.frame)+kMessageContentImagePadding, self.model.contentSize.width, self.model.contentSize.height);
            self.messsageVideoPlayImageView.center = self.messageImageImageView.center;
        }
        // 加载标识
        self.indicatorView.x = CGRectGetMinX(self.contentBgView.frame) - self.indicatorView.width-kMessageContentMarginLeft;
        self.indicatorView.centerY = self.contentBgView.centerY;
        // 消息错误
        self.messageErrorBtn.frame = self.indicatorView.frame;
    }
}

#pragma mark - getters and setters
- (void)setModel:(UBMessageCellModel *)model {
    _model = model;
    model.cell = self;
    [self hideSubviews];
    // 用户名
    self.usernameLabel.text = model.message.groupSenderName;
    
    // 文本消息
    NSString *txt = @"";
    self.messageTextLabel.font = kMessageContentTextFont;
    self.messageTextLabel.textColor = [UIColor colorWithWhite:0.196 alpha:1.000];
    
    if (model.messageType == UBMessageTypeText) {
        txt = ((EMTextMessageBody *)model.messageBody).text;
        self.messageTextLabel.attributedText = model.attributedText;
    } else if (model.messageType == UBMessageTypeImage) {
        
        self.messageImageImageView.image = [UIImage imageWithContentsOfFile:[(EMImageMessageBody *)model.messageBody thumbnailLocalPath]];
        if (!self.messageImageImageView.image) {
            self.loading = YES;
        } else {
            self.loading = NO;
        } 
        
    } else if (model.messageType == UBMessageTypeVoice) {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)model.messageBody;
        [self.voiceView setPostion:self.model.messagePositon andDuration:voiceBody.duration];
        if (model.messagePositon==UBMessagePositionLeft) {
            self.unreadDot.hidden = model.isMessageRead;
        } else {
            self.unreadDot.hidden = YES;
        }
        self.loading = !model.voiceIsExists;
        
    } else if(model.messageType == UBMessageTypeVideo) {
        self.messageImageImageView.hidden = NO;
        EMVideoMessageBody *body = (EMVideoMessageBody *)model.messageBody;
        self.messageImageImageView.image = [UIImage imageWithContentsOfFile:[body thumbnailLocalPath]];
        if (!self.messageImageImageView.image) {
            self.loading = YES;
            self.messsageVideoPlayImageView.hidden = YES;
        } else {
            self.loading = NO;
            self.messsageVideoPlayImageView.hidden = NO;
        }
    
    } else if (model.messageType == UBMessageTypeLocation) {
        self.messageImageImageView.image = [UIImage imageNamed:@"icon_map"];
        EMLocationMessageBody *locationBody = (EMLocationMessageBody *)model.messageBody;
        self.messageTextLabel.text = locationBody.address;
        self.messageTextLabel.font = [UIFont systemFontOfSize:12];
        self.messageTextLabel.textColor = [UIColor whiteColor];
        [self.contentView bringSubviewToFront:self.messageTextLabel];
    }
    self.loading = model.loading;
    // 消息发送状态
    if (model.message.deliveryState==eMessageDeliveryState_Delivering) { // 发送中。。。
        self.loading = YES;
    }  else if (model.message.deliveryState==eMessageDeliveryState_Failure) {
        self.messageErrorBtn.hidden = NO;
    }
    [self layoutIfNeeded];
}

- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"DefaultAvatar"];
        [self.contentView addSubview:_iconImageView];
        _iconImageView.layer.cornerRadius = kMessageIconWH / 2;
        _iconImageView.layer.masksToBounds = YES;
    }
    return _iconImageView;
}


- (UBMessageCellContentBgView *)contentBgView {
    if (!_contentBgView) {
        _contentBgView = [UBMessageCellContentBgView contentBgView];
        [self.contentView addSubview:_contentBgView];
        [_contentBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentBgViewDid)]];
        [_contentBgView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(contentBgLongPress:)]];
    }
    return _contentBgView;
}

- (UIImageView *)messageImageImageView {
    if (!_messageImageImageView) {
        _messageImageImageView = [[UIImageView alloc] init];
        _messageImageImageView.layer.cornerRadius = 14;
        _messageImageImageView.layer.masksToBounds = YES;
        _messageImageImageView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
        [self.contentView addSubview:_messageImageImageView];
    }
    return _messageImageImageView;
}

- (UIImageView *)messsageVideoPlayImageView {
    if (!_messsageVideoPlayImageView) {
        _messsageVideoPlayImageView = [[UIImageView alloc] init];
        _messsageVideoPlayImageView.image = [UIImage imageNamed:@"icon_play_normal"];
        _messsageVideoPlayImageView.size = CGSizeMake(35, 35);
        [self.contentView addSubview:_messsageVideoPlayImageView];
    }
    return _messsageVideoPlayImageView;
}
- (UILabel *)usernameLabel {
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] init];
        _usernameLabel.numberOfLines = 1;
        _usernameLabel.font = [UIFont systemFontOfSize:11];
        _usernameLabel.textColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
        [self.contentView addSubview:_usernameLabel];
    }
    return _usernameLabel;
}
- (UILabel *)messageTextLabel {
    if (!_messageTextLabel) {
        _messageTextLabel = [[UILabel alloc] init];
        _messageTextLabel.numberOfLines = 0;
        _messageTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_messageTextLabel];
        _messageTextLabel.font = kMessageContentTextFont;
    }
    return _messageTextLabel;
}

- (UBMessageCellVoiceView *)voiceView {
    if (!_voiceView) {
        _voiceView = [UBMessageCellVoiceView voiceView];
        [self.contentView addSubview:_voiceView];
    }
    return _voiceView;
}

- (void)setPlayVoiceAnimation:(BOOL)playVoiceAnimation {
    _playVoiceAnimation = playVoiceAnimation;
    if (playVoiceAnimation==YES) {
        self.voiceView.playVoiceAnimation = YES;
    }else {
        self.voiceView.playVoiceAnimation = NO;
    }
}

- (UIView *)unreadDot {
    if (!_unreadDot) {
        _unreadDot = [[UIView alloc] init];
        _unreadDot.backgroundColor = [UIColor redColor];
        _unreadDot.frame = CGRectMake(0, 0, 8, 8);
        _unreadDot.layer.cornerRadius = 4;
        _unreadDot.layer.masksToBounds = YES;
        [self.contentView addSubview:_unreadDot];
    }
    return _unreadDot;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.size = CGSizeMake(20, 20);
        _indicatorView.hidesWhenStopped = YES;
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        [self.contentView addSubview:_indicatorView];
    }
    return _indicatorView;
}

- (UIButton *)messageErrorBtn {
    if (!_messageErrorBtn) {
        _messageErrorBtn = [[UIButton alloc] init];
        [self.contentView addSubview:_messageErrorBtn];
        [_messageErrorBtn setImage:[UIImage imageNamed:@"icon_message_cell_error"] forState:UIControlStateNormal];
    }
    return _messageErrorBtn;
}
- (void)setLoading:(BOOL)loading {
    _loading = loading;
    if (loading) {
        [self.indicatorView startAnimating];
    }else {
        [self.indicatorView stopAnimating];
    }
}

- (void)setIsMessageRead:(BOOL)isMessageRead {
    _isMessageRead = isMessageRead;
    self.unreadDot.hidden = isMessageRead;    
}




@end
