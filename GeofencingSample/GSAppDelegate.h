//
//  GSAppDelegate.h
//  GeofencingSample
//
//  Created by 越智 修司 on 2012/12/28.
//  Copyright (c) 2012年 ClipReaderProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface GSAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>
-(BOOL)saveGeofenceInfo:(NSDictionary*) dict;
-(NSDictionary*)loadGeofenceInfo;
-(BOOL)isMonitoringActivated;
-(void)activateMonitoring;
-(void)deactivateMonitoring;

@property (strong, nonatomic) CLLocationManager*	locationManager;
@property (strong, nonatomic) UIWindow*			window;

@end
