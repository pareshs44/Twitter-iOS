//
//  SaveResults.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 11/8/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SaveResults : NSObject

@property (strong, nonatomic) NSManagedObjectContext *backgroundContext;
- (void)saveInBackgroundContextTweets:(NSMutableArray *)tweets
                       inHomeTimeline:(NSNumber *)isInHome
                          withSuccess:(void (^)())success;

@end
