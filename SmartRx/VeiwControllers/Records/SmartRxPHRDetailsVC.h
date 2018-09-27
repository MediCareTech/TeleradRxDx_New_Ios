//
//  SmartRxPHRDetailsVC.h
//  SmartRx
//
//  Created by Anil Kumar on 09/09/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmartRxDataTVC.h"
#import "SmartRxImageTVC.h"
#import <QuickLook/QuickLook.h>
#import "SmartRxCommonClass.h"
#import "SmartRxCarePlaneSubVC.h"
#import "NetworkChecking.h"
#import "SmartRxAddPhrUIPicker.h"
#import "NSString+DateConvertion.h"
#import "SmartRxAddPhrNumbers.h"
#import "SmartRxAddBMI.h"
#import "CorePlot-CocoaTouch.h"

@interface SmartRxPHRDetailsVC : UIViewController<UITableViewDataSource,UITableViewDelegate, CPTPlotSpaceDelegate, CPTPlotDataSource, CPTAxisDelegate, loginDelegate,MBProgressHUDDelegate>
@property (nonatomic, retain) NSMutableDictionary *dictPhrDetails;
@property (nonatomic, weak) NSMutableDictionary *dictEditPhrDetails;
@property (strong, nonatomic) IBOutlet UITableView *tblPhrDetails;
@property (retain, nonatomic) UITableView *tempTable;
@property (nonatomic, retain) NSMutableArray *phrResponse;
@property (nonatomic, retain) NSMutableArray *phrGraphArray;
@property (nonatomic, readwrite) BOOL pickerUINeeded, editClicked;
@property (nonatomic, readwrite) BOOL responseReceived;
@property (nonatomic, readwrite) BOOL tableLoaded;
@property (nonatomic, readwrite) int graphCount;;
@property (nonatomic, retain) NSString *compareTitleString;
@property (nonatomic, readwrite) NSUInteger phrID;
@property (nonatomic, readwrite) float minValue;
@property (nonatomic, readwrite) float maxValue;
@property (nonatomic, readwrite) NSUInteger minYear;
@property (nonatomic, readwrite) NSUInteger maxYear;
@property (nonatomic, readwrite) float minValue2;
@property (nonatomic, readwrite) float maxValue2;
@property (nonatomic, retain) NSString *yAxisString;
@property (nonatomic, retain) NSString *yAxisString2;
@property (nonatomic, retain) NSString *lastHeightValue;
@property (nonatomic, retain) NSString *lastHeightUnit;
@property (nonatomic, readwrite) NSMutableArray *customTickLocations;
@property (nonatomic, readwrite) NSMutableArray *dateGraphArray;
@property (nonatomic, readwrite) NSMutableArray *valueGraphArray;
@property (nonatomic, readwrite) NSMutableArray *value2GraphArray;
@property (nonatomic, strong) NSString *graphDateString;
@property (weak, nonatomic) IBOutlet UIView *graphView;
@property (nonatomic, retain) NSMutableArray *data;
@property (nonatomic, retain) NSMutableArray *data2;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *hostingView;
@property (nonatomic, retain) CPTXYGraph *graph;
@property (nonatomic, retain) CPTPlotRange *graphPlotConstant;
- (void)drawBarGraph;
- (IBAction)editPhrButtonClicked:(id)sender;
@end
