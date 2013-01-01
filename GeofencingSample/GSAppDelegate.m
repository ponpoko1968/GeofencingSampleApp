//
//  GSAppDelegate.m
//  GeofencingSample
//
//  Created by 越智 修司 on 2012/12/28.
//  Copyright (c) 2012年 ClipReaderProject. All rights reserved.
//

#import "GSAppDelegate.h"

@implementation GSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Override point for customization after application launch.
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
  [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
  [self.locationManager startUpdatingLocation];

  return YES;
}

-(BOOL)saveGeofenceInfo:(NSDictionary*) dict
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:dict forKey:@"GeofenceInfo"];
  return [defaults synchronize];
}

-(NSDictionary*)loadGeofenceInfo
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *dict = [defaults dictionaryForKey:@"GeofenceInfo"];
  return dict;
}

-(BOOL)isMonitoringActivated
{
  NSArray *regionArray = [[self.locationManager monitoredRegions] allObjects];
  return [regionArray count] > 0;
}

-(void)activateMonitoring
{
  NSDictionary* regionData = [self loadGeofenceInfo];
  if (regionData) {
    // 設定済みデータあり.

    // 領域を作成し観測を開始する
    float radiusOnMeter = [[regionData valueForKey:@"geofenceRadius"] doubleValue];

    CLLocationCoordinate2D coordinate =
      CLLocationCoordinate2DMake([[regionData valueForKey:@"geofenceCenterLatitude"] doubleValue],
				 [[regionData valueForKey:@"geofenceCenterLongitude"] doubleValue]);
    CLRegion *grRegion = [[CLRegion alloc] initCircularRegionWithCenter:coordinate radius:radiusOnMeter identifier:@"Home"];
    Log(@"lat=%lf long=%lf radius=%f", coordinate.latitude, coordinate.longitude, radiusOnMeter);
    Log(@"Start Monitoring");
    [self.locationManager startMonitoringForRegion:grRegion];
    Log(@"Monitored Regions: %i", [[self.locationManager monitoredRegions] count]);
  }
    
}

-(void)deactivateMonitoring
{
  NSArray *regionArray = [[self.locationManager monitoredRegions] allObjects];
  Log(@"monitoredRegions# before stop = %d", [regionArray count]);
  for (int i = 0; i < [regionArray count]; i++) { // loop through array of regions turning them off
    [self.locationManager stopMonitoringForRegion:[regionArray objectAtIndex:i]];
  }
  regionArray = [[self.locationManager monitoredRegions] allObjects];
  Log(@"monitoredRegions# after stop = %d", [regionArray count]);
}


- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    Log(@"Exited Region");
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    Log(@"Entered Region");
}


							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
