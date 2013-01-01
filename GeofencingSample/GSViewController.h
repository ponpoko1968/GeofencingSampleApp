//
//  GSViewController.h
//  GeofencingSample
//
//  Created by 越智 修司 on 2012/12/28.
//  Copyright (c) 2012年 ClipReaderProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface GSViewController : UIViewController

-(IBAction) fixPositionButtonTouched:(id)sender;
-(IBAction) rangeChanged:(id)sender;
-(IBAction) toggleMonitoring:(id)sender;
// マップビュー
@property(nonatomic,strong) IBOutlet MKMapView *		_mapView;
// ジオフェンス中心点を設定するボタン
@property(nonatomic,strong) IBOutlet UIButton *			_fixPositionButton;
// ジオフェンス作動範囲を設定するスライダー
@property(nonatomic,strong) IBOutlet UISlider *			_rangeSlider;
// ジオフェンスをモニタリングするスイッチ
@property(nonatomic,strong) IBOutlet UISwitch *			_monitoringSwitch;

@end
