//
//  WBCommonListViewController.h
//  iOS-Base
//
//  Created by xusj on 15/12/2.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MJRefresh.h>
#import "WBCommonNoDataView.h"
#import "WBCommonNoNetworkView.h"

@interface WBCommonListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView           *tableView;     // table
@property (strong, nonatomic) NSMutableArray        *tableViewData; // 列表数据
@property (strong, nonatomic) WBCommonNoDataView    *noDataView;    // 没有数据
@property (strong, nonatomic) WBCommonNoNetworkView *noNetworkView; // 没有网络
/** 页面是否加载过 */
@property (assign, nonatomic, getter=isLoaded) BOOL loaded;

@end
