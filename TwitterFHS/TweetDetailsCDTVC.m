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
#import "ManagedObjectManager.h"

@interface TweetDetailsCDTVC ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation TweetDetailsCDTVC
static CGFloat const IMAGE_HORIZONTAL_PADDING = 20.0f;
static CGFloat const RIGHT_HORIZONTAL_PADDING = 10.0f;
static CGFloat const LABEL_HORIZONTAL_PADDING = 8.0f;

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
    [self refresh];
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


-(CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userTweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.contentLabel.text = tweet.content;
    cell.creatorLabel.text = tweet.createdBy.name;
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    
    CGFloat imageWidth = image.size.width;
    cell.contentLabel.preferredMaxLayoutWidth = cell.contentLabel.superview.bounds.size.width - (imageWidth + IMAGE_HORIZONTAL_PADDING + LABEL_HORIZONTAL_PADDING + RIGHT_HORIZONTAL_PADDING);
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

-(TweetCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userTweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.contentLabel.text = tweet.content;
    cell.creatorLabel.text = tweet.createdBy.name;
    cell.timeLabel.text = [[tweet.time substringFromIndex:4] substringToIndex:12];
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    return cell;
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 2;
    if(y > h + reload_distance) {
        [self fetchMoreTweets];
    }
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:[NSString stringWithString:self.createdBy.screenName] forKey:@"screen_name"];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchUserTimelineHavingParameters:parameters withSuccess:^(NSMutableArray *results)
        {
            [[ManagedObjectManager sharedInstance].backgroundContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[NSNumber numberWithBool:NO] inManagedObjectContext:[ManagedObjectManager sharedInstance].backgroundContext];
                }
                NSError * error = nil;
                BOOL success = [[ManagedObjectManager sharedInstance].backgroundContext save:&error];
                if(!success) {
                    NSLog(@"Error saving in core data");
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.refreshControl endRefreshing];
                });
            }];
        }];
    });
}

-(void) fetchMoreTweets
{
    NSIndexPath *path = [self.tableView indexPathForCell:[[self.tableView visibleCells] lastObject]];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:path];
    NSString * maxId = tweet.unique;
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:[NSString stringWithString:self.createdBy.screenName] forKey:@"screen_name"];
    [parameters setObject:maxId forKey:@"max_id"];
    
    [self.activityIndicator startAnimating];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchUserTimelineHavingParameters:parameters withSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [[ManagedObjectManager sharedInstance].backgroundContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[NSNumber numberWithBool:NO] inManagedObjectContext:[ManagedObjectManager sharedInstance].backgroundContext];
                }
                NSError * error = nil;
                BOOL success = [[ManagedObjectManager sharedInstance].backgroundContext save:&error];
                if(!success) {
                    NSLog(@"Error saving in core data");
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }];
        }];
    });
}
@end
