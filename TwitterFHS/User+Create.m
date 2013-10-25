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
    if([userDictionary[@"unique"] length]) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                                  ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", userDictionary[@"unique"]];
        
        NSError * error;
        NSArray * matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || ([matches count] > 1)) {
            NSLog(@"Error: Inconsistency in core data!");
        }
        else if(![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            user.name = userDictionary[@"name"];
            user.screenName = userDictionary[@"screenName"];
            user.unique = userDictionary[@"unique"];
            user.followersCount = [NSString stringWithFormat:@"%@", userDictionary[@"followersCount"]];
            user.followingCount = [NSString stringWithFormat:@"%@", userDictionary[@"followingCount"]];
            user.tweetsCount = [NSString stringWithFormat:@"%@", userDictionary[@"tweetsCount"]];
            user.thumbnail = userDictionary[@"thumbnail"];
         }
        else {
            user = [matches lastObject];
            user.followersCount = [NSString stringWithFormat:@"%@", userDictionary[@"followersCount"]];
            user.followingCount = [NSString stringWithFormat:@"%@", userDictionary[@"followingCount"]];
            user.tweetsCount = [NSString stringWithFormat:@"%@", userDictionary[@"tweetsCount"]];
            user.thumbnail = userDictionary[@"thumbnail"];
        }
    }
    return user;
}

@end;

