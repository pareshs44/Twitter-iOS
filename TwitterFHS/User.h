//
//  User.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSSet *follower;
@property (nonatomic, retain) NSSet *follows;
@property (nonatomic, retain) NSSet *tweets;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addFollowerObject:(User *)value;
- (void)removeFollowerObject:(User *)value;
- (void)addFollower:(NSSet *)values;
- (void)removeFollower:(NSSet *)values;

- (void)addFollowsObject:(User *)value;
- (void)removeFollowsObject:(User *)value;
- (void)addFollows:(NSSet *)values;
- (void)removeFollows:(NSSet *)values;

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

@end
