//
//  Feed+Twitter.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "Feed+Twitter.h"
#import "User+Create.h"

@implementation Feed (Twitter)

+(Feed *) feedWithDetails:(NSDictionary *)feedDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Feed * feed = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Feed"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", feedDictionary[@"id_str"]];
    
    // execute fetch
    NSError * error = nil;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || ([matches count] > 1)) {
        //error
    }
    else if(![matches count]) {
        feed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
        
        //Add values to attributes of feed here....
        feed.unique = feedDictionary[@"id_str"];
        feed.content = feedDictionary[@"text"];
        feed.time = feedDictionary[@"created_at"];
        feed.createdBy = [feedDictionary valueForKeyPath:@"user.name"];
        NSURL * imageURL = [[NSURL alloc] initWithString:[feedDictionary valueForKeyPath:@"user.profile_image_url"]];
        feed.thumbnail = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        NSMutableDictionary * userDictionary = [NSMutableDictionary dictionaryWithObject:@"Paresh Shukla" forKey:@"name"];
        [userDictionary setObject:@"shuklaparesh_44" forKey:@"screenName"];
        [userDictionary setObject:@"1" forKey:@"unique"];
        User * user = [User userWithDetails:userDictionary inManagedContext:context];
        feed.feedOf = user;
    }
    else {
        feed = [matches lastObject];
    }
    
    
    
    
    
    
    return feed;
}

@end
