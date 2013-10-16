//
//  ViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/20/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)showLoginWindow:(id)sender {
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:self withCompletion:^(BOOL success) {
        NSLog(success? @"L0L success":@"O noes!!! Loggen faylur!!!");
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
    NSString *username = [[FHSTwitterEngine sharedEngine]loggedInUsername];// self.engine.loggedInUsername;
    if (username.length > 0) {
        self.lbl.text = [NSString stringWithFormat:@"Logged in as %@",username];
        //[self listResults];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;        
    } else {
        self.lbl.text = @"You are not logged in.";
    }
    
}
- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

/*
- (void)listResults {
    
    dispatch_async(GCDBackgroundThread, ^{
        @autoreleasepool {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
            
            // the following line contains a FHSTwitterEngine method wich do the search.
            
            self.dict = [[FHSTwitterEngine sharedEngine]searchTweetsWithQuery:@"#iOS" count:100 resultType:FHSTwitterEngineResultTypeRecent unil:nil sinceID:nil maxID:nil];
            // NSLog(@"%@",dict);
            NSArray *results = [self.dict objectForKey:@"statuses"];
            
            //  NSLog(@"array text = %@",results);
            for (NSDictionary *item in results) {
                NSLog(@"text == %@",[item objectForKey:@"text"]);
                NSLog(@"name == %@",[[item objectForKey:@"user"]objectForKey:@"name"]);
                NSLog(@"screen name == %@",[[item objectForKey:@"user"]objectForKey:@"screen_name"]);
                NSLog(@"pic == %@",[[item objectForKey:@"user"]objectForKey:@"profile_image_url_https"]);
            }
            
            dispatch_sync(GCDMainThread, ^{
                @autoreleasepool {
                    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Complete!" message:@"Your list of followers has been fetched" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [av show];
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                }
            });
        }
    });
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *logIn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    logIn.frame = CGRectMake(100, 100, 100, 100);
    [logIn setTitle:@"Login" forState:UIControlStateNormal];
    [logIn addTarget:self action:@selector(showLoginWindow:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logIn];
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"R9sI6x6sZQdFzHK912tIQw" andSecret:@"9xFxAYxaTFFmSEJj67lBwDHKAzWakSst0xiJtRcniDs"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
