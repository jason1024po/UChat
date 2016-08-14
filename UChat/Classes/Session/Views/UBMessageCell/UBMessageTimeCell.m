//
//  UBMessageTimeCell.m
//  UChat
//
//  Created by xsj on 16/1/25.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageTimeCell.h"
#import "UIView+Extension.h"

@interface UBMessageTimeCell()

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation UBMessageTimeCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *Identifier = @"UBMessageTimeCell";
    UBMessageTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    if (!cell) {
        cell = [[UBMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self timeLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10]}];
    
    self.timeLabel.frame = CGRectMake(0, 25,  size.width+15, 16);
    self.timeLabel.centerX = self.contentView.centerX;
}



- (void)setText:(NSString *)text {
    _text = text;
    self.timeLabel.text = text;
    [self layoutIfNeeded];
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.backgroundColor = [UIColor colorWithRed:0.749 green:0.7608 blue:0.7765 alpha:1.0];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.layer.cornerRadius = 7;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_timeLabel];
    }
    return _timeLabel;
}

@end
