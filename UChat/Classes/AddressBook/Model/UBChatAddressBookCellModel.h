//
//  UBChatAddressBookCellModel.h
//  UChat
//
//  Created by xsj on 16/1/19.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UBChatAddressBookCellModel : NSObject

/** icon */
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, strong) NSString *titele;
@property (nonatomic, strong) id data;
/** 点击的回调 */
@property (nonatomic, copy) dispatch_block_t didBlock;

+ (instancetype)modelWithIcon:(NSString *)icon title:(NSString *)title didBlock:(dispatch_block_t)didBlock;

@end
