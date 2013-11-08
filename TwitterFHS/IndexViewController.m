//
//  IndexViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/1/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "IndexViewController.h"
#import "ManagedObjectManager.h"
#import <CoreData/CoreData.h>
#import "RootViewController.h"

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
    
    __weak IndexViewController * weakSelf = self;
    void(^contextCreated)(void) = ^{
        [weakSelf.activityIndicator stopAnimating];
        [weakSelf performSegueWithIdentifier:@"Successful LogIn" sender:weakSelf];
    };
    
    dispatch_queue_t logInQ = dispatch_queue_create("LogIn Queue", NULL);
    if(storedToken) {
        [TwitterOAuthClient sharedInstance].accessToken = storedToken;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        dispatch_async(logInQ, ^{
            [[TwitterOAuthClient sharedInstance] verifyUserCredentialsWithSuccess:^(NSMutableArray *results) {
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [[ManagedObjectManager sharedInstance] createContextsWithSuccess:contextCreated];
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
                [[ManagedObjectManager sharedInstance] createContextsWithSuccess:contextCreated];
            }];
        });
    }
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    RootViewController * rootTabBarController = (RootViewController *)segue.destinationViewController;
    rootTabBarController.mainContext = [ManagedObjectManager sharedInstance].mainContext;
    rootTabBarController.backgroundContext = [ManagedObjectManager sharedInstance].backgroundContext;
}

@end
