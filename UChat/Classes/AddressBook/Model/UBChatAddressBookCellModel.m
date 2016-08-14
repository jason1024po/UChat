//
//  UBChatAddressBookCellModel.m
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBChatAddressBookCellModel.h"

@implementation UBChatAddressBookCellModel

+ (instancetype)modelWithIcon:(NSString *)icon title:(NSString *)title didBlock:(dispatch_block_t)didBlock {
    UBChatAddressBookCellModel *model = [[self alloc]init];
    model.icon = icon;
    model.titele = title;
    model.didBlock = didBlock;
    return model;    
}

@end
