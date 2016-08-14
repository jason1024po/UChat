//
//  UBInputToolMoreMediaView.h
//  UChat
//
//  Created by xusj on 16/1/13.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UBMessageMacro.h"

typedef NS_ENUM(NSInteger, UBMediaViewButtonType){
    UBMediaViewButtonTypePhoto=1,
    UBMediaViewButtonTypeLocation,
    UBMediaViewButtonTypeCamera,
    UBMediaViewButtonTypeVoiceCall,
    UBMediaViewButtonTypeVideoCall,
};

@protocol UBInputToolMoreMediaViewDelegate <NSObject>

@optional
/** 按钮点击 */
- (void)mediaButtonDidWithType:(UBMediaViewButtonType)type;

@end

@interface UBInputToolMoreMediaView : UIView

@property (nonatomic, weak) id<UBInputToolMoreMediaViewDelegate>delegate;

@end
