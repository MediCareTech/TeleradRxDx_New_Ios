//
//  SmartRxMapVC.m
//  CareBridge
//
//  Created by Gowtham on 28/08/17.
//  Copyright © 2017 pacewisdom. All rights reserved.
//

#import "SmartRxMapVC.h"

@interface SmartRxMapVC ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    NSString *latitude;
    NSString *longitude;
    CGFloat rowHeight;

}
@property(nonatomic,strong) NSArray<MKMapItem *> *mapkitArray;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationArr;
@property (nonatomic, strong) NSArray *locationOriginal;


@end

@implementation SmartRxMapVC
-(void)numberKeyBoardReturn
{
    UIToolbar* numberToolbar;
    
    numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(retunWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    self.searchBar.inputAccessoryView = numberToolbar;
}
-(void)retunWithNumberPad{
    [self.searchBar resignFirstResponder];
    self.tableView.hidden = YES;;

//    if (self.mapkitArray.count < 1) {
//        self.tableView.hidden = YES;;
//
//    } else{
//        self.tableView.hidden = NO;;
//
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.hidden = YES;
    [self.tableView setTableFooterView:[UIView new]];
    [self numberKeyBoardReturn];
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration =0.40; //user needs to press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
//    if (self.postalCode != nil) {
//        self.searchBar.text = self.postalCode;
//        [self getSearchAddress:self.postalCode];
//    }
}
- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    latitude = [NSString stringWithFormat:@"%f",touchMapCoordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",touchMapCoordinate.longitude];
    
    //[self.delegate tapOnMap:touchMapCoordinate];

    //[self getAddress:touchMapCoordinate];
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure you want to choose this location?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *  action) {
        [self addPinToMap:touchMapCoordinate];
        [self getAddress:touchMapCoordinate];
       // [self dismissViewControllerAnimated:YES completion:nil];
        //[self.delegate tapOnMap:touchMapCoordinate];

    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:cancelAction];
    [controller addAction:yesAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];
  
}
-(void)addPinToMap:(CLLocationCoordinate2D) coordinate{
    
    MKPointAnnotation *annot = [[MKPointAnnotation alloc] init];
    annot.coordinate = coordinate;
    [self.mapView addAnnotation:annot];
}

-(void)getAddress:(CLLocationCoordinate2D )selectedLocation{
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:selectedLocation.latitude longitude:selectedLocation.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    
      
    [geocoder reverseGeocodeLocation:location completionHandler: ^(NSArray *placemarks, NSError *error) {
        //do something
        
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        // Long address
        // NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
        // Short address
        
        
        NSArray *lines = placemark.addressDictionary[ @"FormattedAddressLines"];
        NSString *addressString = [lines componentsJoinedByString:@","];
        NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:latitude,@"latitude",longitude,@"longitude",addressString,@"addressString",placemark.addressDictionary[@"ZIP"],@"postalCode", nil];
        [self.delegate tapOnMap:location];
        
        //  NSString *locatedAt = [placemark subLocality];
        NSLog(@"%@",addressString);
        dispatch_async(dispatch_get_main_queue(),^{
            [self dismissViewControllerAnimated:YES completion:nil];

        });

        //        [locationBtn setTitle:addressString forState:UIControlStateNormal];
        
    }];
    
}
#pragma mark -Table View Methods
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat cellHeight =0.0f;
//    if (self.locationArr[indexPath.row] != nil) {
//        cellHeight = [self estimatedHeight:self.locationArr[indexPath.row]];
//
//    }
//    return cellHeight;
//}
-(CGFloat)estimatedHeight:(NSString *)strToCalCulateHeight
{
    UILabel *lblHeight = [[UILabel alloc]initWithFrame:CGRectMake(40,30, 300,21)];
    lblHeight.text = strToCalCulateHeight;
    lblHeight.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
    //    NSLog(@"The number of lines is : %d\n and the text length is: %d", [lblHeight numberOfLines], [strToCalCulateHeight length]);
    CGSize maximumLabelSize = CGSizeMake(300,9999);
    CGSize expectedLabelSize;
    expectedLabelSize = [lblHeight.text  sizeWithFont:lblHeight.font constrainedToSize:maximumLabelSize lineBreakMode:lblHeight.lineBreakMode];
    CGFloat heightLbl=expectedLabelSize.height;
    
    heightLbl = heightLbl+ 16;
    
    return heightLbl;
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   // return self.locationOriginal.count;
    return  self.mapkitArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    MKMapItem *item = self.mapkitArray[indexPath.row];
    MKPlacemark *placeMark= item.placemark;
    NSArray *lines = placeMark.addressDictionary[ @"FormattedAddressLines"];
    NSString *addressString = [lines componentsJoinedByString:@","];
    cell.textLabel.text = addressString;
    
   // NSDictionary *dict = self.locationOriginal[indexPath.row];
   // cell.textLabel.text = dict[@"formatted_address"];

    //cell.textLabel.text = self.locationOriginal[indexPath.row];
    [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
    [cell.textLabel setTextColor:[UIColor darkGrayColor]];
    cell.textLabel.numberOfLines = 10;
    //cell.selectionStyle=UITableViewCellEditingStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.searchBar resignFirstResponder];
    MKMapItem *item = self.mapkitArray[indexPath.row];
    MKPlacemark *placeMark= item.placemark;
    NSArray *lines = placeMark.addressDictionary[ @"FormattedAddressLines"];
    
    NSString *addressString = [lines componentsJoinedByString:@","];
    
    
//    NSDictionary *dict = self.locationOriginal[indexPath.row];
//    latitude = dict[@"location"][@"lat"];
//    longitude = dict[@"location"][@"lng"];
//    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
//    [self getAddress:coordinate];
    latitude = [NSString stringWithFormat:@"%f",placeMark.location.coordinate.latitude];
    longitude = [NSString stringWithFormat:@"%f",placeMark.location.coordinate.latitude];

    NSDictionary *location = [NSDictionary dictionaryWithObjectsAndKeys:addressString,@"addressString",latitude,@"latitude",longitude,@"longitude",placeMark.addressDictionary[@"ZIP"],@"postalCode", nil];
    [self.delegate tapOnMap:location];
    
    [self dismissViewControllerAnimated:YES completion:nil];

    //NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.locationArr[indexPath.row],@"locationName", nil];
   
   
}
#pragma mark -Search bar Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.locationArr removeAllObjects];
    [self getSearchAddress:searchText];
    //[self searchCoordinatesForAddress:searchBar.text];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}
-(void)getSearchAddress:(NSString *)address{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc]init];
    request.naturalLanguageQuery = address;
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc]initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        if (response ==nil) {
            self.tableView.hidden = YES;
            return ;
        } else {
            self.mapkitArray = response.mapItems;
            if (self.mapkitArray.count) {
                self.tableView.hidden = NO;
            }else {
                self.tableView.hidden = YES;

            }
            dispatch_async(dispatch_get_main_queue(),^{
                [self.tableView reloadData];
            });
            NSLog(@"matching items :%@",self.mapkitArray);
        }
    }];
}
-(void)searchAddressUsingAppleMaps:(NSString *)address{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        NSLog(@"address strinb:%@",placemark.addressDictionary);
    }];
}
- (void) searchCoordinatesForAddress:(NSString *)inAddress
{
    //Build the string to Query Google Maps.
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false",inAddress];
    
    //Replace Spaces with a '+' character.
    [urlString setString:[urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
    
    //Create NSURL string from a formate URL string.
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask  = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *err;
        NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        NSLog(@"response:%@",resDict);
        self.locationArr = [NSMutableArray array];
        NSMutableArray *tempArr = [[NSMutableArray alloc]init];
        NSArray *resArr = resDict[@"results"];
        for (NSDictionary *dict in resArr) {
            NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:dict[@"formatted_address"],@"formatted_address",dict[@"geometry"][@"location"],@"location", nil];
            [tempArr addObject:tempDict];
            //[tempArr addObject:dict[@"formatted_address"]];
            //[self.locationArr addObject:dict[@"formatted_address"]];
        }
        self.locationOriginal = [tempArr copy];
  
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.locationOriginal.count) {
                self.tableView.hidden = NO;
            } else {
                self.tableView.hidden = YES;

            }
                 [self.tableView reloadData];
            
        });
        
    }];
    [dataTask resume];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self setUpLocationService];
}
- (void)setUpLocationService {
    _locationManager = [CLLocationManager new];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    if ([CLLocationManager locationServicesEnabled]) {
        
        [_locationManager startUpdatingLocation];
        
    }
    
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation

{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 3000, 3000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    [_locationManager stopUpdatingLocation];
     

}
#pragma mark - Custom AlertView

-(void)customAlertView:(NSString *)title Message:(NSString *)message tag:(NSInteger)alertTag
{
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    alertView.tag=alertTag;
    [alertView show];
    alertView=nil;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999)
        [self dismissViewControllerAnimated:YES completion:nil];
  }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
