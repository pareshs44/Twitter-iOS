//
//  Feed+Twitter.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "Feed.h"

@interface Feed (Twitter)

+(Feed *) feedWithDetails:(NSDictionary *)feedDictionary inManagedObjectContext:(NSManagedObjectContext *)context;

@end
