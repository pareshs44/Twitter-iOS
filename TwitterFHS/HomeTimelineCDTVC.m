//
//  HomeTimelineCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/19/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "HomeTimelineCDTVC.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"
#import "ManagedObjectManager.h"
#import "SaveResults.h"

@interface HomeTimelineCDTVC ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) TwitterOAuthClient *twitterClient;
@property (strong, nonatomic) TweetCell *prototypeCell;

@end

@implementation HomeTimelineCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self setUpFetchedResultsController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.activityIndicator stopAnimating];
    [self.refreshControl beginRefreshing];
    [self refresh];
}

- (NSManagedObjectContext *)mainContext {
    return [ManagedObjectManager sharedInstance].mainContext;
}

- (TwitterOAuthClient *)twitterClient {
    return [TwitterOAuthClient sharedInstance];
}

- (TweetCell *)prototypeCell {
    if(!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"tweet"];
    }
    return _prototypeCell;
}

- (void)setUpFetchedResultsController {
    if(self.mainContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                                  ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"inHomeTimeline = %@", @YES];
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:request
                                         managedObjectContext:self.mainContext
                                         sectionNameKeyPath:nil
                                         cacheName:nil];
    }
    else {
        NSLog(@"Main Context not set.");
    }

}

- (IBAction)refresh {
    [self fetchTweetsWithMaxId:nil withSuccess:^{
        [self.refreshControl endRefreshing];
    }];
}

- (void)fetchTweetsWithMaxId:maxId withSuccess:(void(^)())success {
    NSMutableDictionary *parameters = nil;
    if(maxId) {
        parameters = [NSMutableDictionary dictionaryWithObject:maxId
                                                        forKey:@"max_id"];
    }
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [self.twitterClient fetchHomeTimelineHavingParameters:parameters
                                                  withSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             SaveResults *saveResults = [[SaveResults alloc] init];
             [saveResults saveInBackgroundContextTweets:results
                                         inHomeTimeline:@YES
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
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.contentLabel.text = tweet.content;
    cell.creatorLabel.text = tweet.createdBy.name;
    NSDateFormatter *displayDateFormat = [[NSDateFormatter alloc] init];
    [displayDateFormat setDateFormat:@"MMM dd HH:mm"];
    cell.timeLabel.text = [displayDateFormat stringFromDate:tweet.time];
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath * indexPath = nil;
    if([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    if(indexPath) {
        if([segue.identifier isEqualToString:@"tweetDetails"]) {
            Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
            User *createdBy = tweet.createdBy;
            [segue.destinationViewController
             performSelector:@selector(setCreatedBy:) withObject:createdBy];
        }
    }
}

@end
