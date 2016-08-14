//
//  UBInputToolBar.m
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UBInputToolBar.h"

#import "UIView+Extension.h"
#import <EaseMob.h>
#import "WBCommonMacro.h"
#import "UBInputToolBarVoiceButton.h"
#import <Masonry.h>
#import "EMCDDeviceManager.h"
#import "UBEmotionKeyBoard.h"
#import "HWEmotionKeyboard.h"


@interface UBInputToolBar()<UITextViewDelegate,UBInputToolMoreMediaViewDelegate>

/** 顶部1px线 */
@property (nonatomic, strong) UIView *topLineView;
/** 底部1px线 */
@property (nonatomic, strong) UIView *bottomLineView;
/** 顶部工具条view */
@property (nonatomic, strong) UIView *topBarView;
/** 录音按钮 */
@property (nonatomic, strong) UBInputToolBarVoiceButton *voiceButton;
/** 键盘按钮 */
@property (nonatomic, strong) UIButton *keyboardButton;
/** 表情按钮 */
@property (nonatomic, strong) UIButton *emotionButton;
/** 更多按钮 */
@property (nonatomic, strong) UIButton *moreButton;
/** 录音按钮 */
@property (nonatomic, strong) UIButton *recordButton;
/** 更多媒体面板 */
@property (nonatomic, strong) UBInputToolMoreMediaView *moreMediaView;
/** 表情面板 */
@property (nonatomic, strong) UBEmotionKeyBoard *emotionKeyBoard;
/** 辅助textfield */
@property (nonatomic, strong) UITextField *assistTextField;

// top高度约束
@property (nonatomic, weak) MASConstraint *topBarViewHeight;

@property (nonatomic, strong) HWEmotionKeyboard *hmEmotionKeyBoard;

@end

static CGFloat toolbarDefaultHeight = 46;

@implementation UBInputToolBar


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.980 alpha:1.000];
        // 初始化设置
        [self initSetup];
    }
    return self;
}

- (void)initSetup {
    // init子控件
    [self topLineView];
    [self bottomLineView];
    [self topBarView];
    [self keyboardButton];
    [self voiceButton];
    [self recordButton];
    [self inputTextView];
    [self moreButton];
    [self emotionButton];
    [self moreMediaView];
    
    // 文字改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self.inputTextView];
    // 表情选中的通知
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(emotionDidSelect:) name:HWEmotionDidSelectNotification object:nil];
    // 点击发送按钮通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toolBarSenderButtonDid) name:UBToolBarSenderButtonDidNotification object:nil];
    // 删除文字的通知
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(emotionDidDelete) name:HWEmotionDidDeleteNotification object:nil];
    // menu隐藏代理
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    // 键盘的frame发生改变时发出的通知（位置和尺寸）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

#pragma mark -life cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"-----UBInputToolBar--dealloc-");
}

#pragma mark - 监听表情操作方法
/** 删除文字 */
- (void)emotionDidDelete {
    [self.inputTextView deleteBackward];
}
/** 表情被选中了 */
- (void)emotionDidSelect:(NSNotification *)notification {
    HWEmotion *emotion = notification.userInfo[HWSelectEmotionKey];
    [self.inputTextView insertEmotion:emotion];
    [self textDidChange];
}
/** 点了表情发送按钮 */
- (void)toolBarSenderButtonDid {
    if (self.inputTextView.fullText.length>0) {
        [self sendTextMessage:self.inputTextView.fullText];
        self.inputTextView.text = @"";
    }
}


#pragma mark - private method
/** 键盘的frame发生改变时调用（显示、隐藏等）*/
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    if (!self.inputTextView.isFirstResponder) {
        // 重置键盘
        self.inputTextView.inputView = nil;
    }
}


- (void)menuDidHide:(NSNotification *)notification {
    [UIMenuController sharedMenuController].menuItems = nil;
}
/** 文本键盘按钮点击 */
- (void)keyboardButtonDid:(UIButton *)sender {
    self.keyboardButton.hidden = YES;
    self.voiceButton.hidden = NO;
    self.inputTextView.hidden = NO;
    self.recordButton.hidden = YES;
    self.inputTextView.inputView = nil;
    [self.inputTextView becomeFirstResponder];
    // 切换为文本输入时重新计算输入框高度
    [self setupTextViewHeight:self.inputTextView];
}
/** 录音按钮点击 */
- (void)voiceButtonDid:(UIButton *)sender {
    self.keyboardButton.hidden = NO;
    self.voiceButton.hidden = YES;
    self.inputTextView.hidden = YES;
    self.recordButton.hidden = NO;
    [self.inputTextView endEditing:YES];
    // 计算高度
    [self setupSizeToHeight:toolbarDefaultHeight];
}
/** 表情键盘按钮点击 */
- (void)emotionButtonDid:(UIButton *)sender {
    // 切换为文字输入
    self.keyboardButton.hidden = YES;
    self.voiceButton.hidden = NO;
    self.inputTextView.hidden = NO;
    self.recordButton.hidden = YES;
    // 重新计算输入框高度
    [self setupTextViewHeight:self.inputTextView];;
    
    BOOL isKeyBoard = self.inputTextView.inputView!=self.hmEmotionKeyBoard;
    
    // 开始切换键盘
    self.switchingKeybaord = YES;
    // 退出键盘
    [self.inputTextView endEditing:YES];
    [self.assistTextField endEditing:YES];
    // 结束切换键盘
    self.switchingKeybaord = NO;
    // 设置键盘
    if (isKeyBoard) {
        self.inputTextView.inputView=self.hmEmotionKeyBoard;
    } else {
        self.inputTextView.inputView = nil;
    }   
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 弹出键盘
        [self.inputTextView becomeFirstResponder];
    });
}
- (void)moreMediaButtonDid:(UIButton *)sender {
    self.inputTextView.inputView = nil;
    BOOL isTextEditing = self.assistTextField.isFirstResponder;
    // 开始切换键盘
    self.switchingKeybaord = YES;
    // 退出键盘
    [self.inputTextView endEditing:YES];
    [self.assistTextField endEditing:YES];
    // 结束切换键盘
    self.switchingKeybaord = NO;
    
    // 判断当前是否是更多媒体面板
    if (!isTextEditing) {
        self.assistTextField.inputView = self.moreMediaView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 弹出键盘
            [self.assistTextField becomeFirstResponder];
        });
       
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 弹出键盘
            [self.inputTextView becomeFirstResponder];
        });
    }
}

- (void)recoredButtonTouchDown:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didStartRecordingVoiceAction)]) {
        [self.delegate didStartRecordingVoiceAction];
    }
}
- (void)recoredButtonTouchUpInside:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
        [self.delegate didFinishRecoingVoiceAction];
    }   
}
- (void)recordButtonTouchUpOutside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
        [self.delegate didCancelRecordingVoiceAction];
    }
}

- (void)recordDragInside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
        [self.delegate didDragInsideAction];
    }
}
- (void)recordDragOutside:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
        [self.delegate didDragOutsideAction];
    }
}

- (void)textDidChange {
    [self setupTextViewHeight:self.inputTextView];
}

/** 设置自身的高度 */
- (void)setupSizeToHeight:(CGFloat)height {
    self.topBarViewHeight.mas_equalTo(height);
    // 计算高度
    if ([self.delegate respondsToSelector:@selector(inputViewSizeToHeight:)]) {
        [self.delegate inputViewSizeToHeight:height];
    }
}

#pragma mark - UBInputToolMoreMediaViewDelegate
- (void)mediaButtonDidWithType:(UBMediaViewButtonType)type {
    if ([self.delegate respondsToSelector:@selector(moreMediaButtonDidWithType:)]) {
        [self.delegate moreMediaButtonDidWithType:type];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UBInputTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendTextMessage:textView.fullText];
        textView.text = @"";
        return NO;
    }
    return YES;
}
/** 开始编辑 */
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    // 重置弹出菜单
    [[UIMenuController sharedMenuController] setMenuItems:nil];
    [[UIMenuController sharedMenuController] update];
    if (textView==self.inputTextView) {
        self.moreButton.selected = NO;
        
        self.switchingKeybaord = YES;
        //    // 退出键盘
        [self.inputTextView endEditing:YES];
        [self.assistTextField endEditing:YES];
        //    // 结束切换键盘
        self.switchingKeybaord = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 弹出键盘
            [self.inputTextView becomeFirstResponder];
        });
      
    }
    return YES;
}

// 设置textView高度
- (void)setupTextViewHeight:(UITextView *)textView {
    CGFloat textViewContentH = [self getTextViewContentH:textView];
    if (textViewContentH>35) {
        textViewContentH += 10;
    } else {
        textViewContentH = toolbarDefaultHeight;
    }
    // 计算高度
    [self setupSizeToHeight:textViewContentH];
}

/** 计算文本高度 */
- (CGFloat)getTextViewContentH:(UITextView *)textView {
    return IOS8 ? textView.contentSize.height : ceilf([textView sizeThatFits:textView.frame.size].height);
}

// 发送文本消息
- (void)sendTextMessage:(NSString *)text {
    if ([self.delegate respondsToSelector:@selector(sendMessageWithType:andMessageBody:)]) {
        [self.delegate sendMessageWithType:UBMessageTypeText andMessageBody:text];
    }
    // 计算高度
    [self setupSizeToHeight:toolbarDefaultHeight];
}

#pragma mark getters and setters
- (UBEmotionKeyBoard *)emotionKeyBoard {
    if (!_emotionKeyBoard) {
        _emotionKeyBoard = [[UBEmotionKeyBoard alloc] init];
        _emotionKeyBoard.frame = CGRectMake(0, 0, self.width, 168);
    }
    return _emotionKeyBoard;
}

- (HWEmotionKeyboard *)hmEmotionKeyBoard {
    if (!_hmEmotionKeyBoard) {
        _hmEmotionKeyBoard = [[HWEmotionKeyboard alloc] init];
        _hmEmotionKeyBoard.frame = CGRectMake(0, 0, self.width, 208);
    }
    return _hmEmotionKeyBoard;
}


- (UBInputToolMoreMediaView *)moreMediaView {
    if (!_moreMediaView) {
        _moreMediaView = [[UBInputToolMoreMediaView alloc] init];
        _moreMediaView.delegate = self;
        _moreMediaView.frame = CGRectMake(0, 0, self.width, 168);
    }
    return _moreMediaView;
}

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] init];
        [self addSubview:_topBarView];
        [_topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.top.equalTo(self);
            self.topBarViewHeight = make.height.mas_equalTo(toolbarDefaultHeight);
        }];
    }
    return _topBarView;
}

- (UBInputToolBarVoiceButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton= [[UBInputToolBarVoiceButton alloc] init];
        
        [self.topBarView addSubview:_voiceButton];
        [_voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topBarView).with.offset(8);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(35);
            make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        }];        
         [_voiceButton addTarget:self action:@selector(voiceButtonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton *)keyboardButton {
    if (!_keyboardButton) {
        _keyboardButton = [[UIButton alloc] init];
        [_keyboardButton setImage:[UIImage imageNamed:@"icon_toolview_keyboard_normal"] forState:UIControlStateNormal];
        [_keyboardButton setImage:[UIImage imageNamed:@"icon_toolview_keyboard_pressed"] forState:UIControlStateHighlighted];
        [self.topBarView addSubview:_keyboardButton];
        [_keyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.topBarView).with.offset(8);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(35);
            make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        }];
        [_keyboardButton addTarget:self action:@selector(keyboardButtonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardButton;
}

- (UBInputTextView *)inputTextView {
    if (!_inputTextView) {
        _inputTextView = [[UBInputTextView alloc] init];
        _inputTextView.delegate = self;
        [self.topBarView addSubview:_inputTextView];
        [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBarView).with.offset(6);
            make.left.equalTo(self.voiceButton.mas_right).with.offset(12);
            make.right.equalTo(self.emotionButton.mas_left).with.offset(-10);
            make.bottom.equalTo(self.topBarView).with.offset(-6.5);
        }];
    }
    return _inputTextView;
}

- (UIButton *)recordButton {
    if (!_recordButton) {
        _recordButton = [[UIButton alloc] init];
        [_recordButton setTitle:@"按住说话" forState:UIControlStateNormal];
        [_recordButton setTitle:@"松开发送" forState:UIControlStateHighlighted];
        [_recordButton setTitleColor:[UIColor colorWithWhite:0.431 alpha:1.000] forState:UIControlStateNormal];
        [_recordButton setBackgroundImage:[UIImage imageNamed:@"common_highlight_bg"] forState:UIControlStateHighlighted];
        _recordButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _recordButton.layer.borderWidth = .5f;
        _recordButton.layer.cornerRadius = 5.0f;
        _recordButton.layer.masksToBounds = YES;
        _recordButton.layer.borderColor = [UIColor colorWithRed:0.765 green:0.784 blue:0.804 alpha:1.000].CGColor;
        [self.topBarView addSubview:_recordButton];
        [_recordButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topBarView).with.offset(6);
            make.left.equalTo(self.voiceButton.mas_right).with.offset(12);
            make.right.equalTo(self.emotionButton.mas_left).with.offset(-10);
            make.bottom.equalTo(self.topBarView).with.offset(-6.5);
        }];
        [_recordButton addTarget:self action:@selector(recoredButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recoredButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        
        [_recordButton addTarget:self action:@selector(recordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
   
        [_recordButton addTarget:self action:@selector(recordDragOutside:) forControlEvents:UIControlEventTouchDragExit];
        [_recordButton addTarget:self action:@selector(recordDragInside:) forControlEvents:UIControlEventTouchDragEnter];
        [_recordButton addTarget:self action:@selector(recordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchCancel];
        
    }
    return _recordButton;
}

- (UIButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[UIButton alloc] init];
        [_moreButton setImage:[UIImage imageNamed:@"icon_toolview_add_normal"] forState:UIControlStateNormal];
        [_moreButton setImage:[UIImage imageNamed:@"icon_toolview_add_pressed"] forState:UIControlStateHighlighted];
        [self.topBarView addSubview:_moreButton];
        [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.topBarView).with.offset(-8);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(35);
            make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        }];
        [_moreButton addTarget:self action:@selector(moreMediaButtonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreButton;
}

- (UIButton *)emotionButton {
    if (!_emotionButton) {
        _emotionButton = [[UIButton alloc] init];
        [_emotionButton setImage:[UIImage imageNamed:@"icon_toolview_emotion_normal"] forState:UIControlStateNormal];
        [_emotionButton setImage:[UIImage imageNamed:@"icon_toolview_emotion_pressed"] forState:UIControlStateHighlighted];
        [self.topBarView addSubview:_emotionButton];
        [_emotionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.moreButton.mas_left).with.offset(-8);
            make.height.mas_equalTo(35);
            make.width.mas_equalTo(35);
            make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        }];
        [_emotionButton addTarget:self action:@selector(emotionButtonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _emotionButton;
}

- (UITextField *)assistTextField {
    if (!_assistTextField) {
        _assistTextField = [[UITextField alloc] init];
        [self addSubview:_assistTextField];
    }
    return _assistTextField;
}

- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectMake(40, 6, self.width-100, self.height-12)];
        _topLineView.backgroundColor = [UIColor colorWithWhite:0.784 alpha:1.000];
        [self addSubview:_topLineView];
        [_topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(.5);
        }];
    }
    return _topLineView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(40, 6, self.width-100, self.height-12)];
        _bottomLineView.backgroundColor = [UIColor colorWithWhite:0.843 alpha:1.000];
        [self addSubview:_bottomLineView];
        [_bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.topBarView.mas_bottom).offset(-.5);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(.5);
        }];
    }
    return _bottomLineView;
}
@end
