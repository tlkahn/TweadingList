//
//  ViewController.h
//  STTwitterDemoiOSSafari
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STTwitter.h"
#import <SafariServices/SafariServices.h>
#import "AppDelegate.h"
@class WebViewVC;

@interface ViewController : UIViewController <UIActionSheetDelegate, STTwitterAPIOSProtocol>

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *previousBatchFirstTweetTimestampString;
@property (nonatomic, strong) NSString *twitterScreenName;
@property (nonatomic, strong) STTwitterAPI *twitter;
@property (nonatomic, strong) WebViewVC *webViewVC;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *doneLabel;

- (IBAction)loginWithiOSAction:(id)sender;
- (IBAction)loginOnTheWebAction:(id)sender;
- (IBAction)getTimelineAction:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verfier;

@end
