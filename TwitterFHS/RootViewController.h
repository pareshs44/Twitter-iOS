//
//  RootViewController.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 11/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITabBarController

@property (strong, nonatomic) NSManagedObjectContext * mainContext;
@property (strong, nonatomic) NSManagedObjectContext * backgroundContext;

@end
