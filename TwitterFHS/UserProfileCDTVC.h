//
//  UserProfileCDTVC.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface UserProfileCDTVC : CoreDataTableViewController

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end
