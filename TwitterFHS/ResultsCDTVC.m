//
//  ResultsCDTVC.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ResultsCDTVC.h"
#import "Feed.h"
#import "TweetCell.h"

@implementation ResultsCDTVC

-(void) setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    
    if(managedObjectContext) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:request
                                         managedObjectContext:managedObjectContext
                                         sectionNameKeyPath:nil
                                         cacheName:nil];
        
    }
    else {
        self.fetchedResultsController = nil;
    }
}

-(TweetCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TweetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"feed"];
    Feed * feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.titleLabel.text = feed.content;

    cell.subtitleLabel.text =  feed.createdBy;              //need to set the correct value of user name and also set the image.
    
    UIImage * image = [[UIImage alloc] initWithData:feed.thumbnail];
    
    cell.imageView.image = image;

    return cell;
}
@end