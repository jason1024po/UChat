//
//  UBInvitationManagerTool.h
//  UChat
//
//  Created by xsj on 16/1/29.
//  Copyright © 2016年 xusj. All rights reserved.
//  好友请求添加工具

#import <Foundation/Foundation.h>
@class ApplyEntity;
@interface UBInvitationManagerTool : NSObject

+ (instancetype)sharedInstance;

-(void)addInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username;

-(void)removeInvitation:(ApplyEntity *)applyEntity loginUser:(NSString *)username;

-(NSArray *)applyEmtitiesWithloginUser:(NSString *)username;

@end

@interface ApplyEntity : NSObject

@property (nonatomic, strong) NSString * applicantUsername;
@property (nonatomic, strong) NSString * applicantNick;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverUsername;
@property (nonatomic, strong) NSString * receiverNick;
@property (nonatomic, strong) NSNumber * style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;

@end
