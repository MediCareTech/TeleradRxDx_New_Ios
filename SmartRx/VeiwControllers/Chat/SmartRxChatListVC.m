//
//  SmartRxChatListVC.m
//  SmartRx
//
//  Created by SmartRx-iOS on 21/02/18.
//  Copyright © 2018 smartrx. All rights reserved.
//

#import "SmartRxChatListVC.h"
#import "ConversationViewController.h"
#import "SmartRxDashBoardVC.h"
#import "ChatHistoryResponseModel.h"
#import "ChatListCell.h"

@interface SmartRxChatListVC ()
@property(nonatomic,strong) NSArray *chatListArray;
@property(nonatomic,strong) NSString *doctorId;
@property(nonatomic,strong) NSString *roomName;
@property(nonatomic,strong) NSString *chatMessage;
@property(nonatomic,strong) NSString *doctorName;
@property(nonatomic,strong) NSString *doctorPic;
@property(nonatomic,strong) ChatHistoryResponseModel *selectedChat;

@end

@implementation SmartRxChatListVC
-(void)navigationBackButton
{
    self.navigationItem.hidesBackButton=YES;
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backBtnImage = [UIImage imageNamed:@"icn_back.png"];
    [backBtn setImage:backBtnImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(-40, -2, 100, 40);
    UIView *backButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    backButtonView.bounds = CGRectOffset(backButtonView.bounds, 0, -7);
    [backButtonView addSubview:backBtn];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:backButtonView];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIButton *btnFaq = [UIButton buttonWithType:UIButtonTypeCustom];
    btnFaq.tag=1;
    UIImage *faqBtnImag = [UIImage imageNamed:@"icn_home.png"];
    [btnFaq setImage:faqBtnImag forState:UIControlStateNormal];
    
    [btnFaq addTarget:self action:@selector(homeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnFaq.frame = CGRectMake(20, -2, 60, 40);
    UIView *btnFaqView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 70, 47)];
    btnFaqView.bounds = CGRectOffset(btnFaqView.bounds, 0, -7);
    [btnFaqView addSubview:btnFaq];
    UIBarButtonItem *rightbutton = [[UIBarButtonItem alloc] initWithCustomView:btnFaqView];
    self.navigationItem.rightBarButtonItem = rightbutton;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[SmartRxCommonClass sharedManager] setNavigationTitle:@"Chats" controler:self];

    //self.noAppsLbl.text = @"Click on the chat icon to get connected with one of our doctors.";
    [self.tableView setTableFooterView:[UIView new]];
    self.noAppsLbl.hidden = YES;
    [self navigationBackButton];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];

    [self makeRequestForChatList];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.selectedChat = nil;
    self.doctorPic = nil;
    self.doctorId = nil;
    self.doctorName = nil;
    self.chatMessage = nil;
    self.roomName = nil;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark - Action Methods

-(IBAction)clikOnAddBtn:(id)sender{
    [self makeRequestForChatRequest];
}
-(void)backBtnClicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)homeBtnClicked:(id)sender
{
    
    for (UIViewController *controller in [self.navigationController viewControllers])
    {
        if ([controller isKindOfClass:[SmartRxDashBoardVC class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
        }
    }
}
-(void)makeRequestForChatList{
    NSString *userId=[[NSUserDefaults standardUserDefaults]objectForKey:@"userid"];
    NSLog(@"patient id..........:%@",userId);
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@",sectionId];
    NSString *url=[NSString stringWithFormat:@"%s/%@",kBaseUrl,@"chat_history"];
    NSLog(@"sessionid ..........:%@",sectionId);

    NSLog(@"chat url......:%@",url);

    [[SmartRxCommonClass sharedManager] postOrGetData:url postPar:bodyText method:@"POST" setHeader:NO successHandler:^(id response) {
        if ([[response[0] objectForKey:@"authorized"]integerValue] == 0 && [[response[0] objectForKey:@"result"]integerValue] == 0)
        {
            SmartRxCommonClass *smartLogin=[[SmartRxCommonClass alloc]init];
            smartLogin.loginDelegate=self;
            [smartLogin makeLoginRequest];
            
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                
                NSLog(@"chat history........:%@",response);

            [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
            NSDictionary *tempDict = response[0];
            NSArray *dataArray = tempDict[@"data"];
            NSMutableArray *tempArr = [[NSMutableArray alloc]init];
            for (NSDictionary *dict in dataArray) {
                ChatHistoryResponseModel *model= [[ChatHistoryResponseModel alloc]init];
                if ([dict[@"dispname"] isKindOfClass:[NSString class]]) {

                    model.doctorName = dict[@"dispname"];

                }else {
                    model.doctorName = @"Unkown";

                }
                model.doctorId = dict[@"from_id"];
                model.doctorProfilePic = dict[@"profilepic"];
                model.roomId = dict[@"room_id"];
                model.lastMessageTime = dict[@"last_msg_senton"];
                [tempArr addObject:model];
            }
            self.chatListArray = [tempArr copy];
            if (self.chatListArray.count) {
                self.tableView.hidden = NO;
                self.noAppsLbl.hidden = YES;
                [self.tableView reloadData];
            }else {
                self.tableView.hidden = YES;
                self.noAppsLbl.hidden = NO;
            }
                
        });
        }

    } failureHandler:^(id response) {
        dispatch_async(dispatch_get_main_queue(),^{

        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
        [self showAlert:@"Network not available"];
            
        });

    }];
    
}
-(void)makeRequestForChatRequest{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    NSString *sectionId=[[NSUserDefaults standardUserDefaults]objectForKey:@"sessionid"];
    NSLog(@"session id.......:%@",sectionId);
    NSString *bodyText = [NSString stringWithFormat:@"sessionid=%@",sectionId];
    //NSURL *url = [NSURL URLWithString:@"https://dev.smartrx.in/api/chat_request"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%s/chat_request",kBaseUrl]];
    NSLog(@"chat url......:%@",url);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    //[request setValue:@"no-cache" forHTTPHeaderField:@"cache-control"];
    
   // [request setValue:@"PHPSESSID=gt2hsgqudgctussld1s7pneam5" forHTTPHeaderField:@"Set-Cookie"];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];//multipart/form-data
    [request setHTTPBody:[[NSString stringWithFormat:@"%@",bodyText] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
        NSDictionary *fields = [HTTPResponse allHeaderFields];
        NSString *cookie = [fields valueForKey:@"Set-Cookie"];
        NSLog(@"cookie ......:%@",fields);
        if (!error) {
            id temp = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"chat data......:%@",temp);
            
            if (temp != nil) {
                
                if ([temp[0][@"status"] integerValue]== 1 || [temp[0][@"status"] integerValue]== 4) {
                    self.roomName  = temp[0][@"room_name"];
                    self.chatMessage  = temp[0][@"message"];
                    
                }else if ([temp[0][@"status"] integerValue]== 2 ){
                    NSArray *arr = temp[0][@"data"];
                    self.roomName  = arr[0][@"room_name"];
                    self.chatMessage  = arr[0][@"message"];
                    self.doctorId  = arr[0][@"docid"];
                    self.doctorName = arr[0][@"dispname"];
                    self.doctorPic = arr[0][@"room_name"];
                    
                }else if([temp[0][@"status"] integerValue]== -1){
                    dispatch_async(dispatch_get_main_queue(),^{
                        [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                        [self showAlert:temp[0][@"message"]];
                        
                    });
                }
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                    [self moveToChatHistoryController];
                });
            }
        }else {
            dispatch_async(dispatch_get_main_queue(),^{
                
                [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
                [self showAlert:@"Network not available"];
                
            });
           
        }
    }];
    [dataTask resume];
}
-(void)showAlert:(NSString *)message{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
    [controller addAction:okAction];
    [self presentViewController:controller animated:YES completion:nil];
    controller.view.tintColor = [UIColor blueColor];

}

#pragma mark -Tableview methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 70.0;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    ChatHistoryResponseModel *model = self.chatListArray[indexPath.row];
    [cell setCellData:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedChat = self.chatListArray[indexPath.row];
    self.doctorId = self.selectedChat.doctorId;
    self.roomName = self.selectedChat.roomId;
    self.doctorName = self.selectedChat.doctorName;
    self.doctorPic = self.selectedChat.doctorProfilePic;
    [self moveToChatHistoryController];
}
#pragma mark - Custom delegates for section id
-(void)sectionIdGenerated:(id)sender;
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.view.userInteractionEnabled = YES;
    NetworkChecking *networkAvailabilityCheck=[NetworkChecking new];
    if ([networkAvailabilityCheck reachable])
    {
        [self makeRequestForChatList];
    }
    else{
       [self showAlert:@"Network not available"];
        
    }
}

-(void)errorSectionId:(id)sender
{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.view.userInteractionEnabled = YES;
}
-(void)logoutTheSession{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];

    [self.navigationController popViewControllerAnimated:YES];
    
}
#pragma mark - Navigation
-(void)moveToChatHistoryController{
    
    [self performSegueWithIdentifier:@"chatConversationVC" sender:nil];
}
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"chatConversationVC"]) {
        ConversationViewController *controller = segue.destinationViewController;
        controller.doctorId = self.doctorId;
        controller.roomName = self.roomName;
        controller.chatMessage = self.chatMessage;
        controller.doctorName = self.doctorName;
        controller.doctorPic = self.doctorPic;
        controller.selectedChat = self.selectedChat;
        
    }
}



@end
