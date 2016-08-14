//
//  UBChatAddressBookCell.h
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBChatAddressBookCellModel.h"

@interface UBChatAddressBookCell : UITableViewCell

@property (nonatomic, strong) UBChatAddressBookCellModel *model;

+ (instancetype)cellWithTableView:(UITableView *)tableView;



@end
