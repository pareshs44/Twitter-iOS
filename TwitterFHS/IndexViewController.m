//
//  IndexViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/1/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "IndexViewController.h"
#import "ResultsTableViewController.h"
#import "TwitterOAuthClient.h"

@interface IndexViewController ()

@end

@implementation IndexViewController

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.twitterOAuthClient fetchHomeTimelineWithSuccess:^(NSMutableArray *results) {

        ResultsTableViewController * rtvc = [[[[segue.destinationViewController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    rtvc.results = (NSMutableArray *)results;

    rtvc.title = @"User Timeline";
    [rtvc.tableView reloadData];
    }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSString * indexBackground = [NSString stringWithFormat:@"indexBackground.png"];
//    UIImageView * backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:indexBackground]];
//    [self.view addSubview:backgroundImage];
//    [self.view sendSubviewToBack:backgroundImage];
	// Do any additional setup after loading the view.
}

- (IBAction)logInWithToken:(id)sender {
    self.twitterOAuthClient = [TwitterOAuthClient sharedInstance];
    //[self.twitterOAuthClient logInToTwitter];
}


- (IBAction)logIn:(id)sender {
    self.twitterOAuthClient = [TwitterOAuthClient sharedInstance];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_queue_t logInQ = dispatch_queue_create("LogIn Queue", NULL);
    
    dispatch_async(logInQ, ^{
        [self.twitterOAuthClient logInToTwitterWithSuccess:^(NSMutableArray *results) {
            [self performSegueWithIdentifier:@"Successful LogIn" sender:self];
        }];
         
    /*:^{
            
            //UITabBarController *tabBar = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            //ResultsTableViewController *rtvc = (ResultsTableViewController *)[[(UINavigationController *)[tabBar.viewControllers objectAtIndex:0] viewControllers] objectAtIndex:0];

            //[self presentViewController:tabBar animated:YES completion:nil];



                    [self performSegueWithIdentifier:@"Successful LogIn" sender:self];


                }];
     */

     });
}

@end
