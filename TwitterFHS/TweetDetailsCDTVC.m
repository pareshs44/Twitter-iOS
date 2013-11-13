//
//  TweetDetailsCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "TweetDetailsCDTVC.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"
#import "ManagedObjectManager.h"
#import "SaveResults.h"

@interface TweetDetailsCDTVC ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) TwitterOAuthClient *twitterClient;
@property (strong, nonatomic) TweetCell *prototypeCell;

@end

@implementation TweetDetailsCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator stopAnimating];
    [self.refreshControl beginRefreshing];
    [self refresh];
}

- (void)setCreatedBy:(User *)createdBy {
    _createdBy = createdBy;
    self.title = createdBy.name;
    [self setupFetchedResultsController];
}

- (TwitterOAuthClient *)twitterClient {
    return [TwitterOAuthClient sharedInstance];
}

- (TweetCell *)prototypeCell {
    if(!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"userTweet"];
    }
    return _prototypeCell;
}

- (void)setupFetchedResultsController {
    NSAssert(self.createdBy.managedObjectContext, @"Main Context not set.");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                              ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"createdBy = %@", self.createdBy];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.createdBy.managedObjectContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
}

- (IBAction)refresh {
    [self fetchTweetsWithMaxId:nil withSuccess:^{
        [self.refreshControl endRefreshing];
    }];
}

- (void)fetchTweetsWithMaxId:maxId withSuccess:(void(^)())success {
    NSMutableDictionary *parameters = [NSMutableDictionary
                                       dictionaryWithObject:self.createdBy.screenName
                                       forKey:@"screen_name"];
    if(maxId) {
        [parameters setObject:maxId forKey:@"max_id"];
    }
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [self.twitterClient fetchUserTimelineHavingParameters:parameters
                                                  withSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            SaveResults *saveResults = [[SaveResults alloc] init];
            [saveResults saveInBackgroundContextTweets:results
                                        inHomeTimeline:@NO
                                           withSuccess:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    success();
                });
            }];

        }];
    });
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return [self.prototypeCell tweetCellHeightForData:tweet];
}

- (CGFloat)tableView:(UITableView *)tableView
estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FIXED_HEIGHT;
}

- (TweetCell *)tableView:(UITableView *)tableView
   cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userTweet"];
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.contentLabel.text = tweet.content;
    cell.creatorLabel.text = tweet.createdBy.name;
    NSDateFormatter *displayDateFormat = [[NSDateFormatter alloc] init];
    [displayDateFormat setDateFormat:@"MMM dd HH:mm"];
    cell.timeLabel.text = [displayDateFormat stringFromDate:tweet.time];
    UIImage *image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 2;
    __block BOOL isFetching = FALSE;
    if((y > h + reload_distance) && !isFetching) {
        isFetching = !isFetching;
        NSIndexPath *path = [self.tableView indexPathForCell:[[self.tableView visibleCells] lastObject]];
        Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:path];
        NSString *maxId = tweet.unique;
        [self.activityIndicator startAnimating];
        [self fetchTweetsWithMaxId:maxId withSuccess:^{
            isFetching = !isFetching;
            [self.activityIndicator stopAnimating];
        }];
    }
}

@end
