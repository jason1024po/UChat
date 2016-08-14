//
//  UBMessageViewController.m
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UBMessageViewController.h"
#import "UBSessionViewController.h"
#import <EaseMobSDKFull/EaseMob.h>
#import "UBMessageViewCell.h"
#import <EMChatManagerLoginDelegate.h>
#import "UBMessageCallViewController.h"
#import "UBMessageCallVideoViewController.h"
#import "UBMessageMacro.h"
#import "UBInvitationManagerTool.h"

@interface UBMessageViewController ()<UITableViewDataSource, UITableViewDelegate, EMChatManagerDelegate, IChatManagerDelegate, EMCallManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *tableViewData;
@property (nonatomic, strong) NSArray *groupsData;

@end

@implementation UBMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"首页";
    
    [self tableView];
    
    // 设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    // 时实通话代理
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
    // 设置实时通话码率
    [[EaseMob sharedInstance].callManager setBitrate:150];
    
    // 时实通话界面present消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCallViewPresent) name:UBMessageCallViewPresentNotification object:nil];
    // 时实通话界面dismiss消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageCallViewDismiss) name:UBMessageCallViewDismissNotification object:nil];
    // 加载会话列表
    [self loadConversations];
}

/** 移除代理 */
- (void)messageCallViewPresent {
    [[EaseMob sharedInstance].callManager removeDelegate:self];
}
/** 添加代理 */
- (void)messageCallViewDismiss {
    [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
}

- (void)dealloc {
//    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

/** 刷新 */
- (void)refreshTableView:(UIRefreshControl *)refreshControl {
    [self loadConversations];
}

- (void)loadConversations {
    [self.tableViewData removeAllObjects];
    // 获取历史会话记录
    // 1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    // 2.如果内存里没有会话记录，从数据库Conversation表
    if (conversations.count == 0) {
        conversations =  [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    for (EMConversation *obj in conversations) {
        [self.tableViewData addObject:obj];
    }
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    [self didUnreadMessagesCountChanged];
}

#pragma mark - lify cycle
- (void)viewWillAppear:(BOOL)animated {
    [self loadConversations];
}

#pragma mark - ICallManagerDelegate
/** 实时通话来了 */
- (void)callSessionStatusChanged:(EMCallSession *)callSession changeReason:(EMCallStatusChangedReason)reason error:(EMError *)error {
    if (callSession.status==eCallSessionStatusConnected) { // 通话连接完成等待接听
        if (callSession.type==eCallSessionTypeAudio) { // 语音通话
            [[EaseMob sharedInstance].callManager removeDelegate:self];
            UBMessageCallViewController *callVc = [[UBMessageCallViewController alloc] initWithSession:callSession];
            callVc.callee = YES;
            callVc.dismiss = ^{
                [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
            };
            [self presentViewController:callVc animated:YES completion:nil];
        } else if (callSession.type==eCallSessionTypeVideo){ // 视频通话
            [[EaseMob sharedInstance].callManager removeDelegate:self];
            UBMessageCallVideoViewController *callVc = [[UBMessageCallVideoViewController alloc] initWithSession:callSession];
            callVc.callee = YES;
            callVc.dismiss = ^{
                [[EaseMob sharedInstance].callManager addDelegate:self delegateQueue:nil];
            };
            [self presentViewController:callVc animated:YES completion:nil];
        }
    }
    if (error) {
        [[EaseMob sharedInstance].callManager asyncEndCall:callSession.sessionId reason:eCallReason_Hangup];
        return;
    }
}

#pragma mark - EMChatManagerChatDelegate
- (void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    self.title = @"连接中...";
}
/** 自动登录完成 */
- (void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error {
    if (!error) {
        self.title = @"首页";
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
            if (!error) {
                self.groupsData = groups;
                
                [self.tableViewData enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (conversation.conversationType==eConversationTypeGroupChat) {
                        [groups enumerateObjectsUsingBlock:^(EMGroup *group, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([conversation.chatter isEqualToString:group.groupId]) {
                                conversation.ext = @{@"groupSubject":group.groupSubject};
                            }
                        }];
                    }
                }];
                [self.tableView reloadData];
            }
        } onQueue:nil];
    }
}

/** 收到消息 */
- (void)didReceiveMessage:(EMMessage *)message {
    [self loadConversations];
//    [self didUnreadMessagesCountChanged];
    NSLog(@"收到消息了s");
}

#pragma mark - 好友添加请求
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message {    
    ApplyEntity *applyEntity = [[ApplyEntity alloc] init];
    applyEntity.applicantUsername = username;
    applyEntity.reason = message;
    applyEntity.groupId = @"";
    applyEntity.receiverUsername = kMessageUsername;
    
    UBInvitationManagerTool *invitationMrg = [UBInvitationManagerTool sharedInstance];
    [invitationMrg addInvitation:applyEntity loginUser:kMessageUsername];
    // 红点
    UITabBarItem *addressBookTabItm =  self.navigationController.tabBarController.childViewControllers[1].tabBarItem;
    NSString *badgeValue = [NSString stringWithFormat:@"%lu", (unsigned long)[invitationMrg applyEmtitiesWithloginUser:kMessageUsername].count];
    addressBookTabItm.badgeValue = badgeValue;   
}


#pragma mark - chatManager代理方法

//1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState{
    //    eEMConnectionConnected,   //连接成功
    //    eEMConnectionDisconnected,//未连接
    if (connectionState == eEMConnectionDisconnected) {
        NSLog(@"网络断开，未连接...");
        self.title = @"未连接.";
    }else{
        NSLog(@"网络通了...");
        self.title = @"消息";
    }
}


-(void)willAutoReconnect{
    NSLog(@"将自动重连接...");
    self.title = @"连接中....";
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        NSLog(@"自动重连接成功...");
        self.title = @"消息";
    }else{
        NSLog(@"自动重连接失败... %@",error);
    }
}

#pragma mark 未读消息数改变
- (void)didUnreadMessagesCountChanged{
    //更新表格
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
    
}

-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累
    
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.tableViewData) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    
    self.navigationController.tabBarItem.badgeValue = totalUnreadCount ? [NSString stringWithFormat:@"%ld",totalUnreadCount] : nil;
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}
#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UBMessageViewCell *cell = [UBMessageViewCell cellWithTableView:tableView];
    EMConversation *conversation = self.tableViewData[indexPath.row];
    cell.conversation = conversation;
//    cell.nameLabel.text = conversation.chatter;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.hidesBottomBarWhenPushed = YES;
    UBSessionViewController *sessionVc = [[UBSessionViewController alloc] init];
    sessionVc.conversation = self.tableViewData[indexPath.row];
    [self.navigationController pushViewController:sessionVc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableViewData removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor colorWithRed:0.8941 green:0.9059 blue:0.9255 alpha:1.0];
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}
- (UIRefreshControl *)refreshControl {
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc] init];
        [self.tableView addSubview:_refreshControl];
        [_refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}
- (NSMutableArray *)tableViewData {
    if (!_tableViewData) {
        _tableViewData = [NSMutableArray array];
    }
    return _tableViewData;
}

@end
