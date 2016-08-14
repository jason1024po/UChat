//
//  UBMessageCallViewController.m
//  UChat
//
//  Created by xusj on 16/1/15.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCallViewController.h"
#import <EaseMob.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "UBMessageMacro.h"

@interface UBMessageCallViewController ()<EMCallManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (nonatomic, strong) NSString *audioCategory;

@property (weak, nonatomic) IBOutlet UIView *responseView;

/** 接听按钮 */
- (IBAction)answerBtnDid:(UIButton *)sender;
/** 拒接按钮 */
- (IBAction)rejectBtnDid:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *hangupView;


@property (nonatomic, strong) EMCallSession *callSession;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 时长 */
@property (nonatomic, assign) NSInteger duration;

- (IBAction)cancelButtonDid:(UIButton *)sender;

@property (nonatomic, strong) CTCallCenter *g_callCenter;
/** 静音 */
- (IBAction)silenceBtnDid:(UIButton *)sender;
/** 杨声器 */
- (IBAction)speakerOutBtnDid:(UIButton *)sender;


@end

@implementation UBMessageCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timeLabel.text = @"正在建立连接...";
    if (self.isCaller) {
        [self startByCaller];
    } else {
        [self startByCallee];
    }
    
}

- (instancetype)initWithSession:(EMCallSession *)session {
    self  = [self init];
    if (self) {
        self.callSession = session;
        self.usernameLabel.text = self.callSession.sessionChatter;
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
        
        self.usernameLabel.text = session.sessionChatter;
    }
    
    return self;
}



//主叫方开始界面回调
- (void)startByCaller {
    self.timeLabel.text = @"正在呼叫...";
    self.responseView.hidden = YES;
    self.hangupView.hidden = NO;
}
//被叫方开始界面回调
- (void)startByCallee {
    self.timeLabel.text = @"等待接听...";
    self.responseView.hidden = NO;
    self.hangupView.hidden = YES;
}


- (void)dealloc {
    NSLog(@"UBMessageCallViewController--dealloc");
}

/** 开始通话 */
- (void)callSessionConntcted {
    self.duration = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
- (void)countdown {
    NSString *minute = [NSString stringWithFormat:@"%d", self.duration/60];
    if (minute.length<2) {
        minute = [NSString stringWithFormat:@"0%@", minute];
    }
    NSString *second = [NSString stringWithFormat:@"%d", self.duration%60];
    if (second.length<2) {
        second = [NSString stringWithFormat:@"0%@", second];
    }
    NSString *txt = [NSString stringWithFormat:@"%@:%@", minute, second];
    self.timeLabel.text = txt;
    self.duration ++ ;
}
/** 移除定时器 */
- (void)removeTimer {
    // 停止定时器
    [self.timer invalidate];
    self.timer = nil;
}



- (IBAction)cancelButtonDid:(UIButton *)sender {
    [self close];
}

/** 关闭界面 */
- (void)close {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[EaseMob sharedInstance].callManager asyncEndCall:self.callSession.sessionId reason:eCallReason_Null];
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        [self removeTimer];
        // 发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:UBMessageCallViewDismissNotification object:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismiss) {
                self.dismiss();
            }
        }];
    });
}

#pragma mark - ICallManagerDelegate
- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error {
    
    if (callSession.status == eCallSessionStatusAccepted) {
        // 同意并开始通话
        [self callSessionConntcted];
    }
    if (reason==eCallReason_Reject) {
        NSLog(@"对方拒绝");
        [self close];
    }
}

/** 静音 */
- (IBAction)silenceBtnDid:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [[EaseMob sharedInstance].callManager markCallSession:self.callSession.sessionId asSilence:sender.isSelected];
}
/** 杨声器 */
- (IBAction)speakerOutBtnDid:(UIButton *)sender {
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (sender.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    sender.selected = !sender.selected;
}

/** 接听 */
- (IBAction)answerBtnDid:(UIButton *)sender {
    self.responseView.hidden = YES;
    self.hangupView.hidden = NO;
    self.timeLabel.text = @"连接中...";
    
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    _audioCategory = audioSession.category;
    if(![_audioCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    [[EaseMob sharedInstance].callManager asyncAnswerCall:self.callSession.sessionId];
}
/** 拒接 */
- (IBAction)rejectBtnDid:(UIButton *)sender {
    EMError *error = [[EaseMob sharedInstance].callManager asyncEndCall:self.callSession.sessionId reason:eCallReasonReject];
    if (error) {
        // 应该关闭界面
        [self close];
    }
}
#pragma mark - setters

@end
