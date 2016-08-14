//
//  UBMessageLocationViewController.h
//  UChat
//
//  Created by xusj on 16/1/7.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

//typedef void(^UBLocationsenderComplete)(CLLocationCoordinate2D locationCoordinate, NSString *address);

@interface UBMessageLocationViewController : UIViewController

/** 位置 */
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;
/** 是否发送地图 */
@property (nonatomic, assign, getter=isSender) BOOL send;
/** 发送按钮did */
@property (nonatomic, copy) void(^senderComplete)(CLLocationCoordinate2D locationCoordinate, NSString *address);

/**
 *  设置位置信息及坐标
 *
 *  @param coordinate 坐标
 *  @param address    地址信息
 */
- (void)setLocationCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address;



@end
