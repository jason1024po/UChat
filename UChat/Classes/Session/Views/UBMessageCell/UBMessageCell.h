//
//  UBMessageCell.h
//  UChat
//
//  Created by xusj on 16/1/4.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBMessageCellModel.h"
#import "UBMessageMacro.h"
#import "UBMessageCellContentBgView.h"

@protocol UBMessageCellDelegate <NSObject>

@optional
/**
 *  消息点击
 *
 *  @param model 消息model
 */
- (void)messageCellDidWithModel:(UBMessageCellModel *)model;
/**
 *  长按消息
 *
 *  @param model 消息model
 */
- (void)messageCellLongPressWithModel:(UBMessageCellModel *)model;


@end

@interface UBMessageCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;
/** 内容背景 */
@property (nonatomic, strong) UBMessageCellContentBgView *contentBgView;
/** model */
@property (nonatomic, strong) UBMessageCellModel *model;
/** 语音播放动画 */
@property (nonatomic, assign) BOOL playVoiceAnimation;
/** 是否已读 */
@property (nonatomic, assign) BOOL isMessageRead;
/** 加载 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

@property (nonatomic, weak) id<UBMessageCellDelegate>delegate;

@end
