//
//  UBMessageTimeCell.h
//  UChat
//
//  Created by xsj on 16/1/25.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UBMessageTimeCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) NSString  *text;
@end
