//
//  appConstants.h
//  smartRx
//
//  Created by Vishal Gupta on 24/04/13.
//  Copyright (c) 2013 Vishal Gupta. All rights reserved.
//

#ifndef smartRx_appConstants_h
#define smartRx_appConstants_h

#define UI_BLUECOLOR [UIColor colorWithRed:(49/255.0) green:(99/255.0) blue:(232/255.0) alpha:1.0]

#define APP_SCREEN_ANIMATION_STYLE  UIModalTransitionStyleFlipHorizontal


#define CUSTOM_HOSPINFO_TABLE_CELL   @"CUSTOM_HOSPINF_TABLE_CELL"
#define CUSTOM_HOSPINFO_SPEC_TABLE_CELL   @"CUSTOM_HOSPINF_SPEC_TABLE_CELL"
#define CUSTOM_TABLE_LIST_CELL          CUSTOM_HOSPINFO_TABLE_CELL


#define SUCCESS_ALERT_TAG               100

#define APP_DATA_STORAGE_MIN_WEEK_COUNT 1
#define APP_DATA_STORAGE_MAX_WEEK_COUNT 3
#define APP_TOTAL_FEATURES_COUNT        5
#define APP_DEFAULT_DATA_SETTINGS_WEEK  APP_DATA_STORAGE_MAX_WEEK_COUNT
#define APP_DEFAULT_PUSH_NOTIFICATION_STATUS 0//0 for OFF & 1 for OFF

#define APP_IS_REGISTERED                   @"IsAppRegistered"
#define APP_ISLOGGED_IN                     @"IsAppLoggedIn"
#define APP_SPLASH_IMAGE_PATH               @"AppSplashScreenPath"
#define APP_LOGO_IMAGE_PATH                 @"AppLogoImagePath"

#define UI_KEY_HOSP_SPEC_TITLE              @"hospInfoSpecTitle"
#define UI_KEY_HOSP_SPEC_ROW_SELECTED       @"hospInfoSpecRowSelected"

#define APP_KEY_CUSTOMER_ID                 @"appCustomerID"
#define APP_KEY_PATIENT_ID                  @"appPatientID"
#define APP_KEY_MOBILE_NO                   @"appMobileNo"
#define APP_KEY_PASSWORD                    @"appPassword"
#define APP_KEY_ISLOGGEDIN                  @"appLoggedIn"
#define APP_KEY_IS_PUSH_ON                  @"appIsPushEnabled"
#define APP_KEY_DATA_WEEK_MAX               @"appDataSettingsWeek"
#define APP_KEY_PROFILE_SYNCED              @"appProfileSynced"
#define APP_KEY_FEATURE_ENABLED             @"feaureEnabled"

#define APP_KEY_MSG_TYPE_NAME               @"MsgTypeName"
#define APP_KEY_MSG_TYPE_ICON               @"MsgTypeIcon"

#define APP_KEY_QA_TYPE_ICON                @"qaTypeIcon"


#define IPHONE5_HEIGHT                      568
#define IPHONE_NORMAL_HEIGHT                480

#define APP_FEATURE_NI                      @"Sorry ! this feature is not implemented in this release , please wait for the next release."
#define APP_FEATURE_ON_PROGRESS             @"Sorry ! this feature implementation is on progress, please wait for the next release."
#define APP_ACTIVITY_TEXT                   @"Please Wait.."
#define APP_ACTIVITY_REFRESH_TEXT           @"Please Wait..Refreshing"
#define APP_SESSION_EXPIRED_MSG             @"Sorry! Your session has expired. Please wait, we are refreshing your session"
#define APP_ACQUIRING_SESSION_MSG           @"Please wait, we are refreshing your session"


#define APP_DEFAULT_HEADER_TITLE            @"RK SmartCare"


#define DATABASE_FILE_NAME                  @"VVshPrasadnuVishnudjhhjhfdfdVshnuWitalicut"
//#define DATABASE_FILE_NAME                  @"smartRxDBClient"
#define DATABASE_FILE_EXTENSION             @"sqlite"

#define APP_SPLASH_IMAGE_X                  33
#define APP_SPLASH_IMAGE_Y                  157
#define APP_SPLASH_IMAGE_WIDTH              256.0
#define APP_SPLASH_IMAGE_HEIGHT             256.0

#define APP_DEFAULT_SPLASH_FILENAME         @"splash.jpg"
#define APP_DEFAULT_SPLASH_FILENAME_I5      @"splash-568h@2x.jpg"
#define APP_DEFAULT_LOGO_FILENAME           @"icon.png"
#define APP_DEFAULT_ATTACH_IMAGE            @"attach"
#define APP_DEFAULT_ATTACH_IMAGE_SEL        @"attachHL"
#define APP_DEFAULT_ATTACHED_VIDEO          @"VDattach"
#define APP_DEFAULT_ATTACHED_VIDEO_SEL      @"VDattachHL"

#define APP_STATUS_BAR_HEIGHT               20
#define APP_SCREEN_HEADER_HEIGHT            44
#define APP_SCREEN_HEADER_WIDTH             320
#define APP_SCREEN_TITLE_HEIGHT             40
#define APP_SCREEN_TITLE_WIDTH              320
#define APP_CONTENT_AREA_HEIGHT             464
#define APP_CONTENT_AREA_WIDTH              320
#define APP_TITLEBAR_X                      0
#define APP_TITLEBAR_Y                      APP_SCREEN_HEADER_HEIGHT

#define APP_HEADER_IMAGE_X                  10
#define APP_HEADER_IMAGE_Y                  07
#define APP_HEADER_IMAGE_WIDTH              30.0
#define APP_HEADER_IMAGE_HEIGHT             30.0
#define APP_HEADERBAR_HEIGHT                44
#define APP_TITLEBAR_HEIGHT                 40
#define APP_STATUSBAR_HEIGHT                20
#define APP_BOTTOMBAR_HEIGHT                48
#define APP_HEADER_X_PADDING                7.0

#define APP_HEADER_LABEL_X                  55
#define APP_HEADER_LABEL_Y                  10
#define APP_HEADER_LABEL_WIDTH              230.0
#define APP_HEADER_LABEL_HEIGHT             25.0



#define APP_ACTIVITY_INDICATOR_HEIGHT       50
#define APP_ACTIVITY_INDICATOR_WIDTH        50


#define APP_TABBAR_HEIGHT                   50
#define APP_TABBAR_WIDTH                    320

#define APP_DEVICE_SCREEN_HEIGHT            [UIScreen mainScreen].bounds.size.height
#define APP_DEVICE_SCREEN_WIDTH             [UIScreen mainScreen].bounds.size.width

#define APPDEL_CURRENT_VIEW_HEIGHT          [UIScreen mainScreen].bounds.size.height-APP_STATUS_BAR_HEIGHT
#define APPDEL_CURRENT_VIEW_WIDTH           view.frame.size.width

#define APP_SPLASH_SCREEN_DURATION          3.0
#define APP_ANIMATION_DURATION              0.4
#define APP_CURRENT_VIEW_HEIGHT             APPDEL_CURRENT_VIEW_HEIGHT
#define APP_CURRENT_VIEW_WIDTH              self.view.frame.size.width
#define APP_VIEW_INVALID_MAX_HEIGHT         1200
#define UI_GENDER_COUNT                     2
#define UI_GENDER_MALE                      @"Male"
#define UI_GENDER_FEMALE                    @"Female"
#define APP_DATE_DISPLAY_FORMAT             @"yyyy-MM-dd HH:mm:ss"
#define APP_DATE_SERVER_FORMAT              @"yyyy-MM-dd HH:mm:ss"
#define APP_DATE_DISPLAY_FORMAT_QA          @"dd-MMM-yyyy HH:mm:ss"
#define APP_QA_SERVER_FORMAT                APP_DATE_SERVER_FORMAT
#define APP_DATE_NEW_DISPLAY_FORMAT         @"dd MMM yyyy"
#define APP_DATE_DISPLAY_MSG_QA             @"dd-MMM"

#define APP_MOBILE_NUMBER_LENGTH            10

#define APP_ERROR()                         NSLog(@"Hey your logic failed / Server side is behaving differently...check out!")
#define SERVER_ERROR()                      NSLog(@"Hey.. your code is not able to understand what your server is saying !!")
#define SHOW_USER_ALERT(message,delega)     [self.appDelegate showUserAlert:message delegate:delega]
#define SHOW_USER_ALERT_TAG(message,delega,ta) [self.appDelegate showUserAlert:message delegate:delega tag:ta]
#define IS_INTERNET_AVAILABLE               [self.appDelegate IsInternetAvailable]
#define HIDE_KEYBOARD_IN_VIEW()             [self.appDelegate hideKeyboardInView:self.view]
#define GET_DATE_FORMAT(Date,dateFormat)    [self.appDelegate getDateText:Date format:dateFormat]
#define GET_DATE_FROM_STRING(dateStr,dateFormat) [self.appDelegate getDateFromString:dateStr format:dateFormat]
#define GET_DATE_FOR_PAGE(date,pageTitle)   [self.appDelegate getDateForPage:date pageType:pageTitle]
#define GET_DATESTRING_FORPAGE(date,pageTitle) [self.appDelegate getDateStringForPage:date pageType:pageTitle]
#define VALIDATE_EMAIL_ADDRESS(email)       [self.appDelegate validateEmailWithString:email]
#define SHOW_ACTIVITY_VIEW(view)            [self.appDelegate showActivityView:view isShow:YES]
#define HIDE_ACTIVITY_VIEW(view)            [self.appDelegate showActivityView:view isShow:NO]

#define UI_BUTTON_HEIGHT                    25
#define UI_BUTTON_LABEL_SIZE                12
#define UI_PAGE_HEADER_TITLE_SIZE           18

#define UI_GENDER_PICKER_HEIGHT             216
#define UI_GENDER_PICKER_WIDTH              APP_CURRENT_VIEW_WIDTH
#define UI_GENDER_PICK_TOPBAR_HEIGHT        40
#define UI_GENDER_PICK_TOPBAR_WIDTH         UI_GENDER_PICKER_WIDTH
#define UI_GENDER_PICK_BAR_BUTTON_HEIGHT    30
#define UI_GENDER_PICK_BAR_BUTTON_WIDTH     50


#define UI_PICKER_HEIGHT                    216
#define UI_PICKER_WIDTH                     APP_CURRENT_VIEW_WIDTH
#define UI_PICK_TOPBAR_HEIGHT               40
#define UI_PICKER_TOPBAR_WIDTH              UI_PICKER_WIDTH
#define UI_PICKER_BAR_BUTTON_HEIGHT         30
#define UI_PICKER_BAR_BUTTON_WIDTH          50


#define UI_FORGOT_HEADER_IMAGE              @"BR_forgotPass"
#define UI_VALIDATE_HEADER_IMAGE            @"BR_validate"
#define DEFAULT_PROFILE_IMAGE               @"profilePic"
#define DEFAULT_PROFILE_IMAGE_SEL           @"profilePicHL"

#define APP_ALERT_DISMIS_TITLE              @"OK"
#define APP_ALERT_TITLE                     @"RK SmartCare"
#define APP_SERVER_RESPONSE_ERROR           @"Sorry ! Unable to process your request now, Please try again later."
#define APP_NO_NETWORK_ERROR                @"Sorry ! Unable to process your request now. Please check your internet connection or try again."
#define APP_UNEXPECTED_ERROR                @"Sorry ! Unable to process your request now. Please try again later."
#define CUST_CODE_EMPTY_MSG                 @"Please enter your customer code"
#define MOB_NUMBER_EMPTY_MSG                @"Please enter your mobile number"
#define MOB_NUMBER_INVALID_MSG              @"Please enter a 10 digit mobile number"
#define PATIENT_NAME_EMPTY_MSG              @"Please enter your name"
#define EMAIL_EMPTY_MSG                     @"Please enter your email address"
#define EMAIL_INVALID_MSG                   @"Please enter a valid email address"
#define PASSWORD_EMPTY_MSG                  @"Please enter your password"
#define T_C_INVALID_MSG                     @"Please check Terms and Conditions"

#define FORGOT_PASSWORD_SUCCESS_MSG         @"Your password reset is done"
#define FORGOT_PASSWORD_FAILURE_MSG         @"Error in initiating the password reset ! Please try again later"
#define REGISTER_INVALID_PATIENT_MSG        @"Patient details not found"
#define REGSITER_DUPLICATE_PATIENT_MSG      @"This mobile is already registered. Please use forgot password to reset your password"
#define REGISTER_EMPTY_MOBILE_MSG           @"Mobile number cannot be empty"
#define REGISTER_INVALID_MOBILE_MSG         @"Mobile number is not valid"
#define REGISTER_INVALID_NAME_MSG           @"Patient name is not valid"
#define REGISTER_SUCCESS_MSG                @"Your registration is completed and login password has sent to your mobile number."

#define LOGIN_FAILURE_MSG                   @"Invalid mobile or password.Please try again"
#define LOGIN_FAILURE_INACTIVE_MSG          @"Your account is not authorized now. Please try again later."

#define FORGOT_SUCCESS_MSG                  @"Your password reset is completed and your password has sent to your mobile number."
#define FORGOT_FAILUTE_MSG                  @"We are unable to process your password reset request.Please trty again later."

#define PROFILE_NO_CAMERA_MSG               @"Sorry! Unable to open your camera, please try again later."

#define PROFILE_NO_GALLERY_MSG              @"Sorry! Unable to open your gallery, please try again later."
#define EDIT_PROFILE_SUCCESS                @"Your profile successfully updated"
#define EDIT_PROFILE_SUCCESS_WO_IMAGE       @"Your profile successfully updated without your profile image, please try again for profile image"
#define EDIT_PROFILE_MOBILE_EDIT_WARNING_MSG @"Sorry ! Editing the mobile number is not allowed. Please contact the hospital."

#define FEED_TITLE_EMPTY_MSG                @"Please enter the title"
#define FEED_COMPLAINT_EMPTY_MSG            @"Complaint/Feedback should not be empty"


#define FEED_SUCCESS_MSG                    @"Feedback posted successfully."
#define FEED_SUCCESS_WITHOUT_ATTACH_MSG     @"Feedback posted, but there is some problem sending your attachements. Please try again later."
#define POSTOP_NO_TEMPLATE_AVAILABLE_MSG    @"No post operative care templates are available, please try later"
#define POSTOP_NO_CONTENTS_AVAILABLE_MSG    @"No contents are available, please try later"


#define DOCTOR_REQUEST_FAILED_MSG           @"Sorry!Failed to fetch doctor details, please try again later"
#define ADD_QA_SUBJECT_EMPTY_MSG            @"Please enter your question's subject"
#define ADD_QA_QUESTION_EMPTY_MSG           @"Please enter your question."
#define ADD_QA_DOCTOR_LIST_EMPTY            @"Please select a doctor to continue"

#define ADD_QA_SUCCESS_WTHOUT_FILEUPLOAD_MSG @"Your Question sent to doctor successfylly"
#define ADD_QA_SUCCESS_MSG                 @"Your question is sent. You will be notified once it’s answered"
#define QA_CREDIT_ERROR                     @"No credits available, please contact hospital front desk"

#define POST_QA_REPLY_QUESTION_EMPTY_MSG           @"Please enter your reply."
#define POST_QA_REPLY_SUCCESS_WTHOUT_FILEUPLOAD_MSG @"Reply is posted successfylly without file upload"
#define POST_QA_REPLY_SUCCESS_MSG                 @"Reply is posted succesfully"
#define POST_QA_REPLY_ALREADY_CLOSED_MSG          @"Question has already marked completed!"

#define BOOK_APT_LOCATION_EMPTY_MSG             @"No locations are available, please try again"
#define BOOK_APT_DOCTORS_EMPTY_MSG              @"No doctors are available, please try again"
#define BOOK_APT_SPECIALITY_EMPTY_MSG                @"No specialities are available for the selected location, please try for some other location"
#define BOOK_APT_SPECIALITY_ERROR_MSG                @"Error is fetching the specialities, please try again"
#define BOOK_APT_SLOTS_EMPTY_MSG                @"No slots are available for the selected date, please try for some other date"
#define BOOK_APT_DATE_EMPTY_MSG                 @"Please select a booking date"
#define BOOK_APT_LOCATION_ERROR_MSG             @"Error in fetching the location, please try again later"
#define BOOK_APT_DOCTORS_ERROR_MSG              @"Error in fetching doctor list, please try again later"
#define BOOK_APT_SLOTS_ERROR_MSG                @"Error in fetching doctor slots, please try again later"

#define BOOK_APT_SELECT_LOACTION                @"Please select the location"
#define BOOK_APT_SELECT_SPECIALITY              @"Please select the speciality"
#define BOOK_APT_SELECT_DOCTOR                  @"Please select the doctor"
#define BOOK_APT_SELECT_TIMESLOTS               @"Please select the time slot"
#define BOOK_APT_ENTER_REASON                   @"Please enter the reason"

#define BOOK_APT_SUCCESS                        @"Your appointment has been created.You will receive confirmation soon"
#define BOOK_APT_FAILURE                        @"Requested appointment is not available. Please try with another try slots"

#define APT_FEAURE_NOT_ENABLED_MESSAGE                  @"Appointments are not available for you. Please contact the hospital"
#define QA_FEAURE_NOT_ENABLED_MESSAGE                   @"Q&A are not available for you. Please contact the hospital"
#define APT_NOT_AVAILABLE_MESSAGE                       @"No appointments to show. Click “+” icon to book new appointment. Click refresh for more accurate results"
#define QA_NOT_AVAILABLE_MESSAGE                        @"No questions are available.Click “+” icon to ask new question to doctor.Click refresh button to get more accurate results."
#define APP_TURN_ON_INTERNET_MSG                     @"Please turn on your internet connectivity and try again"

#define PROFILE_IMAGE_SELECTED_WRONG_FORMAT_MSG     @"You selected an invalid image, Please select/capture an image"

#define FORGOT_PASS_BUTTON_TEXT             @"RESET"
#define VALIDATE_BUTTON_TEXT                @"VALIDATE"


#define UI_PROFILE_SCROLLVIEW_CONTENT_HEIGHT    580.0f





#define UI_HOSP_INFO_SERVICES_TITLE         @"Services"
#define UI_HOSP_INFO_SPECIALITY_TITLE       @"Specialities"
#define UI_HOSP_INFO_CONTACT_TITLE          @"Contact Us"

#define UI_HOSP_INFO_SERVICES_IMAGE         @"services-circle"
#define UI_HOSP_INFO_SPECIALITY_IMAGE       @"specialities-circle"
#define UI_HOSP_INFO_CONTACT_IMAGE          @"contact-us-circle"

#define HOSP_INFO_TABLE_CELL_HEIGHT         50.0f


//DEscribes the order of items in the hospital Info table view
typedef enum HOSPINFO_TABLE_ROW
{
    HOSPINFO_TABLE_ROW_SERVICES=0,
    HOSPINFO_TABLE_ROW_SPECIALITY=1,
    HOSPINFO_TABLE_ROW_CONTACT=2
}HOSPINFO_TABLE_ROW;

//Describes the different pickerTypes currently active in the view
typedef enum UI_PICKER_TYPE
{
    UI_PICKER_TYPE_UNKNOWN,
    UI_PICKER_TYPE_GENDER,
    UI_PICKER_TYPE_DATA_SETTINGS,
    UI_PICKER_TYPE_DOB
}UI_PICKER_TYPE;

//Describes the different pages in the application
typedef enum UI_PAGE_TYPE {
    UI_PAGE_TYPE_UNKNOWN,
    UI_PAGE_TYPE_LOGIN,
    UI_PAGE_TYPE_REGISTER,
    UI_PAGE_TYPE_FORGOT_PASSWORD,
    UI_PAGE_TYPE_VALIDATE_USER,
    UI_PAGE_TYPE_HOME,
    UI_PAGE_TYPE_APPOINTMENT,
    UI_PAGE_TYPE_BOOK_APPOINTMENT,
    UI_PAGE_TYPE_UPDATE_APPOINTMENT,
    UI_PAGE_TYPE_MESSAGE,
    UI_PAGE_TYPE_MESSAGE_DETAILS,
    UI_PAGE_TYPE_PROFILE_SETTINGS,
    UI_PAGE_TYPE_REHAB_SUPPORT,
    UI_PAGE_TYPE_REHAB_TEMPLATE,
    UI_PAGE_TYPE_REHAB_INFO,
    UI_PAGE_TYPE_QA,
    UI_PAGE_TYPE_QA_POST_REPLY,
    UI_PAGE_TYPE_ASK_QUESTION,
    UI_PAGE_TYPE_QUESTION_DETAILS,
    UI_PAGE_TYPE_FEEDBACK,
    UI_PAGE_TYPE_SPLASH,
    UI_PAGE_TYPE_HOSP_INFO,
    UI_PAGE_TYPE_HOSP_INFO_SERVICES,
    UI_PAGE_TYPE_HOSP_INFO_SPECIALITY,
    UI_PAGE_TYPE_HOSP_INFO_SPECIALITY_CONTENTS,
    UI_PAGE_TYPE_HOSP_INFO_CONTACT,
    
}UI_PAGE_TYPE;
//Describes the different web service requests in the application
typedef enum UI_REQUEST_TYPE
{
    UI_REQUEST_TYPE_VALIDATE_USER,
    UI_REQUEST_TYPE_VALIDATE_LOGIN,
    UI_REQUEST_TYPE_FORGOT_PASSWORD,
    UI_REQUEST_TYPE_REGISTRATION
    
}UI_REQUEST_TYPE;
//Describes the features available in the Application for particular user
typedef enum APP_FEAURES_NAME
{
    APP_FEATURE_NAMES_APPOINTMENTS,
    APP_FEATURE_NAMES_QA,
    APP_FEATURE_NAMES_FEEDBACK,
    APP_FEATURE_NAMES_E_CONSULT,
    APP_FEATURE_NAMES_LOYALITY_PROGRAM,
    APP_FEATURE_NAMES_MESSAGE,
    APP_FEATURE_NAMES_REHAB_SUPPORT,
    APP_FEATURE_NAMES_HOSP_INFO
    
}APP_FEATURE_NAMES;

//DEscribes the different types of messages
typedef enum APP_MSG_TYPE
{
    APP_MSG_TYPE_UNKNOWN=0,
    APP_MSG_TYPE_CARE_TEMPLATES=1,
    APP_MSG_TYPE_PROMOTIONS=2,
    APP_MSG_TYPE_COMMUNICATION=3,
    APP_MSG_TYPE_APPOINTMENT=4,
    APP_MSG_TYPE_QA_ALERT=5,
    APP_MSG_TYPE_FEEDBACK=6
    
}APP_MSG_TYPE;
//Describe different types of QA entries
typedef enum APP_QA_TYPE
{
    APP_QA_TYPE_UNKNOWN =0,
    APP_QA_TYPE_QUESTION=1,
    APP_QA_TYPE_FEEDBACK=2
}APP_QA_TYPE;

//Describes which media has selected through mediaPickerController
typedef enum APP_MEDIA_TYPE
{
    APP_MEDIA_TYPE_NONE,
    APP_MEDIA_TYPE_IMAGE,
    APP_MEDIA_TYPE_VIDEO
}APP_MEDIA_TYPE;
#endif
