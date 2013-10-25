//
//  UserProfileCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "UserProfileCDTVC.h"
#import "Tweet.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"
#import "UseDocument.h"

@interface UserProfileCDTVC ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCount;

@end

@implementation UserProfileCDTVC

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
    if(!self.managedObjectContext)
        [UseDocument useDocumentWithSuccess:^(UIManagedDocument *document) {
            self.managedObjectContext = document.managedObjectContext;
            [self refresh];
            //[self setLabels];
        }];
}

-(void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if(managedObjectContext) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"createdBy.screenName = %@", [TwitterOAuthClient sharedInstance].accessToken.userInfo[@"screen_name"]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [self setLabels];
    }
    else {
        self.fetchedResultsController = nil;
    }
}


-(void) setLabels
{
    NSIndexPath * index = [NSIndexPath indexPathForRow:0 inSection:0];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:index];
    User * user = tweet.createdBy;
    self.title = user.name;
    self.screenName.text = user.screenName;
    self.followersCount.text = user.followersCount;
    self.followingCount.text = user.followingCount;
    self.tweetsCount.text = user.tweetsCount;
    self.userImage.image = [[UIImage alloc]initWithData:user.thumbnail];
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
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:[[TwitterOAuthClient sharedInstance].accessToken.userInfo objectForKey:@"screen_name"] forKey:@"screen_name"];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchUserTimelineHavingParameters:parameters withSuccess:^(NSMutableArray *results)
        {
            [self.managedObjectContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[[NSNumber alloc] initWithBool:NO] inManagedObjectContext:self.managedObjectContext];;
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
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:[[TwitterOAuthClient sharedInstance].accessToken.userInfo objectForKey:@"screen_name"] forKey:@"screen_name"];
    [parameters setObject:maxId forKey:@"max_id"];
    
    [self.activityIndicator startAnimating];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchUserTimelineHavingParameters:parameters withSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.managedObjectContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inHomeTimeline:[NSNumber numberWithBool:NO] inManagedObjectContext:self.managedObjectContext];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.activityIndicator stopAnimating];
                });
            }];
        }];
    });
}


@end
