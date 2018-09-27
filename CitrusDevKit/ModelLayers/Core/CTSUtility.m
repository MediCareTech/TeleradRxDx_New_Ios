//
//  CTSUtility.m
//  RestFulltester
//
//  Created by Yadnesh Wankhede on 17/06/14.
//  Copyright (c) 2014 Citrus. All rights reserved.
//

#import "CTSUtility.h"
#import "CreditCard-Validator.h"
#import "CTSError.h"
#import "CTSRestError.h"
#import "NSObject+logProperties.h"

#define ALPHABETICS @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
#define NUMERICS @"0123456789"

#import "CTSAuthLayerConstants.h"
#define amex @[ @"34", @"37" ]
#define discover @[ @"60", @"62", @"64", @"65" ]
#define JCB @[ @"35" ]
#define DinerClub @[ @"30", @"36", @"38", @"39" ]
#define VISA @[ @"4" ]
#define MAESTRO \
@[            \
@"67",      \
@"56",      \
@"502260",  \
@"504433",  \
@"504434",  \
@"504435",  \
@"504437",  \
@"504645",  \
@"504681",  \
@"504753",  \
@"504775",  \
@"504809",  \
@"504817",  \
@"504834",  \
@"504848",  \
@"504884",  \
@"504973",  \
@"504993",  \
@"508125",  \
@"508126",  \
@"508159",  \
@"508192",  \
@"508227",  \
@"600206",  \
@"603123",  \
@"603741",  \
@"603845",  \
@"622018"   \
]
#define MASTER @[ @"5" ]
#define RUPAY @[ @"607", @"5085", @"5086" ,@"5087", @"5088" , @"6069", @"6081", @"6521", @"6522", @"6524" ]

//5085 5086 5087 5088 6069 607 6081 6521 6522 6524

#define UNKNOWN_CARD_TYPE @"UNKNOWN"

@implementation CTSUtility
+ (BOOL)validateCardNumber:(NSString*)number {
        return [CreditCard_Validator checkCreditCardNumber:number];
}

+ (NSString*)readFromDisk:(NSString*)key {
    LogTrace(@"Key %@ value %@",
             key,
             [[NSUserDefaults standardUserDefaults] valueForKey:key]);
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

+ (void)saveToDisk:(id)data as:(NSString*)key {
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeFromDisk:(NSString*)key {
    LogTrace(@"removing key %@", key);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary*)readSigninTokenAsHeader {
    return @{
             @"Authorization" : [NSString
                                 stringWithFormat:@" Bearer %@",
                                 [CTSUtility
                                  readFromDisk:MLC_SIGNIN_ACCESS_OAUTH_TOKEN]]
             };
}

+ (NSDictionary*)readOauthTokenAsHeader:(NSString*)oauthToken {
    return @{
             @"Authorization" : [self readAsBearer:oauthToken]
             };
}

+(NSString *)readAsBearer:(NSString *)oauthToken{
    return [NSString stringWithFormat:@"Bearer %@", oauthToken];


}
+ (NSDictionary*)readSignupTokenAsHeader {
    return @{
             @"Authorization" : [NSString
                                 stringWithFormat:@" Bearer %@",
                                 [CTSUtility
                                  readFromDisk:MLC_SIGNUP_ACCESS_OAUTH_TOKEN]]
             };
}

//+ (BOOL)validateEmail:(NSString*)candidate {
//  NSString* emailRegex =
//      @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
//      @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
//      @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
//      @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
//      @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
//      @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
//      @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
//  NSPredicate* emailTest =
//      [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
//
//  return [emailTest evaluateWithObject:candidate];
//}

+ (BOOL)validateEmail:(NSString*)candidate {
    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate* emailTest =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

//+ (BOOL)validateMobile:(NSString*)mobile {
//    BOOL error = NO;
//    if ([mobile length] == 10) {
//        error = YES;
//    }
//    return error;
//}

+ (BOOL)validateCVV:(NSString*)cvv cardNumber:(NSString*)cardNumber {
    if (cvv == nil)
        return YES;
    BOOL error = NO;
    if ([CreditCard_Validator checkCardBrandWithNumber:cardNumber] ==
        CreditCardBrandAmex) {
        if ([cvv length] == 4) {
            error = YES;
        }
    } else {
        if ([cvv length] == 3) {
            error = YES;
        }
    }
    return error;
}

+ (BOOL)validateExpiryDate:(NSString*)date {
    NSArray* subStrings = [date componentsSeparatedByString:@"/"];
    if ([subStrings count] < 2) {
        return NO;
    }
   //yy string
   if([[subStrings objectAtIndex:1] length] != 4){
        return NO;
    }
    //mm string
    if([[subStrings objectAtIndex:0] length] > 2 || [[subStrings objectAtIndex:0] length] < 1){
        return NO;
    }
    
    int month = [[subStrings objectAtIndex:0] intValue];
    int year = [[subStrings objectAtIndex:1] intValue];
   // NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  NSDateComponents * components =  [gregorianCalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    
    //year passed
    if(year < [components year]){
        return NO;
    }
    
    //same year, month passed
    if(year == [components year] && month < [components month]){
        return NO;
    }
    
    //invalid month
    if(month > 12 || month <1){
    
        return NO;
    }
    
    //invalid year/upper limit year
    if(year > 2099){
        return NO;
    }
    
    return YES;
 


   
        

        
    //return [self validateExpiryDateMonth:month year:year];
}

+ (BOOL)validateExpiryDateMonth:(int)month year:(int)year {
    int expiryYear = year;
    int expiryMonth = month;
    if (![self validateExpiryMonth:month year:year]) {
        return FALSE;
    }
    if (![self validateExpiryYear:year]) {
        return FALSE;
    }
    return [self hasMonthPassedYear:expiryYear month:expiryMonth];
}

+ (BOOL)validateExpiryMonth:(int)month year:(int)year {
    int expiryYear = year;
    int expiryMonth = month;
    if (expiryMonth == 0) {
        return FALSE;
    }
    return (expiryYear >= 1 && expiryMonth <= 12);
}

+(NSString*)correctExpiryDate:(NSString *)date{
    NSArray* subStrings = [date componentsSeparatedByString:@"/"];
    if ([subStrings count] < 2) {
        return date;
    }
    NSString *newDate = nil;
    if([[subStrings objectAtIndex:1] length] == 2 ){
        newDate = [NSString stringWithFormat:@"%@/20%@",[subStrings objectAtIndex:0],[subStrings objectAtIndex:1]];
    }else if([[subStrings objectAtIndex:1] length] == 4){
        return date;
    }
    return newDate;
}


+ (BOOL)validateExpiryYear:(int)year {
    int expiryYear = year;
    if (expiryYear == 0) {
        return FALSE;
    }
    return [self hasYearPassed:expiryYear];
    // return FALSE;
}
+ (BOOL)hasYearPassed:(int)year {
    int normalized = [self normalizeYear:year];
    NSCalendar* gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components =
    [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    int currentyear = (int)[components year];
    return normalized >= currentyear;
}

+ (BOOL)hasMonthPassedYear:(int)year month:(int)month {
    NSCalendar* gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* components =
    [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSDateComponents* monthcomponent =
    [gregorian components:NSCalendarUnitMonth fromDate:[NSDate date]];
    int currentYear = (int)[components year];
    int currentmonth = (int)[monthcomponent month];
    int normalizeyear = [self normalizeYear:year];
    // Expires at end of specified month, Calendar month starts at 0
    return [self hasYearPassed:year] ||
    (normalizeyear == currentYear && month < (currentmonth + 1));
}
+ (int)normalizeYear:(int)year {
    if (year < 100 && year >= 0) {
        NSCalendar* gregorian =
        [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents* components =
        [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
        NSInteger yearr = [components year];
        NSString* currentYear = [NSString stringWithFormat:@"%d", (int)yearr];
        
        NSString* prefix =
        [currentYear substringWithRange:NSMakeRange(0, currentYear.length - 2)];
        
        // year = Integer.parseInt(String.format(Locale.US, "%s%02d", prefix,
        // year));
        year = [[NSString stringWithFormat:@"%@%02d", prefix, year] intValue];
    }
    return year;
}

+ (BOOL)toBool:(NSString*)boolString {
    if ([boolString isEqualToString:@"false"])
        return NO;
    else
        return YES;
}

+ (NSString*)fetchCardSchemeForCardNumber:(NSString*)cardNumber {
    
    if ([CTSUtility hasPrefixArray:MAESTRO cardNumber:cardNumber]) {
        return @"MTRO";
    }
    else if ([CTSUtility hasPrefixArray:amex cardNumber:cardNumber]) {
        return @"AMEX";
    }
    else if ([CTSUtility hasPrefixArray:RUPAY cardNumber:cardNumber]) {
        return @"RPAY";
    }
    else if ([CTSUtility hasPrefixArray:discover cardNumber:cardNumber]) {
        return @"DISCOVER";
    }
    else if ([CTSUtility hasPrefixArray:JCB cardNumber:cardNumber]) {
        return @"JCB";
    }
    else if ([CTSUtility hasPrefixArray:DinerClub cardNumber:cardNumber]) {
        return @"DINERS";
    }
    else if ([CTSUtility hasPrefixArray:VISA cardNumber:cardNumber]) {
        return @"VISA";
    }
    else if ([CTSUtility hasPrefixArray:MASTER cardNumber:cardNumber]) {
        return @"MCRD";
    }
    
    return UNKNOWN_CARD_TYPE;
    
}

//Vikas
+ (NSMutableArray*)fetchMappedCardSchemeForSaveCards:(NSArray*)cardsSchemeArray {
    
    NSMutableArray *schemeArray = [[NSMutableArray alloc]init];
    
    for (NSString *scheme in cardsSchemeArray) {
        
        if ([scheme isEqualToString:@"Visa"]) {
            [schemeArray addObject:@"VISA"];
        }
        else if ([scheme isEqualToString:@"Maestro Card"]) {
            [schemeArray addObject:@"MTRO"];
        }
        else if ([scheme isEqualToString:@"Master Card"]) {
            [schemeArray addObject:@"MCRD"];
        }
        else if ([scheme isEqualToString:@"Amex"]) {
            [schemeArray addObject:@"AMEX"];
        }
        else if ([scheme isEqualToString:@"Diners"]) {
            [schemeArray addObject:@"DINERCLUB"];
        }
        else if ([scheme isEqualToString:@"discover"]) {
            [schemeArray addObject:@"DISCOVER"];
        }
        else if ([scheme isEqualToString:@"RuPay"]) {
            [schemeArray addObject:@"RPAY"];
        }
    }
    return schemeArray;
}

+ (UIImage *)fetchSchemeImageBySchemeType:(NSString *)scheme{
    return [UIImage imageNamed:[[[CTSDataCache sharedCache] fetchCachedDataForKey:SCHEME_LOGO_KEY]valueForKey:scheme]];
}

+ (UIImage *)fetchBankLogoImageByBankIssuerCode:(NSString *)bankIssuerCode{
    return [UIImage imageNamed:[[[CTSDataCache sharedCache] fetchCachedDataForKey:BANK_LOGO_KEY] valueForKey:bankIssuerCode]];
}

+ (UIImage *)fetchBankLogoImageByBankName:(NSString *)bankName{
    
    UIImage *bankImage = [UIImage imageNamed:[[[CTSDataCache sharedCache] fetchCachedDataForKey:BANK_LOGO_WITH_BANK_NAME_KEY] valueForKey:bankName]];
    if (bankImage) {
        return bankImage;
    }
    else{
        UIImage *bankImage =[UIImage imageNamed:[[NSBundle mainBundle] pathForResource: @"default_bank" ofType: @"png"]];
        return bankImage;
    }
}

+(NSString *)fetchBankCodeForName:(NSString *)nameOfBank{
    NSArray *bankCodes = [[[CTSDataCache sharedCache] fetchCachedDataForKey:BANK_LOGO_KEY] allKeysForObject:nameOfBank];
    if([bankCodes count] > 1 || [bankCodes count] == 0){
        return nil;
    }
    else{
        return [bankCodes objectAtIndex:0];
    }
}

+(BOOL)isMaestero:(NSString *)number{
    if([[CTSUtility fetchCardSchemeForCardNumber:number] isEqualToString:@"MTRO"]){
        return YES;
    }
    return NO;
}

+(BOOL)isAmex:(NSString *)number{
    if([[CTSUtility fetchCardSchemeForCardNumber:number] isEqualToString:@"AMEX"]){
        return YES;
    }
    return NO;
}

//Vikas
+ (UIImage*)getSchmeTypeImage:(NSString*)cardNumber {
    // Card scheme validation
    if (cardNumber.length == 0){
        return nil;
    }
    else {
        
        NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:cardNumber];
        return [CTSUtility fetchSchemeImageBySchemeType:scheme];
        
        /*
        if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
            return [UIImage imageNamed:@"amex.png"];
        } else if ([scheme caseInsensitiveCompare:@"discover"] == NSOrderedSame) {
            return [UIImage imageNamed:@"discover.png"];
        } else if ([scheme caseInsensitiveCompare:@"mtro"] == NSOrderedSame) {
            return [UIImage imageNamed:@"mtro.png"];
        } else if ([scheme caseInsensitiveCompare:@"mcrd"] == NSOrderedSame) {
            return [UIImage imageNamed:@"mcrd.png"];
        } else if ([scheme caseInsensitiveCompare:@"rupay"] == NSOrderedSame) {
            return [UIImage imageNamed:@"rupay.png"];
        } else if ([scheme caseInsensitiveCompare:@"visa"] == NSOrderedSame) {
            return [UIImage imageNamed:@"visa.png"];
        } else if ([scheme caseInsensitiveCompare:@"jcb"] == NSOrderedSame) {
            return [UIImage imageNamed:@"jcb.png"];
        } else if ([scheme caseInsensitiveCompare:@"dinerclub"] == NSOrderedSame) {
            return [UIImage imageNamed:@"dinerclub.png"];
        }
         */
        
    }
    return nil;
}

+ (BOOL)hasPrefixArray:(NSArray*)array cardNumber:(NSString*)cardNumber {
    for (int i = 0; i < [array count]; i++) {
        if ([cardNumber hasPrefix:[array objectAtIndex:i]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary*)getResponseIfTransactionIsFinished:(NSData*)postData {
    // contains the HTTP body as in an HTTP POST request.
    NSString* dataString =
    [[NSString alloc] initWithData:postData encoding:NSASCIIStringEncoding];
    LogTrace(@"dataString %@ ", dataString);
    
    NSMutableDictionary* responseDictionary = nil;
    if ([dataString rangeOfString:@"TxStatus" options:NSCaseInsensitiveSearch]
        .location != NSNotFound) {
        responseDictionary = [[NSMutableDictionary alloc] init];
        
        NSArray* separatedByAMP = [dataString componentsSeparatedByString:@"&"];
        LogTrace(@"separated by & %@", separatedByAMP);
        
        for (NSString* string in separatedByAMP) {
            NSArray* separatedByEQ = [string componentsSeparatedByString:@"="];
            LogTrace(@"separatedByEQ %@ ", separatedByEQ);
            
            [responseDictionary setObject:[separatedByEQ objectAtIndex:1]
                                   forKey:[separatedByEQ objectAtIndex:0]];
        }
        LogTrace(@" final dictionary %@ ", responseDictionary);
    }
    return responseDictionary;
}

+ (NSDictionary*)getResponseIfTransactionIsComplete:(UIWebView *)webview {
    // contains the HTTP body as in an HTTP POST request.
    NSString *iosResponse = [webview stringByEvaluatingJavaScriptFromString:@"postResponseiOS()"];
    LogTrace(@"iosResponse %@",iosResponse);
    if(iosResponse == nil ){
        return nil;
    }
    else{
        NSError *error;
        NSDictionary *dictionary =  [NSJSONSerialization JSONObjectWithData: [iosResponse dataUsingEncoding:NSUTF8StringEncoding]
                                                                           options: NSJSONReadingMutableContainers
                                                                             error: &error];
        LogTrace(@" dictionary %@ ",dictionary);
        LogTrace(@" error %@ ",error);
        return dictionary;
    }
}


+ (BOOL)appendHyphenForCardnumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet]
          characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 4 || range.location == 9 || range.location == 14)) {
        textField.text =
        [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 5 || range.location == 10 || range.location == 15)) {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:@""];
        return NO;
    }
    return YES;
}


+ (BOOL)appendHyphenForMobilenumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // Reject appending non-digit characters
    if (range.length == 0 &&
        ![[NSCharacterSet decimalDigitCharacterSet]
          characterIsMember:[string characterAtIndex:0]]) {
            return NO;
        }
    
    // Auto-add hyphen before appending 4rd or 7th digit
    if (range.length == 0 &&
        (range.location == 3 || range.location == 7)) {
        textField.text =
        [NSString stringWithFormat:@"%@-%@", textField.text, string];
        return NO;
    }
    
    // Delete hyphen when deleting its trailing digit
    if (range.length == 1 &&
        (range.location == 4 || range.location == 8)) {
        range.location--;
        range.length = 2;
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:@""];
        return NO;
    }
    return YES;
}


+ (BOOL)enterNumericOnly:(NSString*)string{
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:NUMERICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)enterCharecterOnly:(NSString*)string{
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:ALPHABETICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if (![myCharSet characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}


+ (BOOL)validateCVVNumber:(UITextField*)textField replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // CVV validation
    // if amex allow 4 digits, if non amex only 3 should allowed.
    NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:textField.text];
    NSInteger textfieldLength = textField.text.length - range.length + string.length;
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:NUMERICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
                if (textfieldLength > 4) {
                    return NO;
                } else {
                    return YES;
                }
            } else if ([scheme caseInsensitiveCompare:@"amex"] !=
                       NSOrderedSame) {
                if (textfieldLength > 3) {
                    return NO;
                } else {
                    return YES;
                }
            }
            
        } else {
            return NO;
        }
    }
    return YES;
}

+ (BOOL)validateCVVNumber:(UITextField*)textField cardNumber:(NSString*)cardNumber replacementString:(NSString*)string shouldChangeCharactersInRange:(NSRange)range{
    // CVV validation
    // if amex allow 4 digits, if non amex only 3 should allowed.
    NSString* scheme = [CTSUtility fetchCardSchemeForCardNumber:[cardNumber stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    NSInteger textfieldLength = textField.text.length - range.length + string.length;
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:NUMERICS];
    for (int i = 0; i < [string length]; i++) {
        unichar c = [string characterAtIndex:i];
        if ([myCharSet characterIsMember:c]) {
            if ([scheme caseInsensitiveCompare:@"amex"] == NSOrderedSame) {
                if (textfieldLength > 4) {
                    return NO;
                } else {
                    return YES;
                }
            } else if ([scheme caseInsensitiveCompare:@"amex"] !=
                       NSOrderedSame) {
                if (textfieldLength > 3) {
                    return NO;
                } else {
                    return YES;
                }
            }
            
        } else {
            return NO;
        }
    }
    return YES;
}


+ (NSString*)createTXNId {
    NSString* transactionId;
    long long CurrentTime =
    (long long)([[NSDate date] timeIntervalSince1970] * 1000);
    transactionId = [NSString stringWithFormat:@"CTS%lld", CurrentTime];
    return transactionId;
}

+(BOOL)validateBill:(CTSBill *)bill{
    if(bill == nil){
        return NO;
    }
    if([CTSUtility validateAmountString:bill.amount.value]== NO){
        return NO;
    }
    if(bill.requestSignature == nil){
        return NO;
    
    }
    if(bill.merchantAccessKey == nil){
        return NO;
    }
    if (bill.returnUrl == nil) {
        return NO;
    }
    return YES;
}

+(BOOL)string:(NSString *)source containsString:(NSString*)desti{
    if ([source rangeOfString:desti options:NSCaseInsensitiveSearch].location != NSNotFound){
        return YES;
    }
    return NO;

}

+(NSArray *)getLoadResponseIfSuccesfull:(NSURLRequest *)request{
    
    NSURL* URL = [request URL];
    NSString* fragmentString = URL.fragment;
    NSArray* response = [fragmentString componentsSeparatedByString:@":"];
    return response;
}

+(BOOL)isVerifyPage:(NSString *)urlString{
    BOOL isVerifyPage = NO;
    if( [self string:urlString containsString:@"prepaid/pg/verify/"] ){
        LogTrace(@"not logged in");
        isVerifyPage = YES;
    }
    return isVerifyPage;
}

+(void)deleteSigninCookie{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain rangeOfString:@"citrus" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            [storage deleteCookie:cookie];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(NSHTTPCookie *)getCitrusCookie{
    NSHTTPCookie *userCookie = nil;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) {
        if ([cookie.domain rangeOfString:@"citrus" options:NSCaseInsensitiveSearch].location != NSNotFound && cookie.expiresDate != nil) {
            userCookie = cookie;
        }
    }
    return userCookie;
}


+(BOOL)isUserCookieValid{
    return ![self hasUserCookieExpired];
}

//+(BOOL)hasUserCookieExpired{
//   BOOL hasUserCookieExpired = NO;
//    
//    NSHTTPCookie *userCookie = [self getCitrusCookie];
//    if(userCookie==nil){
//        LogTrace(@"Citrus Cookie Not Found");
//        return YES;
//    }
//
//    if ([userCookie.expiresDate compare:[NSDate date]] == NSOrderedDescending) {
//        LogTrace(@"Citrus Cookie Expiry Date Not Passed");
//        hasUserCookieExpired = NO;
//    } else if ([userCookie.expiresDate compare:[NSDate date]] == NSOrderedAscending) {
//        LogTrace(@"Citrus Cookie Expiry Date Passed");
//        hasUserCookieExpired = YES;
//    } else {
//        LogTrace(@"Citrus Cookie Expiry Same As Today");
//        hasUserCookieExpired = YES;
//    }
//    return hasUserCookieExpired;
//}



+(BOOL)hasUserCookieExpired{
    BOOL hasUserCookieExpired = NO;
    
    NSHTTPCookie *userCookie = [self getCitrusCookie];
    if(userCookie==nil){
        LogTrace(@"Citrus Cookie Not Found");
        return YES;
    }
    
    NSLog(@"Citrus Cookie Found %@",userCookie);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    
    NSLog(@"Cookie Expiry Date is %@",[formatter stringFromDate:userCookie.expiresDate]);
    
    NSLog(@"Today's Date %@",[formatter stringFromDate:[NSDate date]]);
    
    if ([userCookie.expiresDate compare:[NSDate date]] == NSOrderedDescending) {
        LogTrace(@"Citrus Cookie Expiry Date Not Passed");
        hasUserCookieExpired = NO;
    } else if ([userCookie.expiresDate compare:[NSDate date]] == NSOrderedAscending) {
        LogTrace(@"Citrus Cookie Expiry Date Passed");
        hasUserCookieExpired = YES;
    } else {
        LogTrace(@"Citrus Cookie Expiry Same As Today");
        hasUserCookieExpired = NO;
    }
    return hasUserCookieExpired;
}




+(BOOL)isCookieSetAlready{
    BOOL isSet = NO;
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        // LogTrace(@"Cookie doamin %@", cookie.domain);
        if ([cookie.domain rangeOfString:@"citrus" options:NSCaseInsensitiveSearch].location != NSNotFound) {
            // LogTrace(@"string does not contain citrus");
            isSet = YES;
            break;
        }
    }
    return isSet;
}

+(NSString *)toStringBool:(BOOL)paramBool{
    if(paramBool){
        return @"true";
    }
    else{
        return @"false";
    }
}

+(BOOL)convertToBool:(NSString *)boolStr{
    if([boolStr caseInsensitiveCompare:@"true"]== NSOrderedSame){
        return YES;
    }
    else{
        return NO;
    }
}

+(BOOL)isEmail:(NSString *)string{
    if([string rangeOfString:@"@"].location != NSNotFound){
        return YES;
    }
    else{
        return NO;
    }
    
}

+(NSDictionary *)errorResponseIfReturnUrlDidntRespond:(NSString *)returnUrl webViewUrl:(NSString *)webviewUrl currentResponse:(NSDictionary *)responseDict{
    if( [CTSUtility isURL:[NSURL URLWithString:returnUrl] toUrl:[NSURL URLWithString:webviewUrl]]){
        LogTrace(@"final Return URL completed loading found");
        if(responseDict == nil){
            NSError *error = [CTSError getErrorForCode:ReturnUrlCallbackNotValid];
            responseDict = [NSDictionary dictionaryWithObject:error forKey:CITRUS_ERROR_DOMAIN];
        }
    }
    return responseDict;
    
}





+(BOOL)isURL:(NSURL *)aURL toUrl:(NSURL *)bUrl{

    if ([bUrl isEqual:aURL]) return YES;
    if ([[bUrl scheme] caseInsensitiveCompare:[aURL scheme]] != NSOrderedSame) return NO;
    if ([[bUrl host] caseInsensitiveCompare:[aURL host]] != NSOrderedSame) return NO;
    
    // NSURL path is smart about trimming trailing slashes
    // note case-sensitivty here
    if ([[bUrl path] compare:[aURL path]] != NSOrderedSame) return NO;
    
    // at this point, we've established that the urls are equivalent according to the rfc
    // insofar as scheme, host, and paths match
    
    // according to rfc2616, port's can weakly match if one is missing and the
    // other is default for the scheme, but for now, let's insist on an explicit match
    if ([[bUrl port] compare:[aURL port]] != NSOrderedSame) return NO;
    
    if ([[bUrl query] compare:[aURL query]] != NSOrderedSame) return NO;
    
    // for things like user/pw, fragment, etc., seems sensible to be
    // permissive about these.  (plus, I'm tired :-))
    return YES;



}


+(NSDictionary *)errorResponseTransactionForcedClosedByUser{
    NSError *error = [CTSError getErrorForCode:TransactionForcedClosed];
    NSDictionary * responseDict = [NSDictionary dictionaryWithObject:error forKey:CITRUS_ERROR_DOMAIN];
    return responseDict;
}

+(NSDictionary *)errorResponseTransactionFailed{
    NSError *error = [CTSError getErrorForCode:TransactionFailed];
    NSDictionary * responseDict = [NSDictionary dictionaryWithObject:error forKey:CITRUS_ERROR_DOMAIN];
    return responseDict;
}


+(NSDictionary *)errorResponseDeviceOffline:(NSError *)error{
    NSDictionary * responseDict = [NSDictionary dictionaryWithObject:error forKey:CITRUS_ERROR_DOMAIN];
    return responseDict;
}


+(int)extractReqId:(NSMutableDictionary *)response{
    int reqId = [(NSString *)[response valueForKey:@"reqId"] intValue];
    [response removeObjectForKey:@"reqId"];
    return reqId;
}
+(NSError *)extractError:(NSMutableDictionary *)response{
    NSError * reqId = [response valueForKey:CITRUS_ERROR_DOMAIN];
    [response removeObjectForKey:CITRUS_ERROR_DOMAIN];
    return reqId;
}
+(NSError *)verifiyEmailOrMobile:(NSString *)userName{
    
    NSError *error = nil;
    
    if([CTSUtility isEmail:userName]){
        if (![CTSUtility validateEmail:userName]) {
            error = [CTSError getErrorForCode:EmailNotValid];
            
        }
    }else{
        userName = [CTSUtility mobileNumberToTenDigitIfValid:userName];
        if (!userName) {
            error = [CTSError getErrorForCode:MobileNotValid];
        }
    }
    return error;
}


+(NSString*)mobileNumberToTenDigitIfValid:(NSString *)number{
    NSString *proccessedNumber = nil;
    if([self validateMobile:number] == YES){
        proccessedNumber = [self mobileNumberToTenDigit:number];
    }
    return proccessedNumber;
}


+ (BOOL)validateMobile:(NSString*)mobile {

    NSString *phoneRegex = @"[789][0-9]{3}([0-9]{6})?";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    BOOL matches = [test evaluateWithObject:mobile];
    return matches;
    
//    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"^(?:0091|\\+91||91|0)[7-9][0-9]{9}$"];
//    return [regex evaluateWithObject:mobile];
}

+ (NSString *)mobileNumberToTenDigit:(NSString*)mobile {
    // remove hyphens
    // first extra charecters
    // return number
    NSCharacterSet* myCharSet =
    [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    NSCharacterSet *invertedValidCharSet = [myCharSet invertedSet];
    NSArray* words = [mobile componentsSeparatedByCharactersInSet:invertedValidCharSet];
    NSString* proccesedNumber = [words componentsJoinedByString:@""];
    
    return proccesedNumber;
}

+(NSString *)toJson:(NSDictionary *)dict{
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
   return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

}

+(NSDictionary *)toDict:(NSString *)json{
    NSData *dataJson = [json dataUsingEncoding:NSUTF8StringEncoding ];
    return  [NSJSONSerialization JSONObjectWithData:dataJson options:kNilOptions error:nil];

}

+(BOOL)stringContainsSpecialChars:(NSString *)toCheck exceptChars:(NSString*)exceptionChars exceptCharSet:(NSCharacterSet*)exceptionCharSet {
    BOOL isContain = NO;
    NSString *setString = [NSString stringWithFormat:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789%@",exceptionChars];
    NSMutableCharacterSet *setBase = [NSMutableCharacterSet characterSetWithCharactersInString:setString];
  if(exceptionCharSet)
    [setBase formUnionWithCharacterSet:exceptionCharSet];
    
    NSCharacterSet * set = [setBase invertedSet];
    
        if ([toCheck rangeOfCharacterFromSet:set].location != NSNotFound) {
        isContain = YES;
    }
    return isContain;
}


+(BOOL)isNonNumeric:(NSString *)string{
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([string rangeOfCharacterFromSet:notDigits].location != NSNotFound)
    {
        return YES;
    }
    return NO;
}



+(BOOL)string:(NSString *)toCheck containsCharSet:(NSCharacterSet *)exceptionCharSet{
    BOOL isContain = NO;
    if ([toCheck rangeOfCharacterFromSet:exceptionCharSet].location != NSNotFound) {
        isContain = YES;
    }
    return isContain;

}

+(BOOL)islengthInvalid:(NSString*)string{
    if( string == nil || string.length>255 || string.length == 0){
        return YES;
    }
    return NO;
}

+(BOOL)validateAmountString:(NSString *)amount{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:amount];
    if(myNumber){
        return YES;
    }
    return NO;
}


+(CTSContactUpdate *)convertFromProfile:(CTSProfileContactRes *)profile contact:(CTSContactUpdate *)contact{
    if(contact == nil){
        contact = [[CTSContactUpdate alloc] init];
    }
    
    [contact substituteFromProfile:profile];

    return contact;

}

+(CTSContactUpdate *)convertFromProfile:(CTSProfileContactRes *)profile {
    CTSContactUpdate* contact = [[CTSContactUpdate alloc] init];
    [contact substituteFromProfile:profile];
    return contact;
}

+(CTSContactUpdate *)correctContactIfNeeded:(CTSContactUpdate *)contact{
    if(contact == nil){
        contact = [[CTSContactUpdate alloc] initDefault];
    }
    else{
        [contact substituteDefaults];
    }
    return contact;

}
+(CTSUserAddress *)correctAdressIfNeeded:(CTSUserAddress *)address{
    if(address == nil){
        address = [[CTSUserAddress alloc] initDefault];
    }
    else{
        [address substituteDefaults];
    }
    return address;
}

+(NSString *)fetchSigninId:(CTSKeyStore *)keyStore{
    return keyStore.signinId;
}

+(NSString *)fetchVanityUrl:(CTSKeyStore *)keyStore{
    return keyStore.vanity;
}


+(NSString *)fetchSigninSecret:(CTSKeyStore *)keyStore{
    return keyStore.signinSecret;
}

+(NSString *)fetchSignupId:(CTSKeyStore *)keyStore{
    return keyStore.signUpId;
}

+(NSString *)fetchSigUpSecret:(CTSKeyStore *)keyStore{
    return keyStore.signUpSecret;

}

+(NSString *)grantTypeFor:(PasswordType)type{
    NSString *grantType = nil;
    
    if(type == PasswordTypeOtp){
        grantType = MLC_SIGNIN_GRANT_TYPE_OTP;
    }
    else if (type == PasswordTypePassword){
        grantType = MLC_SIGNIN_GRANT_TYPE;
        
    }
    return grantType;
    
}


+(CTSKeyStore *)fetchCachedKeyStore{
  CTSKeyStore *keyStore =  [[CTSDataCache sharedCache] fetchCachedDataForKey:CACHE_KEY_KEY_STORE];
    return keyStore;
}


+(NSString*)fetchFromEnvironment:(NSString *)key{
    NSString *value = nil;
    NSDictionary * dict = [[CTSDataCache sharedCache] fetchCachedDataForKey:CACHE_KEY_ENV];
    value  = [dict objectForKey:key];
    return value;
}

+ (CTSBill*)getDPBillFromServer:(CTSRuleInfo *)ruleInfo txn:(NSString *)txnID billUrl:(NSString*)billUrl{
    // Configure your request here.
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?amount=%@&dpOperation=%@&ruleName=%@&alteredAmount=%@&txn_id=%@",billUrl,ruleInfo.originalAmount,[ruleInfo toDpTypeString],ruleInfo.ruleName,ruleInfo.alteredAmount,txnID];
    LogTrace(@"urlString %@",urlString);
    // https://salty-plateau-1529.herokuapp.com/billGenerator.stg4.php?amount=100.00&dpOperation=calculatePricing&ruleName=nbRuleBySalil
    // https://salty-plateau-1529.herokuapp.com/billGenerator.stg4.php?amount=100.00&dpOperation=validateRule&ruleName=nbRuleBySalil&alteredAmount=90.00&txn_id=144120088361171
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:urlString]];
    [urlReq setHTTPMethod:@"POST"];
    NSError* error = nil;
    NSData* signatureData = [NSURLConnection sendSynchronousRequest:urlReq
                                                  returningResponse:nil
                                                              error:&error];
    NSString* billJson = [[NSString alloc] initWithData:signatureData
                                               encoding:NSUTF8StringEncoding];
    JSONModelError *jsonError;
    CTSBill* sampleBill = [[CTSBill alloc] initWithString:billJson
                                                    error:&jsonError];
    LogTrace(@"billJson %@",billJson);
    LogTrace(@"signature %@ ", sampleBill);
    return sampleBill;
}


+(void)requestDPBillForRule:(CTSRuleInfo *)ruleInfo billURL:(NSString *)billUrl callback:(ASBillCallback)callback{
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?amount=%@&dpOperation=%@&ruleName=%@&alteredAmount=%@",billUrl,ruleInfo.originalAmount,[ruleInfo toDpTypeString],ruleInfo.ruleName,ruleInfo.alteredAmount];
    LogTrace(@"urlString %@",urlString);
    // https://salty-plateau-1529.herokuapp.com/billGenerator.stg4.php?amount=100.00&dpOperation=calculatePricing&ruleName=nbRuleBySalil
    // https://salty-plateau-1529.herokuapp.com/billGenerator.stg4.php?amount=100.00&dpOperation=validateRule&ruleName=nbRuleBySalil&alteredAmount=90.00&txn_id=144120088361171
    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:urlString]];
    [urlReq setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
    [NSURLConnection sendAsynchronousRequest:urlReq queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError *  connectionError) {
        NSError *billError = connectionError;
        CTSBill* sampleBill = nil;
        if(connectionError == nil){
            NSString* billJson = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
            JSONModelError *jsonError;
            sampleBill = [[CTSBill alloc] initWithString:billJson
                                                   error:&jsonError];
            if(jsonError){
                billError = jsonError;
            }
            LogTrace(@"billJson %@",billJson);
            LogTrace(@"signature %@ ", sampleBill);
        }
        callback(sampleBill,billError);
    }];
}



+(void)requestBillAmount:(NSString *)amount billURL:(NSString *)billUrl callback:(ASBillCallback)callback{
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@?amount=%@",billUrl,amount];
    LogTrace(@"urlString %@",urlString);

    NSMutableURLRequest* urlReq = [[NSMutableURLRequest alloc] initWithURL:
                                   [NSURL URLWithString:urlString]];
    [urlReq setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
    [NSURLConnection sendAsynchronousRequest:urlReq queue:queue completionHandler:^(NSURLResponse * response, NSData *data, NSError * connectionError) {
        NSError *billError = connectionError;
        CTSBill* sampleBill = nil;
        if(connectionError == nil){
            NSString* billJson = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
            JSONModelError *jsonError;
            sampleBill = [[CTSBill alloc] initWithString:billJson
                                                   error:&jsonError];
            if(jsonError){
                billError = jsonError;
            }
            LogTrace(@"billJson %@",billJson);
            LogTrace(@"signature %@ ", sampleBill);
        }
        callback(sampleBill,billError);
    }];
}




+(NSString *)convertToDecimalAmountString:(NSString *)amount{
    LogTrace(@"amount before truncation %@",amount);

    if([self validateAmountString:amount]){
        NSArray *seperatedByDecimal = [amount componentsSeparatedByString:@"."];
        NSString *rs = [seperatedByDecimal objectAtIndex:0];
        NSString *paise = @"";
        if([seperatedByDecimal count] > 1){
         paise = [seperatedByDecimal objectAtIndex:1];
        }
        
        if([paise length] == 0){
            paise = @"00";
        }
        else if([paise length] == 1){
            paise = [NSString stringWithFormat:@"%@0",paise];
        }
        else if([paise length] > 2){
            paise = [paise substringToIndex:2];
        }
        
        
        if([rs length] == 0){
        rs = @"0";
        }
        
        amount = [NSString stringWithFormat:@"%@.%@",rs,paise];

        LogTrace(@"amount after truncation %@",amount);
        
        return amount;
    }
    else{
        LogTrace(@"amount after truncation %@",nil);

        return nil;
    }
    
    
}

+(CTSKeyStore *)keyStore{
    return [[CTSDataCache sharedCache] fetchCachedDataForKey:CACHE_KEY_KEY_STORE];
}


+ (CTSRestCoreResponse*)addJsonErrorToResponse:(CTSRestCoreResponse*)response {
    JSONModelError* jsonError = nil;
    NSError* serverError = response.error;
    CTSRestError* error;
    error = [[CTSRestError alloc] initWithString:response.responseString
                                           error:&jsonError];
    
    if(error != nil && error.errorMessage == nil && error.errorDescription == nil && error.error == nil){
        //error may be in the form of other unexpected json, try with other format
        NSDictionary *dict = [CTSUtility toDict:response.responseString];
        
        error.errorMessage = [dict valueForKey:@"errorMessage"];
        error.errorCode = [dict valueForKey:@"errorCode"];
        if(error.errorMessage == nil){
            error = nil;
        }
    }
    
    [error logProperties];
    if (error != nil) {
        if (error.type != nil) {
            error.error = error.type;
        } else {
            error.type = error.error;
        }
        
        if(error.errorDescription == nil){
            error.errorDescription = error.description;
        }
        else{
            error.description = error.errorDescription;
        }
        
        
        if(error.errorMessage != nil){
            error.errorDescription = error.errorMessage;
        }
        
        if(error.error_desc != nil){
            error.errorDescription = error.error_desc;
        }
        
    } else {
        error = [[CTSRestError alloc] init];
    }
    
    error.serverResponse = response.responseString;
    
    NSString *newDes;
    if(error.errorDescription != nil){
        newDes =error.errorDescription;
    }
    else {
        newDes =[[serverError userInfo] valueForKey:NSLocalizedDescriptionKey];
        
    }
    
    
    
    NSDictionary* userInfo = @{
                               CITRUS_ERROR_DESCRIPTION_KEY : error,
                               NSLocalizedDescriptionKey :newDes
                               
                               };
    response.error = [NSError errorWithDomain:CITRUS_ERROR_DOMAIN
                                         code:[serverError code]
                                     userInfo:userInfo];
    return response;
}


+(BOOL)isErrorJson:(NSString *)string{
    
    if(string){
        NSDictionary *dict = [CTSUtility toDict:string];
        if([dict valueForKey:@"errorDescription"] || [dict valueForKey:@"error"] || [dict valueForKey:@"errorCode"] || [dict valueForKey:@"errorMessage"] || [dict valueForKey:@"error_desc"]){
            return YES;
        }
    }
    return NO;
}



+(NSString*)getHTMLWithString:(NSString *)string{
    // NSString *string = @";<div>iPhone SDK Development Forums</div>";
    NSString *result = nil;
    
    // Determine "<div>" location
    NSRange divRange = [string rangeOfString:@"<html>" options:NSCaseInsensitiveSearch];
    if (divRange.location != NSNotFound)
    {
        // Determine "</div>" location according to "<div>" location
        NSRange endDivRange;
        
        endDivRange.location = divRange.length + divRange.location;
        endDivRange.length   = [string length] - endDivRange.location;
        endDivRange = [string rangeOfString:@"</html>" options:NSCaseInsensitiveSearch range:endDivRange];
        
        if (endDivRange.location != NSNotFound)
        {
            // Tags found: retrieve string between them
            divRange.location += divRange.length;
            divRange.length = endDivRange.location - divRange.location;
            
            result = [string substringWithRange:divRange];
        }
    }
    return result;
}


@end
