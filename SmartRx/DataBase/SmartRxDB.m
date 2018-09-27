//
//  SmartRxDB.m
//  SmartRx
//
//  Created by Manju Basha on 07/12/15.
//  Copyright © 2015 smartrx. All rights reserved.
//

#import "SmartRxDB.h"
#import "SmartRxAppDelegate.h"

@implementation SmartRxDB

+ (id)sharedDBManager {
    static SmartRxDB *sharedDBManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDBManager = [[self alloc] init];
    });
    return sharedDBManager;
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark Save & Retrieve methods

-(void)saveLoginData:(NSMutableDictionary *)response;
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSManagedObjectContext *context= [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Login"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    
    NSError *error = nil;
    [response enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
        NSLog(@"%@ => %@", key, value);
        NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Login" inManagedObjectContext:context];
        [devices setValue:key forKey:@"key"];
        [devices setValue:value forKey:@"value"];
    }];
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        NSLog(@"Login Data saved successfully");
    }
    [self fetchLoginDetails];
}

-(NSArray *)fetchLoginDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Login"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    for (int i=0; i<[fetchDevices count];i++)
    {
        NSManagedObject *obj=nil;
        obj=[fetchDevices objectAtIndex:i];
        
        NSLog(@"This is the object : %@",obj);
        //        NSDictionary *dictFetchData=[NSDictionary dictionaryWithObjectsAndKeys:[obj valueForKey:@"calendarDate"],@"date",[obj valueForKey:@"climate_icon"],@"weatherIconUrl",[obj valueForKey:@"temperature"],@"tempMaxC", nil];
        //
        //        [arrTemp addObject:dictFetchData];
        
    }
    return arrTemp;
}

-(void)saveUserProfile:(NSMutableDictionary *)response;
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    
    NSString *strDate = [response objectForKey:@"dob"];
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [format setTimeZone:gmt];
    [format setDateFormat:@"dd-mm-yyyy"];
    NSDate *dobDate = [format dateFromString:strDate];
    
    NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"age"] integerValue]] forKey:@"age"];
    [devices setValue:dobDate forKey:@"dob"];
    [devices setValue:[response objectForKey:@"email"] forKey:@"email"];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"feature_alerts"] integerValue]] forKey:@"feature_alerts"];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"gender"] integerValue]] forKey:@"gender"];
    if ([response[@"hmspid"] isKindOfClass:[NSString class]]) {
        [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"hmspid"] integerValue]] forKey:@"hmspid"];
    }
     if ([response[@"location"] isKindOfClass:[NSString class]]) {
         [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"location"] integerValue]] forKey:@"location"];
     }
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"mweek"] integerValue]] forKey:@"mweek"];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"notifications"] integerValue]] forKey:@"notifications"];
    if ([response objectForKey:@"primary_interest"] != [NSNull null] && [[response objectForKey:@"primary_interest"] length] > 0)
        [devices setValue:[response objectForKey:@"primary_interest"] forKey:@"primary_interest"];
    else
        [devices setValue:@"" forKey:@"primary_interest"];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"primary_user"] integerValue]] forKey:@"primary_user"];
    [devices setValue:[response objectForKey:@"primaryphone"] forKey:@"primaryphone"];
    [devices setValue:[response objectForKey:@"profile_pic"] forKey:@"profile_pic"];
    [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"recno"] integerValue]] forKey:@"recno"];
    if ([response[@"referal_doc"] isKindOfClass:[NSString class]]) {
        [devices setValue:[NSNumber numberWithInteger:[[response objectForKey:@"referal_doc"] integerValue]] forKey:@"referal_doc"];
    }

    [devices setValue:[response objectForKey:@"name"] forKey:@"name"];
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    else
    {
        NSLog(@"Profile Data saved successfully");
        [self profileDetails];
    }
}

-(NSArray *)profileDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Profile"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    
    
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
    for (int i=0; i<[fetchDevices count];i++)
    {
        NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
        NSManagedObject *obj=nil;
        obj=[fetchDevices objectAtIndex:i];
        [dictFetchData setObject:[obj valueForKey:@"age"] forKey:@"age"];
        if ([obj valueForKey:@"dob"] != nil)
            [dictFetchData setObject:[obj valueForKey:@"dob"] forKey:@"dob"];
        else
            [dictFetchData setObject:@"" forKey:@"dob"];
        [dictFetchData setObject:[obj valueForKey:@"email"] forKey:@"email"];
        [dictFetchData setObject:[obj valueForKey:@"feature_alerts"] forKey:@"feature_alerts"];
        [dictFetchData setObject:[obj valueForKey:@"hmspid"] forKey:@"hmspid"];
        [dictFetchData setObject:[obj valueForKey:@"location"] forKey:@"location"];
        [dictFetchData setObject:[obj valueForKey:@"mnotify"] forKey:@"mnotify"];
        [dictFetchData setObject:[obj valueForKey:@"mweek"] forKey:@"mweek"];
        [dictFetchData setObject:[obj valueForKey:@"name"] forKey:@"name"];
        [dictFetchData setObject:[obj valueForKey:@"notifications"] forKey:@"notifications"];
        [dictFetchData setObject:[obj valueForKey:@"primary_interest"] forKey:@"primary_interest"];
        [dictFetchData setObject:[obj valueForKey:@"primary_user"] forKey:@"primary_user"];
        [dictFetchData setObject:[obj valueForKey:@"primaryphone"] forKey:@"primaryphone"];
        [dictFetchData setObject:[obj valueForKey:@"profile_pic"] forKey:@"profile_pic"];
        [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
        [dictFetchData setObject:[obj valueForKey:@"referal_doc"] forKey:@"referal_doc"];
        
        [arrTemp insertObject:dictFetchData atIndex:i];
    }
    return arrTemp;
}

#pragma mark -  Messages

-(void)saveMessages:(NSArray *)arrMsgDetails
{
    
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrMsgDetails count])
    {
        for (int i = 0; i < [arrMsgDetails count]; i++)
        {
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Messages" inManagedObjectContext:context];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"recno"] forKey:@"recno"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"careid"] forKey:@"careid"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"postopid"] forKey:@"postopid"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"tracker_type"] forKey:@"tracker_type"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"postop_rectype"] forKey:@"postop_rectype"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"patid"] forKey:@"patid"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"opid"] forKey:@"opid"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"operation"] forKey:@"operation"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"updateddate"] forKey:@"updateddate"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"alertmethod"] forKey:@"alertmethod"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"alerttxt"] forKey:@"alerttxt"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"senton"] forKey:@"senton"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"status"] forKey:@"status"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"qid"] forKey:@"qid"];
            [devices setValue:[[arrMsgDetails objectAtIndex:i]objectForKey:@"title"] forKey:@"title"];
            [devices setValue:[NSDate date] forKey:@"createDate"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Messages saved successfully");
        }
        context=nil;
    }
}
-(void)updateObjectInCoreData :(NSString *)messageId value:(NSString *)upDateValue
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"recno == %@",messageId];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *arrTemp = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    NSManagedObject *obj;
    if ([arrTemp count])
    {
        obj=[arrTemp objectAtIndex:0];
        [obj setValue:upDateValue forKey:@"status"];
    }
    
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}
-(void)deleteMsgFromCoreData :(NSString *)messageId
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"recno == %@",messageId];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *arrTemp = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([arrTemp count])
    {
        for (NSManagedObject * obj in arrTemp) {
            [context deleteObject:obj];
        }
    }
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

-(NSArray *)fetchMessagesFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Messages"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            if ([obj valueForKey:@"title"] && [obj valueForKey:@"title"] != nil && [obj valueForKey:@"title"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"title"] forKey:@"title"];
            else
                [dictFetchData setObject:@"" forKey:@"title"];
            if ([obj valueForKey:@"qid"] && [obj valueForKey:@"qid"] != nil && [obj valueForKey:@"qid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"qid"] forKey:@"qid"];
            else
                [dictFetchData setObject:@"" forKey:@"qid"];
            
            [dictFetchData setObject:[obj valueForKey:@"status"] forKey:@"status"];
            [dictFetchData setObject:[obj valueForKey:@"senton"] forKey:@"senton"];
            [dictFetchData setObject:[obj valueForKey:@"alerttxt"] forKey:@"alerttxt"];
            [dictFetchData setObject:[obj valueForKey:@"alertmethod"] forKey:@"alertmethod"];
            [dictFetchData setObject:[obj valueForKey:@"updateddate"] forKey:@"updateddate"];
            [dictFetchData setObject:[obj valueForKey:@"operation"] forKey:@"operation"];
            [dictFetchData setObject:[obj valueForKey:@"opid"] forKey:@"opid"];
            [dictFetchData setObject:[obj valueForKey:@"patid"] forKey:@"patid"];
            [dictFetchData setObject:[obj valueForKey:@"postop_rectype"] forKey:@"postop_rectype"];
            [dictFetchData setObject:[obj valueForKey:@"tracker_type"] forKey:@"tracker_type"];
            [dictFetchData setObject:[obj valueForKey:@"postopid"] forKey:@"postopid"];
            [dictFetchData setObject:[obj valueForKey:@"careid"] forKey:@"careid"];
            [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            //            NSDictionary *dictFetchData=[NSDictionary dictionaryWithObjectsAndKeys:[obj valueForKey:@"title"],@"title",[obj valueForKey:@"qid"],@"qid",[obj valueForKey:@"status"],@"status",[obj valueForKey:@"status"],@"senton",[obj valueForKey:@"alerttxt"],@"alerttxt",[obj valueForKey:@"alertmethod"],@"alertmethod",[obj valueForKey:@"updateddate"],@"updateddate",[obj valueForKey:@"operation"],@"operation",[obj valueForKey:@"opid"],@"opid",[obj valueForKey:@"patid"],@"patid",[obj valueForKey:@"postop_rectype"],@"postop_rectype",[obj valueForKey:@"tracker_type"],@"tracker_type",[obj valueForKey:@"postopid"],@"postopid",[obj valueForKey:@"careid"],@"careid",[obj valueForKey:@"recno"],@"recno", nil];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}


#pragma mark -  Location

-(void)saveLocation:(NSArray *)arrLocationDetails
{
    
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrLocationDetails count])
    {
        for (int i = 0; i < [arrLocationDetails count]; i++)
        {
            NSString *strDate = [[arrLocationDetails objectAtIndex:i]objectForKey:@"modified"];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [format setTimeZone:gmt];
            [format setDateFormat:@"yyyy-mm-dd HH:mm:SS"];
            NSDate *modifiedDate = [format dateFromString:strDate];
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:context];
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"apt_contact"] != [NSNull null] && [[arrLocationDetails objectAtIndex:i]objectForKey:@"apt_contact"] != nil)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"apt_contact"] forKey:@"apt_contact"];
            else
                [devices setValue:@"" forKey:@"apt_contact"];
            
            [devices setValue:[NSNumber numberWithInteger:[[[arrLocationDetails objectAtIndex:i]objectForKey:@"custid"] integerValue]] forKey:@"custid"];
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"fd_email"] != [NSNull null] && [[arrLocationDetails objectAtIndex:i]objectForKey:@"fd_email"] != nil)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"fd_email"] forKey:@"fd_email"];
            else
                [devices setValue:@"" forKey:@"fd_email"];
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locationaddress"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationaddress"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationaddress"] forKey:@"locationaddress"];
            else
                [devices setValue:@"" forKey:@"locationaddress"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locationmap"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationmap"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationmap"] forKey:@"locationmap"];
            else
                [devices setValue:@"" forKey:@"locationmap"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locationname"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationname"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationname"] forKey:@"locationname"];
            else
                [devices setValue:@"" forKey:@"locationname"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locationvideo"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationvideo"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locationvideo"] forKey:@"locationvideo"];
            else
                [devices setValue:@"" forKey:@"locationvideo"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"loccontact"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"loccontact"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"loccontact"] forKey:@"loccontact"];
            else
                [devices setValue:@"" forKey:@"loccontact"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locdetails"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locdetails"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locdetails"] forKey:@"locdetails"];
            else
                [devices setValue:@"" forKey:@"locdetails"];
            
            if ([[arrLocationDetails objectAtIndex:i]objectForKey:@"locname"] != [NSNull null] && [[[arrLocationDetails objectAtIndex:i]objectForKey:@"locname"] length] > 0)
                [devices setValue:[[arrLocationDetails objectAtIndex:i]objectForKey:@"locname"] forKey:@"locname"];
            else
                [devices setValue:@"" forKey:@"locname"];
            
            [devices setValue:modifiedDate forKey:@"modified"];
            
            [devices setValue:[NSNumber numberWithInteger:[[[arrLocationDetails objectAtIndex:i]objectForKey:@"locid"] integerValue]] forKey:@"locid"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrLocationDetails objectAtIndex:i]objectForKey:@"recno"] integerValue]] forKey:@"recno"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Location saved successfully");
        }
        context=nil;
    }
}


-(NSArray *)fetchLocationsFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Location"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            if ([obj valueForKey:@"locationaddress"] && [obj valueForKey:@"locationaddress"] != nil && [obj valueForKey:@"locationaddress"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locationaddress"] forKey:@"locationaddress"];
            else
                [dictFetchData setObject:@"" forKey:@"locationaddress"];
            
            if ([obj valueForKey:@"locationmap"] && [obj valueForKey:@"locationmap"] != nil && [obj valueForKey:@"locationmap"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locationmap"] forKey:@"locationmap"];
            else
                [dictFetchData setObject:@"" forKey:@"locationmap"];
            
            if ([obj valueForKey:@"locationimg"] && [obj valueForKey:@"locationimg"] != nil && [obj valueForKey:@"locationimg"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locationimg"] forKey:@"locationimg"];
            else
                [dictFetchData setObject:@"" forKey:@"locationimg"];
            
            if ([obj valueForKey:@"locationname"] && [obj valueForKey:@"locationname"] != nil && [obj valueForKey:@"locationname"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locationname"] forKey:@"locationname"];
            else
                [dictFetchData setObject:@"" forKey:@"locationname"];
            
            if ([obj valueForKey:@"locationvideo"] && [obj valueForKey:@"locationvideo"] != nil && [obj valueForKey:@"locationvideo"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locationvideo"] forKey:@"locationvideo"];
            else
                [dictFetchData setObject:@"" forKey:@"locationvideo"];
            
            if ([obj valueForKey:@"loccontact"] && [obj valueForKey:@"loccontact"] != nil && [obj valueForKey:@"loccontact"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"loccontact"] forKey:@"loccontact"];
            else
                [dictFetchData setObject:@"" forKey:@"loccontact"];
            
            if ([obj valueForKey:@"locdetails"] && [obj valueForKey:@"locdetails"] != nil && [obj valueForKey:@"locdetails"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locdetails"] forKey:@"locdetails"];
            else
                [dictFetchData setObject:@"" forKey:@"locdetails"];
            
            
            [dictFetchData setObject:[obj valueForKey:@"apt_contact"] forKey:@"apt_contact"];
            [dictFetchData setObject:[obj valueForKey:@"custid"] forKey:@"custid"];
            [dictFetchData setObject:[obj valueForKey:@"fd_email"] forKey:@"fd_email"];
            [dictFetchData setObject:[obj valueForKey:@"locid"] forKey:@"locid"];
            [dictFetchData setObject:[obj valueForKey:@"locname"] forKey:@"locname"];
            [dictFetchData setObject:[obj valueForKey:@"modified"] forKey:@"modified"];
            [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            //            NSDictionary *dictFetchData=[NSDictionary dictionaryWithObjectsAndKeys:[obj valueForKey:@"title"],@"title",[obj valueForKey:@"qid"],@"qid",[obj valueForKey:@"status"],@"status",[obj valueForKey:@"status"],@"senton",[obj valueForKey:@"alerttxt"],@"alerttxt",[obj valueForKey:@"alertmethod"],@"alertmethod",[obj valueForKey:@"updateddate"],@"updateddate",[obj valueForKey:@"operation"],@"operation",[obj valueForKey:@"opid"],@"opid",[obj valueForKey:@"patid"],@"patid",[obj valueForKey:@"postop_rectype"],@"postop_rectype",[obj valueForKey:@"tracker_type"],@"tracker_type",[obj valueForKey:@"postopid"],@"postopid",[obj valueForKey:@"careid"],@"careid",[obj valueForKey:@"recno"],@"recno", nil];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}


#pragma mark -  Doctors

-(void)saveDoctor:(NSArray *)arrDoctorsDetails
{
    
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Doctor"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrDoctorsDetails count])
    {
        for (int i = 0; i < [arrDoctorsDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Doctor" inManagedObjectContext:context];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"doc_details"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"doc_details"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"doc_details"] forKey:@"doc_details"];
            else
                [devices setValue:@"" forKey:@"doc_details"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"biography"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"biography"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"biography"] forKey:@"biography"];
            else
                [devices setValue:@"" forKey:@"biography"];
            
            [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"dispname"] forKey:@"dispname"];
            
            [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"deptname"] forKey:@"deptname"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"experience"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"experience"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"experience"] forKey:@"experience"];
            else
                [devices setValue:@"" forKey:@"experience"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"expertise"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"expertise"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"expertise"] forKey:@"expertise"];
            else
                [devices setValue:@"" forKey:@"expertise"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"languages_known"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"languages_known"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"languages_known"] forKey:@"languages_known"];
            else
                [devices setValue:@"" forKey:@"languages_known"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"speciality"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"speciality"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"speciality"] forKey:@"speciality"];
            else
                [devices setValue:@"" forKey:@"speciality"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profsummary"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profsummary"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profsummary"] forKey:@"profsummary"];
            else
                [devices setValue:@"" forKey:@"profsummary"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"qualification"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"qualification"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"qualification"] forKey:@"qualification"];
            else
                [devices setValue:@"" forKey:@"qualification"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aeconsult_amount"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aeconsult_amount"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aeconsult_amount"] integerValue]] forKey:@"aeconsult_amount"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"aeconsult_amount"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aservice_amount"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aservice_amount"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"aservice_amount"] integerValue]] forKey:@"aservice_amount"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"aservice_amount"];
            
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_appointment"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_appointment"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_appointment"] integerValue]] forKey:@"enable_appointment"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"enable_appointment"];
            
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_econsult"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_econsult"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"enable_econsult"] integerValue]] forKey:@"enable_econsult"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"enable_econsult"];
            
            if ([[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profilepic"] != [NSNull null] && [[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profilepic"] length] > 0)
                [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"profilepic"] forKey:@"profilepic"];
            else
                [devices setValue:@"" forKey:@"profilepic"];
            
            [devices setValue:[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"locationid"] forKey:@"locationid"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"specid"] integerValue]] forKey:@"specid"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"recno"] integerValue]] forKey:@"recno"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"gender"] integerValue]] forKey:@"gender"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrDoctorsDetails objectAtIndex:i]objectForKey:@"specid"] integerValue]] forKey:@"specid"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Doctors saved successfully");
            [self fetchDoctorsFromDataBase];
        }
        context=nil;
    }
}


-(NSArray *)fetchDoctorsFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Doctor"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            if ([obj valueForKey:@"biography"] && [obj valueForKey:@"biography"] != nil && [obj valueForKey:@"biography"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"biography"] forKey:@"biography"];
            else
                [dictFetchData setObject:@"" forKey:@"biography"];
            
            if ([obj valueForKey:@"doc_details"] && [obj valueForKey:@"doc_details"] != nil && [obj valueForKey:@"doc_details"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"doc_details"] forKey:@"doc_details"];
            else
                [dictFetchData setObject:@"" forKey:@"doc_details"];
            
            if ([obj valueForKey:@"experience"] && [obj valueForKey:@"experience"] != nil && [obj valueForKey:@"experience"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"experience"] forKey:@"experience"];
            else
                [dictFetchData setObject:@"" forKey:@"experience"];
            
            if ([obj valueForKey:@"expertise"] && [obj valueForKey:@"expertise"] != nil && [obj valueForKey:@"expertise"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"expertise"] forKey:@"expertise"];
            else
                [dictFetchData setObject:@"" forKey:@"expertise"];
            
            if ([obj valueForKey:@"expertise"] && [obj valueForKey:@"profsummary"] != nil && [obj valueForKey:@"profsummary"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"profsummary"] forKey:@"profsummary"];
            else
                [dictFetchData setObject:@"" forKey:@"profsummary"];
            
            if ([obj valueForKey:@"qualification"] && [obj valueForKey:@"qualification"] != nil && [obj valueForKey:@"qualification"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"qualification"] forKey:@"qualification"];
            else
                [dictFetchData setObject:@"" forKey:@"qualification"];
            
            if ([obj valueForKey:@"expertise"] && [obj valueForKey:@"speciality"] != nil && [obj valueForKey:@"speciality"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"speciality"] forKey:@"speciality"];
            else
                [dictFetchData setObject:@"" forKey:@"speciality"];
            
            [dictFetchData setObject:[obj valueForKey:@"profilepic"] forKey:@"profilepic"];
            [dictFetchData setObject:[obj valueForKey:@"locationid"] forKey:@"locationid"];
            [dictFetchData setObject:[obj valueForKey:@"languages_known"] forKey:@"languages_known"];
            [dictFetchData setObject:[obj valueForKey:@"gender"] forKey:@"gender"];
            [dictFetchData setObject:[obj valueForKey:@"aeconsult_amount"] forKey:@"aeconsult_amount"];
            [dictFetchData setObject:[obj valueForKey:@"aservice_amount"] forKey:@"aservice_amount"];
            [dictFetchData setObject:[obj valueForKey:@"deptname"] forKey:@"deptname"];
            [dictFetchData setObject:[obj valueForKey:@"dispname"] forKey:@"dispname"];
            [dictFetchData setObject:[obj valueForKey:@"enable_appointment"] forKey:@"enable_appointment"];
            [dictFetchData setObject:[obj valueForKey:@"enable_econsult"] forKey:@"enable_econsult"];
            [dictFetchData setObject:[obj valueForKey:@"specid"] forKey:@"specid"];
            [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}


#pragma mark -  Specialities

-(void)saveSpeciality:(NSArray *)arrSpecialityDetails
{
    
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Specialities"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrSpecialityDetails count])
    {
        for (int i = 0; i < [arrSpecialityDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Specialities" inManagedObjectContext:context];
            NSString *strDate = [[arrSpecialityDetails objectAtIndex:i]objectForKey:@"modified"];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
            [format setTimeZone:gmt];
            [format setDateFormat:@"yyyy-mm-dd HH:mm:SS"];
            NSDate *modifiedDate = [format dateFromString:strDate];
            
            NSString *strCreatedDate = [[arrSpecialityDetails objectAtIndex:i]objectForKey:@"created"];
            NSDate *createdDate = [format dateFromString:strCreatedDate];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"AboutSpeciality"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"AboutSpeciality"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"AboutSpeciality"] forKey:@"aboutSpeciality"];
            else
                [devices setValue:@"" forKey:@"aboutSpeciality"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"author"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"author"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"author"] forKey:@"author"];
            else
                [devices setValue:@"" forKey:@"author"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"custid"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"custid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"custid"] integerValue]] forKey:@"custid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"custid"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"deptname"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"deptname"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"deptname"] forKey:@"deptname"];
            else
                [devices setValue:@"" forKey:@"deptname"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"description"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"description"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"description"] forKey:@"spec_description"];
            else
                [devices setValue:@"" forKey:@"spec_description"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"hmsspid"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"hmsspid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"hmsspid"] integerValue]] forKey:@"hmsspid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"hmsspid"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"imgsrc"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"imgsrc"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"imgsrc"] forKey:@"imgsrc"];
            else
                [devices setValue:@"" forKey:@"imgsrc"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"keyword"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"keyword"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"keyword"] forKey:@"keyword"];
            else
                [devices setValue:@"" forKey:@"keyword"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"locid"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"locid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"locid"] integerValue]] forKey:@"locid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"locid"];
            
            if ([[arrSpecialityDetails objectAtIndex:i]objectForKey:@"title"] != [NSNull null] && [[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"title"] length] > 0)
                [devices setValue:[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"title"] forKey:@"title"];
            else
                [devices setValue:@"" forKey:@"title"];
            
            [devices setValue:createdDate forKey:@"created"];
            [devices setValue:modifiedDate forKey:@"modified"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"recno"] integerValue]] forKey:@"recno"];
            [devices setValue:[NSNumber numberWithInteger:[[[arrSpecialityDetails objectAtIndex:i]objectForKey:@"status"] integerValue]] forKey:@"status"];
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Specialities saved successfully");
        }
        context=nil;
    }
}


-(NSArray *)fetchSpecialitiesFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Specialities"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            if ([obj valueForKey:@"aboutSpeciality"] && [obj valueForKey:@"aboutSpeciality"] != nil && [obj valueForKey:@"aboutSpeciality"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"aboutSpeciality"] forKey:@"aboutSpeciality"];
            else
                [dictFetchData setObject:@"" forKey:@"biography"];
            
            if ([obj valueForKey:@"author"] && [obj valueForKey:@"author"] != nil && [obj valueForKey:@"author"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"author"] forKey:@"author"];
            else
                [dictFetchData setObject:@"" forKey:@"author"];
            
            if ([obj valueForKey:@"custid"] && [obj valueForKey:@"custid"] != nil && [obj valueForKey:@"custid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"custid"] forKey:@"custid"];
            else
                [dictFetchData setObject:@"" forKey:@"custid"];
            
            if ([obj valueForKey:@"deptname"] && [obj valueForKey:@"deptname"] != nil && [obj valueForKey:@"deptname"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"deptname"] forKey:@"deptname"];
            else
                [dictFetchData setObject:@"" forKey:@"deptname"];
            
            if ([obj valueForKey:@"spec_description"] && [obj valueForKey:@"spec_description"] != nil && [obj valueForKey:@"spec_description"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"spec_description"] forKey:@"description"];
            else
                [dictFetchData setObject:@"" forKey:@"description"];
            
            if ([obj valueForKey:@"hmsspid"] && [obj valueForKey:@"hmsspid"] != nil && [obj valueForKey:@"hmsspid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"hmsspid"] forKey:@"hmsspid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"hmsspid"];
            
            if ([obj valueForKey:@"imgsrc"] && [obj valueForKey:@"imgsrc"] != nil && [obj valueForKey:@"imgsrc"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"imgsrc"] forKey:@"imgsrc"];
            else
                [dictFetchData setObject:@"" forKey:@"imgsrc"];
            
            if ([obj valueForKey:@"modified"] && [obj valueForKey:@"modified"] != nil && [obj valueForKey:@"modified"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"modified"] forKey:@"modified"];
            else
                [dictFetchData setObject:@"" forKey:@"modified"];
            
            if ([obj valueForKey:@"created"] && [obj valueForKey:@"created"] != nil && [obj valueForKey:@"created"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"created"] forKey:@"created"];
            else
                [dictFetchData setObject:@"" forKey:@"modified"];
            
            if ([obj valueForKey:@"locid"] && [obj valueForKey:@"locid"] != nil && [obj valueForKey:@"locid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"locid"] forKey:@"locid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"locid"];
            
            if ([obj valueForKey:@"status"] && [obj valueForKey:@"status"] != nil && [obj valueForKey:@"status"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"status"] forKey:@"status"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"status"];
            
            
            [dictFetchData setObject:[obj valueForKey:@"keyword"] forKey:@"keyword"];
            [dictFetchData setObject:[obj valueForKey:@"title"] forKey:@"title"];
            [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark -  Econsult & Appointments

-(void)saveEconApt:(NSArray *)arrEconAptDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconApt"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrEconAptDetails count])
    {
        for (int i = 0; i < [arrEconAptDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"EconApt" inManagedObjectContext:context];
            NSString *strDate = [[arrEconAptDetails objectAtIndex:i]objectForKey:@"appdate"];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone systemTimeZone];
            [format setTimeZone:gmt];
            [format setDateFormat:@"yyyy-mm-dd"];
            NSDate *appdate = [format dateFromString:strDate];
            
            NSDate *updatedDate;
            
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"app_method"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"app_method"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"app_method"]integerValue]] forKey:@"app_method"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"app_method"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"appid"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"appid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"appid"]integerValue]] forKey:@"appid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"appid"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"appdate"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"appdate"] length] > 0)
                [devices setValue:appdate forKey:@"appdate"];
            else
                [devices setValue:@"" forKey:@"appdate"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptime"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptime"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptime"] forKey:@"apptime"];
            else
                [devices setValue:@"" forKey:@"apptime"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptype"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptype"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"apptype"] integerValue]] forKey:@"apptype"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"apptype"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"conid"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"conid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"conid"] integerValue]] forKey:@"conid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"conid"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"consultation_type"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"consultation_type"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"consultation_type"]integerValue]] forKey:@"consultation_type"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"consultation_type"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"custid"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"custid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"custid"]integerValue]] forKey:@"custid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"custid"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"deptname"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"deptname"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"deptname"] forKey:@"deptname"];
            else
                [devices setValue:@"" forKey:@"deptname"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"diagnosis"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"diagnosis"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"diagnosis"] forKey:@"diagnosis"];
            else
                [devices setValue:@"" forKey:@"diagnosis"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"dispname"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"dispname"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"dispname"] forKey:@"dispname"];
            else
                [devices setValue:@"" forKey:@"dispname"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"emailid"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"emailid"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"emailid"] forKey:@"emailid"];
            else
                [devices setValue:@"" forKey:@"emailid"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"reason"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"reason"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"reason"] forKey:@"reason"];
            else
                [devices setValue:@"" forKey:@"reason"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"recno"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"recno"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"recno"] integerValue]] forKey:@"recno"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"recno"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"status"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"status"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"status"] integerValue]] forKey:@"status"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"status"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"suggestion"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"suggestion"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"suggestion"] forKey:@"suggestion"];
            else
                [devices setValue:@"" forKey:@"suggestion"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"symptom"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"symptom"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"symptom"] forKey:@"symptom"];
            else
                [devices setValue:@"" forKey:@"symptom"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"updated"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"updated"] length] > 0)
            {
                NSString *strupdatedDate = [[arrEconAptDetails objectAtIndex:i]objectForKey:@"updated"];
                [format setDateFormat:@"yyyy-mm-dd HH:mm:SS"];
                updatedDate = [format dateFromString:strupdatedDate];
                [devices setValue:updatedDate forKey:@"updated"];
            }
            else
                [devices setValue:nil forKey:@"updated"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"usertype"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"usertype"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrEconAptDetails objectAtIndex:i]objectForKey:@"usertype"] integerValue]] forKey:@"usertype"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"usertype"];
            
            if ([[arrEconAptDetails objectAtIndex:i]objectForKey:@"vsession"] != [NSNull null] && [[[arrEconAptDetails objectAtIndex:i]objectForKey:@"vsession"] length] > 0)
                [devices setValue:[[arrEconAptDetails objectAtIndex:i]objectForKey:@"vsession"] forKey:@"vsession"];
            else
                [devices setValue:@"" forKey:@"vsession"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Specialities saved successfully");
        }
        context=nil;
    }
    
}

-(NSArray *)fetchEconAptFromDataBase:(NSInteger)EconAptType
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconApt"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"apptype == %d",EconAptType];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"appdate" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            
            if ([obj valueForKey:@"app_method"] && [obj valueForKey:@"app_method"] != nil && [obj valueForKey:@"app_method"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"app_method"] forKey:@"app_method"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"app_method"];
            
            if ([obj valueForKey:@"appdate"] && [obj valueForKey:@"appdate"] != nil && [obj valueForKey:@"appdate"] != [NSNull null])
            {
                NSDateFormatter *format = [[NSDateFormatter alloc]init];
                NSTimeZone *gmt = [NSTimeZone systemTimeZone];
                [format setTimeZone:gmt];
                [format setDateFormat:@"yyyy-mm-dd"];
                NSDate *appdate = [obj valueForKey:@"appdate"];
                NSString *appStr = [format stringFromDate:appdate];
                [dictFetchData setObject:appStr forKey:@"appdate"];
            }
            else
                [dictFetchData setObject:nil forKey:@"appdate"];
            
            if ([obj valueForKey:@"appid"] && [obj valueForKey:@"appid"] != nil && [obj valueForKey:@"appid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"appid"] forKey:@"appid"];
            else
                [dictFetchData setObject:@"" forKey:@"appid"];
            
            if ([obj valueForKey:@"apptime"] && [obj valueForKey:@"apptime"] != nil && [obj valueForKey:@"apptime"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"apptime"] forKey:@"apptime"];
            else
                [dictFetchData setObject:@"" forKey:@"apptime"];
            
            if ([obj valueForKey:@"apptype"] && [obj valueForKey:@"apptype"] != nil && [obj valueForKey:@"apptype"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"apptype"] forKey:@"apptype"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"apptype"];
            
            if ([obj valueForKey:@"conid"] && [obj valueForKey:@"conid"] != nil && [obj valueForKey:@"conid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"conid"] forKey:@"conid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"conid"];
            
            if ([obj valueForKey:@"consultation_type"] && [obj valueForKey:@"consultation_type"] != nil && [obj valueForKey:@"consultation_type"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"consultation_type"] forKey:@"consultation_type"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"consultation_type"];
            
            if ([obj valueForKey:@"custid"] && [obj valueForKey:@"custid"] != nil && [obj valueForKey:@"custid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"custid"] forKey:@"custid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"custid"];
            
            if ([obj valueForKey:@"deptname"] && [obj valueForKey:@"deptname"] != nil && [obj valueForKey:@"deptname"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"deptname"] forKey:@"deptname"];
            else
                [dictFetchData setObject:@"" forKey:@"deptname"];
            
            if ([obj valueForKey:@"diagnosis"] && [obj valueForKey:@"diagnosis"] != nil && [obj valueForKey:@"diagnosis"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"diagnosis"] forKey:@"diagnosis"];
            else
                [dictFetchData setObject:@"" forKey:@"diagnosis"];
            
            if ([obj valueForKey:@"dispname"] && [obj valueForKey:@"dispname"] != nil && [obj valueForKey:@"dispname"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"dispname"] forKey:@"dispname"];
            else
                [dictFetchData setObject:@"" forKey:@"dispname"];
            
            if ([obj valueForKey:@"emailid"] && [obj valueForKey:@"emailid"] != nil && [obj valueForKey:@"emailid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"emailid"] forKey:@"emailid"];
            else
                [dictFetchData setObject:@"" forKey:@"emailid"];
            
            if ([obj valueForKey:@"reason"] && [obj valueForKey:@"reason"] != nil && [obj valueForKey:@"reason"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"reason"] forKey:@"reason"];
            else
                [dictFetchData setObject:@"" forKey:@"reason"];
            
            if ([obj valueForKey:@"recno"] && [obj valueForKey:@"recno"] != nil && [obj valueForKey:@"recno"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"recno"];
            
            if ([obj valueForKey:@"status"] && [obj valueForKey:@"status"] != nil && [obj valueForKey:@"status"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"status"] forKey:@"status"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"status"];
            
            if ([obj valueForKey:@"reason"] && [obj valueForKey:@"reason"] != nil && [obj valueForKey:@"reason"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"reason"] forKey:@"reason"];
            else
                [dictFetchData setObject:@"" forKey:@"reason"];
            
            if ([obj valueForKey:@"suggestion"] && [obj valueForKey:@"suggestion"] != nil && [obj valueForKey:@"suggestion"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"suggestion"] forKey:@"suggestion"];
            else
                [dictFetchData setObject:@"" forKey:@"suggestion"];
            
            if ([obj valueForKey:@"symptom"] && [obj valueForKey:@"symptom"] != nil && [obj valueForKey:@"symptom"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"symptom"] forKey:@"symptom"];
            else
                [dictFetchData setObject:@"" forKey:@"symptom"];
            
            if ([obj valueForKey:@"vsession"] && [obj valueForKey:@"vsession"] != nil && [obj valueForKey:@"vsession"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"vsession"] forKey:@"vsession"];
            else
                [dictFetchData setObject:@"" forKey:@"vsession"];
            
            if ([obj valueForKey:@"updated"] && [obj valueForKey:@"updated"] != nil && [obj valueForKey:@"updated"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"updated"] forKey:@"updated"];
            else
                [dictFetchData setObject:@"" forKey:@"updated"];
            
            if ([obj valueForKey:@"usertype"] && [obj valueForKey:@"usertype"] != nil && [obj valueForKey:@"usertype"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"usertype"] forKey:@"usertype"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"usertype"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
    
}


-(void)saveEconRequest:(NSArray *)arrEconRequestDetails conid:(NSInteger)econID type:(NSString *)RequestType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconRequest"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eConId == %d && requestType == %@",econID, RequestType];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        [self updateEconRequestInCoreData:arrEconRequestDetails conid:econID type:RequestType];
    }
    else
    {
        if ([arrEconRequestDetails count])
        {
            for (int i = 0; i < [arrEconRequestDetails count]; i++)
            {
                
                NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"EconRequest" inManagedObjectContext:context];
                
                [devices setValue:[NSNumber numberWithInteger:econID] forKey:@"eConId"];
                [devices setValue:arrEconRequestDetails forKey:@"request"];
                [devices setValue:RequestType forKey:@"requestType"];
            }
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Econsult Requests saved successfully");
        }
        context=nil;
    }
}

-(NSDictionary *)fetchEconRequestFromDataBase:(NSInteger)eConid type:(NSString *)RequestType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconRequest"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"eConId == %d && requestType == %@",eConid,RequestType];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        obj=[fetchDevices objectAtIndex:0];
        
        if ([obj valueForKey:@"request"] && [obj valueForKey:@"request"] != nil && [obj valueForKey:@"request"] != [NSNull null])
            return [obj valueForKey:@"request"];
        else
            return nil;
    }
    else
        return nil;
}

-(void)updateEconRequestInCoreData :(NSArray *)upDateValue conid:(NSInteger)econID type:(NSString *)RequestType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconRequest"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eConId == %d && requestType == %@",econID, RequestType];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *arrTemp = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    NSManagedObject *obj;
    if ([arrTemp count])
    {
        obj=[arrTemp objectAtIndex:0];
        [obj setValue:upDateValue forKey:@"request"];
    }
    
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}


-(void)saveEconReport:(NSArray *)arrEconReportDetails conid:(NSInteger)econID type:(NSString *)ReportType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconReport"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"eConId == %d && reportType == %@",econID, ReportType];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        [self updateEconReportInCoreData:arrEconReportDetails conid:econID type:ReportType];
    }
    else
    {
        if ([arrEconReportDetails count])
        {
            for (int i = 0; i < [arrEconReportDetails count]; i++)
            {
                
                NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"EconReport" inManagedObjectContext:context];
                
                [devices setValue:[NSNumber numberWithInteger:econID] forKey:@"eConId"];
                [devices setValue:arrEconReportDetails forKey:@"report"];
                [devices setValue:ReportType forKey:@"reportType"];
            }
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Econsult Reports saved successfully");
        }
        context=nil;
    }
}

-(NSDictionary *)fetchEconReportFromDataBase:(NSInteger)eConid type:(NSString *)ReportType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconReport"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"eConId == %d && reportType == %@",eConid, ReportType];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        obj=[fetchDevices objectAtIndex:0];
        
        if ([obj valueForKey:@"report"] && [obj valueForKey:@"report"] != nil && [obj valueForKey:@"report"] != [NSNull null])
            return [obj valueForKey:@"report"];
        else
            return nil;
    }
    else
        return nil;
}

-(void)updateEconReportInCoreData :(NSArray *)upDateValue conid:(NSInteger)econID type:(NSString *)ReportType;
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"EconReport"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"eConId == %d && reportType == %@",econID,ReportType];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *arrTemp = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    NSManagedObject *obj;
    if ([arrTemp count])
    {
        obj=[arrTemp objectAtIndex:0];
        [obj setValue:upDateValue forKey:@"report"];
    }
    
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
}


#pragma mark - Services
-(void)saveServiceList:(NSArray *)arrServiceListDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ServicesList"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrServiceListDetails count])
    {
        for (int i = 0; i < [arrServiceListDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"ServicesList" inManagedObjectContext:context];
            NSString *strDate = [[arrServiceListDetails objectAtIndex:i]objectForKey:@"created"];
            NSDateFormatter *format = [[NSDateFormatter alloc]init];
            NSTimeZone *gmt = [NSTimeZone systemTimeZone];
            [format setTimeZone:gmt];
            [format setDateFormat:@"yyyy-mm-dd"];
            NSDate *createdDate = [format dateFromString:strDate];
            
            NSDate *modifiedDate;
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"appstatus"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"appstatus"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrServiceListDetails objectAtIndex:i]objectForKey:@"appstatus"] integerValue]] forKey:@"appstatus"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"appstatus"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"cancel_reason"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"cancel_reason"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"cancel_reason"] forKey:@"cancel_reason"];
            else
                [devices setValue:@"" forKey:@"cancel_reason"];

            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"disc"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"disc"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"disc"] forKey:@"disc"];
            else
                [devices setValue:@"" forKey:@"disc"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_sugg"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_sugg"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_sugg"] forKey:@"doc_sugg"];
            else
                [devices setValue:@"" forKey:@"doc_sugg"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_updated"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_updated"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"doc_updated"] forKey:@"doc_updated"];
            else
                [devices setValue:@"" forKey:@"doc_updated"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"name"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"name"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"name"] forKey:@"name"];
            else
                [devices setValue:@"" forKey:@"name"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"paystatus"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"paystatus"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"paystatus"] forKey:@"paystatus"];
            else
                [devices setValue:@"" forKey:@"paystatus"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_date"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_date"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_date"] forKey:@"service_date"];
            else
                [devices setValue:@"" forKey:@"service_date"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_name"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_name"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_name"] forKey:@"service_name"];
            else
                [devices setValue:@"" forKey:@"service_name"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_time"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_time"] length] > 0)
                [devices setValue:[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_time"] forKey:@"service_time"];
            else
                [devices setValue:@"" forKey:@"service_time"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"paid_amount"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"paid_amount"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrServiceListDetails objectAtIndex:i]objectForKey:@"paid_amount"]integerValue]] forKey:@"paid_amount"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"paid_amount"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"patid"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"patid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrServiceListDetails objectAtIndex:i]objectForKey:@"patid"]integerValue]] forKey:@"patid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"patid"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"created"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"created"] length] > 0)
                [devices setValue:createdDate forKey:@"created"];
            else
                [devices setValue:@"" forKey:@"created"];

            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"modified"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"modified"] length] > 0)
            {
                NSString *strupdatedDate = [[arrServiceListDetails objectAtIndex:i]objectForKey:@"modified"];
                [format setDateFormat:@"yyyy-mm-dd HH:mm:SS"];
                modifiedDate = [format dateFromString:strupdatedDate];
                [devices setValue:modifiedDate forKey:@"modified"];
            }
            else
                [devices setValue:@"" forKey:@"modified"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"recno"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"recno"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrServiceListDetails objectAtIndex:i]objectForKey:@"recno"] integerValue]] forKey:@"recno"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"recno"];
            
            if ([[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_amount"] != [NSNull null] && [[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_amount"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrServiceListDetails objectAtIndex:i]objectForKey:@"service_amount"] integerValue]] forKey:@"service_amount"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"service_amount"];
            
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Specialities saved successfully");
        }
        context=nil;
    }
}

-(NSArray *)fetchServiceListFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"ServicesList"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modified" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"appstatus"] && [obj valueForKey:@"appstatus"] != nil && [obj valueForKey:@"appstatus"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"appstatus"] forKey:@"appstatus"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"appstatus"];
            
            if ([obj valueForKey:@"cancel_reason"] && [obj valueForKey:@"cancel_reason"] != nil && [obj valueForKey:@"cancel_reason"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"cancel_reason"] forKey:@"cancel_reason"];
            else
                [dictFetchData setObject:@"" forKey:@"cancel_reason"];
            
            if ([obj valueForKey:@"created"] && [obj valueForKey:@"created"] != nil && [obj valueForKey:@"created"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"created"] forKey:@"created"];
            else
                [dictFetchData setObject:@"" forKey:@"created"];
            
            if ([obj valueForKey:@"disc"] && [obj valueForKey:@"disc"] != nil && [obj valueForKey:@"disc"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"disc"] forKey:@"disc"];
            else
                [dictFetchData setObject:@"" forKey:@"disc"];
            
            if ([obj valueForKey:@"doc_updated"] && [obj valueForKey:@"doc_updated"] != nil && [obj valueForKey:@"doc_updated"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"doc_updated"] forKey:@"doc_updated"];
            else
                [dictFetchData setObject:@"" forKey:@"doc_updated"];

            if ([obj valueForKey:@"doc_sugg"] && [obj valueForKey:@"doc_sugg"] != nil && [obj valueForKey:@"doc_sugg"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"doc_sugg"] forKey:@"doc_sugg"];
            else
                [dictFetchData setObject:@"" forKey:@"doc_sugg"];

            
            if ([obj valueForKey:@"modified"] && [obj valueForKey:@"modified"] != nil && [obj valueForKey:@"modified"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"modified"] forKey:@"modified"];
            else
                [dictFetchData setObject:@"" forKey:@"modified"];
            
            if ([obj valueForKey:@"recno"] && [obj valueForKey:@"recno"] != nil && [obj valueForKey:@"recno"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"recno"] forKey:@"recno"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"recno"];
            
            if ([obj valueForKey:@"name"] && [obj valueForKey:@"name"] != nil && [obj valueForKey:@"name"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"name"] forKey:@"name"];
            else
                [dictFetchData setObject:@"" forKey:@"name"];
            
            if ([obj valueForKey:@"paystatus"] && [obj valueForKey:@"paystatus"] != nil && [obj valueForKey:@"paystatus"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"paystatus"] forKey:@"paystatus"];
            else
                [dictFetchData setObject:@"" forKey:@"paystatus"];
            
            if ([obj valueForKey:@"service_date"] && [obj valueForKey:@"service_date"] != nil && [obj valueForKey:@"service_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"service_date"] forKey:@"service_date"];
            else
                [dictFetchData setObject:@"" forKey:@"service_date"];

            if ([obj valueForKey:@"service_name"] && [obj valueForKey:@"service_name"] != nil && [obj valueForKey:@"service_name"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"service_name"] forKey:@"service_name"];
            else
                [dictFetchData setObject:@"" forKey:@"service_name"];
            
            if ([obj valueForKey:@"service_time"] && [obj valueForKey:@"service_time"] != nil && [obj valueForKey:@"service_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"service_time"] forKey:@"service_time"];
            else
                [dictFetchData setObject:@"" forKey:@"service_time"];
            
            if ([obj valueForKey:@"paid_amount"] && [obj valueForKey:@"paid_amount"] != nil && [obj valueForKey:@"paid_amount"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"paid_amount"] forKey:@"paid_amount"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"paid_amount"];
            
            if ([obj valueForKey:@"patid"] && [obj valueForKey:@"patid"] != nil && [obj valueForKey:@"patid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"patid"] forKey:@"patid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"patid"];
            
            if ([obj valueForKey:@"service_amount"] && [obj valueForKey:@"service_amount"] != nil && [obj valueForKey:@"service_amount"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"service_amount"] forKey:@"service_amount"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"service_amount"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark - Question


-(void)savePreviousQuestionsInDataBase:(NSArray *)arrQuestions
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PreviousQuestions"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrQuestions count])
    {
        for (int i = 0; i < [arrQuestions count]; i++)
        {
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"PreviousQuestions" inManagedObjectContext:context];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"qid"] forKey:@"qid"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"qtitle"] forKey:@"qtitle"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"qdesc"] forKey:@"qdesc"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"docreadstatus"] forKey:@"docreadstatus"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"modified"] forKey:@"modified"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"iscompleted"] forKey:@"iscompleted"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"askrfeed"] forKey:@"askrfeed"];
            [devices setValue:[[arrQuestions objectAtIndex:i]objectForKey:@"lans"] forKey:@"lans"];
            
            [devices setValue:[NSDate date] forKey:@"date"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
            NSLog(@"question saved successfully");
    }
}

-(NSArray *)fetchPreviousQuestionsFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PreviousQuestions"];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSArray *arrQuestions;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            obj=[fetchDevices objectAtIndex:i];
            NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:[obj valueForKey:@"qid"],@"qid",[obj valueForKey:@"qtitle"],@"qtitle",[obj valueForKey:@"qdesc"],@"qdesc",[obj valueForKey:@"docreadstatus"],@"docreadstatus",[obj valueForKey:@"modified"],@"modified",[obj valueForKey:@"iscompleted"],@"iscompleted",[obj valueForKey:@"askrfeed"],@"askrfeed",[obj valueForKey:@"lans"],@"lans", nil];
            [arrTemp addObject:dictTemp];
        }
        arrQuestions=arrTemp;
    }
    return arrQuestions;
}

-(void)updatePreviousQuestion:(NSString *)qid
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"PreviousQuestions"];
    NSPredicate *predicate =
    [NSPredicate predicateWithFormat:@"qid == %@",qid];
    [fetchRequest setPredicate:predicate];
    NSMutableArray *arrTemp = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    NSManagedObject *obj;
    if ([arrTemp count])
    {
        obj=[arrTemp objectAtIndex:0];
        [obj setValue:@"0" forKey:@"docreadstatus"];
    }
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

-(void)saveQuestionDetaislInDataBase:(NSDictionary *)quesDetails master:(NSDictionary *)dictMaster answers:(NSArray *)answers
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"QuestionDetails"];
    
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"qid == %@",[quesDetails objectForKey:@"qid"]];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([dictMaster count])
    {
        NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"QuestionDetails" inManagedObjectContext:context];
        [devices setValue:dictMaster forKey:@"master"];
        [devices setValue:[quesDetails objectForKey:@"qid"]  forKey:@"qid"];
        if ([answers count])
        {
            [devices setValue:answers forKey:@"answers"];
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
            NSLog(@"question saved successfully");
    }
}
-(id)fetchQuestionDetaisFromDataBase:(NSDictionary *)dictQuestionDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"QuestionDetails"];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"qid == %@",[dictQuestionDetails objectForKey:@"qid"]];
    [fetchRequest setPredicate:predicate];
    
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    id response;
    if ([fetchDevices count])
    {
        
        NSManagedObject *obj=[fetchDevices objectAtIndex:0];
        response =obj;
        
    }
    return response;
}
#pragma mark - PHR
/******************PHR DATA******************/

-(void)savePHRData:(NSString *)PHRName details:(NSArray *)phrDetailsArr
{
    if([PHRName isEqualToString:@"BMI"])
    {
        [self saveBMI:phrDetailsArr];
    }
    else if([PHRName isEqualToString:@"Blood Sugar"])
    {
        [self saveBloodSugar:phrDetailsArr];
    }
    else if([PHRName isEqualToString:@"Blood Pressure"])
    {
        [self saveBloodSugar:phrDetailsArr];
    }
    else if([PHRName isEqualToString:@"Pulse"])
    {
        [self savePulse:phrDetailsArr];
    }
    else if([PHRName isEqualToString:@"Temperature"])
    {
        [self saveTemperature:phrDetailsArr];
    }
    else
    {
        [self saveDailyActivities:phrDetailsArr];
    }

}

-(NSArray *)fetchPHRData:(NSString *)PHRName
{
    NSArray *phrArray;
    if([PHRName isEqualToString:@"BMI"])
    {
        phrArray = [self fetchBMIFromDataBase];
    }
    else if([PHRName isEqualToString:@"Blood Sugar"])
    {
        phrArray = [self fetchBloodSugarFromDataBase];
    }
    else if([PHRName isEqualToString:@"Blood Pressure"])
    {
        phrArray = [self fetchBloodPressureFromDataBase];
    }
    else if([PHRName isEqualToString:@"Pulse"])
    {
        phrArray = [self fetchPulseFromDataBase];
    }
    else if([PHRName isEqualToString:@"Temperature"])
    {
        phrArray = [self fetchTemperatureFromDataBase];
    }
    else
    {
        phrArray = [self fetchDailyActivitiesFromDataBase];
    }
    return phrArray;

}
#pragma mark - BMI
//BMI

-(void)saveBMI:(NSArray *)arrBMIDetails
{
    
//    
//    NSManagedObjectContext *context= [self managedObjectContext];
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BMI"];
//  
//    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//    fetchRequest=nil;
//   
//    if ([fetchDevices count])
//    {
//        for (NSManagedObject * obj in fetchDevices) {
//            [context deleteObject:obj];
//        }
//    }
//    if ([arrBMIDetails count])
//    {
//        for (int i = 0; i < [arrBMIDetails count]; i++)
//        {
//            
//            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"BMI" inManagedObjectContext:context];
//            
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
//                [devices setValue:[[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
//            else
//                [devices setValue:@"" forKey:@"checked_date"];
//            
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
//                [devices setValue:[[arrBMIDetails objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
//            else
//                [devices setValue:@"" forKey:@"checked_time"];
//            
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"height"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"height"] length] > 0)
//                
//                [devices setValue:[NSNumber numberWithDouble:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"height"]doubleValue]] forKey:@"height"];
//            else
//                [devices setValue:[NSNumber numberWithDouble:0] forKey:@"height"];
//
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"height_unit"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"height_unit"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"height_unit"]integerValue]] forKey:@"height_unit"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"height_unit"];
//
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"weight"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"weight"] length] > 0)
//                [devices setValue:[NSNumber numberWithDouble:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"weight"]doubleValue]] forKey:@"weight"];
//            else
//                [devices setValue:[NSNumber numberWithDouble:0] forKey:@"weight"];
//
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"weight_unit"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"weight_unit"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"weight_unit"]integerValue]] forKey:@"weight_unit"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"weight_unit"];
//
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"weightkg"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"weightkg"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"weightkg"]integerValue]] forKey:@"weightkg"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"weightkg"];
//            
//            if ([[arrBMIDetails objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrBMIDetails objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrBMIDetails objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
//            
//            
//        }
//        if (![context save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }
//        else
//        {
//            NSLog(@"Weight saved successfully");
//        }
//        context=nil;
//    }
    
}

-(NSArray *)fetchBMIFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BMI"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"height"] && [obj valueForKey:@"height"] != nil && [obj valueForKey:@"height"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"height"] forKey:@"height"];
            else
                [dictFetchData setObject:[NSNumber numberWithDouble:0] forKey:@"height"];
            
            if ([obj valueForKey:@"weight"] && [obj valueForKey:@"weight"] != nil && [obj valueForKey:@"weight"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"weight"] forKey:@"weight"];
            else
                [dictFetchData setObject:[NSNumber numberWithDouble:0] forKey:@"weight"];

            if ([obj valueForKey:@"height_unit"] && [obj valueForKey:@"height_unit"] != nil && [obj valueForKey:@"height_unit"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"height_unit"] forKey:@"height_unit"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"height_unit"];
            
            if ([obj valueForKey:@"weight_unit"] && [obj valueForKey:@"weight_unit"] != nil && [obj valueForKey:@"weight_unit"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"weight_unit"] forKey:@"weight_unit"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"weight_unit"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];

            if ([obj valueForKey:@"weightkg"] && [obj valueForKey:@"weightkg"] != nil && [obj valueForKey:@"weightkg"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"weightkg"] forKey:@"weightkg"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"weightkg"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;

}

#pragma mark - BLOOD SUGAR
-(void)saveBloodSugar:(NSArray *)arrSugarDetails
{
//    NSManagedObjectContext *context= [self managedObjectContext];
//  
//    NSError *error = nil;
//  
//    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
//  
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BloodSugar"];
//   
//    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
//   
//    fetchRequest=nil;
//   
//    if ([fetchDevices count])
//    {
//        for (NSManagedObject * obj in fetchDevices)
//        {
//            [context deleteObject:obj];
//        }
//    }
//    
//    if ([arrSugarDetails count])
//    {
//        for (int i = 0; i < [arrSugarDetails count]; i++)
//        {
//            
//            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"BloodSugar" inManagedObjectContext:context];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
//                [devices setValue:[[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
//            else
//                [devices setValue:@"" forKey:@"checked_date"];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
//                [devices setValue:[[arrSugarDetails objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
//            else
//                [devices setValue:@"" forKey:@"checked_time"];
//            
//           
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar"]integerValue]] forKey:@"blood_sugar"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"blood_sugar"];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar_mg"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar_mg"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"blood_sugar_mg"]integerValue]] forKey:@"blood_sugar_mg"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"blood_sugar_mg"];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"check_with"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"check_with"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"check_with"]integerValue]] forKey:@"check_with"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"check_with"];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_check"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_check"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_check"]integerValue]] forKey:@"sugar_check"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"sugar_check"];
//
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_unit"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_unit"] length] > 0)
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"sugar_unit"]integerValue]] forKey:@"sugar_unit"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"sugar_unit"];
//            
//            if ([[arrSugarDetails objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrSugarDetails objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
//                
//                [devices setValue:[NSNumber numberWithInteger:[[[arrSugarDetails objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
//            else
//                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
//            
//            
//        }
//        if (![context save:&error]) {
//            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
//        }
//        else
//        {
//            NSLog(@"Blood Sugar saved successfully");
//        }
//        context=nil;
//    }
//    
}

-(NSArray *)fetchBloodSugarFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BloodSugar"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"blood_sugar"] && [obj valueForKey:@"blood_sugar"] != nil && [obj valueForKey:@"blood_sugar"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"blood_sugar"] forKey:@"blood_sugar"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"blood_sugar"];
            
            if ([obj valueForKey:@"blood_sugar_mg"] && [obj valueForKey:@"blood_sugar_mg"] != nil && [obj valueForKey:@"blood_sugar_mg"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"blood_sugar_mg"] forKey:@"blood_sugar_mg"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"blood_sugar_mg"];
            
            if ([obj valueForKey:@"check_with"] && [obj valueForKey:@"check_with"] != nil && [obj valueForKey:@"check_with"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"check_with"] forKey:@"check_with"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"check_unit"];
            
            if ([obj valueForKey:@"sugar_check"] && [obj valueForKey:@"sugar_check"] != nil && [obj valueForKey:@"sugar_check"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"sugar_check"] forKey:@"sugar_check"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"sugar_check"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            if ([obj valueForKey:@"sugar_unit"] && [obj valueForKey:@"sugar_unit"] != nil && [obj valueForKey:@"sugar_unit"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"sugar_unit"] forKey:@"sugar_unit"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"sugar_unit"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark - BLOOD PRESSURE
-(void)saveBloodPressure:(NSArray *)arrBPDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BloodPressure"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrBPDetails count])
    {
        for (int i = 0; i < [arrBPDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"BloodPressure" inManagedObjectContext:context];
            
            if ([[arrBPDetails objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrBPDetails objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
                [devices setValue:[[arrBPDetails objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [devices setValue:@"" forKey:@"checked_date"];
            
            if ([[arrBPDetails objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrBPDetails objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
                [devices setValue:[[arrBPDetails objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [devices setValue:@"" forKey:@"checked_time"];
            
            
            if ([[arrBPDetails objectAtIndex:i]objectForKey:@"bp_disambiguation"] != [NSNull null] && [[[arrBPDetails objectAtIndex:i]objectForKey:@"bp_disambiguation"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrBPDetails objectAtIndex:i]objectForKey:@"bp_disambiguation"]integerValue]] forKey:@"bp_disambiguation"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"bp_disambiguation"];
            
            if ([[arrBPDetails objectAtIndex:i]objectForKey:@"bp_systolic"] != [NSNull null] && [[[arrBPDetails objectAtIndex:i]objectForKey:@"bp_systolic"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrBPDetails objectAtIndex:i]objectForKey:@"bp_systolic"]integerValue]] forKey:@"bp_systolic"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"bp_systolic"];
            
            if ([[arrBPDetails objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrBPDetails objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrBPDetails objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Blood Pressure saved successfully");
        }
        context=nil;
    }
}

-(NSArray *)fetchBloodPressureFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"BloodPressure"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"bp_disambiguation"] && [obj valueForKey:@"bp_disambiguation"] != nil && [obj valueForKey:@"bp_disambiguation"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"bp_disambiguation"] forKey:@"bp_disambiguation"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"bp_disambiguation"];
            
            if ([obj valueForKey:@"bp_systolic"] && [obj valueForKey:@"bp_systolic"] != nil && [obj valueForKey:@"bp_systolic"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"bp_systolic"] forKey:@"bp_systolic"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"bp_systolic"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark - PULSE
-(void)savePulse:(NSArray *)arrPulseDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Pulse"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrPulseDetails count])
    {
        for (int i = 0; i < [arrPulseDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Pulse" inManagedObjectContext:context];
            
            if ([[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
                [devices setValue:[[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [devices setValue:@"" forKey:@"checked_date"];
            
            if ([[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
                [devices setValue:[[arrPulseDetails objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [devices setValue:@"" forKey:@"checked_time"];
            
            if ([[arrPulseDetails objectAtIndex:i]objectForKey:@"pulse"] != [NSNull null] && [[[arrPulseDetails objectAtIndex:i]objectForKey:@"pulse"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrPulseDetails objectAtIndex:i]objectForKey:@"pulse"]integerValue]] forKey:@"pulse"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"pulse"];
            
            if ([[arrPulseDetails objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrPulseDetails objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrPulseDetails objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Pulse saved successfully");
        }
        context=nil;
    }
}

-(NSArray *)fetchPulseFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Pulse"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"pulse"] && [obj valueForKey:@"pulse"] != nil && [obj valueForKey:@"pulse"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"pulse"] forKey:@"pulse"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"pulse"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark - TEMEPRATURE
-(void)saveTemperature:(NSArray *)arrTemperatureDetails
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Temperature"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrTemperatureDetails count])
    {
        for (int i = 0; i < [arrTemperatureDetails count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"Temperature" inManagedObjectContext:context];
            
            if ([[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
                [devices setValue:[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [devices setValue:@"" forKey:@"checked_date"];
            
            if ([[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
                [devices setValue:[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [devices setValue:@"" forKey:@"checked_time"];
            
            if ([[arrTemperatureDetails objectAtIndex:i]objectForKey:@"temperature"] != [NSNull null] && [[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"temperature"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"temperature"]integerValue]] forKey:@"temperature"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"temperature"];
            
            if ([[arrTemperatureDetails objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrTemperatureDetails objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Temperature saved successfully");
        }
        context=nil;
    }
}

-(NSArray *)fetchTemperatureFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Temperature"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"temperature"] && [obj valueForKey:@"temperature"] != nil && [obj valueForKey:@"temperature"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"temperature"] forKey:@"temperature"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"temperature"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

#pragma mark - DAILY ACTIVITIES
-(void)saveDailyActivities:(NSArray *)arrDailyActivities
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DailyActivities"];
    NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        for (NSManagedObject * obj in fetchDevices) {
            [context deleteObject:obj];
        }
    }
    if ([arrDailyActivities count])
    {
        for (int i = 0; i < [arrDailyActivities count]; i++)
        {
            
            NSManagedObject *devices = [NSEntityDescription insertNewObjectForEntityForName:@"DailyActivities" inManagedObjectContext:context];
            
            if ([[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_date"] != [NSNull null] && [[[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_date"] length] > 0)
                [devices setValue:[[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [devices setValue:@"" forKey:@"checked_date"];
            
            if ([[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_time"] != [NSNull null] && [[[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_time"] length] > 0)
                [devices setValue:[[arrDailyActivities objectAtIndex:i]objectForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [devices setValue:@"" forKey:@"checked_time"];
            
            if ([[arrDailyActivities objectAtIndex:i]objectForKey:@"activity_type"] != [NSNull null] && [[[arrDailyActivities objectAtIndex:i]objectForKey:@"activity_type"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDailyActivities objectAtIndex:i]objectForKey:@"activity_type"]integerValue]] forKey:@"activity_type"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"activity_type"];

            if ([[arrDailyActivities objectAtIndex:i]objectForKey:@"daily_activity"] != [NSNull null] && [[[arrDailyActivities objectAtIndex:i]objectForKey:@"daily_activity"] length] > 0)
                [devices setValue:[[arrDailyActivities objectAtIndex:i]objectForKey:@"daily_activity"] forKey:@"daily_activity"];
            else
                [devices setValue:@"" forKey:@"daily_activity"];
            
            if ([[arrDailyActivities objectAtIndex:i]objectForKey:@"phrid"] != [NSNull null] && [[[arrDailyActivities objectAtIndex:i]objectForKey:@"phrid"] length] > 0)
                [devices setValue:[NSNumber numberWithInteger:[[[arrDailyActivities objectAtIndex:i]objectForKey:@"phrid"] integerValue]] forKey:@"phrid"];
            else
                [devices setValue:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            
        }
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
        else
        {
            NSLog(@"Daily Activities saved successfully");
        }
        context=nil;
    }
}

-(NSArray *)fetchDailyActivitiesFromDataBase
{
    NSManagedObjectContext *context= [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"DailyActivities"];
    NSMutableArray *fetchDevices = [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
    fetchRequest=nil;
    fetchRequest=nil;
    if ([fetchDevices count])
    {
        NSManagedObject *obj=nil;
        NSMutableArray *arrTemp=[[NSMutableArray alloc]init];
        for (int i = 0; i < [fetchDevices count]; i++)
        {
            NSMutableDictionary *dictFetchData = [[NSMutableDictionary alloc] init];
            obj=[fetchDevices objectAtIndex:i];
            
            if ([obj valueForKey:@"checked_date"] && [obj valueForKey:@"checked_date"] != nil && [obj valueForKey:@"checked_date"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_date"] forKey:@"checked_date"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_date"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"daily_activity"] && [obj valueForKey:@"daily_activity"] != nil && [obj valueForKey:@"daily_activity"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"daily_activity"] forKey:@"daily_activity"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"daily_activity"];
            
            if ([obj valueForKey:@"checked_time"] && [obj valueForKey:@"checked_time"] != nil && [obj valueForKey:@"checked_time"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"checked_time"] forKey:@"checked_time"];
            else
                [dictFetchData setObject:@"" forKey:@"checked_time"];
            
            if ([obj valueForKey:@"phrid"] && [obj valueForKey:@"phrid"] != nil && [obj valueForKey:@"phrid"] != [NSNull null])
                [dictFetchData setObject:[obj valueForKey:@"phrid"] forKey:@"phrid"];
            else
                [dictFetchData setObject:[NSNumber numberWithInteger:0] forKey:@"phrid"];
            
            [arrTemp insertObject:dictFetchData atIndex:i];
        }
        return arrTemp;
    }
    else
        return nil;
}

-(void)clearDatbaseWhenUserLogout
{
    NSArray *arrKeys=[[NSArray alloc]initWithObjects:@"BloodPressure",@"BloodSugar",@"BMI", @"DailyActivities", @"Doctor", @"EconApt", @"EconReport", @"EconRequest", @"Location", @"Login", @"Messages", @"PreviousQuestions", @"Profile", @"Pulse", @"QuestionDetails", @"Questions", @"ServicesList", @"Specialities", @"Temperature", nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        for (int i = 0; i < [arrKeys count]; i++)
        {
            NSString *strTrackerName=[arrKeys objectAtIndex:i];
            NSManagedObjectContext *context= [self managedObjectContext];
            NSError *error = nil;
            
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:strTrackerName];
            NSMutableArray *fetchDevices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            fetchRequest=nil;
            if ([fetchDevices count])
            {
                for (NSManagedObject * obj in fetchDevices) {
                    [context deleteObject:obj];
                }
            }
            if (![context save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            context=nil;
        }
    });
}
#pragma mark - Cart

-(BOOL)saveCartData:(CartRequestModel *)cartModel{
    
    SmartRxAppDelegate *appDelegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSEntityDescription *descriptiopn = [NSEntityDescription entityForName:@"Cart" inManagedObjectContext:appDelegate.managedObjectContext];
    
    Cart *cart = [[Cart alloc]initWithEntity:descriptiopn insertIntoManagedObjectContext:appDelegate.managedObjectContext];
    
    cart.serviceType = cartModel.serviceType;
    cart.providerServiceId = cartModel.providerServiceId;
    cart.servicePrice = cartModel.servicePrice;
    cart.scheduledDate = cartModel.scheduledDate;
    cart.scheduledTime = cartModel.scheduledTime;
    cart.bookingLocationId = cartModel.bookingLocationId;
    cart.serviceName = cartModel.serviceName;
    cart.providerName = cartModel.providerName;
    cart.userId = cartModel.userId;
    cart.isScheduled = [NSNumber numberWithBool:cartModel.isScheduled];
    NSError *error;
    BOOL IsSaved;
    if (![appDelegate.managedObjectContext save:&error]){
        
        NSLog(@"error :%@",error);
        IsSaved = NO;
    } else {
        [self fetchCartItems];
        IsSaved = YES;
    }
    return IsSaved;

}
-(NSArray *)fetchCartItems{
    
    SmartRxAppDelegate *appDelegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cart"];
    NSString *userid = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userid];
    [request setPredicate:predicate];
    NSEntityDescription *descrption = [NSEntityDescription entityForName:@"Cart" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:descrption];
   
    NSArray *fetchDevices = [appDelegate.managedObjectContext executeFetchRequest:request error:nil] ;
    appDelegate.cartCount = fetchDevices.count;
    return fetchDevices;
}
-(void)deleteCartItem:(Cart *)selectedItem{
    
    SmartRxAppDelegate *delegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Cart"];
    //serviceName
    //serviceType
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(serviceName == %@) AND (scheduledDate == %@) AND (scheduledTime = %@)", selectedItem.serviceName,selectedItem.scheduledDate,selectedItem.scheduledTime];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
   // NSManagedObjectContext *managedObjectContext = delegate.managedObjectContext;
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error && result.count > 0) {
        
                NSManagedObject *managedObject = result[0];
                [delegate.managedObjectContext deleteObject:managedObject];
        
//        for(NSManagedObject *managedObject in result){
//            
//            [delegate.managedObjectContext deleteObject:managedObject];
//        }
        
        //Save context to write to store
        [delegate.managedObjectContext save:nil];
        [self fetchCartItems];
        
    }
    
    
}
-(void)deleteCartDataBase{
    
    SmartRxAppDelegate *delegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Cart"];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userid];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    
    NSArray *result = [delegate.managedObjectContext executeFetchRequest:request error:&error];
    
    if (!error && result.count > 0) {
        
        //        NSManagedObject *managedObject = result[self.selectedIndex.row];
        //        [managedObjectContext deleteObject:managedObject];
        
        for(NSManagedObject *managedObject in result){
            [delegate.managedObjectContext deleteObject:managedObject];
        }
        //Save context to write to store
        [delegate.managedObjectContext save:nil];
        [self fetchCartItems];
        
    }
    
}


@end
