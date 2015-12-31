//
//  ViewController.m
//  STTwitterDemoiOSSafari
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "ViewController.h"
#import "STTwitter.h"
#import "WebViewVC.h"
#import <Accounts/Accounts.h>

typedef void (^accountChooserBlock_t)(ACAccount *account, NSString *errorMessage); // don't bother with NSError for that

@interface ViewController ()
@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *iOSAccounts;
@property (nonatomic, strong) accountChooserBlock_t accountChooserBlock;
@end

// https://dev.twitter.com/docs/auth/implementing-sign-twitter

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view, typically from a nib.

    
    self.accountStore = [[ACAccountStore alloc] init];
    self.webViewVC = nil;
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"EuXhOu7221cZtMAh86GE4L9rH"
                                                 consumerSecret:@"S25h6rmJttp79OPdRJhYwt3P0N87WljDkOdb1AatZKGqw03vaa"
                    ];
    
    
}

- (BOOL) shouldAutorotate {
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginWithiOSAction:(id)sender {
    
    NSLog(@"Trying to login with iOS...");

    __weak typeof(self) weakSelf = self;
    
    self.accountChooserBlock = ^(ACAccount *account, NSString *errorMessage) {
        
        NSString *status = nil;
        if(account) {
            status = [NSString stringWithFormat:@"Did select %@", account.username];
            
            [weakSelf loginWithiOSAccount:account];
        } else {
            status = errorMessage;
        }
        NSLog(@"status updated to: %@", status);
    };
    
    [self chooseAccount];
}

- (void)loginWithiOSAccount:(ACAccount *)account {
    
    self.twitter = nil;
    self.twitter = [STTwitterAPI twitterAPIOSWithAccount:account delegate:self];
    
    [_twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        self.twitterScreenName = username;
        UILabel *label = (UILabel *)[self.view viewWithTag:4];
        label.text = [NSString stringWithFormat:@"@%@", username];
        NSLog(@"finished account sign in. Current twitter screen name has been set up as: %@", [NSString stringWithFormat:@"@%@ (%@)", username, userID]);
//        UIButton *sendToSafariBtn = (UIButton *)[self.view viewWithTag:3];
//        sendToSafariBtn.hidden = false;
//        UIButton *signInBtn = (UIButton *)[self.view viewWithTag:1];
//        signInBtn.hidden = true;

        
    } errorBlock:^(NSError *error) {
        NSLog(@"ran into issues when trying to log in twitter using native app account, because %@", [error localizedDescription]);
    }];
    
}

- (IBAction)loginOnTheWebAction:(id)sender {

    NSLog(@"Trying to login with Safari...");
    WebViewVC *webViewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewVC"];
    webViewVC.rootVC = self;
    self.webViewVC = webViewVC;
    
    void (^callback) (NSURL *url, NSString *oauthToken) = ^(NSURL *url, NSString *oauthToken) {
        [self presentViewController:webViewVC animated:YES completion:^{
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSLog(@"web view is sending request to: %@", url);
            [webViewVC.webView loadRequest:request];
        }];
        
    };
    
    [_twitter postTokenRequest:callback
authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://com.joshguo.myapp"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                        }
                    ];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier {
    
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:^{
        //
    }];
    
    [_twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"----successfully signed in twitter");
        self.twitterScreenName = screenName;
        NSLog(@"Twitter screen name is in view controller has been updated to @%@", screenName);
        UILabel *label = (UILabel *)[self.view viewWithTag:4];
        label.text = [NSString stringWithFormat:@"@%@", screenName];
        
//        UIButton *sendToSafariBtn = (UIButton *)[self.view viewWithTag:3];
//        sendToSafariBtn.hidden = false;
//        UIButton *signInTwitterBtn = (UIButton *)[self.view viewWithTag:1];
//        signInTwitterBtn.hidden = true;
//        NSLog(@"%@", oauthToken);
//        NSLog(@"%@", oauthTokenSecret);
//        NSLog(@"%@", userID);
//        NSLog(@"-- screenName: %@", screenName);
        
        /*
         At this point, the user can use the API and you can read his access tokens with:
         
         _twitter.oauthAccessToken;
         _twitter.oauthAccessTokenSecret;
         
         You can store these tokens (in user default, or in keychain) so that the user doesn't need to authenticate again on next launches.
         
         Next time, just instanciate STTwitter with the class method:
         
         +[STTwitterAPI twitterAPIWithOAuthConsumerKey:consumerSecret:oauthToken:oauthTokenSecret:]
         
         Don't forget to call the -[STTwitter verifyCredentialsWithSuccessBlock:errorBlock:] after that.
         */
        
    } errorBlock:^(NSError *error) {
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

- (IBAction)getTimelineAction:(id)sender {
    
    if (self.twitterScreenName.length == 0) {
        [NSException raise:@"Twitter user name is empty" format:@"twitter screen name has not been set up yet. Maybe user has not signed in"];
    }
    NSInteger statusCount = 20;
    [_twitter getUserTimelineWithScreenName:self.twitterScreenName
                                      count:statusCount
                               successBlock:^(NSArray *statuses) {
                                   SSReadingList * readList   = [SSReadingList defaultReadingList];

                                   NSString *currentBatchFirstTweetTimestampString = [statuses[0] valueForKey:@"created_at"];
                                   if (currentBatchFirstTweetTimestampString.length == 0) {
                                       NSLog(@"invalid twitter data");
                                   }
                                   
                                   BOOL status = nil;
                                   NSString *url = nil;
                                   NSArray *urls = nil;
                                   NSError * readListError = nil;
                                   NSInteger tmpCount = statuses.count;
                                   NSInteger totalImport = 0;
                                   for (int i=0; i<statuses.count; i++, totalImport += 1) {
                                       float currentProgress = 100 / tmpCount * (i+1);
                                       [self.progressBar setProgress:currentProgress animated:YES];
                                       if (self.previousBatchFirstTweetTimestampString.length > 0 && [[statuses[i] valueForKey:@"created_at"] isEqualToString:self.previousBatchFirstTweetTimestampString] ) {
                                           NSLog(@"found equal previous first tweet timestamp and current cursor timestamp");
                                           break;
                                       }
                                       urls = statuses[i][@"entities"][@"urls"];
                                       if (urls && urls.count > 0) {
                                           url = urls[0][@"expanded_url"];
                                           status =[readList addReadingListItemWithURL:[NSURL URLWithString:url] title:@"from twitter" previewText:statuses[i][@"text"] error:&readListError];
                                           if(status) {
                                               NSLog(@"Added URL: %@", url);
                                           }
                                           else
                                               NSLog(@"Error: %@", readListError);
                                       }
                                       
                                   }
                                   NSLog(@"done");
                                   UILabel *flag = [self.view viewWithTag:4];
                                   flag.text = [NSString stringWithFormat:@"Done. You have imported %ld tweets.",(long)totalImport];
//                                   self.doneLabel.text = [NSString stringWithFormat:@"Done. You have imported %ld",(long)totalImport];
                                   self.previousBatchFirstTweetTimestampString = currentBatchFirstTweetTimestampString;
                                   NSLog(@"previousBatchFirstTweetTimestampString reset to %@, not saved yet:", currentBatchFirstTweetTimestampString);
                                   self.statuses = statuses;

                            
                               }
                                 errorBlock:^(NSError *error) {
                                     NSLog(@"get timeline is reporting errors: %@", [error localizedDescription]);
                               }];
}

- (void)chooseAccount {
    
    ACAccountType *accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if(granted == NO) {
                _accountChooserBlock(nil, @"Acccess not granted.");
                return;
            }
            
            self.iOSAccounts = [_accountStore accountsWithAccountType:accountType];
            
            if([_iOSAccounts count] == 0) {
                [self loginOnTheWebAction:nil];
                return;
            }
            else if([_iOSAccounts count] == 1) {
                ACAccount *account = [_iOSAccounts lastObject];
                _accountChooserBlock(account, nil);
            } else {
                UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Select an account:"
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                  destructiveButtonTitle:nil otherButtonTitles:nil];
                for(ACAccount *account in _iOSAccounts) {
                    [as addButtonWithTitle:[NSString stringWithFormat:@"@%@", account.username]];
                }
                [as showInView:self.view.window];
            }
        }];
    };
    
#if TARGET_OS_IPHONE &&  (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
    if (floor(NSFoundationVersionNumber) < NSFoundationVersionNumber_iOS_6_0) {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                     withCompletionHandler:accountStoreRequestCompletionHandler];
    } else {
        [self.accountStore requestAccessToAccountsWithType:accountType
                                                   options:NULL
                                                completion:accountStoreRequestCompletionHandler];
    }
#else
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:accountStoreRequestCompletionHandler];
#endif

}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if(buttonIndex == [actionSheet cancelButtonIndex]) {
        _accountChooserBlock(nil, @"Account selection was cancelled.");
        return;
    }
    
    NSUInteger accountIndex = buttonIndex - 1;
    ACAccount *account = [_iOSAccounts objectAtIndex:accountIndex];
    
    _accountChooserBlock(account, nil);
}

#pragma mark STTwitterAPIOSProtocol

- (void)twitterAPI:(STTwitterAPI *)twitterAPI accountWasInvalidated:(ACAccount *)invalidatedAccount {
    if(twitterAPI != _twitter) return;    
    NSLog(@"-- account was invalidated: %@ | %@", invalidatedAccount, invalidatedAccount.username);
}

#pragma mark utils

- (NSDate *) parseTwitterTimestampToNSDate:(NSString *)twitterTimestamp {
    
    NSError *regexError        = nil;
    NSString *regexPattern     = @"([A-Za-z]{3})\\s([A-Za-z]{3})\\s(\\d{2})\\s(\\d{2}:\\d{2}:\\d{2})\\s([\\+\\-]\\d{4})\\s(\\d{4})";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:0 error:&regexError];
    if (regexError) {
        NSLog(@"Couldn't create regex with given string and options");
    }
    
    NSString *visibleText = twitterTimestamp;
    
    if (self.previousBatchFirstTweetTimestampString.length == 0) {
        visibleText = @"Tue Dec 15 02:30:16 +0000 1995";
    } else {
        visibleText = self.previousBatchFirstTweetTimestampString;
    }
    NSRange visibleTextRange   = NSMakeRange(0, visibleText.length);
    NSArray *matches           = [regex matchesInString:@"Mon Dec 14 18:02:05 +0000 2015" options:NSMatchingReportProgress range:visibleTextRange];
    NSDate *result;
    
    for (NSTextCheckingResult *match in matches)
    {
        NSString* matchText = [visibleText substringWithRange:[match range]];
        NSLog(@"match: %@", matchText);
        
        NSRange weekdayRange = [match rangeAtIndex:1];
        NSRange monthRange   = [match rangeAtIndex:2];
        NSRange dayRange     = [match rangeAtIndex:3];
        NSRange timeRange    = [match rangeAtIndex:4];
        NSRange zuluRange    = [match rangeAtIndex:5];
        NSRange yearRange    = [match rangeAtIndex:6];
        
        NSLog(@"group1: %@", [visibleText substringWithRange:weekdayRange]);
        NSLog(@"group2: %@", [visibleText substringWithRange:monthRange]);
        NSLog(@"group3: %@", [visibleText substringWithRange:dayRange]);
        NSLog(@"group4: %@", [visibleText substringWithRange:timeRange]);
        NSLog(@"group5: %@", [visibleText substringWithRange:zuluRange]);
        NSLog(@"group6: %@", [visibleText substringWithRange:yearRange]);
        
        NSString *matchedYear  = [visibleText substringWithRange:yearRange];
        NSString *matchedMonth = [visibleText substringWithRange:monthRange];
        NSString *matchedDay   = [visibleText substringWithRange:dayRange];
        NSString *matchedTime  = [visibleText substringWithRange:timeRange];
        NSString *matchedZulu  = [visibleText substringWithRange:zuluRange];
        
        NSString *formatTimestamp = [NSString stringWithFormat:@"%@-%@-%@ %@ %@", matchedYear, matchedMonth, matchedDay, matchedTime, matchedZulu];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        NSDate *capturedStartDate      = [dateFormatter dateFromString:formatTimestamp];
        result = capturedStartDate;

    }
    return result;
}
@end
