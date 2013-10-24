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
#import "UseDocument.h"

@interface HomeTimelineCDTVC ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

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
        [UseDocument useDocumentWithSuccess:^(UIManagedDocument *document) {
            self.managedObjectContext = document.managedObjectContext;
            [self refresh];
        }];
}

//-(void) useMiniTwitterDocument
//{
//    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
//    url = [url URLByAppendingPathComponent:@"iOS7MiniTwitterDocument"];
//    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
//    
//    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
//        [document saveToURL:url
//           forSaveOperation:UIDocumentSaveForCreating
//          completionHandler:^(BOOL success) {
//              if(success) {
//                  self.managedObjectContext = document.managedObjectContext;
//                  [self refresh];
//              }
//          }];
//    }
//    
//    else if(document.documentState == UIDocumentStateClosed) {
//        [document openWithCompletionHandler:^(BOOL success) {
//            if(success) {
//                self.managedObjectContext = document.managedObjectContext;
//                [self refresh];
//            }
//        }];
//    }
//    
//    else {
//        self.managedObjectContext = document.managedObjectContext;
//        [self refresh];
//    }
//}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        //NSArray * feeds = [client fetchTimeline];
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineWithSuccess:^(NSMutableArray *results) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

-(CGFloat) tableView:(UITableView *) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = tweet.content;
    NSLog(@"tweet content: %@", tweet.content);
    cell.subtitleLabel.text = tweet.createdBy.name;
    UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
    cell.thumbnailImageView.image = image;
    CGFloat imageWidth = image.size.width;
    NSLog(@"imageWidth: %f", imageWidth);
    NSLog(@"boundsWidth: %f", self.tableView.bounds.size.width);
    NSLog(@"superViewBoundsWidth: %f", cell.titleLabel.superview.bounds.size.width);
    cell.titleLabel.preferredMaxLayoutWidth = cell.titleLabel.superview.bounds.size.width - (imageWidth + 20.0f + 8.0f + 10.0f);    //tableView.bounds.size.width -33 - 20 - imageWidth - 8 - 10 - (imageWidth + 48.0f);
    NSLog(@"maxLayoutWidth: %f", cell.titleLabel.preferredMaxLayoutWidth);
    [cell.contentView setNeedsLayout];
    [cell.contentView layoutIfNeeded];
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    NSLog(@"rowHeight: %f", height);
    return height + 1.0f;
    
    
//    
//    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    UIImage * image = [UIImage imageWithData:tweet.createdBy.thumbnail];
//    CGFloat imageWidth = image.size.width;
//    CGSize constraints = CGSizeMake(tableView.bounds.size.width - (imageWidth + 48.0f), 20000.0f);
//    //CGSize tweetContentSize = [tweet.content boundingRectWithSize:constraints options:<#(NSStringDrawingOptions)#> attributes:<#(NSDictionary *)#> context:];
//    CGSize tweetContentSize = [tweet.content sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] constrainedToSize:constraints lineBreakMode:NSLineBreakByWordWrapping];
//    CGSize tweetTitleSize = [tweet.createdBy.name sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] constrainedToSize:constraints lineBreakMode:NSLineBreakByWordWrapping];
//    
//    return tweetContentSize.height + tweetTitleSize.height + 28.0f;// + 40.0f;
    
    
    
    
    
    
//    
//    MTTweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    id tweetMessage = tweet.tweetMessage;
//    CGSize constraint = CGSizeMake(tableView.bounds.size.width - (CELL_MARGIN_LEFT + CELL_MARGIN_BETWEEN_PROFILE_PIC_AND_RIGHT_CONTENT + PROFILE_PICTURE_WIDTH + CELL_MARGIN_RIGHT), 20000.0f);
//    
//    CGSize tweetMessageSize = [tweetMessage sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    
//    CGSize tweetedBySize = [tweet.tweetedBy.name sizeWithFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
//    
//    return (CELL_MARGIN_TOP*2 + CELL_MARGIN_BOTTOM + tweetedBySize.height + tweetMessageSize.height);
    
}

-(TweetCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tweet"];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //[cell.titleLabel sizeToFit];
    //[cell.titleLabel ali]
    cell.titleLabel.text = tweet.content;
    NSLog(@"Cell k andar tweetContent: %@", tweet.content);
    NSLog(@"Cell k andar labelText: %@", cell.titleLabel.text);
    cell.subtitleLabel.text = tweet.createdBy.name;
    //cell.titleLabel.text = tweet.createdBy.screenName;
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
    float reload_distance = 10;
    if(y > h + reload_distance) {
        [self fetchMoreTweets];
    }
}

-(void) fetchMoreTweets
{
    NSArray *visibleRows = [self.tableView visibleCells];
    UITableViewCell *lastVisibleCell = [visibleRows lastObject];
    NSIndexPath *path = [self.tableView indexPathForCell:lastVisibleCell];
    Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:path];
    NSString * maxId = tweet.unique;
    
    [self.activityIndicator startAnimating];
    dispatch_queue_t feedQ = dispatch_queue_create("Feed Fetch", NULL);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    dispatch_async(feedQ, ^{
        [[TwitterOAuthClient sharedInstance] fetchHomeTimelineAfterId:(NSString *)maxId WithSuccess:^(NSMutableArray *results) {
            NSLog(@"%@", results);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.managedObjectContext performBlock:^{
                for(NSDictionary * tweet in results) {
                    [Tweet tweetWithDetails:tweet inManagedObjectContext:self.managedObjectContext];
                }
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

@end
