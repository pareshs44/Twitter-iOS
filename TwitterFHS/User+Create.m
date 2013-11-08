//
//  User+Create.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "User+Create.h"

@implementation User (Create)

+(User *) userWithDetails:(NSDictionary *)userDictionary inManagedContext:(NSManagedObjectContext *)context
{
    User * user = nil;
    if([userDictionary[@"id_str"] length]) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                                  ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", userDictionary[@"id_str"]];
        
        NSError * error;
        NSArray * matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || ([matches count] > 1)) {
            NSLog(@"Error: Inconsistency in user core data!");
        }
        else if(![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            user.name = userDictionary[@"name"];
            user.screenName = userDictionary[@"screen_name"];
            user.unique = userDictionary[@"id_str"];
            user.followersCount = [NSString stringWithFormat:@"%@", userDictionary[@"followers_count"]];
            user.followingCount = [NSString stringWithFormat:@"%@", userDictionary[@"friends_count"]];
            user.tweetsCount = [NSString stringWithFormat:@"%@", userDictionary[@"statuses_count"]];
            NSURL * imageURL = [[NSURL alloc] initWithString:[userDictionary valueForKey:@"profile_image_url"]];
            user.thumbnail = [[NSData alloc] initWithContentsOfURL:imageURL];
         }
        else {
            user = [matches lastObject];
            user.followersCount = [NSString stringWithFormat:@"%@", userDictionary[@"followers_count"]];
            user.followingCount = [NSString stringWithFormat:@"%@", userDictionary[@"friends_count"]];
            user.tweetsCount = [NSString stringWithFormat:@"%@", userDictionary[@"statuses_count"]];
            NSURL * imageURL = [[NSURL alloc] initWithString:[userDictionary valueForKey:@"profile_image_url"]];
            user.thumbnail = [[NSData alloc] initWithContentsOfURL:imageURL];
        }
    }
    return user;
}

@end;

