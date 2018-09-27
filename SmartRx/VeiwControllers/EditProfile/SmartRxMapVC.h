//
//  SmartRxMapVC.h
//  CareBridge
//
//  Created by Gowtham on 28/08/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationDelegate <NSObject>

-(void)tapOnMap:(NSDictionary *)addressDict;

@end

@interface SmartRxMapVC : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property(nonatomic,weak) id<LocationDelegate> delegate;
@end
