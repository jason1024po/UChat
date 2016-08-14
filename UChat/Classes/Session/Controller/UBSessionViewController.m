//
//  UBSessionViewController.m
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UBSessionViewController.h"
#import "UBInputToolBar.h"
#import "UIView+Extension.h"
#import <Masonry.h>
#import <IChatManagerDelegate.h>
#import <EMMessage.h>
#import <IEMMessageBody.h>
#import <EMTextMessageBody.h>
#import <EMImageMessageBody.h>
#import <EMLocationMessageBody.h>
#import <EMVoiceMessageBody.h>
#import <EMVideoMessageBody.h>
#import <EMFileMessageBody.h>
#import "UBMessageCell.h"
#import "UBMessageCellModel.h"
#import <MapKit/MapKit.h>
#import "UBMessageLocationViewController.h"
#import "EMCDDeviceManagerBase.h"
#import "EMCDDeviceManager+Media.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MWPhotoBrowser.h>
#import "WBCommonMacro.h"
#import "UBMessageRecordView.h"
#import <NSDate+DateTools.h>
#import <TargetConditionals.h>
#import "UBMessageCallViewController.h"
#import "UBMessageTimeCell.h"
#import "UBMessageTimeTool.h"
#import "UBMessageCallVideoViewController.h"

@interface UBSessionViewController()<UBInputToolBarDelegate, IChatManagerDelegate, UBMessageCellDelegate, UITableViewDataSource, UITableViewDelegate, MWPhotoBrowserDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UBInputToolBar *inputToolBar;
@property (nonatomic, strong) UBMessageRecordView *messageRecordView;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) MWPhotoBrowser *photoBrowser;

@property (nonatomic) NSTimeInterval messageTimeIntervalTag;

/** 正在操作的消息对象 */
@property (nonatomic, strong) UBMessageCellModel *operationMessageModel;
/** 长按-正在操作的消息对象 */
@property (nonatomic, strong) UBMessageCellModel *operationMessageForMenu;

// 约束
@property (nonatomic, weak) MASConstraint *inputToolBarBottom;
@property (nonatomic, weak) MASConstraint *inputToolBarHeight;

/** 是否滚动到底部 */
@property (nonatomic, assign, getter=isScrollToBottom) BOOL scrollToBottom;

/** 系统快捷菜单 */
@property (nonatomic, strong) UIMenuController *menuControl;
// 复制
@property (nonatomic, strong) UIMenuItem *itemCopy;
// 删除
@property (nonatomic, strong) UIMenuItem *itemDelete;
// 转发
@property (nonatomic, strong) UIMenuItem *itemTransmit;

@end
/** 每页获取的消息条数 */
static NSInteger messagePageCount = 50;

@implementation UBSessionViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithRed:0.8688 green:0.8823 blue:0.9069 alpha:1.0];
    self.title = self.conversation.chatter;
    if (self.conversation.conversationType==eConversationTypeGroupChat) {
        self.title = [self.conversation.ext objectForKey:@"groupSubject"];
    }    
    // menu隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDidHide:) name:UIMenuControllerDidHideMenuNotification object:nil];
    // 消息按下通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEdit) name:UBMessageTouchesBeganNotification object:nil];
    
    // 环信代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    

    [self tableView];
    [self refreshControl];
    [self inputToolBar];
    [self messageRecordView];
    // 将会话写入数据库【内存】
    [[EaseMob sharedInstance].chatManager insertConversationToDB:self.conversation append2Chat:YES];
    // 将当前会话消息全部标记为已读
    [self.conversation markAllMessagesAsRead:YES];
    
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
     [self loadMessage:timestamp];
}
- (void)dealloc {
    // 重置弹出菜单
//    [[UIMenuController sharedMenuController] setMenuItems:nil];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    NSLog(@"dealloc------");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/**
 *  收到消息
 */
- (void)didReceiveMessage:(EMMessage *)message {
    
    UBMessageCellModel *messageCellModel = [[UBMessageCellModel alloc] init];
    messageCellModel.showUsername = self.conversation.conversationType != eConversationTypeChat;
    messageCellModel.message = message;
    
    [self.tableViewData addObject:messageCellModel];
    [self.tableView reloadData];
    if (self.isScrollToBottom) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableViewData.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    // 将当前会话消息全部标记为已读
    [self.conversation markAllMessagesAsRead:YES];
}

- (void)didReceiveOfflineMessages:(NSArray *)offlineMessages {
    NSLog(@"离线消息---%@", offlineMessages);
}

- (void)didFetchingMessageAttachments:(EMMessage *)message
                             progress:(float)progress {
    NSLog(@"下载进度---%f", progress);
}
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error {
    NSLog(@"----didMessageAttachmentsStatusChanged----");
    [self.tableView reloadData];
}

#pragma mark - 第一响应者
- (BOOL)canBecomeFirstResponder {
    return YES;
}

#pragma mark - UBMessageCellDelegate
/** 消息长按操作 */
- (void)messageCellLongPressWithModel:(UBMessageCellModel *)model {
    self.operationMessageForMenu = model;
    if (model.messageType==UBMessageTypeText) { // 文本消息长按
        [self.menuControl setMenuItems:@[self.itemCopy, self.itemDelete, self.itemTransmit]];
    } else { // 其它消息长按
        [self.menuControl setMenuItems:@[self.itemDelete]];
    }
    // 显示弹出菜单
    [self.menuControl setTargetRect:model.cell.contentBgView.frame inView:model.cell];
    [self.menuControl setMenuVisible:YES animated:YES];
}
/** 各种消息点击 */
- (void)messageCellDidWithModel:(UBMessageCellModel *)model {
    // 点击任意停止播放语音
    if (self.operationMessageModel) {
        self.operationMessageModel.cell.playVoiceAnimation = NO;
    }
    // 第二次点击了消息
    if (self.operationMessageModel==model) {
        // 暂停播放语音
        [[EMCDDeviceManager sharedInstance] stopPlaying];
        // 停止播放语音动画
        self.operationMessageModel.cell.playVoiceAnimation = NO;
        // 清除正在操作的消息
        self.operationMessageModel = nil;
        return;
    }
    // 正在操作的消息
    self.operationMessageModel = model;
    
    if (model.messageType==UBMessageTypeText) {
        // 点击文本消息
    } else if (model.messageType==UBMessageTypeImage) {
        // 点击了图片消息
        [self imageMessageDid:model];
    } else if (model.messageType==UBMessageTypeVoice) {
        // 点击了语音消息
        [self voiceMessageDid:model];
    } else if (model.messageType==UBMessageTypeVideo) {
        // 点击了视频消息
        [self videoMessageDid:model];
    } else if (model.messageType==UBMessageTypeLocation) {
        // 点击了定位消息
        [self locationMessageDid:model];
    }
}
/** 图片消息点击 */
- (void)imageMessageDid:(UBMessageCellModel *)model {
    id <IChatManager> chatManager = [[EaseMob sharedInstance] chatManager];
    EMImageMessageBody *imageBody = (EMImageMessageBody *)model.messageBody;
    NSMutableArray *photos = [NSMutableArray array];
    self.photos = photos;
    // 隐藏tabbar
    self.hidesBottomBarWhenPushed = YES;
    
    if (imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed) {
        if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed) {
            UIImage *originImage = [UIImage imageWithContentsOfFile:imageBody.localPath];
            if (originImage) {
                //发送已读回执
                [chatManager sendReadAckForMessage:model.message];
                [photos addObject:[MWPhoto photoWithImage:originImage]];
                [self.navigationController pushViewController:self.photoBrowser animated:YES];
            }else {
                NSLog(@"本地图片不存在");
            }
        }else {
            model.cell.loading = YES;
            [chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                model.cell.loading = NO;
                //发送已读回执
                [chatManager sendReadAckForMessage:model.message];
                UIImage *originImage = [UIImage imageWithContentsOfFile:imageBody.localPath];
                if (originImage) {
                    [photos addObject:[MWPhoto photoWithImage:originImage]];
                    [self.navigationController pushViewController:self.photoBrowser animated:YES];
                }else {
                    NSLog(@"本地图片不存在");
                }
            } onQueue:nil];
        }
    } else { // 缩略图没有下载
        model.cell.loading = YES;
        //获取缩略图
        [chatManager asyncFetchMessageThumbnail:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
            model.cell.loading = NO;
            if (!error) {
                [self.tableView reloadData];
            }else{
                NSLog(@"缩略图还是下失败了");
            }
            
        } onQueue:nil];
    }
}
/** 定位消息点击 */
- (void)locationMessageDid:(UBMessageCellModel *)model {
    EMLocationMessageBody *body = (EMLocationMessageBody *)model.message.messageBodies.firstObject;
    UBMessageLocationViewController *mapVc = [[UBMessageLocationViewController alloc] init];
    mapVc.locationCoordinate = CLLocationCoordinate2DMake(body.latitude, body.longitude);
    [mapVc setLocationCoordinate:CLLocationCoordinate2DMake(body.latitude, body.longitude) address:body.address];
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapVc animated:YES];
}
/** 语音消息点击 */
- (void)voiceMessageDid:(UBMessageCellModel *)model {
    
    model.cell.isMessageRead = YES;
    model.isMessageRead = YES;
    model.cell.playVoiceAnimation = YES;
    
    EMVoiceMessageBody *body = (EMVoiceMessageBody *)model.messageBody;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断本地路劲是否存在
    if ([fileManager fileExistsAtPath:body.localPath]) {
        // 发送已读回执
        dispatch_async(dispatch_queue_create("uben.xyz", NULL), ^{
            [[EaseMob sharedInstance].chatManager sendReadAckForMessage:model.message];
        });
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)model.messageBody;
        [self playVoiceWithPath:voiceBody.localPath completion:^(NSError *error) {
            model.cell.playVoiceAnimation = NO;
            if (error) {
                NSLog(@"播放错误");
                return;
            }
        }];
        return;
    }
    // 下载音频
    [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        NSLog(@"音频下载了");
        if (!error) {
            // 发送已读回执
            dispatch_async(dispatch_queue_create("uben.xyz", NULL), ^{
                [[EaseMob sharedInstance].chatManager sendReadAckForMessage:model.message];
            });
            EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody *)model.messageBody;
            [self playVoiceWithPath:voiceBody.localPath completion:^(NSError *error) {
                model.cell.playVoiceAnimation = NO;
                if (error) {
                    NSLog(@"播放错误");
                    return;
                }
            }];
        } else {
            NSLog(@"音频下载错误");
        }
    } onQueue:nil];
    
}
/** 视频消息点击 */
- (void)videoMessageDid:(UBMessageCellModel *)model {
    EMVideoMessageBody *body = (EMVideoMessageBody *)model.messageBody;
    NSURL *videoURL = [NSURL fileURLWithPath:body.localPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 判断本地路劲是否存在
    if ([fileManager fileExistsAtPath:body.localPath]) {
        [self playVideoWithURL:videoURL];
        return;
    }
    model.cell.loading = YES;
    // 下载视频
    [[EaseMob sharedInstance].chatManager asyncFetchMessage:model.message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        if (!error) {
            model.cell.loading = NO;
            [self playVideoWithURL:videoURL];
        } else {
            NSLog(@"视频下载错误");
        }
    } onQueue:nil];
}

/** 根据path播放录音　*/
- (void)playVoiceWithPath:(NSString *)path completion:(void(^)(NSError *error))completon {
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:path completion:^(NSError *error){
        if (completon) {
            completon(error);
            return;
        }
    }];
}

/** 根据url开始播放视频 */
- (void)playVideoWithURL:(NSURL *)videoURL {
    MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    [moviePlayerController.moviePlayer prepareToPlay];
    moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
    [self.navigationController presentMoviePlayerViewControllerAnimated:moviePlayerController];
}


#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < self.photos.count) {
        return [self.photos objectAtIndex:index];
    }
    return nil;
}
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    return @"1/1";
}

#pragma mark - private method
/** metnu隐藏 */
- (void)menuDidHide:(NSNotification *)notification {
    [UIMenuController sharedMenuController].menuItems = nil;
}
/** 复制 */
- (void)copyItemClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.operationMessageForMenu.text;
}
/** 删除 */
- (void)deleteItemClicked:(id)sender {
    NSLog(@"删除");
}
/** 转发 */
- (void)transmitItemClicked:(id)sender {
    NSLog(@"转发");
}

/** 键盘的frame发生改变时调用（显示、隐藏等）*/
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    // 如果正在切换键盘，就不要执行后面的代码
//    if (self.switchingKeybaord) return;
    if (self.inputToolBar.switchingKeybaord) return;
    
    NSDictionary *userInfo = notification.userInfo;
    // 动画的持续时间
    // double duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 键盘的frame
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.inputToolBarBottom.offset(-(self.view.height - keyboardF.origin.y));
    
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    if (keyboardF.origin.y>=self.view.height) {
        contentInset.bottom = 15;
    } else {
        contentInset.bottom =  keyboardF.size.height + 15;
    }
    self.tableView.contentInset = contentInset;
    
    if (self.tableViewData.count>1) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableViewData.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }   
    
//    [UIView animateWithDuration:duration animations:^{
        [self.inputToolBar layoutIfNeeded];
//    }];
    
}

- (void)endEdit {
    [self.view endEditing:YES];
}
// 加载更多消息
- (void)refreshTableView:(UIRefreshControl *)refreshControl {
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
    if (self.tableViewData.count>1) {
        timestamp = [(UBMessageCellModel *)(self.tableViewData[1]) message].timestamp;
    }
    [self loadMessage:timestamp];
}
/**
 *  加载消息
 *
 *  @param timestamp 时间戳
 */
- (void)loadMessage:(NSTimeInterval)timestamp {
//    dispatch_async(__background, ^{
    // 是否加载过
    BOOL firstLoading = !self.tableViewData.count;
    NSArray *messages = [self.conversation loadNumbersOfMessages:messagePageCount before:timestamp]; // 根据时间戳读取指定条数的消息
    if (firstLoading) {
        for (int i=0; i<messages.count; i++) {
            EMMessage *message = messages[i];
            //计算時間间隔
            CGFloat interval = (self.messageTimeIntervalTag - message.timestamp/1000);
            if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
                NSString *timeStr = [UBMessageTimeTool timeStr:message.timestamp/1000];
                [self.tableViewData addObject:timeStr];
                self.messageTimeIntervalTag = message.timestamp/1000;
            }
            UBMessageCellModel *messageCellModel = [[UBMessageCellModel alloc] init];
            messageCellModel.showUsername = self.conversation.conversationType != eConversationTypeChat;
            messageCellModel.message = message;
            
            [self.tableViewData addObject:messageCellModel];
        }
        [self.tableView reloadData];
        // 首次加载滚动到底部
        [self.tableView setContentOffset:CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    } else {
        self.messageTimeIntervalTag  = [(UBMessageCellModel *)(self.tableViewData[1]) message].timestamp;
        NSInteger scrollRow = 0; // 滚动位置
        for (int i=0; i<messages.count; i++) {
            EMMessage *message = messages[messages.count-i-1];
            
            UBMessageCellModel *messageCellModel = [[UBMessageCellModel alloc] init];
            messageCellModel.showUsername = self.conversation.conversationType != eConversationTypeChat;
            messageCellModel.message = message;
            [self.tableViewData insertObject:messageCellModel atIndex:0];
            scrollRow ++;
            //计算時間间隔
            CGFloat interval = (self.messageTimeIntervalTag - message.timestamp/1000);
            if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
                NSString *timeStr = [UBMessageTimeTool timeStr:message.timestamp/1000];
                [self.tableViewData insertObject:timeStr atIndex:0];
                self.messageTimeIntervalTag = message.timestamp/1000;
                scrollRow ++;
            }
        }
        [self.tableView reloadData];
        if (messages.count>0) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scrollRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    [self.refreshControl endRefreshing];
}


#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableViewData[indexPath.row] isKindOfClass:[NSString class]]) {
        UBMessageTimeCell *timeCell = [UBMessageTimeCell cellWithTableView:tableView];
        timeCell.text = self.tableViewData[indexPath.row];
        return timeCell;
    } else {
        UBMessageCell *cell = [UBMessageCell cellWithTableView:tableView];
        cell.model = self.tableViewData[indexPath.row];
        cell.delegate = self;
        return cell;
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UBMessageCellModel *cellModel = self.tableViewData[indexPath.row];
    if (cellModel.messageType==UBMessageTypeVoice) {
    }
    NSLog(@"点了cell");
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 判断是否滚动到底部
    if (self.tableView.contentSize.height-self.tableView.contentOffset.y>self.tableView.frame.size.height+100) {
        self.scrollToBottom = NO;
    } else {
        self.scrollToBottom = YES;
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tableViewData[indexPath.row] isKindOfClass:[NSString class]]) {
        return 45; // 时间cell高度
    }else {
        UBMessageCellModel *cellMessageModel = (UBMessageCellModel *)self.tableViewData[indexPath.row];
        return cellMessageModel.cellHeight; // 消息cell高度
    }
}

#pragma mark - UBInputToolBarDelegate
/** 按下录音按钮开始录音 */
- (void)didStartRecordingVoiceAction {
    self.messageRecordView.hidden = NO;
    [self.messageRecordView recordButtonTouchDown];
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time, x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (error) {
//            NSLog(NSLocalizedString(@"message.startRecordFail", @"failure to start recording"));
        }
    }];
}

/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction {
    [self.messageRecordView recordButtonTouchUpOutside];
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    self.messageRecordView.hidden = YES;
    NSLog(@"取消录音");
}

/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction {
    [self.messageRecordView recordButtonTouchUpInside];
    self.messageRecordView.hidden = YES;
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {

            EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath displayName:recordPath];
            voice.duration = aDuration;
            EMVoiceMessageBody *body = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
            // 发送消息
            [self sendMessageWithMessageBody:body];
        } else {
            
        }
    }];
}

/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction {
    NSLog(@"当手指离开按钮的范围内时");
    [self.messageRecordView recordButtonDragOutside];
}

/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction {
    NSLog(@"当手指再次进入按钮的范围内时");
    [self.messageRecordView recordButtonDragInside];
}

#pragma mark - 发送各种消息
/** 发送文本消息 */
- (void)sendMessageWithType:(UBMessageType)type andMessageBody:(id)messageBody {
    NSString *text = (NSString *)messageBody;
    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    // 发送消息
    [self sendMessageWithMessageBody:body];
}
/** 发送图片消息 */
- (void)sendImageMessage:(UIImage *)image {
    EMChatImage *imgChat = [[EMChatImage alloc] initWithUIImage:image displayName:@"displayName.jpg"];
    EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithChatObject:imgChat];
    // 发送消息
    [self sendMessageWithMessageBody:body];
}
/** 发送位置消息 */
- (void)sendLocationMessage:(CLLocationCoordinate2D)coordinate address:(NSString *)address {
    EMChatLocation *locChat = [[EMChatLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude address:address];
    EMLocationMessageBody *body = [[EMLocationMessageBody alloc] initWithChatObject:locChat];
    // 发送消息
    [self sendMessageWithMessageBody:body];
}

/** 发送视频消息 */
- (void)sendVideoMessageWithURL:(NSURL *)movUrl {
    EMChatVideo *videoChat = [[EMChatVideo alloc] initWithFile:[movUrl relativePath] displayName:@"displayName"];
    EMVideoMessageBody *body = [[EMVideoMessageBody alloc] initWithChatObject:videoChat];
    // 发送消息
    [self sendMessageWithMessageBody:body];
}
/** 统一发送消息出口 */
-(void)sendMessageWithMessageBody:(id<IEMMessageBody>)body {
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.conversation.chatter bodies:@[body]];
    message.messageType = (EMMessageType)self.conversation.conversationType; // 设置为单聊消息
    
    // 消息cellModel
    UBMessageCellModel *messageModel = [[UBMessageCellModel alloc] init];
    messageModel.showUsername = self.conversation.conversationType != eConversationTypeChat;
    messageModel.message = message;
    messageModel.loading = YES;
    
    // 添加时间
    self.messageTimeIntervalTag = [(UBMessageCellModel *)([self.tableViewData lastObject]) message].timestamp/1000;
    CGFloat interval = (self.messageTimeIntervalTag - message.timestamp/1000);
    if (self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60) {
        [self.tableViewData addObject:[UBMessageTimeTool timeStr:message.timestamp/1000]];
    }
    
    // 添加消息
    [self.tableViewData addObject:messageModel];
    // 刷新表格
    [self.tableView reloadData];
    // 滚动到底部(感觉不加延时有时候动画效果不流畅)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.tableViewData.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    });
    
    // 异步发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        messageModel.loading = YES; // 菊花转
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        messageModel.loading = NO;  // 菊花停止转
    } onQueue:nil];
    
}

/** 设置输入框高度 */
- (void)inputViewSizeToHeight:(CGFloat)toHeight {
    self.inputToolBarHeight.mas_equalTo(toHeight);
    [UIView animateWithDuration:.25 animations:^{
        [self.inputToolBar layoutIfNeeded];
    }];
}

/** 更多媒体发送 */
- (void)moreMediaButtonDidWithType:(UBMediaViewButtonType)type {
    if (type==UBMediaViewButtonTypeCamera) {
#if TARGET_IPHONE_SIMULATOR
        NSLog(@"模拟器不支持相机功能！");
#elif TARGET_OS_IPHONE
        // 弹出相机
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
#endif
    } else if (type==UBMediaViewButtonTypePhoto) { // 图片发送
        // 弹出照片选择
        self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        [self presentViewController:self.imagePicker animated:YES completion:nil];
    }
    if(type==UBMediaViewButtonTypeLocation) {
        // 位置发送
        UBMessageLocationViewController *vc = [[UBMessageLocationViewController alloc] init];
        vc.send = YES;
        vc.senderComplete = ^(CLLocationCoordinate2D locationCoordinate, NSString *address) {
            [self sendLocationMessage:locationCoordinate address:address];
        };
        self.hidesBottomBarWhenPushed = YES;
        [self.view endEditing:YES];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type==UBMediaViewButtonTypeVoiceCall) {
        // 语音通话
        EMError *error = nil;
        EMCallSession *callSession = [[EaseMob sharedInstance].callManager asyncMakeVoiceCall:self.conversation.chatter timeout:50 error:&error];
        UBMessageCallViewController *callVc = [[UBMessageCallViewController alloc] initWithSession:callSession];
        callVc.caller = YES;
        // 发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:UBMessageCallViewPresentNotification object:nil];
        [self presentViewController:callVc animated:YES completion:nil];
        
    } else if(type==UBMediaViewButtonTypeVideoCall) {
        // 视频通话
        EMError *error = nil;
        EMCallSession *callSession = [[EaseMob sharedInstance].callManager asyncMakeVideoCall:self.conversation.chatter timeout:50 error:&error];
        UBMessageCallVideoViewController *callVc = [[UBMessageCallVideoViewController alloc] initWithSession:callSession];
        callVc.caller = YES;
        // 发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:UBMessageCallViewPresentNotification object:nil];
        [self presentViewController:callVc animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // 视频转换
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        // 发送视频
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        // 发送图片
        UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
        [self sendImageMessage:orgImage];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.imagePicker dismissViewControllerAnimated:YES completion:NULL];
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}


#pragma mark getters and setters

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.frame;
        UIEdgeInsets paddding = self.tableView.contentInset;
        paddding.bottom = 15;
        _tableView.contentInset = paddding;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _tableView.height -= 46;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
        [_tableView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)]];
        
    }
    return _tableView;
}

- (NSMutableArray<UBMessageCellModel *> *)tableViewData {
    if (!_tableViewData) {
        _tableViewData = [NSMutableArray array];
    }
    return _tableViewData;
}
- (MWPhotoBrowser *)photoBrowser {
//    if (!_photoBrowser) { // 每个图片浏览器必须重新实例化
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        // Set options
        browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
        browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        browser.autoPlayOnAppear = NO; // Auto-play first video
        // Customise selection images to change colours if required
        browser.customImageSelectedIconName = @"ImageSelected.png";
        browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
        // Optionally set the current visible photo before displaying
        [browser setCurrentPhotoIndex:0];
        _photoBrowser = browser;
//    }
    return _photoBrowser;
}

- (UBInputToolBar *)inputToolBar {
    if (!_inputToolBar) {
        _inputToolBar = [[UBInputToolBar alloc] init];
        _inputToolBar.delegate = self;
        [self.view addSubview:_inputToolBar];
        [_inputToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            self.inputToolBarHeight = make.height.mas_equalTo(46);
            self.inputToolBarBottom = make.bottom.equalTo(self.view);
        }];
        // 键盘的frame发生改变时发出的通知（位置和尺寸）
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    return _inputToolBar;
}

- (UBMessageRecordView *)messageRecordView {
    if (!_messageRecordView) {
        _messageRecordView = [[UBMessageRecordView alloc] init];
        _messageRecordView.hidden = YES;
        [self.view addSubview:_messageRecordView];
        [_messageRecordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(150, 100));
            make.center.equalTo(self.view);
        }];
    }
    return _messageRecordView;
}

- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [self.tableView addSubview:_refreshControl];
        [_refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}
- (UIImagePickerController *)imagePicker {
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    return _imagePicker;
}
- (UIMenuController *)menuControl {
    if (!_menuControl) {
        _menuControl = [UIMenuController sharedMenuController];
    }
    return _menuControl;
}
- (UIMenuItem *)itemCopy {
    if (!_itemCopy) {
        _itemCopy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)];
    }
    return _itemCopy;
}
- (UIMenuItem *)itemDelete {
    if (!_itemDelete) {
        _itemDelete = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClicked:)];
    }
    return _itemDelete;
}
- (UIMenuItem *)itemTransmit {
    if (!_itemTransmit) {
        _itemTransmit = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(transmitItemClicked:)];
    }
    return _itemTransmit;
}

@end
