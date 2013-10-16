//
//  Feed.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/9/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) User *feedOf;

@end
