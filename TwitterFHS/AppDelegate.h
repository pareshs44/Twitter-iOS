//
//  AppDelegate.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/20/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFJSONRequestOperation.h"
#import "AFOAuth1Client.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AFOAuth1Client * twitterClient;
@end
