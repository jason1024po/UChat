//
//  UBChatAddressBookViewController.m
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBChatAddressBookViewController.h"
#import <EaseMob.h>
#import "UBSessionViewController.h"
#import "UBChatAddressBookCell.h"
#import "UBChatAddressBookCellModel.h"
#import "UBChatGroupListController.h"
#import "UBAcceptedBuddyViewController.h"
#import "UBInvitationManagerTool.h"

@interface UBChatAddressBookViewController ()<UITableViewDataSource, UITableViewDelegate, EMChatManagerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableViewData;
/** 好友列表数据源 */
@property (nonatomic, strong) NSArray *buddyList;

@property (nonatomic, strong) UIButton *navRightButton;

@end

@implementation UBChatAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title= @"通讯录";

    [self setupView];

    [self tableView];
    
    [self setupData];
    
    // 添加聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    self.buddyList =  [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"=== %@",self.buddyList);
    
    [self.tableView reloadData];
    if (self.buddyList.count<1) {
        [self loadBuddyListFromServer];
    }
}
- (void)setupView {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.navRightButton];
}

- (void)setupData {
    UBChatAddressBookCellModel *model = [UBChatAddressBookCellModel modelWithIcon:@"icon_message_normal" title:@"验证消息" didBlock:^{
        UBAcceptedBuddyViewController *vc = [[UBAcceptedBuddyViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UBChatAddressBookCellModel *model1 = [UBChatAddressBookCellModel modelWithIcon:@"icon_team_advance_normal" title:@"群组" didBlock:^{
        UBChatGroupListController *vc = [[UBChatGroupListController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UBChatAddressBookCellModel *model2 = [UBChatAddressBookCellModel modelWithIcon:@"icon_blacklist_normal" title:@"黑名单" didBlock:^{
        UBChatGroupListController *vc = [[UBChatGroupListController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    [self.tableViewData addObject:@[model,model1,model2]];
}


#pragma mark - event response
- (void)addBuddy {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"好友名字"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    

    [alert show];
}
- (void)navRightButtonDid:(UIButton *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"添加好友", @"创建群组", nil];
    [actionSheet showInView:self.view];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==0) {
        NSLog(@"添加好友");
        // 添加好友
        [self addBuddy];
    } else if (buttonIndex==1){
        NSLog(@"创建群组");
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        UITextField *textfield=[alertView textFieldAtIndex:0];
        // 添加好友
        EMError *error = nil;
        BOOL isSuccess = [[EaseMob sharedInstance].chatManager addBuddy:textfield.text message:@"我想加您为好友" error:&error];
        if (isSuccess && !error) {
            NSLog(@"添加(%@)好友成功", textfield.text);
        }else {
            NSLog(@"添加好友失败");
        }
    }
}


#pragma mark -UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableViewData.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableViewData[section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  !section ? 0 : 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBChatAddressBookCell *cell = [UBChatAddressBookCell cellWithTableView:tableView];
    cell.model = self.tableViewData[indexPath.section][indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBChatAddressBookCellModel *cellModel = self.tableViewData[indexPath.section][indexPath.row];
    // 有自定义点击事件
    if (cellModel.didBlock) {
        cellModel.didBlock();
        return;
    }
    // 默认跳转
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:cellModel.titele conversationType:eConversationTypeChat];
    
    UBSessionViewController *sessionVc = [[UBSessionViewController alloc] init];
    sessionVc.conversation = conversation;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sessionVc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
}

#pragma mark - chatmanger的代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (!error) {//自动登录成功，此时buddyList就有值
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"=== %@",self.buddyList);
        [self.tableView reloadData];
    }
}


#pragma mark 好友添加请求同意
-(void)didAcceptedByBuddy:(NSString *)username{
    // 把新的好友显示到表格
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友添加请求同意 %@",buddyList);
#warning buddyList的个数，仍然是没有添加好友之前的个数，从新服务器获取
    [self loadBuddyListFromServer];
    
}

#pragma mark 从新服务器获取好友列表
-(void)loadBuddyListFromServer{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        NSLog(@"从服务器获取的好友列表 %@",buddyList);
        
        // 赋值数据源
        self.buddyList = buddyList;
        
        // 刷新
        [self.tableView reloadData];
        
    } onQueue:nil];
}

#pragma mark 好友列表数据被更新
-(void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd{
    
    NSLog(@"好友列表数据被更新 %@",buddyList);
    // 重新赋值数据源
    self.buddyList = buddyList;
    // 刷新
    [self.tableView reloadData];
}

#pragma mark - 被好友删除
-(void)didRemovedByBuddy:(NSString *)username{
    // 刷新表格
    [self loadBuddyListFromServer];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section; // 第二组删除
}
/** 删除好友 */
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUsername = buddy.username;
        
        // 删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
    
}


#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor colorWithRed:0.8599 green:0.8567 blue:0.8815 alpha:1.0];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray *)tableViewData {
    if (!_tableViewData) {
        _tableViewData = [NSMutableArray array];
    }
    return _tableViewData;
}

- (void)setBuddyList:(NSArray *)buddyList {
    _buddyList = buddyList;
    NSMutableArray *mArr = [NSMutableArray array];
    for (EMBuddy *buddy in buddyList) {
        UBChatAddressBookCellModel *model = [UBChatAddressBookCellModel modelWithIcon:@"DefaultAvatar" title:buddy.username didBlock:nil];
        [mArr addObject:model];
    }
    self.tableViewData[1] = mArr;
}

- (UIButton *)navRightButton {
    if (!_navRightButton) {
        _navRightButton = [[UIButton alloc] init];
        [_navRightButton setBackgroundImage:[UIImage imageNamed:@"icon_tinfo_normal"] forState:UIControlStateNormal];
        [_navRightButton setBackgroundImage:[UIImage imageNamed:@"icon_tinfo_pressed"] forState:UIControlStateHighlighted];
        _navRightButton.frame = (CGRect){CGPointMake(15, 0), _navRightButton.currentBackgroundImage.size};
        [_navRightButton addTarget:self action:@selector(navRightButtonDid:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navRightButton;
}

@end
