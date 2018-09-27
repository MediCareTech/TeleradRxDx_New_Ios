





//
//  SmartRxCommonClass.m
//  SmartRx
//
//  Created by PaceWisdom on 22/04/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import "SmartRxCommonClass.h"
#import "NSString+MD5.h"
#import "SmartRxAppDelegate.h"

@implementation SmartRxCommonClass


+ (id)sharedManager {
    static SmartRxCommonClass *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void)openGallary:(UIViewController *)controller{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = (id)self;
    self.imageDelegate = (id)controller;
    [controller presentViewController:picker animated:YES completion:nil];
}


#pragma mark - ImagePicker Delegate Methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.imageDelegate imageSelected:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [picker dismissViewControllerAnimated:YES completion:nil];
    //getting image name when selected
    /*NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
     ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
     {
     ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
     NSLog(@"[imageRep filename] : %@", [imageRep filename]);
     };
     ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
     [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
     */
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Make Request to server

-(void)postOrGetData:(NSString *)UrlString postPar:(id )postParaDict method:(NSString *)methodType setHeader:(BOOL)header  successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler{
    NSURL *url = [NSURL URLWithString:UrlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    [request setHTTPMethod:methodType];
    if (header) {
        [request setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"] forHTTPHeaderField:@"session_id"];
    }
    [request setValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
    [request setValue:@"PHPSESSID=lel6oqbccs5mgc7eb6a0nikau7" forHTTPHeaderField:@"Set-Cookie"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    
    if ([methodType isEqualToString:@"POST"])
    {
      
        [request setHTTPBody:[[NSString stringWithFormat:@"%@",postParaDict ] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //request.timeoutInterval=30;
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *  response, NSError *  error) {
        dispatch_async(dispatch_get_main_queue(),^{
        NSLog(@"The connection : %@", response);
            
        if (!error) {
           // NSString *tempStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
                failureHandler(responseData);
                return;
            }
            dispatch_async(dispatch_get_main_queue(),^{
                 successHandler(responseData);
            });
           
        }else{
            
            failureHandler(error);
        }
        });
    }];
    [dataTask resume];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        NSLog(@"The connection : %@", response);
//        if (!connectionError) {
//            
//            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
//                failureHandler(responseData);
//                return;
//            }
//            successHandler(responseData);
//        }else{
//            failureHandler(connectionError);
//        }
//    }];
}
-(void)requestGETFitbitData:(NSString *)strURL Token:(NSString *)token success:(void (^)(NSDictionary *responseObject))success failure:(void (^)(NSError *error))failure{
    
    BOOL isNetworkAvailable = [self checkNetConnection];
    
    if (!isNetworkAvailable) {
        [self showAlert:@"Please check your internet connection"];
    }
    else {
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURL *url = [NSURL URLWithString:strURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
        [request setValue:[NSString stringWithFormat:@"Bearer %@",token]  forHTTPHeaderField:@"Authorization"];

        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
        [request setHTTPMethod:@"GET"];

        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
            if (error == nil) {
                id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (responseData[@"errors"] == nil) {
                    success(responseData);
                }else{

                    NSError *manualError = [NSError errorWithDomain:NSLocalizedDescriptionKey code:401 userInfo:responseData[@"errors"][0]];
                    failure(manualError);
                }

            }else {

                failure(error);
            }
        }];
        [task resume];
//        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//        [manager.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@",token] forHTTPHeaderField:@"Authorization"];
//        NSLog(@"token.....:%@",token);
//        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//
//        manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//        [manager GET:strURL parameters:nil  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            NSLog(@"success handler....");
//
//            if([responseObject isKindOfClass:[NSDictionary class]]) {
//                if(success) {
//                    success(responseObject);
//                }
//            }
//            else {
//                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
//                NSLog(@"fitbit response......:%@",responseObject);
//                if(success) {
//                    success(response);
//                }
//            }
//
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"failure handler....");
//            if(failure) {
//
//                failure(error);
//            }
//
//        }];
    }
}
-(void)showAlert :(NSString *)message{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.rootViewController = [UIViewController new];
    window.windowLevel = UIWindowLevelAlert + 1;
    
    UIAlertController* alertView = [UIAlertController alertControllerWithTitle:@"Info!" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertView addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        window.hidden = YES;
    }]];
    
    [window makeKeyAndVisible];
    [window.rootViewController presentViewController:alertView animated:YES completion:nil];
}
-(void)addEHR:(NSDictionary *)postDict successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler{
    
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];

    NSString *url=[NSString stringWithFormat:@"%s/ehr/member/%@",kBaseUrl,userId];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:sectionId forHTTPHeaderField:@"sessionid"];
    NSString *bodyText=nil;
    bodyText = [NSString stringWithFormat:@"%@=%@",@"sessionid",sectionId];
    NSMutableData *postData = [[NSMutableData alloc]initWithData:[[NSString stringWithFormat:@"%@",bodyText ] dataUsingEncoding:NSUTF8StringEncoding]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    
    [postData appendData:[[NSString stringWithFormat:@"&data_items="] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:data];
    [request setHTTPBody:postData];
    NSString *cokie = [[NSUserDefaults standardUserDefaults] objectForKey:@"cookie"];
    if (cokie) {
        [request addValue:cokie forHTTPHeaderField:@"Cookie"];
        
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    request.timeoutInterval = 15.0;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
        
        
        if (!error) {
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
                failureHandler(responseData);
                return;
            }
            successHandler(responseData);
            
        }else {
            successHandler(error);
            
        }
        
        
    }];
    [dataTask resume];
    
    
}

-(NSString *)urlenc:(NSString *)val
{
    CFStringRef safeString =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)val,
                                            NULL,
                                            CFSTR("/%&=?$#+-~@<>|\*,.()[]{}^!"),
                                            kCFStringEncodingUTF8);
    return [NSString stringWithFormat:@"%@", safeString];
}

-(void)makeLoginRequest
{
    NSString *strPasword=[[NSUserDefaults standardUserDefaults]objectForKey:@"Password"];
     NSString *strMobileNum=[[NSUserDefaults standardUserDefaults]objectForKey:@"MobileNumber"];
    NSString *cid=[[NSUserDefaults standardUserDefaults]objectForKey:@"cidd"];
    
    if ([strPasword length] > 0)
    {
        
        //strPasword=[NSString md5:strPasword];
    }
    if (strPasword && [strMobileNum length] > 0)
    {
        
        NSData *data = [[NSUserDefaults standardUserDefaults] valueForKey:@"PushToken"];
        NSString *strPushToken = [[[data description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        
        NSString *bodyText = [NSString stringWithFormat:@"%@=%@",@"mobile",strMobileNum];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"cid",cid]];
        bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"pass",strPasword]];
         bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"mode",@"2"]];
         bodyText = [bodyText stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",@"regId",strPushToken]];

        NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"mlogin"];
        [self postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO  successHandler:^(id response) {
            
            NSLog(@"sucess 11 %@",response);
            
            if ([[[response objectAtIndex:0] objectForKey:@"authorized"]integerValue] == 0)
            {
                
                SmartRxAppDelegate *appDelegate = (SmartRxAppDelegate *)[UIApplication sharedApplication].delegate;
                appDelegate.passwordStatus = true;
               [self.loginDelegate performSelectorOnMainThread:@selector(logoutTheSession) withObject:nil waitUntilDone:YES];
            }
            else{
                dispatch_async(dispatch_get_main_queue(),^{
                    
                
                NSLog(@"section idd ==== %@",[[response objectAtIndex:0]objectForKey:@"sessionid"]);
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0]objectForKey:@"sessionid"] forKey:@"sessionid"];
                    [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0]objectForKey:@"emailid"] forKey:@"emailId"];
                [[NSUserDefaults standardUserDefaults]setObject:cid forKey:@"cid"];
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"hosname"] forKey:@"HosName"];
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"dispname"] forKey:@"UserName"];
                [[NSUserDefaults standardUserDefaults]setObject:[[response objectAtIndex:0] objectForKey:@"session_name"] forKey:@"SessionName"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                   
                [self.loginDelegate performSelectorOnMainThread:@selector(sectionIdGenerated:) withObject:nil waitUntilDone:YES];
                     });
            }
                              
        } failureHandler:^(id response) {
           [self.loginDelegate performSelectorOnMainThread:@selector(sectionIdGenerated:) withObject:nil waitUntilDone:YES];
        }];
    }
}

//Dummy code for testing


-(void)postingImageWithText:(NSString *)urlString postData:(id)postParaDict camImg:(UIImage *)img successHandler:(void(^)(id response))successHandler failureHandler:(void(^)(id response))failureHandler
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];

     NSString *boundary =@"0x0hHai1CanHazB0undar135";
    NSString *BoundaryConstant =@"----------V2ymHFg03ehbqgZCaKO6jy";
    
    NSString *contentType = [NSString stringWithFormat:@"application/x-www-form-urlencoded; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // post body
    NSMutableData *body = [NSMutableData data];
    
    // add params (all params are strings)
    for (NSString *param in postParaDict) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", BoundaryConstant] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", param] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [postParaDict objectForKey:param]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    // add image data
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0);
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"patientfile[]"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // set the content-length
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError) {
            id responseData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([responseData isKindOfClass:[NSDictionary class]] && [responseData objectForKey:@"error"]) {
                failureHandler(responseData);
                return;
            }
            successHandler(responseData);
        }else{
            failureHandler(connectionError);
        }
    }];
}
-(BOOL)checkNetConnection
{
    Reachability * reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus] ;
    
    if(internetStatus == NotReachable)
    {
        NSLog(@"Network is not reachable");
        return NO;
    }
    else {
        // NSLog(@"Network is reachable");
        return YES;
    }
}

#pragma mark - Navigation Title adjestment
-(void)setNavigationTitle:(NSString *)title controler:(UIViewController *)controller
{
    if ([title length] <= 25)
    {
        controller.title = title;
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 250, 40)];
        tlabel.text=controller.navigationItem.title;
        tlabel.textColor=[UIColor whiteColor];
        tlabel.textAlignment=NSTextAlignmentCenter;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 17.0];
        tlabel.backgroundColor =[UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth=YES;
        controller.navigationItem.titleView=tlabel;
    }
    else
    {
        controller.title = title;
        UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, 250, 40)];
        tlabel.text=controller.navigationItem.title;
        tlabel.textColor=[UIColor whiteColor];
        tlabel.textAlignment=NSTextAlignmentCenter;
        tlabel.numberOfLines = 10;
        tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 11.0];
        tlabel.backgroundColor =[UIColor clearColor];
//        tlabel.adjustsFontSizeToFitWidth=YES;
        controller.navigationItem.titleView=tlabel;
        
    }
}
@end
