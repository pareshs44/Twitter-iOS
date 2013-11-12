//
//  SaveResults.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 11/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "SaveResults.h"
#import <CoreData/CoreData.h>
#import "ManagedObjectManager.h"
#import "Tweet+Twitter.h"

@implementation SaveResults

- (NSManagedObjectContext *)backgroundContext {
    return [ManagedObjectManager sharedInstance].backgroundContext;
}

- (void)saveInBackgroundContextTweets:(NSMutableArray *)tweets
                       inHomeTimeline:(NSNumber *)isInHome
                           withSuccess:(void (^)())success {
    [self.backgroundContext performBlock:^{
        for(NSDictionary * tweet in tweets) {
            [Tweet tweetWithDetails:tweet
                     inHomeTimeline:isInHome
             inManagedObjectContext:self.backgroundContext];
        }
        NSError *error = nil;
        BOOL didSave = [self.backgroundContext save:&error];
        if(!didSave) {
            NSLog(@"Error saving in core data");
        }
        success();
    }];
}
@end
