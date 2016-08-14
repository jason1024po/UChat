//
//  UBChatSettingViewController.m
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBChatSettingViewController.h"
#import <EaseMob.h>
#import <AVOSCloud.h>
#import "UIImage+Extension.h"
#import "Masonry.h"
#import "UIView+Extension.h"
#import <ODRefreshControl.h>
#import "UBLoginViewController.h"
#import "UIView+HUD.h"
const CGFloat topViewH = 200;

@interface UBChatSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) UIImageView *topImageView;
@property (nonatomic, weak) UIImageView *iconImage;
@property (nonatomic, strong) UIView *footerView;


@end

@implementation UBChatSettingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView.rowHeight = 60;
    [self setupView];
    self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    refreshControl.y = 20;
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl {
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupView {
    // 设置headerview
    [self setupHeaderView];
    self.tableView.tableFooterView = self.footerView;
    
}

#pragma mark - event response
- (void)loginOutBtnDid {
    [self loginOutAction];
}

#pragma mark - privete method
- (void)loginOutAction {
    [self.view showLoading];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [self.view hideLoading];
        if (error && error.errorCode != EMErrorServerNotLogin) {
            
        }
        else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"loginInfo"];
            UBLoginViewController *loginVc = [[UBLoginViewController alloc] init];
            [UIApplication sharedApplication].keyWindow.rootViewController = loginVc;
        }
    } onQueue:nil];
    
    
}

#pragma mark 设置headerview
- (void)setupHeaderView {
    
    // 1.tableviewheaderview背景图
    NSString *imgName = [NSString stringWithFormat:@"icon_cat"];
    UIImage *topImage =  [UIImage imageNamed:imgName];
    
    // 1.0图片模糊
    UIImage *blurImage = [UIImage blurryImage:topImage withBlurLevel:0.6f];
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:blurImage];
    topImageView.clipsToBounds = YES;
    topImageView.alpha = 1;
    
    // 1.1图片拉伸模式
    topImageView.contentMode = UIViewContentModeScaleAspectFill;
    //    topImageView.contentMode= UIViewContentModeScaleAspectFit;
    [self.tableView addSubview:topImageView];
    self.topImageView = topImageView;
    [self.tableView insertSubview:topImageView atIndex:0];
    // 1.2位置
    [topImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).with.offset(-topViewH);
        make.width.equalTo(self.view);
        make.centerX.equalTo(self.view);
        make.height.mas_equalTo(topViewH*2);
    }];
    
    
    // 2. tableview的HeaderView
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, 0, topViewH);
    headerView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = headerView;
    
    NSString *iconName = [NSString stringWithFormat:@"icon_cat"];
    // 2.1.1 创建头像
    UIImageView *iconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    [headerView addSubview:iconImage];
    self.iconImage = iconImage;
    // 2.1.2 尺寸位置
    UIEdgeInsets padding = UIEdgeInsetsMake(10, 0, 0, 0);
    CGSize size = CGSizeMake(80, 80);
    [iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableView);
        make.size.mas_equalTo(size);
        make.centerY.equalTo(headerView.mas_centerY).with.offset(padding.top);
    }];
    // 2.1.3 圆角
    iconImage.layer.cornerRadius = size.width * 0.5;
    iconImage.layer.masksToBounds = YES;
    // 2.1.4 边框
    iconImage.layer.borderWidth = 2.0;
    iconImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    // 2.2.1 昵称
    UILabel *nickLabel = [[UILabel alloc] init];
    nickLabel.alpha = 0.9;
    nickLabel.textColor = [UIColor colorWithWhite:0.961 alpha:1.000];
    nickLabel.font = [UIFont boldSystemFontOfSize:17];
    nickLabel.textAlignment = NSTextAlignmentCenter;
    nickLabel.text = @"♞大神留条命";
    CGSize nickLabelSize = CGSizeMake(150, 25);
    [headerView addSubview:nickLabel];
    [nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(iconImage);
        make.top.equalTo(iconImage.mas_bottom).with.offset(5);
        make.size.mas_equalTo(nickLabelSize);
    }];
    // 2.2.2 字体阴影
    nickLabel.shadowColor = [UIColor colorWithWhite:0.196 alpha:1.000];
    nickLabel.shadowOffset = CGSizeMake(0, 0.5);
}

#pragma mark - tableView滚动监听
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // 1.拖动距离
    CGFloat down = - scrollView.contentOffset.y;
    if (down<=0 || down > topViewH) return;
    // 2.用的自动布局,更新约束
    [self.topImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(topViewH*2 + down*2);
    }];
}


#pragma mark - UItableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell = [[UITableViewCell alloc] init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"用户名：%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"loginInfo"] objectForKey:@"username"]];
    
    return cell;
}


#pragma getters
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.frame = self.view.bounds;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}
- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.frame = CGRectMake(0, 0, self.view.width, 70);
        _footerView.backgroundColor = [UIColor clearColor];
        UIButton *loginOutBtn = [[UIButton alloc] init];
        [loginOutBtn setTitle:@"注销" forState:UIControlStateNormal];
        [loginOutBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_video_normal"] forState:UIControlStateNormal];
        [loginOutBtn setBackgroundImage:[UIImage imageNamed:@"btn_bg_video_pressed"] forState:UIControlStateHighlighted];
        loginOutBtn.frame = CGRectMake(15, 10, _footerView.frame.size.width-30, 44);
        loginOutBtn.layer.cornerRadius = 6;
        loginOutBtn.layer.masksToBounds = YES;
        [_footerView addSubview:loginOutBtn];
        [loginOutBtn addTarget:self action:@selector(loginOutBtnDid) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footerView;
}


@end
