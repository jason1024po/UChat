//
//  UBInputTextView.h
//  UChat
//
//  Created by xusj on 15/12/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HWEmotion.h"
@interface UBInputTextView : UITextView
- (void)insertEmotion:(HWEmotion *)emotion;
- (NSString *)fullText;
@end
