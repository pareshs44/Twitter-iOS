//
//  ComposeTweetViewController.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/15/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TwitterOAuthClient.h"

@interface ComposeTweetViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *composeTweettTextView;
@property (strong, nonatomic) TwitterOAuthClient * twitterOAuthClient;

@end
