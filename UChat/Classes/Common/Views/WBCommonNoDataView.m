//
//  WBCommonNoDataView.m
//  iOS-Base
//
//  Created by xusj on 15/11/30.
//  Copyright © 2015年 xusj. All rights reserved.
//

#import "WBCommonNoDataView.h"

IB_DESIGNABLE
@interface WBCommonNoDataView()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@end

@implementation WBCommonNoDataView

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

+ (instancetype)noDataView {
    return [[[NSBundle mainBundle] loadNibNamed:@"WBCommonNoDataView" owner:self options:nil] firstObject];
}

- (void)setText:(NSString *)text {
    _text = [text copy];
    self.textLabel.text = text;
}



@end
