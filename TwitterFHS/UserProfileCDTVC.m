//
//  UserProfileCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "UserProfileCDTVC.h"
#import "Tweet+Twitter.h"
#import "User.h"
#import "TweetCell.h"
#import "TwitterOAuthClient.h"
#import "ManagedObjectManager.h"
#import "SaveResults.h"

@interface UserProfileCDTVC ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *tweetsCount;
@property (weak, nonatomic) NSManagedObjectContext *mainContext;
@property (weak, nonatomic) TwitterOAuthClient *twitterClient;
@property (strong, nonatomic) TweetCell *prototypeCell;
@property (strong, nonatomic) UIImage *profileImage;

@end

@implementation UserProfileCDTVC

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
    [self setUpFetchedResultsController];
}


-(void) viewWillAppear:(BOOL)animated
{
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
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"userProfileTweet"];
    }
    return _prototypeCell;
}

- (void)setProfileImage:(UIImage *)profileImage
{
    _profileImage = profileImage;
}

- (void)setUpFetchedResultsController
{
    NSAssert(self.mainContext, @"Main Context not set.");
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                              ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"createdBy.screenName = %@",
                         self.twitterClient.accessToken.userInfo[@"screen_name"]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:request
                                     managedObjectContext:self.mainContext
                                     sectionNameKeyPath:nil
                                     cacheName:nil];
    [self setLabels];
}

-(void) setLabels
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:index];
    User *user = tweet.createdBy;
    self.title = user.name;
    self.screenName.text = user.screenName;
    self.followersCount.text = [NSString stringWithFormat:@"%@", user.followersCount];
    self.followingCount.text = [NSString stringWithFormat:@"%@", user.followingCount];
    self.tweetsCount.text = [NSString stringWithFormat:@"%@", user.tweetsCount];
    NSURL *imageURL = [[NSURL alloc]
                       initWithString:user.imageURL];
    self.profileImage = [UIImage imageWithData:
                         [NSData dataWithContentsOfURL:imageURL]];
    self.userImage.image = self.profileImage;
}

- (IBAction)refresh {
    [self fetchTweetsWithMaxId:nil withSuccess:^{
        [self.refreshControl endRefreshing];
    }];
}

- (void)fetchTweetsWithMaxId:maxId withSuccess:(void(^)())success {
    NSMutableDictionary *parameters = [NSMutableDictionary
                                       dictionaryWithObject:
                                       [self.twitterClient.accessToken.userInfo
                                        objectForKey:@"screen_name"]
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
    return UITableViewAutomaticDimension;
}

- (TweetCell *)tableView:(UITableView *)tableView
   cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userProfileTweet"];
    Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.contentLabel.text = tweet.content;
    cell.creatorLabel.text = tweet.createdBy.name;
    NSDateFormatter *displayDateFormat = [[NSDateFormatter alloc] init];
    [displayDateFormat setDateFormat:@"MMM dd HH:mm"];
    cell.timeLabel.text = [displayDateFormat stringFromDate:tweet.time];
    cell.thumbnailImageView.image = self.profileImage;
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
