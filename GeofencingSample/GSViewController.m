//
//  GSViewController.m
//  GeofencingSample
//
//  Created by 越智 修司 on 2012/12/28.
//  Copyright (c) 2012年 ClipReaderProject. All rights reserved.
//
#import "GSAppDelegate.h"
#import "GSViewController.h"


/*!
  @abstract 地図の中心を「×」イメージで表現するアノテーションクラス
 */
@interface CenterAnnotationView : MKAnnotationView
@end
@implementation CenterAnnotationView
- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString*)reuseIdentifier
{
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if( self ){
    UIImage* image = [UIImage imageNamed:@"map_marker"];
    self.frame = CGRectMake(self.frame.origin.x,self.frame.origin.y,image.size.width,image.size.height);
    self.image = image;
  }
  return self;
}
@end

@interface PointAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@end

@implementation PointAnnotation
@synthesize coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord
{
  if( nil != (self = [super  init]) ){
    self.coordinate = coord;
  }
  return self;
}

@end

/*!
  @abstract 地図の中心を表現するアノテーションクラス
 */
@interface CenterAnnotation : PointAnnotation
@end

@implementation CenterAnnotation
@end

/*!
  @abstract ジオフェンスの中心を表現するアノテーションクラス
 */
@interface GeofenceAnnotation : PointAnnotation
@end

@implementation GeofenceAnnotation
@end


@interface GSViewController ()

/*!
  @abstract ジオフェンス領域を表現するアノテーションビューを設定する  
  @param coordinate
  ジオフェンス領域の中心
  @param radius
  ジオフェンス領域の範囲(半径:メートル単位)
 */
-(void)placeGeofenceAt:(CLLocationCoordinate2D) coordinate radius:(CLLocationDistance) radius;

/*!
  @abstract 指定した緯度経度に地図の中心を移動させる
  @param latitude
  緯度
  @param longitude
  経度
 */
-(void) zoomMapAndCenterAtLatitude:(double) latitude andLongitude:(double) longitude;

/*!
  @abstract ジオフェンスの中心位置と範囲を保存する
 */
-(void) save;
@property (nonatomic,strong) CenterAnnotation*		_centerAnnotation;
@property (nonatomic,strong) GeofenceAnnotation*	_geofenceAnnotation;
@property (nonatomic,strong) MKCircle*			_geofenceRange;
@end

@implementation GSViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  GSAppDelegate* app = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
  NSDictionary* data = [app loadGeofenceInfo];

  if( data ){			/*設定済みデータが存在する*/
    CLLocationCoordinate2D coordinate
      = CLLocationCoordinate2DMake([[data valueForKey:@"geofenceCenterLatitude"] doubleValue],
				   [[data valueForKey:@"geofenceCenterLongitude"] doubleValue]);
    self._rangeSlider.value = [self sliderValueFromRadiusOnMeter:[[data valueForKey:@"geofenceRadius"] doubleValue]];
    [self zoomMapAndCenterAtLatitude:coordinate.latitude
			andLongitude:coordinate.longitude];
    [self placeGeofenceAt:coordinate radius:[[data valueForKey:@"geofenceRadius"] doubleValue]];
    self._rangeSlider.value = [self sliderValueFromRadiusOnMeter:[[data valueForKey:@"geofenceRadius"] doubleValue]];
    self._monitoringSwitch.enabled = YES;
  }else{
    [self._mapView.userLocation addObserver:self forKeyPath:@"location" options:0 context:NULL];
    self._rangeSlider.enabled = NO;
    self._monitoringSwitch.enabled = NO;
    // デフォルト範囲を100mに設定
    self._rangeSlider.value = [self sliderValueFromRadiusOnMeter:100.0f];
  }
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

// 指定地点へ地図を移動させてズームレベルを変更する.
- (void) zoomMapAndCenterAtLatitude:(double) latitude andLongitude:(double) longitude
{
    MKCoordinateRegion region;
    region
      = MKCoordinateRegionMakeWithDistance( CLLocationCoordinate2DMake(latitude,longitude),
					    2000.0,
					    2000.0 );
    [self._mapView setRegion:region animated:YES];
}


// userlocationを取得し、地図を移動する.
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
  if( [keyPath isEqualToString:@"location"] ){
    [self zoomMapAndCenterAtLatitude:self._mapView.userLocation.location.coordinate.latitude
			andLongitude:self._mapView.userLocation.location.coordinate.longitude];
    // 現在地移動は一度だけ.
    [self._mapView.userLocation removeObserver:self forKeyPath:@"location"];
    self._centerAnnotation
      = [[CenterAnnotation alloc] initWithCoordinate:self._mapView.region.center];
    [self._mapView addAnnotation:self._centerAnnotation];
  }
}

-(void)save
{
  GSAppDelegate* app = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];
  CLLocationCoordinate2D coordinate = self._geofenceRange.coordinate;
  NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
				       [NSNumber numberWithDouble:coordinate.latitude], @"geofenceCenterLatitude",
				       [NSNumber numberWithDouble:coordinate.longitude], @"geofenceCenterLongitude",
				     [NSNumber numberWithDouble:self._geofenceRange.radius], @"geofenceRadius",
				     nil
			];
  [app saveGeofenceInfo:data];

}
/*!
 */
-(void)placeGeofenceAt:(CLLocationCoordinate2D) coordinate radius:(CLLocationDistance) radius
{
  // 「ピン」の表示
  if( self._geofenceAnnotation ){
    [self._mapView removeAnnotation:self._geofenceAnnotation];
    self._geofenceAnnotation.coordinate = coordinate;
  }
  else{
    self._geofenceAnnotation = [[GeofenceAnnotation alloc] initWithCoordinate:coordinate];
  }
  [self._mapView addAnnotation:self._geofenceAnnotation];

  // 範囲円の表示
  if( self._geofenceRange ){
    [self._mapView removeOverlay:self._geofenceRange];
    self._geofenceRange = nil;
  }
  self._geofenceRange = [MKCircle circleWithCenterCoordinate: coordinate
						      radius: radius];
  [self._mapView addOverlay:self._geofenceRange];
  
}



#pragma mark イベントハンドラ
-(IBAction) fixPositionButtonTouched:(id)sender
{
  Log(@"");
  self._rangeSlider.enabled = YES;
  [self placeGeofenceAt:self._mapView.region.center radius:[self radiusOnMeterWithSliderValue:self._rangeSlider.value]];
  [self save];
}

-(IBAction) rangeChanged:(id)sender
{
  UISlider* slider = sender;
  Log(@"%f",slider.value);

  if( self._geofenceRange ){
    [self._mapView removeOverlay:self._geofenceRange];
    self._geofenceRange = nil;
  }
  self._geofenceRange = [MKCircle circleWithCenterCoordinate: self._geofenceAnnotation.coordinate
						      radius: [self radiusOnMeterWithSliderValue:self._rangeSlider.value]];
  [self._mapView addOverlay:self._geofenceRange];
  self._monitoringSwitch.enabled = YES;
  [self save];
  

}
-(IBAction) toggleMonitoring:(id)sender
{
  UISwitch* monitorSwitch = sender;
  GSAppDelegate* app = (GSAppDelegate*)[[UIApplication sharedApplication] delegate];

  if(monitorSwitch.on){
    [app activateMonitoring];
  }else{
    [app deactivateMonitoring];
  }
}


#pragma mark MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
  Log(@"");
  if( self._centerAnnotation ){
    [self._mapView removeAnnotation:self._centerAnnotation];
  }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
  Log(@"");
  CLLocationCoordinate2D center = mapView.region.center;
  if( self._centerAnnotation ){
    self._centerAnnotation.coordinate = center;
  }else{
    self._centerAnnotation
      = [[CenterAnnotation alloc] initWithCoordinate:center];
    
  }
  [mapView addAnnotation:self._centerAnnotation];

}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation
{
  Log(@"");

  // if it's the user location, just return nil.
  if ([annotation isKindOfClass:[MKUserLocation class]])
    return nil;
  if( [annotation isKindOfClass:[GeofenceAnnotation class]] ){
    MKAnnotationView* geofenceAnnotationView = [self._mapView dequeueReusableAnnotationViewWithIdentifier:@"GeofenceAnnotaionView"];
    if( geofenceAnnotationView ){
      geofenceAnnotationView.annotation = annotation;
    }else{
      geofenceAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"GeofenceAnnotaionView"];
    }
    return geofenceAnnotationView;
  }

  if ([annotation isKindOfClass:[CenterAnnotation class]]) {
    MKAnnotationView* annotationView = [self._mapView  dequeueReusableAnnotationViewWithIdentifier:@"CenterAnnotationView"];
    if( annotationView ){
      annotationView.annotation = annotation;
    }
    else{
      annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CenterAnnotationView"];
    }
    annotationView.image = [UIImage imageNamed:@"map_marker"];
    return annotationView;
  }
  return nil;

}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
{
  Log(@"");
  MKCircle* circle = overlay;
  MKCircleView* circleOverlayView =   [[MKCircleView alloc] initWithCircle:circle];
  circleOverlayView.strokeColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
  circleOverlayView.lineWidth = 4.;
  circleOverlayView.fillColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.35];
  return circleOverlayView;

}


#pragma mark utility functions

// 範囲円の最小値 100m
#define MIN_RADIUS 0.00089992800575953922F

// 範囲円の最大値 10km
#define MAX_RADIUS 0.08954283657307415407F

// 緯度=>メートル定数
#define RADIAN_TO_METER 111120.0F



-(double)radiusOnMeterWithSliderValue:(double)value
{
  return (MIN_RADIUS + MAX_RADIUS * powl(value,2)) * RADIAN_TO_METER;
}

-(double)radiusOnRadianWithSliderValue:(double)value
{
  return MIN_RADIUS + MAX_RADIUS * powl(value,2);
}

-(double)sliderValueFromRadiusOnMeter:(double)radiusOnMeter
{
  return sqrt((radiusOnMeter - MIN_RADIUS* RADIAN_TO_METER)/ (MAX_RADIUS * RADIAN_TO_METER));
}



@end
