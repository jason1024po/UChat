//
//  UBMessageCellModel.m
//  UChat
//
//  Created by xusj on 16/1/4.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageCellModel.h"
#import "WBCommonMacro.h"
#import <EMImageMessageBody.h>
#import "UBMessageMacro.h"
#import <EMVideoMessageBody.h>
#import <EMVoiceMessageBody.h>
#import "HMEmotion.h"
#import "HMEmotionAttachment.h"
#import "HMEmotionTool.h"
#import "HMRegexResult.h"
#import "RegExCategories.h"
#import "UBMessageCell.h"

@implementation UBMessageCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+ (instancetype)modelWithMessage:(EMMessage *)message {
    UBMessageCellModel *model = [[self alloc] init];
    model.message = message;
    model.messageType = UBMessageTypeUnknown;
    return model;
}
+ (instancetype)modelWithMessage:(EMMessage *)message showUsername:(BOOL)showUsername {
    UBMessageCellModel *model = [[self alloc] init];
    model.showUsername = showUsername;
    model.message = message;
    model.messageType = UBMessageTypeUnknown;
    return model;
}

- (void)setMessage:(EMMessage *)message {
    _message = message;
    self.messageBody = message.messageBodies.firstObject;
    
    
    // 是否发送者
    self.sender = [self.message.from isEqualToString:kMessageUsername];
    if (self.sender) {
        self.messagePositon = UBMessagePositionRight;
    } else {
        self.messagePositon = UBMessagePositionLeft;
    }
    
    NSString *txt = @"";
    CGSize size = CGSizeZero;
    
    CGFloat marginW = kMessageIconMarginLeft + kMessageIconWH + kMessageContentMarginLeft + kMessageContentPaddingLeft + kMessageContentPaddingRight + kMessageContentMarginRight;
    // 最大内容宽度
    CGFloat maxContentW = SCREEN_WIDTH-marginW;
    
    if (self.messageBody.messageBodyType == eMessageBodyType_Text) {
        
        self.messageType = UBMessageTypeText;
        txt = ((EMTextMessageBody *)self.messageBody).text;
        self.attributedText = [self attributedStringWithText:txt];
        self.text = txt;
        size = [self.attributedText boundingRectWithSize:CGSizeMake(maxContentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        //size = [self.attributedText boundingRectWithSize:CGSizeMake(maxContentW, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kMessageContentTextFont} context:nil].size;
        
        self.cellHeight = size.height + (15 + kMessageContentPaddingTop + kMessageContentPaddingBottom);
        
    } else if (self.messageBody.messageBodyType == eMessageBodyType_Image) {
        
        self.messageType = UBMessageTypeImage;
        EMImageMessageBody *imgMessageBody = (EMImageMessageBody *)self.messageBody;
        size = imgMessageBody.thumbnailSize;
        if (self.sender) {
            while (size.height>160) {
                size = CGSizeMake(size.width/2, size.height/2);
            }
            while (size.width>160) {
                size = CGSizeMake(size.width/2, size.height/2);
            }
        } else {
            //size = CGSizeMake(size.width*1.5, size.height*1.5);
        }
        self.cellHeight = size.height + kMessageContentImagePadding + kMessageContentImagePadding + 15;
        
    } else if (self.messageBody.messageBodyType == eMessageBodyType_Voice) {
        EMVoiceMessageBody *body = (EMVoiceMessageBody *)self.messageBody;
        self.messageType = UBMessageTypeVoice;
        self.voiceLocaPath = body.localPath;
        CGFloat width = 40 + body.duration * 4;
        if (width>maxContentW) {
            width = maxContentW;
        }
        size = CGSizeMake(width, 40);
        self.cellHeight = 60;
        
    } else if (self.messageBody.messageBodyType == eMessageBodyType_Video) {
        self.messageType = UBMessageTypeVideo;
        EMVideoMessageBody *body = (EMVideoMessageBody *)self.messageBody;
        size = body.size;
        self.cellHeight = size.height + 15 + kMessageContentImagePadding + kMessageContentImagePadding;
    } else if (self.messageBody.messageBodyType == eMessageBodyType_Location){
        
        self.messageType = UBMessageTypeLocation;
        size = CGSizeMake(110, 105);
        self.cellHeight = size.height + kMessageContentImagePadding + kMessageContentImagePadding + 15;
        
    } else {
        self.cellHeight = 60;
    }
    self.contentSize = size;
    
    if (self.showUsername) {
        self.cellHeight += kMessageUsernameLabelHeight;
    }
    
    // 是否未读
    self.isMessageRead = message.isReadAcked;
    
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    if (self.cell) {
        self.cell.loading = loading;
    }
}

- (NSAttributedString *)attributedStringWithText:(NSString *)text {
    // 1.匹配字符串
    NSArray *regexResults = [self regexResultsWithText:text];
    
    // 2.根据匹配结果，拼接对应的图片表情和普通文本
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
    // 遍历
    [regexResults enumerateObjectsUsingBlock:^(HMRegexResult *result, NSUInteger idx, BOOL *stop) {
        HMEmotion *emotion = nil;
        if (result.isEmotion) { // 表情
            emotion = [HMEmotionTool emotionWithDesc:result.string];
        }
        
        if (emotion) { // 如果有表情
            // 创建附件对象
            HMEmotionAttachment *attach = [[HMEmotionAttachment alloc] init];
            
            // 传递表情
            attach.emotion = emotion;
            attach.bounds = CGRectMake(0, -4.5, kMessageContentTextFont.lineHeight+2, kMessageContentTextFont.lineHeight+2);
            
            // 将附件包装成富文本
            NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
            [attributedString appendAttributedString:attachString];
        } else { // 非表情（直接拼接普通文本）
            NSMutableAttributedString *substr = [[NSMutableAttributedString alloc] initWithString:result.string];
            
//            // 匹配#话题#
//            NSString *trendRegex = @"#[a-zA-Z0-9\\u4e00-\\u9fa5]+#";
//            [result.string enumerateStringsMatchedByRegex:trendRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:*capturedRanges];
//                [substr addAttribute:@"HMLinkText" value:*capturedStrings range:*capturedRanges];
//            }];
//            
//            // 匹配@提到
//            NSString *mentionRegex = @"@[a-zA-Z0-9\\u4e00-\\u9fa5\\-_]+";
//            [result.string enumerateStringsMatchedByRegex:mentionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:*capturedRanges];
//                [substr addAttribute:@"HMLinkText" value:*capturedStrings range:*capturedRanges];
//            }];
//            
//            // 匹配超链接
//            NSString *httpRegex = @"http(s)?://([a-zA-Z|\\d]+\\.)+[a-zA-Z|\\d]+(/[a-zA-Z|\\d|\\-|\\+|_./?%&=]*)?";
//            [result.string enumerateStringsMatchedByRegex:httpRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//                [substr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:*capturedRanges];
//                [substr addAttribute:@"HMLinkText" value:*capturedStrings range:*capturedRanges];
//            }];
            
            [attributedString appendAttributedString:substr];
        }
    }];
    
    // 设置字体
    [attributedString addAttribute:NSFontAttributeName value:kMessageContentTextFont range:NSMakeRange(0, attributedString.length)];
    
    return attributedString;
}
/**
 *  根据字符串计算出所有的匹配结果（已经排好序）
 *
 *  @param text 字符串内容
 */
- (NSArray *)regexResultsWithText:(NSString *)text {
    // 用来存放所有的匹配结果
    NSMutableArray *regexResults = [NSMutableArray array];
    
    // 匹配表情
    NSString *emotionRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5\\_\\-]+\\]";
//    [text enumerateStringsMatchedByRegex:emotionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//        HMRegexResult *rr = [[HMRegexResult alloc] init];
//        rr.string = *capturedStrings;
//        rr.range = *capturedRanges;
//        rr.emotion = YES;
//        [regexResults addObject:rr];
//    }];
    NSArray* matches = [text matchesWithDetails:RX(emotionRegex)];
    for (RxMatch *rx in matches) {
        HMRegexResult *rr = [[HMRegexResult alloc] init];
        rr.string = rx.value;
        rr.range = rx.range;
        rr.emotion = YES;
        [regexResults addObject:rr];
    }
    
//    NSLog(@"%@", matches);
   
    
    // 匹配非表情
//    [text enumerateStringsSeparatedByRegex:emotionRegex usingBlock:^(NSInteger captureCount, NSString *const __unsafe_unretained *capturedStrings, const NSRange *capturedRanges, volatile BOOL *const stop) {
//        HMRegexResult *rr = [[HMRegexResult alloc] init];
//        rr.string = *capturedStrings;
//        rr.range = *capturedRanges;
//        rr.emotion = NO;
//        [regexResults addObject:rr];
//    }];

    NSArray *splits = [text splitWithDetails:RX(emotionRegex)];
    
    for (RxMatch *rx in splits) {
        HMRegexResult *rr = [[HMRegexResult alloc] init];
        rr.string = rx.value;
        rr.range = rx.range;
        rr.emotion = NO;
        [regexResults addObject:rr];
    }
    
    // 排序
    [regexResults sortUsingComparator:^NSComparisonResult(HMRegexResult *rr1, HMRegexResult *rr2) {
        NSInteger loc1 = rr1.range.location;
        NSInteger loc2 = rr2.range.location;
        return [@(loc1) compare:@(loc2)];
    }];
    return regexResults;
}

- (BOOL)voiceIsExists {
    if (!_voiceIsExists) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        _voiceIsExists = [fileManager fileExistsAtPath:self.voiceLocaPath];
    }
    return _voiceIsExists;
}


@end
