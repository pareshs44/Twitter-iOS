//
//  IndexViewController.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/1/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterClient.h"
#import "TwitterOAuthClient.h"

@interface IndexViewController : UIViewController
@property (strong, nonatomic) TwitterClient * twitterClient;
@property (strong, nonatomic) TwitterOAuthClient * twitterOAuthClient;

@end
