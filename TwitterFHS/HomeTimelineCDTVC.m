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
#import "ManagedObjectManager.h"
#import "RootViewController.h"

@interface HomeTimelineCDTVC ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) RootViewController * rootTabBarController;

@end

@implementation HomeTimelineCDTVC
static CGFloat const IMAGE_HORIZONTAL_PADDING = 20.0f;
static CGFloat const RIGHT_HORIZONTAL_PADDING = 10.0f;
static CGFloat const LABEL_HORIZONTAL_PADDING = 8.0f;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self setUpFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refresh];
}

- (RootViewController *)rootTabBarController
{
    return (RootViewController *) self.tabBarController;
}

- (void)setUpFetchedResultsController
{
    if(self.rootTabBarController.mainContext) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"inHomeTimeline = %@", [NSNumber numberWithBool:YES]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.rootTabBarController.mainContext sectionNameKeyPath:nil cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }

}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineHavingParameters:nil WithSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

            [self.rootTabBarController.backgroundContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[NSNumber numberWithBool:YES] inManagedObjectContext:self.rootTabBarController.backgroundContext];
                }
                NSError * error = nil;
                BOOL success = [self.rootTabBarController.backgroundContext save:&error];
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
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:maxId forKey:@"max_id"];
    [self.activityIndicator startAnimating];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineHavingParameters:parameters WithSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
            [self.rootTabBarController.backgroundContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[NSNumber numberWithBool:YES] inManagedObjectContext:self.rootTabBarController.backgroundContext];
                }
                NSError * error = nil;
                BOOL success = [self.rootTabBarController.backgroundContext save:&error];
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

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath * indexPath = nil;
    if([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if(indexPath) {
        if([segue.identifier isEqualToString:@"tweetDetails"]) {
            Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
            User * createdBy = tweet.createdBy;
            [segue.destinationViewController performSelector:@selector(setCreatedBy:) withObject:createdBy];
        }
    }
}


-(CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
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
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
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

@end
