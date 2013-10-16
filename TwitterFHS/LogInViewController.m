
//
//  LogInViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "LogInViewController.h"
#import "ResultsTableViewController.h"

#define CLIENT_KEY @"R9sI6x6sZQdFzHK912tIQw"
#define CLIENT_SECRET @"9xFxAYxaTFFmSEJj67lBwDHKAzWakSst0xiJtRcniDs"

@interface LogInViewController ()

@end

@implementation LogInViewController

- (IBAction)showLoginWindow:(id)sender
{
    
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
        NSLog(success? @"L0L success":@"O noes!!! Loggen faylur!!!");
        
    }];
     

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{    
    if([segue.identifier isEqualToString:@"Test Timeline"]) {
        if([segue.destinationViewController isKindOfClass:[ResultsTableViewController class]]) {
            
            ResultsTableViewController * rtvc = segue.destinationViewController;
            rtvc.title = @"User Timeline";
            
            [self.twitterClient getPath:@"statuses/home_timeline.json"
                             parameters:nil
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    
                                    NSMutableArray * responseArray = (NSMutableArray *) responseObject;
                                    NSLog(@"%@", responseArray);
                                    [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    }];
                                    rtvc.results = responseArray;
                                    [rtvc.tableView reloadData];
                                    
                                    //NSLog(@"RTVC RESULTS: %@", rtvc.results);
                                }
             
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"ANDARError: %@", error);
                                }];
            
        }
        
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FHSTwitterEngine sharedEngine] loadAccessToken];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

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
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"R9sI6x6sZQdFzHK912tIQw" andSecret:@"9xFxAYxaTFFmSEJj67lBwDHKAzWakSst0xiJtRcniDs"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];

    

}

- (void)storeAccessToken:(AFOAuth1Token *)accessToken
{
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (AFOAuth1Token *)loadAccessToken
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void) fetchTimeline
{
    
    NSString * urlString = @"https://api.twitter.com/1.1/";
    self.twitterClient = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:urlString] key:CLIENT_KEY secret:CLIENT_SECRET];

    [self.twitterClient authorizeUsingOAuthWithRequestTokenPath:@"/oauth/request_token"
                                          userAuthorizationPath:@"/oauth/authorize"
                                                    callbackURL:[NSURL URLWithString:@"myapp://success"] // af-twitter://success
                                                accessTokenPath:@"/oauth/access_token"
                                                   accessMethod:@"POST"
                                                          scope:nil
                                                        success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                            [self.twitterClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
                                                            [self.twitterClient getPath:@"statuses/user_timeline.json"
                                                                             parameters:nil
                                                                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                    NSArray * responseArray = (NSArray *) responseObject;
                                                                                    [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                                                        //NSLog(@"Success : %@", obj);
                                                                                        //NSLog(@"PIKA PUKA %@", [obj class]);
                                                                                    }];
                                                                                    //NSLog(@"pikachu: %@", responseArray[1][@"text"]);
                                                                                }
                                                                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                    NSLog(@"ANDARError: %@", error);
                                                                                }];
                                                            //NSLog(@"Chico: %@", responseObject);
                                                        }
                                                        failure:^(NSError *error) {
                                                            NSLog(@"BAAHARError : %@", error);
                                                        }];
    
    //[self.twitterClient aut ]
    
    /*
    
    
     */
}

- (IBAction) testButton:(id)sender {
//    //[self.twitterClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
//    [self.twitterClient getPath:@"statuses/user_timeline.json"
//                     parameters:nil
//                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                            NSArray * responseArray = (NSArray *) responseObject;
//                            [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                                //NSLog(@"Success : %@", obj[@"text"]);
//                            }];
//                            NSLog(@"pikachu: %@", responseArray[0][@"text"]);
//                            
//                        }
//                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                            NSLog(@"ANDARError: %@", error);
//                        }];
//    [self performSegueWithIdentifier:@"Test Timeline" sender:sender];

    NSLog(@"HELLO");
    
    TwitterClient *twitterClienttt = [[TwitterClient alloc] init];
    self.twitterClient.accessToken = [self loadAccessToken];
    
    if(!self.twitterClient.accessToken)
    {
        NSLog(@"Token Nahi Tha");
        self.twitterClient.accessToken = [twitterClienttt getOAuthToken];
        [self storeAccessToken:self.twitterClient.accessToken];
    }
    
    [self.twitterClient getPath:@"statuses/home_timeline.json"
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            NSMutableArray * responseArray = (NSMutableArray *) responseObject;
                            [responseArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                
                            }];
                            //rtvc.results = responseArray;
                            //[rtvc.tableView reloadData];
                            
                            //NSLog(@"RTVC RESULTS: %@", rtvc.results);
                            NSLog(@"Pika Pika: %@", responseArray);
                        }
     
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"ANDARError: %@", error);
                        }];
    
    //NSLog(@"Chico: %@", responseObject);
  
}


- (IBAction)showTimeline:(id)sender {
    [self fetchTimeline];
}

@end