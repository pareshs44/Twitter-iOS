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
    if([userDictionary[@"name"] length]) {
        NSFetchRequest * request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", userDictionary[@"name"]];
        
        NSError * error;
        NSArray * matches = [context executeFetchRequest:request error:&error];
        
        if(!matches || ([matches count] > 1)) {
            //error
        }
        else if(![matches count]) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
            user.name = userDictionary[@"name"];
            user.screenName = userDictionary[@"screenName"];
            user.unique = userDictionary[@"unique"];
         }
        else {
            user = [matches lastObject];
        }
    }
    
    return user;
}

@end;

