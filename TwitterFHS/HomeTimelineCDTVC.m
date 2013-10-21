//
//  HomeTimelineCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/19/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "HomeTimelineCDTVC.h"
#import "Tweet.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"

@interface HomeTimelineCDTVC ()

@end

@implementation HomeTimelineCDTVC

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
    url = [url URLByAppendingPathComponent:@"iOS7MiniTwitterDocument"];
    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if(success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if(success) {
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
        }];
    }
    
    else {
        self.managedObjectContext = document.managedObjectContext;
        [self refresh];
    }
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        //NSArray * feeds = [client fetchTimeline];
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineWithSuccess:^(NSMutableArray *results) {
            [self.managedObjectContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inManagedObjectContext:self.managedObjectContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }];
        }];
    });
}



-(void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if(managedObjectContext) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
        //request.predicate = [NSPredicate predicateWithFormat:@"follower = %@", [TwitterOAuthClient sharedInstance].accessToken.userInfo[@"user_name"]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}

-(TweetCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = tweet.content;
    cell.subtitleLabel.text = tweet.createdBy.name;
    //cell.titleLabel.text = tweet.createdBy.screenName;
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    return cell;
}

@end
