//
//  UBInputTextView.m
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "UBInputTextView.h"
#import "HWEmotionAttachment.h"
#import "UITextView+Extension.h"
#import "NSString+Emoji.h"
@implementation UBInputTextView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    self.layer.borderWidth = .5f;
    self.layer.cornerRadius = 5.0f;
    self.layer.borderColor = [UIColor colorWithRed:0.800 green:0.816 blue:0.835 alpha:1.000].CGColor;
    
//    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    self.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 10.0f, 0.0f, 0.0f);
//    self.contentInset =  UIEdgeInsetsMake(0.0f, 5.0f, 0.0f, 5.0f);
    self.scrollsToTop = NO;
    self.contentSize = CGSizeMake(self.contentSize.width-10, self.contentSize.height);
    self.userInteractionEnabled = YES;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    
    self.font = [UIFont systemFontOfSize:16.0f];
    self.textColor = [UIColor colorWithWhite:0.118 alpha:1.000];
//    self.backgroundColor = [UIColor whiteColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
//    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeySend;
//    self.textAlignment = NSTextAlignmentLeft;
    self.layoutManager.allowsNonContiguousLayout = NO;
//     [self scrollRangeToVisible:NSMakeRange(0,0)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange) name:UITextViewTextDidChangeNotification object:self];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    // setNeedsDisplay会在下一个消息循环时刻，调用drawRect:
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    
    [self setNeedsDisplay];
}

- (void)insertEmotion:(HWEmotion *)emotion
{
    if (emotion.code) {
        // insertText : 将文字插入到光标所在的位置
        [self insertText:emotion.code.emoji];
    } else if (emotion.png) {
        // 加载图片
        HWEmotionAttachment *attch = [[HWEmotionAttachment alloc] init];
        
        // 传递模型
        attch.emotion = emotion;
        
        // 设置图片的尺寸
        CGFloat attchWH = self.font.lineHeight;
        attch.bounds = CGRectMake(0, -4, attchWH, attchWH);
        
        // 根据附件创建一个属性文字
        NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:attch];
        
        // 插入属性文字到光标位置
        [self insertAttributedText:imageStr settingBlock:^(NSMutableAttributedString *attributedText) {
            // 设置字体
            [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
        }];
    }
}

- (NSString *)fullText
{
    NSMutableString *fullText = [NSMutableString string];
    
    // 遍历所有的属性文字（图片、emoji、普通文字）
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        // 如果是图片表情
        HWEmotionAttachment *attch = attrs[@"NSAttachment"];
        if (attch) { // 图片
            [fullText appendString:attch.emotion.chs];
        } else { // emoji、普通文本
            // 获得这个范围内的文字
            NSAttributedString *str = [self.attributedText attributedSubstringFromRange:range];
            [fullText appendString:str.string];
        }
    }];
    
    return fullText;
}


/**
 * 监听文字改变
 */
- (void)textDidChange {
    // 重绘（重新调用）
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    // 如果有输入文字，就直接返回，不画占位文字
    if (self.hasText) return;
    
    // 文字属性
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSFontAttributeName] = self.font;
    attrs[NSForegroundColorAttributeName] = [UIColor colorWithRed:0.517 green:0.517 blue:0.517 alpha:1.0];
    // 画文字
//        [@"请输入消息" drawAtPoint:CGPointMake(5, 8) withAttributes:attrs];
    CGFloat x = 8;
    CGFloat w = rect.size.width - 2 * x;
    CGFloat y = 8;
    CGFloat h = rect.size.height - 2 * y;
    CGRect placeholderRect = CGRectMake(x, y, w, h);
    [@"请输入消息" drawInRect:placeholderRect withAttributes:attrs];
}

@end
