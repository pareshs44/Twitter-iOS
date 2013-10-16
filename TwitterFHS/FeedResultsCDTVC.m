//
//  FeedResultsCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "FeedResultsCDTVC.h"
#import "TwitterOAuthClient.h"
#import "Feed+Twitter.h"

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
    NSLog(@"View is gonna appear");
    if(!self.managedObjectContext)
        [self useMiniTwitterDocument];
}

-(void) useMiniTwitterDocument
{
    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"MiniTwitterDifferentDocument"];
    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        NSLog(@"in if");
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if(success) {
                  NSLog(@"in if ka success");
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        NSLog(@"in else if");
        [document openWithCompletionHandler:^(BOOL success) {
            NSLog(@"Just before success");
            if(success) {
                NSLog(@"in else if ka success");
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
        }];
    }
    
    else {
        NSLog(@"in else");
        self.managedObjectContext = document.managedObjectContext;
    }
}

- (IBAction)refresh
{
    NSLog(@"came here");
    [self.refreshControl beginRefreshing];
    TwitterOAuthClient * client = [TwitterOAuthClient sharedInstance];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        NSLog(@"gonna make request");
        //NSArray * feeds = [client fetchTimeline];
        [client fetchHomeTimelineWithSuccess:^(NSMutableArray *results) {
            [self.managedObjectContext performBlock:^{
                for(NSDictionary * feed in results) {
                    [Feed feedWithDetails:feed inManagedObjectContext:self.managedObjectContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }];
        }];
    });
}


@end
