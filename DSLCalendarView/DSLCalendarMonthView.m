/*
 DSLCalendarMonthView.m
 
 Copyright (c) 2012 Dative Studios. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "DSLCalendarDayView.h"
#import "DSLCalendarMonthView.h"
#import "DSLCalendarRange.h"
#import "NSDate+DSLCalendarView.h"
#import "SmartRxAppDelegate.h"


@interface DSLCalendarMonthView ()<MBProgressHUDDelegate>
{
    NSArray *timeStamp;
    NSMutableArray *responseArr;
    NSDateComponents *componentsOfDate;
    MBProgressHUD *HUD;    
}

@property (nonatomic, strong) NSMutableDictionary *dayViewsDictionary;

@end


@implementation DSLCalendarMonthView {
    CGFloat _dayViewHeight;
    __strong Class _dayViewClass;
}


#pragma mark - Memory management



#pragma mark - Initialisation

// Designated initialiser
- (id)initWithMonth:(NSDateComponents*)month width:(CGFloat)width dayViewClass:(Class)dayViewClass dayViewHeight:(CGFloat)dayViewHeight {
    self = [super initWithFrame:CGRectMake(0, 0, width, dayViewHeight)];
    if (self != nil) {
        // Initialise properties
        _month = [month copy];
        _dayViewHeight = dayViewHeight;
        _dayViewsDictionary = [[NSMutableDictionary alloc] init];
        _dayViewClass = dayViewClass;
//        [self makeRequestForDates];        
        [self createDayViews];

    }

    return self;
}
-(void)addSpinnerView{
    
    HUD = [[MBProgressHUD alloc] initWithView:self];
    [self addSubview:HUD];
    HUD.delegate = self;
    [HUD show:YES];
}
#pragma mark - Request methods
-(void)makeRequestForDates
{
    if (![HUD isHidden]) {
        [HUD hide:YES];
    }
    [self addSpinnerView];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"%@=%@&type=1",@"sessionid",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mecondt"];
    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
        [HUD hide:YES];
        [HUD removeFromSuperview];
        NSLog(@"sucess 1 %@",response);
        if ([[response objectForKey:@"authorized"]integerValue] == 0 && [[response objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *sample = [[NSMutableArray alloc]initWithArray:[response objectForKey:@"econdates"]];
                responseArr = [[NSMutableArray alloc]init];
                for (int i=0;i<[sample count];i++)
                {
                    for (int j=0; j<[[sample objectAtIndex:i] count];j++)
                    {
                        [self getDateValues:[[[sample objectAtIndex:i] objectAtIndex:j] doubleValue]];
                        [responseArr addObject:componentsOfDate];
                    }
                }
                
//                responseArr = [[NSMutableArray alloc]init];
//                responseArr = [response objectForKey:@"econdates"];
                NSLog(@"full array : %@", responseArr);
                NSLog(@"\n object residing at 1st index of the array : %@", [responseArr objectAtIndex:0]);
                            });
        }
    } failureHandler:^(id response) {
        
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Error loading dates please try after sometime" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        [HUD hide:YES];
        [HUD removeFromSuperview];
        
    }];
}

- (void)createDayViews {
    NSInteger const numberOfDaysPerWeek = 7;
    
    NSDateComponents *day = [[NSDateComponents alloc] init];
    day.calendar = self.month.calendar;
    day.day = 1;
    day.month = self.month.month;
    day.year = self.month.year;
    
    NSDate *firstDate = [day.calendar dateFromComponents:day];
    day = [firstDate dslCalendarView_dayWithCalendar:self.month.calendar];
    
    NSInteger numberOfDaysInMonth = [day.calendar rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[day date]].length;
    
    NSInteger startColumn = day.weekday - day.calendar.firstWeekday;
    if (startColumn < 0) {
        startColumn += numberOfDaysPerWeek;
    }
    
    NSArray *columnWidths = [self calculateColumnWidthsForColumnCount:numberOfDaysPerWeek];
    CGPoint nextDayViewOrigin = CGPointZero;
    for (NSInteger column = 0; column < startColumn; column++) {
        nextDayViewOrigin.x += [[columnWidths objectAtIndex:column] floatValue];
    }
    
    do {
        for (NSInteger column = startColumn; column < numberOfDaysPerWeek; column++) {
            if (day.month == self.month.month) {
                CGRect dayFrame = CGRectZero;
                dayFrame.origin = nextDayViewOrigin;
                dayFrame.size.width = [[columnWidths objectAtIndex:column] floatValue];
                dayFrame.size.height = _dayViewHeight;
                
                DSLCalendarDayView *dayView = [[_dayViewClass alloc] initWithFrame:dayFrame];
                dayView.day = day;
                switch (column) {
                    case 0:
                        dayView.positionInWeek = DSLCalendarDayViewStartOfWeek;
                        break;
                        
                    case numberOfDaysPerWeek - 1:
                        dayView.positionInWeek = DSLCalendarDayViewEndOfWeek;
                        break;
                        
                    default:
                        dayView.positionInWeek = DSLCalendarDayViewMidWeek;
                        break;
                }
                
                [self.dayViewsDictionary setObject:dayView forKey:[self dayViewKeyForDay:day]];
                [self addSubview:dayView];
            }
            
            day.day = day.day + 1;
            
            nextDayViewOrigin.x += [[columnWidths objectAtIndex:column] floatValue];
        }
        
        nextDayViewOrigin.x = 0;
        nextDayViewOrigin.y += _dayViewHeight;
        startColumn = 0;
    } while (day.day <= numberOfDaysInMonth);
    
    CGRect fullFrame = CGRectZero;
    fullFrame.size.height = nextDayViewOrigin.y;
    for (NSNumber *width in columnWidths) {
        fullFrame.size.width += width.floatValue;
    }
    self.frame = fullFrame;
}
- (void)getDateValues:(double)intVal
{
    NSDate * myDate = [NSDate dateWithTimeIntervalSince1970:intVal];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    componentsOfDate    = [calendar components:(NSCalendarCalendarUnit |
                                                NSYearCalendarUnit     |
                                                NSMonthCalendarUnit    |
                                                NSDayCalendarUnit      |
                                                NSHourCalendarUnit     |
                                                NSMinuteCalendarUnit   |
                                                NSWeekdayCalendarUnit  |
                                                NSSecondCalendarUnit) fromDate:myDate];
}
- (void)updateDaySelectionStatesForRange:(DSLCalendarRange*)range {
    for (DSLCalendarDayView *dayView in self.dayViews) {
        if ([range containsDate:dayView.dayAsDate]) {
            BOOL isStartOfRange = [range.startDay isEqual:dayView.day];
            BOOL isEndOfRange = [range.endDay isEqual:dayView.day];
            
            if (isStartOfRange && isEndOfRange) {
                dayView.selectionState = DSLCalendarDayViewWholeSelection;
            }
            else if (isStartOfRange) {
                dayView.selectionState = DSLCalendarDayViewStartOfSelection;
            }
            else if (isEndOfRange) {
                dayView.selectionState = DSLCalendarDayViewEndOfSelection;
            }
            else {
                dayView.selectionState = DSLCalendarDayViewWithinSelection;
            }
        }
        else {
            dayView.selectionState = DSLCalendarDayViewNotSelected;
        }
    }
}

- (NSArray*)calculateColumnWidthsForColumnCount:(NSInteger)columnCount {
    static NSCache *widthsCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        widthsCache = [[NSCache alloc] init];
    });
    
    NSMutableArray *columnWidths = [widthsCache objectForKey:@(columnCount)];
    if (columnWidths == nil) {
        CGFloat width = floorf(self.bounds.size.width / (CGFloat)columnCount);
        
        columnWidths = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for (NSInteger column = 0; column < columnCount; column++) {
            [columnWidths addObject:@(width)];
        }
        
        CGFloat remainder = self.bounds.size.width - (width * columnCount);
        CGFloat padding = 1;
        if (remainder > columnCount) {
            padding = ceilf(remainder / (CGFloat)columnCount);
        }
        
        for (NSInteger column = 0; column < columnCount; column++) {
            [columnWidths replaceObjectAtIndex:column withObject:@(width + padding)];
            
            remainder -= padding;
            if (remainder < 1) {
                break;
            }
        }
        
        [widthsCache setObject:columnWidths forKey:@(columnCount)];
    }
    
    return columnWidths;
}


#pragma mark - Properties

- (NSSet*)dayViews {
    return [NSSet setWithArray:self.dayViewsDictionary.allValues];
}

- (NSString*)dayViewKeyForDay:(NSDateComponents*)day {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    });

    return [formatter stringFromDate:[day date]];
}

- (DSLCalendarDayView*)dayViewForDay:(NSDateComponents*)day {
    return [self.dayViewsDictionary objectForKey:[self dayViewKeyForDay:day]];
}

@end
