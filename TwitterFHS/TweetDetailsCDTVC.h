//
//  TweetDetailsCDTVC.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "CoreDataTableViewController.h"
@class User;

@interface TweetDetailsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) User * createdBy;

@end
