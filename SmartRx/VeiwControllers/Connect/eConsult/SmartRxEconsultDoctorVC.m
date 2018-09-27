//
//  SmartRxEconsultDoctorVC.m
//  SmartRx
//
//  Created by Manju Basha on 25/03/15.
//  Copyright (c) 2015 smartrx. All rights reserved.
//

#import "SmartRxEconsultDoctorVC.h"

@interface SmartRxEconsultDoctorVC ()

@end

@implementation SmartRxEconsultDoctorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createBorderForAllBoxes];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark borderMethod
- (void)createBorderForAllBoxes
{
    
    self.doctorButton.layer.cornerRadius=0.0f;
    self.doctorButton.layer.masksToBounds = YES;
    self.doctorButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.doctorButton.layer.borderWidth= 1.0f;
    
    self.dateButton.layer.cornerRadius=0.0f;
    self.dateButton.layer.masksToBounds = YES;
    self.dateButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.dateButton.layer.borderWidth= 1.0f;
    
    self.timeButton.layer.cornerRadius=0.0f;
    self.timeButton.layer.masksToBounds = YES;
    self.timeButton.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.timeButton.layer.borderWidth= 1.0f;
    
    self.eConsultMethodBtn.layer.cornerRadius=0.0f;
    self.eConsultMethodBtn.layer.masksToBounds = YES;
    self.eConsultMethodBtn.layer.borderColor=[[UIColor colorWithRed:(148/255.0) green:(148/255.0) blue:(148/255.0) alpha:1.0]CGColor];
    self.eConsultMethodBtn.layer.borderWidth= 1.0f;
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)doctorButtonClicked:(id)sender
{
    
}
- (IBAction)dateButtonClicked:(id)sender
{
    
}

- (IBAction)timeButtonClicked:(id)sender
{
    
}

- (IBAction)eConsultMethodBtnClicked:(id)sender
{
    
}
@end
