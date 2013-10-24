//
//  IndexViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/1/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "IndexViewController.h"

@interface IndexViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.activityIndicator stopAnimating];
}

- (IBAction)logIn:(id)sender {
    [self.activityIndicator startAnimating];
    
    TwitterOAuthToken * storedToken = (TwitterOAuthToken *)[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]objectForKey:@"accessToken"]];
    dispatch_queue_t logInQ = dispatch_queue_create("LogIn Queue", NULL);
    if(storedToken) {
        [TwitterOAuthClient sharedInstance].accessToken = storedToken;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        dispatch_async(logInQ, ^{
            [[TwitterOAuthClient sharedInstance] verifyUserCredentialsWithSuccess:^(NSMutableArray *results) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"Successful LogIn" sender:self];
            }];
        });
    }
    else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        dispatch_queue_t logInQ = dispatch_queue_create("LogIn Queue", NULL);
        dispatch_async(logInQ, ^{
            [[TwitterOAuthClient sharedInstance] logInToTwitterWithSuccess:^(TwitterOAuthToken *accessToken) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:accessToken] forKey:@"accessToken"];
                [self.activityIndicator stopAnimating];
                [self performSegueWithIdentifier:@"Successful LogIn" sender:self];
            }];
        });
    }
}

@end
