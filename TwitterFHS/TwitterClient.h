//
//  TwitterClient.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/27/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFOAuth1Client.h"

#define REQUEST_TOKEN_PATH @"/oauth/request_token"
#define AUTHORIZATION_PATH @"/oauth/authorize"
#define SUCCESS_URL_STRING @"myapp://success"
#define ACCESS_TOKEN_PATH @"/oauth/access_token"
#define ACCESS_METHOD_GET @"GET"
#define ACCESS_METHOD_POST @"POST"


@interface TwitterClient : NSObject
@property (strong, nonatomic) AFOAuth1Client *client;
@property (nonatomic, strong) AFOAuth1Token *accessToken;
@property (nonatomic, strong) NSArray * responseFromTwitterClient;

+ (TwitterClient *)sharedInstance;
-(AFOAuth1Token *) getOAuthToken;
- (void) logInWithSuccess: (void (^)(void))success;
- (void) fetchTimeLineWithSuccess: (void (^)(NSArray* responseArray))success;
-(NSArray *) fetchTimeline;
@end
