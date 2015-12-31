//
//  WebViewVC.h
//  STTwitterDemoIOS
//
//  Created by Nicolas Seriot on 06/08/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface WebViewVC : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) ViewController *rootVC;

- (IBAction)cancel:(id)sender;

@end
