//
//  UBMessageViewCell.h
//  UChat
//
//  Created by xusj on 16/1/15.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EaseMob.h>

@interface UBMessageViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, strong) EMConversation *conversation;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
