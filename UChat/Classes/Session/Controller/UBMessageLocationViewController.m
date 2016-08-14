//
//  UBMessageLocationViewController.m
//  UChat
//
//  Created by xusj on 16/1/7.
//  Copyright © 2016年 xusj. All rights reserved.
//

#import "UBMessageLocationViewController.h"


@interface UBMessageLocationViewController()<MKMapViewDelegate>
/** 地图实例 */
@property (nonatomic, strong) MKMapView *mapView;
/** 大头针 */
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;
/** 定位管理者 */
@property (nonatomic, strong) CLLocationManager *locationManager;
/** 地理编码对象 */
@property (nonatomic, strong) CLGeocoder *geocoder;
/** 发送按钮 */
@property (nonatomic, strong) UIButton *senderButton;
/** 位置 */
//@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/** 地址 */
@property (nonatomic, strong) NSString *address;
@end

@implementation UBMessageLocationViewController


- (instancetype)init {
    self = [super init];
    if (self) {
        [self mapView];
    }
    return self;
}

- (void)viewDidLoad {
    self.title = @"位置";
    
    // 注意:在iOS8中, 如果想要追踪用户的位置, 必须自己主动请求隐私权限
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0) {
        // 主动请求权限
        [self.locationManager requestAlwaysAuthorization];
    }
}

- (void)dealloc {
    NSLog(@"dealloc");
}

#pragma mark - event response
- (void)senderButtonDid {
    if (self.senderComplete) {
        self.senderComplete(self.locationCoordinate, self.address);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    return nil;
    // 自定义annotation
//    static NSString *aID = @"annotationViewID";
//    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:aID];
//    if (!annotationView) {
//        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:aID];
//        annotationView.canShowCallout = YES;
//    }
//    annotationView.annotation = annotation;
//    return annotationView;
}
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views {
    // 显示大头针弹出层
    [self.mapView selectAnnotation:[self.mapView.annotations lastObject] animated:YES];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    // 利用反地理编码获取位置之后设置标题
    [self.geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks firstObject];
        // NSLog(@"获取地理位置成功 name = %@ locality = %@", placemark.name, placemark.locality);
        userLocation.title = placemark.name;
        // userLocation.subtitle = placemark.locality;
        [self setLocationCoordinate:userLocation.location.coordinate address:placemark.name];
       
        self.title = @"位置";
        [self senderButton];
        // 停止更新位置——实现一次定位
        [self.locationManager stopUpdatingLocation];
    }];
    
    // 移动地图到当前用户所在位置
    // 获取用户当前所在位置的经纬度, 并且设置为地图的中心点
    //    [self.customMapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
    
    // 设置地图显示的区域
    // 获取用户的位置
//    CLLocationCoordinate2D center = userLocation.location.coordinate;
    // 指定经纬度的跨度
//    MKCoordinateSpan span = MKCoordinateSpanMake(0.009310,0.007812);
    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
//    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    // 设置显示区域
//    [self.mapView setRegion:region animated:YES];
    
}


#pragma mark getters and setters

- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView.frame = self.view.frame;
        _mapView.delegate = self;
        _mapView.mapType = MKMapTypeStandard;
        _mapView.zoomEnabled = YES;
        [self.view addSubview:_mapView];
    }
    return _mapView;
}

- (void)setLocationCoordinate:(CLLocationCoordinate2D)coordinate address:(NSString *)address {
    _locationCoordinate = coordinate;
    self.address = address;
    self.mapView.centerCoordinate = coordinate;
    
    self.pointAnnotation.coordinate = coordinate;
    self.pointAnnotation.title = address;
    // self.pointAnnotation.subtitle = address;
    [self.mapView addAnnotation:self.pointAnnotation];
    
    // 设置地图显示的区域
    MKCoordinateSpan span = MKCoordinateSpanMake(.01 , .01);
    // 将用户当前的位置作为显示区域的中心点, 并且指定需要显示的跨度范围
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);    
    // 设置显示区域
    [self.mapView setRegion:region animated:YES];
}


- (MKPointAnnotation *)pointAnnotation {
    if (!_pointAnnotation) {
        _pointAnnotation = [[MKPointAnnotation alloc] init];
    }
    return _pointAnnotation;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return _locationManager;
}
- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}
- (UIButton *)senderButton {
    if (!_senderButton) {
        _senderButton = [[UIButton alloc] init];
        [_senderButton setTitle:@"发送" forState:UIControlStateNormal];
        _senderButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_senderButton setTitleColor:[UIColor colorWithRed:0.298 green:0.298 blue:0.298 alpha:1.0] forState:UIControlStateNormal];
        [_senderButton setTitleColor:[UIColor colorWithRed:0.702 green:0.702 blue:0.702 alpha:1.0] forState:UIControlStateHighlighted];
        _senderButton.frame = CGRectMake(0, 0, 40, 30);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_senderButton];
        [_senderButton addTarget:self action:@selector(senderButtonDid) forControlEvents:UIControlEventTouchUpInside];
    }
    return _senderButton;
}

- (void)setSend:(BOOL)send {
    _send = send;
    self.title = @"定位中...";
    self.mapView.userTrackingMode =  MKUserTrackingModeFollow;
}

@end
