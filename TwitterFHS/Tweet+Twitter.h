//
//  Tweet+Twitter.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Twitter)

+(Tweet *) tweetWithDetails:(NSDictionary *)tweetDictionary inManagedObjectContext:(NSManagedObjectContext *)context;
@end
