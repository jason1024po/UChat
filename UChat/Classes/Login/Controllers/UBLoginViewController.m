//
//  UBLoginViewController.m
//  UChat
//
//  Created by xusj on 16/1/8.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBLoginViewController.h"
#import <EaseMob.h>
#import "UIView+HUD.h"
#import "WBBaseTabBarController.h"

@interface UBLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;


- (IBAction)signUpBtn:(UIButton *)sender;
- (IBAction)logInBtn:(UIButton *)sender;

@end

@implementation UBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)signUpBtn:(UIButton *)sender {
    [self.view endEditing:YES];
    //异步注册账号
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:self.userNameTextField.text
                                                         password:self.passwordTextField.text
                                                   withCompletion:
     ^(NSString *username, NSString *password, EMError *error) {
         
         if (!error) {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"注册成功，请登录" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
             [alert show];
         }else{
             NSString *errMessage = nil;
             switch (error.errorCode) {
                 case EMErrorServerNotReachable:
                     errMessage = @"连接服务器失败!";
                     break;
                 case EMErrorServerDuplicatedAccount:
                     errMessage = @"您注册的用户已存在!";
                     break;
                 case EMErrorNetworkNotConnected:
                     errMessage = @"网络未连接!";
                     break;
                 case EMErrorServerTimeout:
                    errMessage = @"连接服务器超时!";
                     break;
                 default:
                     errMessage = @"注册失败";
                     break;
             }
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:errMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
             [alert show];
             
         }
     } onQueue:nil];

    
}

- (IBAction)logInBtn:(UIButton *)sender {
    [self loginWithUsername:self.userNameTextField.text password:self.passwordTextField.text];
}

//点击登陆后的操作
- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    [self.view endEditing:YES];
    MBProgressHUD *hud = [self.view showLoading:@"登录中..."];
    
    //异步登陆账号
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username
                                                        password:password
                                                      completion:
     ^(NSDictionary *loginInfo, EMError *error) {
         [hud hide:YES];
         if (loginInfo && !error) {
             //设置是否自动登录
             [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             //获取数据库中数据
             [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
             
             //获取群组列表
             [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
             
             //保存最近一次登录用户名
             [self saveLastLoginUsername];
             
             [[NSUserDefaults standardUserDefaults] setObject:@{@"username":username,@"password":password} forKey:@"loginInfo"];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
             WBBaseTabBarController *vc = [[WBBaseTabBarController alloc] init];
             [UIApplication sharedApplication].keyWindow.rootViewController = vc;
         }
         else
         {
             if (error.errorCode==EMErrorServerTooManyOperations) { /// 已经登录
                 [[NSUserDefaults standardUserDefaults] setObject:@{@"username":username,@"password":password} forKey:@"loginInfo"];
                 [[NSUserDefaults standardUserDefaults] synchronize];
                 
                 WBBaseTabBarController *vc = [[WBBaseTabBarController alloc] init];
                 [UIApplication sharedApplication].keyWindow.rootViewController = vc;
                 return ;
             }
             
             switch (error.errorCode)
             {
                 case EMErrorNotFound:
//                     TTAlertNoTitle(error.description);
                     break;
                 case EMErrorNetworkNotConnected:
//                     TTAlertNoTitle(NSLocalizedString(@"error.connectNetworkFail", @"No network connection!"));
                     break;
                 case EMErrorServerNotReachable:
//                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!"));
                     break;
                 case EMErrorServerAuthenticationFailure:
//                     TTAlertNoTitle(error.description);
                     break;
                 case EMErrorServerTimeout:
//                     TTAlertNoTitle(NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!"));
                     break;
                 default:
//                     TTAlertNoTitle(NSLocalizedString(@"login.fail", @"Login failure"));
                     break;
             }
         }
     } onQueue:nil];
}

#pragma  mark - private
- (void)saveLastLoginUsername
{
    NSString *username = [[[EaseMob sharedInstance].chatManager loginInfo] objectForKey:kSDKUsername];
    if (username && username.length > 0) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:username forKey:[NSString stringWithFormat:@"em_lastLogin_%@",kSDKUsername]];
        [ud synchronize];
    }
}

@end
