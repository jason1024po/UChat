//
//  UBChatAddressBookCell.m
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBChatAddressBookCell.h"

@interface UBChatAddressBookCell()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation UBChatAddressBookCell

- (void)awakeFromNib {
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"UBChatAddressBookCell";
    UBChatAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UBChatAddressBookCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)setModel:(UBChatAddressBookCellModel *)model {
    _model = model;
    self.iconImageView.image = [UIImage imageNamed:model.icon];
    self.titleLabel.text = model.titele;
}

@end
