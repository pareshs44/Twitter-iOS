//
//  FeedResultsCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "FeedResultsCDTVC.h"
#import "TwitterOAuthClient.h"
#import "Tweet+Twitter.h"

@interface FeedResultsCDTVC ()

@end

@implementation FeedResultsCDTVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(!self.managedObjectContext)
        [self useMiniTwitterDocument];
}

-(void) useMiniTwitterDocument
{
    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MiniTwitterSomeOtherDocument"];
    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        NSLog(@"if");
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if(success) {
                  NSLog(@"if success");
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        NSLog(@"else if");
        [document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                NSLog(@"else if success");
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
        }];
    }
    
    else {
        NSLog(@"else");
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        NSLog(@"gonna make request");
        //NSArray * feeds = [client fetchTimeline];
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineWithSuccess:^(NSMutableArray *results) {
            NSLog(@"tweet: %@", results[0]);
            [self.managedObjectContext performBlock:^{
                NSLog(@"In perform block");
                for(NSDictionary * feed in results) {
                    [Tweet tweetWithDetails:feed inManagedObjectContext:self.managedObjectContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }];
        }];
    });
}


@end
