//
//  RootViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 11/7/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

-(void) setMainContext:(NSManagedObjectContext *)mainContext
{
    _mainContext = mainContext;
}

-(void) setBackgroundContext:(NSManagedObjectContext *)backgroundContext
{
    _backgroundContext = backgroundContext;
}

@end
