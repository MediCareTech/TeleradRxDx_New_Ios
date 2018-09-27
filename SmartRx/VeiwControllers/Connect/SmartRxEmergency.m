//
//  SmartRxEmergency.m
//  SmartRx
//
//  Created by Manju Basha on 14/06/16.
//  Copyright © 2016 smartrx. All rights reserved.
//

#import "SmartRxEmergency.h"

@interface SmartRxEmergency ()

@end

@implementation SmartRxEmergency

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self AlertForDefault];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    NSString *EmerNum=[def valueForKey:@"EmergencyNum"];
    if (EmerNum==nil)
    {
        self.txtMobilenum.text=@"";
    }
    else
    {
        self.txtMobilenum.text=[NSString stringWithFormat:@"%@",[def valueForKey:@"EmergencyNum"]];
    }

    
    
    self.locationManager = [[CLLocationManager alloc] init];
      self.locationManager.delegate = self;
      self.locationManager.distanceFilter = kCLDistanceFilterNone;
      self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
     [self updateCurrentLocation];
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)AlertForDefault
{
    UIAlertView *warn=[[UIAlertView alloc]initWithTitle:@"Note:" message:[NSString stringWithFormat:@"%@  \n\n  %@",@"Please Set mobile number and message to be sent before pressing emergency send button",@"When you press the emergency within 5 seconds,the distress signal will be sent through SMS"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [warn show];
}

- (IBAction)btnBarHelp:(id)sender {

    [self AlertForDefault];
}
//This is the delegate method for CoreLocation

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
   self.LocationObtained=[NSString stringWithFormat:@"%@",locations.lastObject];
    
    [self.locationManager stopUpdatingLocation];
    
}
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView *LocationFail=[[UIAlertView alloc]initWithTitle:@"Notice" message:@"Unable to access your location,Please try again" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try Again", nil];
    [LocationFail show];
    
}

- (void)updateCurrentLocation
{
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}
- (IBAction)btnEmergency:(id)sender
{
    
    if (self.txtMobilenum.text.length<10)
        {
            [self AlertForDefault];
            
    }
    
    else
    {
        SmartRxDB *LocationDetails=[[SmartRxDB alloc]init];
        NSArray *UserHome=[LocationDetails fetchLocationsFromDataBase];
        
         NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
        
        [def setValue:[NSString stringWithFormat:@"%@",self.txtMobilenum.text] forKey:@"EmergencyNum"];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"])
        {
             [self showSMS:[NSString stringWithFormat:@"%@ \n\n %@ \n\n %@",self.txtName.text,self.LocationObtained,self.HomeLocation]];
        }
        else
        {
            [self showSMS:[NSString stringWithFormat:@"%@ \n\n %@",self.txtName.text,self.LocationObtained]];
        }

       
        
    }
   
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
     [self dismissViewControllerAnimated:YES completion:nil];
  
}
- (void)showSMS:(NSString*)message {
    
    if(![MFMessageComposeViewController canSendText]) {
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [warningAlert show];
        return;
    }
    
    NSString *recipents =[NSString stringWithFormat:@"%@",self.txtMobilenum.text];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:[NSArray arrayWithObject:recipents]];
    [messageController setBody:message];
   
    [self presentViewController:messageController animated:YES completion:nil];
   
}
@end
