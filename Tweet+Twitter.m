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
#import "TwitterOAuthClient.h"

@implementation Tweet (Twitter)

+(Tweet *) tweetWithDetails:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Tweet * tweet = nil;
    
    NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", tweetDictionary[@"id_str"]];
    
    // execute fetch
    NSError * error = nil;
    NSArray * matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || ([matches count] > 1)) {
        //error
    }
    else if(![matches count]) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        
        //Add values to attributes of feed here....
        tweet.unique = tweetDictionary[@"id_str"];
        tweet.content = tweetDictionary[@"text"];
        tweet.time = tweetDictionary[@"created_at"];
        //tweet.createdBy = [tweetDictionary valueForKeyPath:@"user.name"];
        //feed.thumbnail = [[NSData alloc] initWithContentsOfURL:imageURL];
        
        NSMutableDictionary * userDictionary = [NSMutableDictionary dictionaryWithObject:[tweetDictionary valueForKeyPath:@"user.name"] forKey:@"name"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.screen_name"] forKey:@"screenName"];
        [userDictionary setObject:[tweetDictionary valueForKeyPath:@"user.id_str"] forKey:@"unique"];
        NSURL * imageURL = [[NSURL alloc] initWithString:[tweetDictionary valueForKeyPath:@"user.profile_image_url"]];
        [userDictionary setObject:[[NSData alloc] initWithContentsOfURL:imageURL] forKey:@"thumbnail"];
        User * user = [User userWithDetails:userDictionary inManagedContext:context];
        tweet.createdBy = user;
    }
    else {
        tweet = [matches lastObject];
    }
    return tweet;
}

@end
