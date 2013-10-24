//
//  TweetDetailsCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "TweetDetailsCDTVC.h"
#import "Tweet.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"

@interface TweetDetailsCDTVC ()

@end

@implementation TweetDetailsCDTVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
}


-(void) setCreatedBy:(User *)createdBy
{
    _createdBy = createdBy;
    self.title = createdBy.name;
    [self setupFetchedResultsController];
}

-(void) setupFetchedResultsController
{
    if(self.createdBy.managedObjectContext) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"createdBy = %@", self.createdBy];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.createdBy.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        //NSArray * feeds = [client fetchTimeline];
        [[TwitterOAuthClient sharedInstance] fetchTimelineOfUser:self.createdBy.screenName withSuccess:^(NSMutableArray *results)
        {
            [self.createdBy.managedObjectContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inManagedObjectContext:self.createdBy.managedObjectContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }];
        }];
    });
}

-(TweetCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userTweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = tweet.content;
    cell.subtitleLabel.text = tweet.createdBy.name;
    //cell.titleLabel.text = tweet.createdBy.screenName;
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    return cell;
}
@end
