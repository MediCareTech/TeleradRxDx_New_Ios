//
//  SmartRxQuestionDetailsVC.h
//  SmartRx
//
//  Created by PaceWisdom on 04/06/14.
//  Copyright (c) 2014 pacewisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartRxQuestionDetailsVC : UIViewController<MBProgressHUDDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary * dicSerialized;
@property (strong, nonatomic) NSArray *arrRecordId;
@property (strong, nonatomic) NSArray * questionImages;
@property (nonatomic, strong) NSString *pdfPath;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (strong, nonatomic) NSDictionary *dictQuestionDetails;
@property (weak, nonatomic) IBOutlet UIButton *btnPostDetails;
@property (weak, nonatomic) IBOutlet UIImageView *imgDivider;
@property (strong, nonatomic) NSArray *arrQuestions;
@property (strong, nonatomic) NSArray *arrAnswers;
@property (strong, nonatomic) NSDictionary *dictQuestionsMaster;
@property (weak, nonatomic) IBOutlet UITableView *tblQusAns;
@property (strong, nonatomic) NSString *strQuesDate;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *lblHspSays;
@property (weak, nonatomic) IBOutlet UILabel *lblDocReplyTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDocReply;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwDoctorReply;
@property (strong, nonatomic) UILabel *questIsAnswered;

@property (weak, nonatomic) IBOutlet UILabel *lblPatientName;
@property (weak, nonatomic) IBOutlet UILabel *lblPatientReplyTime;
@property (weak, nonatomic) IBOutlet UILabel *lblPatientReply;
@property (weak, nonatomic) IBOutlet UIImageView *imgViwReplyDivider;

@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;

@property (weak, nonatomic) IBOutlet UIView *footerButtonView;

- (IBAction)postDetailsBtnClicked:(id)sender;
@end
