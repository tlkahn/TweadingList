//
//  AppDelegate.m
//  STTwitterDemoiOS
//
//  Created by Nicolas Seriot on 10/1/13.
//  Copyright (c) 2013 Nicolas Seriot. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "WebViewVC.h"

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    ViewController *vc = (ViewController *)[[self window] rootViewController];
    vc.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistFilename = [documentsPath stringByAppendingPathComponent:@"TweadingList.plist"];
    
    NSLog(@"File name: %@", plistFilename);
    
    BOOL isFile = [[NSFileManager defaultManager] fileExistsAtPath:plistFilename];
    if(isFile) {
        NSLog (@"File found");
        NSMutableDictionary *appInfoDict = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFilename];
        NSLog(@"app info dict: %@", appInfoDict);
        if ([appInfoDict objectForKey:@"previousBatchFirstTweet"]) {
            vc.previousBatchFirstTweetTimestampString = [appInfoDict objectForKey:@"previousBatchFirstTweet"];
            NSLog(@"previousBatchFirstTweetTimestampString in view controller has been set to: %@", vc.previousBatchFirstTweetTimestampString);
        }
        if ([appInfoDict objectForKey:@"twitterScreenName"]) {
            vc.twitterScreenName = [appInfoDict objectForKey:@"twitterScreenName"];
            NSLog(@"twitterScreenName in view controller has been set to: %@", vc.twitterScreenName);
        }
    }
    else {
        NSLog (@"File not found");
        NSMutableDictionary *appInfoDict = [[NSMutableDictionary alloc] init];
        [appInfoDict setObject:@"" forKey:@"previousBatchFirstTweet"];
        [appInfoDict setObject:@"" forKey:@"twitterUserName"];
        [appInfoDict writeToFile:plistFilename atomically:YES];
        NSLog(@"app info dict file has been created and populated fields with empty date value: %@", appInfoDict);

    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    ViewController *vc = (ViewController *)[[self window] rootViewController];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistFilename = [documentsPath stringByAppendingPathComponent:@"TweadingList.plist"];
    NSMutableDictionary *appInfoDict = [[NSMutableDictionary alloc] init];
    if (vc.previousBatchFirstTweetTimestampString.length == 0) {
        NSLog(@"previousBatchFirstTweetTimestampString in View Controller is empty now. Maybe user has not tap the transcribe button yet.");
    } else {
        [appInfoDict setObject:vc.previousBatchFirstTweetTimestampString forKey:@"previousBatchFirstTweet"];
        NSLog(@"previousBatchFirstTweetTimestampString in ViewController is now set by AppDelegate to %@", vc.previousBatchFirstTweetTimestampString);
    }
    
    if (vc.twitterScreenName.length == 0) {
        NSLog(@"twitter screen name is empty now. Maybe user has not logged in yet.");
    } else {
        [appInfoDict setObject:vc.twitterScreenName forKey:@"twitterScreenName"];
        NSLog(@"twitter screen name in ViewController is now set by AppDelegate to %@", vc.twitterScreenName);
    }

    [appInfoDict writeToFile:plistFilename atomically:YES];
    NSLog(@"file created and populated with app info dict populated as: %@:", appInfoDict);
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:@"myapp"] == NO) return NO;
    
    NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
    
    NSString *token = d[@"oauth_token"];
    NSString *verifier = d[@"oauth_verifier"];
    ViewController *vc = (ViewController *)[[self window] rootViewController];

    if (token) {
        [vc setOAuthToken:token oauthVerifier:verifier];
    } else {
        NSLog(@"token returned is empty. maybe user failed to authenticate");
        if (vc.webViewVC) {
            [vc.webViewVC dismissViewControllerAnimated:YES completion:nil];
        }
        vc.twitter = nil;
        vc.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"EuXhOu7221cZtMAh86GE4L9rH"
                                                   consumerSecret:@"S25h6rmJttp79OPdRJhYwt3P0N87WljDkOdb1AatZKGqw03vaa"
                      ];
    }

    
    return YES;
}

@end
