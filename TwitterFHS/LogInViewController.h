//
//  LogInViewController.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/21/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"
#import "AFOAuth1Client.h"
#import "AFJSONRequestOperation.h"
#import "TwitterClient.h"


@interface LogInViewController : UIViewController <FHSTwitterEngineAccessTokenDelegate>
@property (strong, nonatomic) AFOAuth1Client * twitterClient;

@end
