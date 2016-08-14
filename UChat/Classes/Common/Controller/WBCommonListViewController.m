//
//  WBCommonListViewController.m
//  iOS-Base
//
//  Created by xusj on 15/12/2.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonListViewController.h"

@implementation WBCommonListViewController

- (void)viewDidLoad {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    [self noDataView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)loadNewData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
    });
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 是否没有数据
    self.noDataView.hidden = self.tableViewData.count || !self.isLoaded;
    // 没有网络
    self.noNetworkView.hidden  = YES;
    return self.tableViewData.count;
}

#pragma mark - getters and setters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:_tableView];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}
- (NSMutableArray *)tableViewData {
    if (!_tableViewData) {
        _tableViewData = [NSMutableArray array];
    }
    return _tableViewData;
}
- (WBCommonNoDataView *)noDataView {
    if (!_noDataView) {
        _noDataView = [WBCommonNoDataView noDataView];
        _noDataView.frame = self.tableView.bounds;
        _noDataView.center = self.tableView.center;
        [self.tableView addSubview:_noDataView];
    }
    return _noDataView;
}
- (WBCommonNoNetworkView *)noNetworkView {
    if (!_noNetworkView) {
        WBCommonNoNetworkView *noNetworkView = [WBCommonNoNetworkView noNetworkView];
        noNetworkView.frame = self.tableView.frame;
        [self.tableView addSubview:noNetworkView];
        _noNetworkView = noNetworkView;
        __weak typeof(self) weakSelf = self;
        [noNetworkView setDidHandleBlock:^{
            [weakSelf.tableView.mj_header beginRefreshing];
        }];
    }
    _noNetworkView.hidden = self.tableViewData.count;
    return _noNetworkView;
}


@end
