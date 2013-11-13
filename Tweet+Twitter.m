//
//  Feed+Twitter.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "Tweet+Twitter.h"
#import "User+Create.h"
#import "User.h"

@implementation Tweet (Twitter)

+ (Tweet *)tweetWithDetails:(NSDictionary *)tweetDictionary
             inHomeTimeline:(NSNumber *)home
     inManagedObjectContext:(NSManagedObjectContext *)context {
    Tweet *tweet = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                              ascending:NO]];
    request.predicate = [NSPredicate
                         predicateWithFormat:@"unique = %@", tweetDictionary[@"id_str"]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    NSAssert((matches && ([matches count] <= 1)), @"Error: Inconsistency in tweet core data! Can't return null for match or more than one match.");
    if(![matches count]) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                              inManagedObjectContext:context];
        tweet.unique = tweetDictionary[@"id_str"];
        tweet.content = tweetDictionary[@"text"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"EEE MMM dd HH:mm:ss z yyyy"];
        tweet.time = [dateFormat dateFromString:tweetDictionary[@"created_at"]];
        tweet.inHomeTimeline = home;
        User * user = [User userWithDetails:[tweetDictionary valueForKey:@"user"]
                           inManagedContext:context];
        tweet.createdBy = user;
    }
    else {
        tweet = [matches lastObject];
        tweet.inHomeTimeline = home;
    }
    return tweet;
}

@end
