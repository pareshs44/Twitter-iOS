//
//  Feed+Twitter.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Twitter)

+ (Tweet *)tweetWithDetails:(NSDictionary *)tweetDictionary
             inHomeTimeline:(NSNumber *)home
     inManagedObjectContext:(NSManagedObjectContext *)context;

@end
