//
//  UBMessageCallVideoViewController.m
//  UChat
//
//  Created by xsj on 16/1/27.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCallVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <EaseMob.h>
#import "UIView+Extension.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <ICallManagerCall.h>
#import <EaseMob+CallService.h>
#import "UBMessageMacro.h"

@interface UBMessageCallVideoViewController ()<EMCallManagerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_session;
    AVCaptureVideoDataOutput *_captureOutput;
    AVCaptureDeviceInput *_captureInput;
}
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UIView *bottomBarView;
@property (nonatomic, strong)OpenGLView20 *openGLView;

@property (nonatomic, strong) EMCallSession *callSession;


@property (nonatomic, strong) AVCaptureVideoPreviewLayer *smallCaptureLayer;
@property (nonatomic, assign) UInt8 *imageDataBuffer;

@property (nonatomic, strong) IBOutlet UIView *smallView;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *responseView;

@property (nonatomic, strong) NSString *audioCategory;

/** 定时器 */
@property (nonatomic, strong) NSTimer *timer;
/** 时长 */
@property (nonatomic, assign) NSInteger duration;

/** 静音 */
- (IBAction)silenceBtnDid:(UIButton *)sender;
/** 结束通话 */
- (IBAction)cancelBtnDid:(UIButton *)sender;

/** 接听按钮 */
- (IBAction)answerBtnDid:(UIButton *)sender;
/** 拒接按钮 */
- (IBAction)rejectBtnDid:(UIButton *)sender;

@end

@implementation UBMessageCallVideoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // 调整视图层次
    [self.view sendSubviewToBack:self.openGLView];
    [self.view sendSubviewToBack:self.bgImageView];
    
    if (self.isCaller) {  // 主叫
        [self startByCaller];
    } else { // 被叫
        [self startByCallee];
    }
    
    // 小窗口视图
    [self smallView];
    [self setupCamera];
    
    [_session startRunning];
    self.callSession.displayView = self.openGLView;
    
    
}

- (void)setupSpekout {
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    [audioSession setActive:YES error:nil];
}

- (void)setupCamera {
    //3.创建会话层
    _session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:_openGLView.sessionPreset];
    
    //4.创建、配置输入设备
    AVCaptureDevice *device;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *tmp in devices) {
        if (tmp.position == AVCaptureDevicePositionFront) {
            device = tmp;
            break;
        }
    }
    
    NSError *error = nil;
    _captureInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    [_session beginConfiguration];
    if(!error){
        [_session addInput:_captureInput];
    }
    else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", @"Error") message:error.localizedFailureReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    
    //5.创建、配置输出
    _captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureOutput.videoSettings = _openGLView.outputSettings;
    //    [[_captureOutput connectionWithMediaType:AVMediaTypeVideo] setVideoMinFrameDuration:CMTimeMake(1, 15)];
    _captureOutput.minFrameDuration = CMTimeMake(1, 15);
    //    _captureOutput.minFrameDuration = _openGLView.videoMinFrameDuration;
    _captureOutput.alwaysDiscardsLateVideoFrames = YES;
    dispatch_queue_t outQueue = dispatch_queue_create("com.gh.cecall", NULL);
    [_captureOutput setSampleBufferDelegate:self queue:outQueue];
    [_session addOutput:_captureOutput];
    [_session commitConfiguration];
    
    //6.小窗口显示层
    _smallCaptureLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _smallCaptureLayer.frame = CGRectMake(0, 0, self.smallView.width, self.smallView.height);
    _smallCaptureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_smallView.layer addSublayer:_smallCaptureLayer];
}


- (instancetype)initWithSession:(EMCallSession *)session {
    self  = [self init];
    if (self) {
        self.callSession = session;
        
        [[EaseMob sharedInstance].callManager setBitrate:150];
        
        
        [[EaseMob sharedInstance].callManager removeDelegate:self];
        [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
        g_callCenter = [[CTCallCenter alloc] init];
        g_callCenter.callEventHandler=^(CTCall* call) {
            if(call.callState == CTCallStateIncoming) {
                [[EaseMob sharedInstance].callManager asyncEndCall:_callSession.sessionId reason:eCallReason_Hangup];
            }
        };
    }
    return self;
}


//主叫方开始界面回调
- (void)startByCaller {
    self.timeLabel.text = @"正在呼叫...";
    self.responseView.hidden = YES;
    self.bottomBarView.hidden = NO;
}
//被叫方开始界面回调
- (void)startByCallee {
    self.timeLabel.text = @"等待接听...";
    self.responseView.hidden = NO;
    self.bottomBarView.hidden = YES;
}
/** 开始通话 */
- (void)callSessionConntcted {
    [self setupSpekout];
    
    self.duration = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}
- (void)countdown {
    NSString *minute = [NSString stringWithFormat:@"%ld", (long)self.duration/60];
    if (minute.length<2) {
        minute = [NSString stringWithFormat:@"0%@", minute];
    }
    NSString *second = [NSString stringWithFormat:@"%ld", (long)self.duration%60];
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


- (IBAction)silenceBtnDid:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    [[EaseMob sharedInstance].callManager markCallSession:self.callSession.sessionId asSilence:sender.isSelected];
}

- (IBAction)cancelBtnDid:(UIButton *)sender {
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
/** 接听 */
- (IBAction)answerBtnDid:(UIButton *)sender {
    self.responseView.hidden = YES;
    self.bottomBarView.hidden = NO;
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

#pragma mark - ICallManagerDelegate
- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error {
    
    if(![self.callSession.sessionId isEqualToString:callSession.sessionId]){
        return;
    }
    if (error) {
        NSLog(@"%@", error);
    }
    if (callSession.status == eCallSessionStatusDisconnected) {
    
        NSString *str = @"end";
        if(self.duration == 0)  {
            if (reason == eCallReason_Hangup) {
                str = @"对方挂断";
            }
            else if (reason == eCallReason_Reject){
                str = @"eCallReason_Reject";
            }
            else if (reason == eCallReason_Busy){
                str = @"eCallReason_Busy";
            }
            [self close];
        }
       
    }
    
    
    
    if (callSession.status == eCallSessionStatusAccepted) {
        NSLog(@"同意并开始通话");
        [self callSessionConntcted];
        
    } else if(callSession.status==eCallSessionStatusDisconnected) {
        
        [self close];
    }
    if (reason==eCallReason_Reject) {
        NSLog(@"对方拒绝");
        [self close];
    }

}



#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate


void YUV420spRotate90(UInt8 *  dst, UInt8* src, size_t srcWidth, size_t srcHeight) {
    size_t wh = srcWidth * srcHeight;
    size_t uvHeight = srcHeight >> 1;//uvHeight = height / 2
    size_t uvWidth = srcWidth>>1;
    size_t uvwh = wh>>2;
    //旋转Y
    int k = 0;
    for(int i = 0; i < srcWidth; i++) {
        int nPos = wh-srcWidth;
        for(int j = 0; j < srcHeight; j++) {
            dst[k] = src[nPos + i];
            k++;
            nPos -= srcWidth;
        }
    }
    for(int i = 0; i < uvWidth; i++) {
        int nPos = wh+uvwh-uvWidth;
        for(int j = 0; j < uvHeight; j++) {
            dst[k] = src[nPos + i];
            dst[k+uvwh] = src[nPos + i+uvwh];
            k++;
            nPos -= uvWidth;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (self.callSession.status != eCallSessionStatusAccepted) {
        return;
    }
    
#warning 捕捉数据输出，根据自己需求可随意更改
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess)
    {
        //        UInt8 *bufferbasePtr = (UInt8 *)CVPixelBufferGetBaseAddress(imageBuffer);
        UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
        UInt8 *bufferPtr1 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
        //        printf("addr diff1:%d,diff2:%d\n",bufferPtr-bufferbasePtr,bufferPtr1-bufferPtr);
        
        //        size_t buffeSize = CVPixelBufferGetDataSize(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        //        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
        size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
        //        size_t bytesrow2 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 2);
        //        printf("buffeSize:%d,width:%d,height:%d,bytesPerRow:%d,bytesrow0 :%d,bytesrow1 :%d,bytesrow2 :%d\n",buffeSize,width,height,bytesPerRow,bytesrow0,bytesrow1,bytesrow2);
        
        if (_imageDataBuffer == nil) {
            _imageDataBuffer = (UInt8 *)malloc(width * height * 3 / 2);
        }
        UInt8 *pY = bufferPtr;
        UInt8 *pUV = bufferPtr1;
        UInt8 *pU = _imageDataBuffer + width * height;
        UInt8 *pV = pU + width * height / 4;
        for(int i =0; i < height; i++)
        {
            memcpy(_imageDataBuffer + i * width, pY + i * bytesrow0, width);
        }
        
        for(int j = 0; j < height / 2; j++)
        {
            for(int i = 0; i < width / 2; i++)
            {
                *(pU++) = pUV[i<<1];
                *(pV++) = pUV[(i<<1) + 1];
            }
            pUV += bytesrow1;
        }
        
        YUV420spRotate90(bufferPtr, _imageDataBuffer, width, height);
        [[EaseMob sharedInstance].callManager processPreviewData:(char *)bufferPtr width:width height:height];
        
        /*We unlock the buffer*/
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
}


#pragma mark - getters
- (OpenGLView20 *)openGLView {
    if (!_openGLView) {
        _openGLView = [[OpenGLView20 alloc] initWithFrame:self.view.bounds];
        _openGLView.backgroundColor = [UIColor clearColor];
        _openGLView.sessionPreset = AVCaptureSessionPreset352x288;
        [self.view addSubview:_openGLView];
    }
    return _openGLView;
}


@end
