//
//  UBChatGroupListController.m
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBChatGroupListController.h"
#import <EaseMob.h>
#import "UBChatAddressBookCellModel.h"
#import "UBChatAddressBookCell.h"
#import "UBSessionViewController.h"

@interface UBChatGroupListController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tableViewData;

@end

@implementation UBChatGroupListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"群组";
    [self tableView];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsListWithCompletion:^(NSArray *groups, EMError *error) {
        if (!error) {
            for (EMGroup *group in groups) {
                UBChatAddressBookCellModel *model = [UBChatAddressBookCellModel modelWithIcon:@"DefaultAvatar" title:group.groupSubject didBlock:nil];
                model.data = group;
                [self.tableViewData addObject:model];
            }
            [self.tableView reloadData];
            
            NSLog(@"获取成功 -- %@",groups);
        }
    } onQueue:nil];
    
    
}
- (void)dealloc {
    NSLog(@"---UBChatGroupListController----dealloc");
}


#pragma mark -UITableViewDataSource
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableViewData count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBChatAddressBookCell *cell = [UBChatAddressBookCell cellWithTableView:tableView];
    cell.model = self.tableViewData[indexPath.row];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UBChatAddressBookCellModel *cellModel = self.tableViewData[indexPath.row];
    // 有自定义点击事件
    if (cellModel.didBlock) {
        cellModel.didBlock();
        return;
    }
    // 默认跳转
    EMGroup *group = (EMGroup *)cellModel.data;
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:group.groupId conversationType:eConversationTypeChatRoom];
    
    UBSessionViewController *sessionVc = [[UBSessionViewController alloc] init];
    sessionVc.conversation = conversation;
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sessionVc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
    
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

@end
