//
//  UBMessageViewCell.m
//  UChat
//
//  Created by xusj on 16/1/15.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageViewCell.h"
#import <NSDate+DateTools.h>

@interface UBMessageViewCell()

@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastMessageLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation UBMessageViewCell

- (void)awakeFromNib {
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"UBMessageViewCell";
    UBMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"UBMessageViewCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.unreadLabel.hidden = YES;
    }
    return cell;
}


- (void)setConversation:(EMConversation *)conversation {
    _conversation = conversation;    
    self.nameLabel.text = conversation.chatter;
    // 未读数
    if ([conversation unreadMessagesCount]>0) {
        self.unreadLabel.hidden = ![conversation unreadMessagesCount];
        self.unreadLabel.text = [NSString stringWithFormat:@"%ld", [conversation unreadMessagesCount]];
    }
    // 最后一条消息
    EMMessage *message =  conversation.latestMessage;
    id<IEMMessageBody>messageBody = message.messageBodies.firstObject;
    
    if (messageBody.messageBodyType==eMessageBodyType_Text) {
         self.lastMessageLabel.text = [message.messageBodies.firstObject text];
    }else if (messageBody.messageBodyType==eMessageBodyType_Voice){
        self.lastMessageLabel.text = @"[语音]";
    }else if (messageBody.messageBodyType==eMessageBodyType_Image){
        self.lastMessageLabel.text = @"[图片]";
    }else if (messageBody.messageBodyType==eMessageBodyType_Video){
        self.lastMessageLabel.text = @"[视频]";
    }else if (messageBody.messageBodyType==eMessageBodyType_Location){
        self.lastMessageLabel.text = @"[位置]";
    } else {
        
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp/1000.0];
    // 时间
    self.timeLabel.text = [date formattedDateWithFormat:@"HH:MM"];
    
    if (conversation.conversationType==eConversationTypeGroupChat) {
        if (conversation.ext) {
            self.nameLabel.text = [conversation.ext objectForKey:@"groupSubject"];
        }
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
