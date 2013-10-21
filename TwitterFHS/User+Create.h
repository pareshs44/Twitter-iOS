//
//  User+Create.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "User.h"

@interface User (Create)

+(User *) userWithDetails:(NSDictionary *)userDictionary inManagedContext:(NSManagedObjectContext *)context;

@end
