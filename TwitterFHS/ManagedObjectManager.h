//
//  UseDocument.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/24/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ManagedObjectManager : NSObject

@property (strong, nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (strong, nonatomic, readonly) NSManagedObjectContext *backgroundContext;
+ (ManagedObjectManager *)sharedInstance;
- (void)createContextsWithSuccess:(void (^)())success;

@end
