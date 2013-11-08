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

+(Tweet *) tweetWithDetails:(NSDictionary *)tweetDictionary inHomeTimeline:(NSNumber *)home inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tweet * tweet = nil;
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique" ascending:NO]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", tweetDictionary[@"id_str"]];

    NSError * error = nil;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    if(!matches || ([matches count] > 1)) {
        
        NSLog(@"Error: Inconsistency in tweet core data!");
    }
    else if(![matches count]) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        tweet.unique = tweetDictionary[@"id_str"];
        tweet.content = tweetDictionary[@"text"];
        tweet.time = tweetDictionary[@"created_at"];
        tweet.inHomeTimeline = home;
        NSMutableDictionary * userDictionary = [NSMutableDictionary dictionaryWithObject:[tweetDictionary valueForKeyPath:@"user.name"] forKey:@"name"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.screen_name"] forKey:@"screenName"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.id_str"] forKey:@"unique"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.followers_count"] forKey:@"followersCount"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.friends_count"] forKey:@"followingCount"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.statuses_count"] forKey:@"tweetsCount"];

        NSURL * imageURL = [[NSURL alloc] initWithString:[tweetDictionary valueForKeyPath:@"user.profile_image_url"]];
        [userDictionary setObject:[[NSData alloc] initWithContentsOfURL:imageURL] forKey:@"thumbnail"];
        User * user = [User userWithDetails:[tweetDictionary valueForKey:@"user"] inManagedContext:context];
        tweet.createdBy = user;
    }
    else {
        tweet = [matches lastObject];
    }
    return tweet;
}

@end
