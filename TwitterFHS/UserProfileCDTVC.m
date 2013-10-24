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

@interface UserProfileCDTVC ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end

@implementation UserProfileCDTVC

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
        [[TwitterOAuthClient sharedInstance] fetchTimelineOfUser:[TwitterOAuthClient sharedInstance].accessToken.userInfo[@"screen_name"] withSuccess:^(NSMutableArray *results)
        {
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
        request.predicate = [NSPredicate predicateWithFormat:@"createdBy.screenName = %@", [TwitterOAuthClient sharedInstance].accessToken.userInfo[@"screen_name"]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}


-(TweetCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    TweetCell * cell;
//    if(indexPath.section == 0) {
//        cell = [tableView dequeueReusableCellWithIdentifier:@"booga"];
//    }
    
        TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"userTweet"];
        //indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.titleLabel.text = tweet.content;
        cell.subtitleLabel.text = tweet.createdBy.name;
        //cell.titleLabel.text = tweet.createdBy.screenName;
        UIImage * image = [[UIImage alloc] initWithData:tweet.createdBy.thumbnail];
        cell.thumbnailImageView.image = image;
    self.userImage.image = image;
    return cell;
}

//-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 2;
//}
//
//-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return (section == 0) ? 1 : [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects];
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//	return [NSString stringWithFormat:@"%ld", (long)section];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//	if([title isEqualToString:@"0"]) return 0;
//    else return 1;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return @[@"0", @"1"];
//}
//

//-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSIndexPath * indexPath = nil;
//    if([sender isKindOfClass:[UITableViewCell class]]) {
//        indexPath = [self.tableView indexPathForCell:sender];
//    }
//    
//    if(indexPath) {
//        if([segue.identifier isEqualToString:@"tweetDetails"]) {
//            Tweet * tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
//            User * createdBy = tweet.createdBy;
//            [segue.destinationViewController performSelector:@selector(setCreatedBy:) withObject:createdBy];
//        }
//    }
//}

@end
