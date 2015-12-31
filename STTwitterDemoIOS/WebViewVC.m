//
//  WebViewVC.m
//  STTwitterDemoIOS
//
//  Created by Nicolas Seriot on 06/08/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "WebViewVC.h"
#import "ViewController.h"

@interface WebViewVC ()

@end

@implementation WebViewVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Sign in web view has been cancelled.");
        self.rootVC.twitter = nil;
        self.rootVC.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:@"EuXhOu7221cZtMAh86GE4L9rH"
                                                            consumerSecret:@"S25h6rmJttp79OPdRJhYwt3P0N87WljDkOdb1AatZKGqw03vaa"
                               ];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
