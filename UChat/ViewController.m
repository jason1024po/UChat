//
//  ViewController.m
//  UChat
//
//  Created by xusj on 15/12/29.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "ViewController.h"
#import <EaseMob.h>
#import "UBSessionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self userLogin];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
 
//    EMChatText *txtChat = [[EMChatText alloc] initWithText:@"要发送的消息"];
//    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
//    
//    // 生成message
//    EMMessage *message = [[EMMessage alloc] initWithReceiver:@"13034287105" bodies:@[body]];
//    message.messageType = eMessageTypeChat;
//    
//    EMMessage *retMessage = [[EaseMob sharedInstance].chatManager asyncSendMessage:message
//                                                                          progress:nil];
//    NSLog(@"%@", retMessage);
    
    
    
}

/**
 *  用户注册
 */
- (void)userRegister {
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:@"8001" password:@"111111" withCompletion:^(NSString *username, NSString *password, EMError *error) {
        if (!error) {
            NSLog(@"注册成功");
        }
    } onQueue:nil];
}
/**
 *  用户登录
 */
- (void)userLogin {
    
//    BOOL isAutoLogin = [[EaseMob sharedInstance].chatManager isAutoLoginEnabled];
//    if (!isAutoLogin) {
        NSString *username = @"13245590074";
        NSString *password = @"xushengjiang";
        [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
            
            if (!error) {
                // 设置自动登录
                [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
            }
            
        } onQueue:nil];
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
