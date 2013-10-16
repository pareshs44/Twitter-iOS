//
//  TwitterClient.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/27/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "TwitterClient.h"
#import "TwitterAPIKeys.h"

@implementation TwitterClient

static NSString * urlString = @"https://api.twitter.com/1.1/";

+ (TwitterClient *)sharedInstance {
    static TwitterClient *mySharedInstance = nil;
    static dispatch_once_t onceOnly;
    dispatch_once(&onceOnly, ^{
        NSLog(@"Initializing shared instance for Twitter Client");
        mySharedInstance = [[TwitterClient alloc] init];
    });
    return mySharedInstance;
}

-(void) setClient:(AFOAuth1Client *)client
{
    _client = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:urlString] key:CLIENT_KEY secret:CLIENT_SECRET];
}


- (id) init
{
    self = [super init];
    self.client = [[AFOAuth1Client alloc] initWithBaseURL:[NSURL URLWithString:urlString] key:CLIENT_KEY secret:CLIENT_SECRET];
    if(!self)
        return nil;
    return self;
    
}

- (AFOAuth1Token *) getOAuthToken
{
    [self.client authorizeUsingOAuthWithRequestTokenPath:REQUEST_TOKEN_PATH
                                          userAuthorizationPath:AUTHORIZATION_PATH
                                                    callbackURL:[NSURL URLWithString:SUCCESS_URL_STRING]
                                                accessTokenPath:ACCESS_TOKEN_PATH
                                                   accessMethod:ACCESS_METHOD_POST
                                                          scope:nil
                                                        success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                            NSLog(@"Token mil gaya: %@", accessToken);
                                                            self.accessToken = accessToken;
                                                        }
                                                        failure:^(NSError *error) {
                                                            NSLog(@"Error : %@", error);
                                                            self.accessToken = nil;
                                                        }];
    return self.accessToken;

}

- (void) logInWithSuccess: (void (^)(void))success
{
    [self.client authorizeUsingOAuthWithRequestTokenPath:REQUEST_TOKEN_PATH
                                   userAuthorizationPath:AUTHORIZATION_PATH
                                             callbackURL:[NSURL URLWithString:SUCCESS_URL_STRING]
                                         accessTokenPath:ACCESS_TOKEN_PATH
                                            accessMethod:ACCESS_METHOD_POST
                                                   scope:nil
                                                 success:^(AFOAuth1Token *accessToken, id responseObject) {
                                                     if(success)
                                                         success();
                                                 }
                                                 failure:^(NSError *error) {
                                                     NSLog(@"Error : %@", error);
                                                 }];
   
}

- (void) fetchTimeLineWithSuccess: (void (^)(NSArray* responseArray))success
{
    [self.client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self.client getPath:@"statuses/user_timeline.json"
                     parameters:nil
                        success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            
                            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                            NSMutableArray * responseArray = (NSMutableArray *) responseObject;
                            for(NSDictionary * result in responseArray) {
                                NSLog(@"Each Response time: %@", [result valueForKeyPath:@"user.name"]);
                            }
                            //NSLog(@"Timeline Response: %@", responseArray[1]);
                            if(success) {
                                success(responseArray);
                            }

                            //NSLog(@"RTVC RESULTS: %@", rtvc.results);
                        }
     
                        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            NSLog(@"ANDARError: %@", error);
                        }];
}

-(NSArray *) fetchTimeline
{
    //[self.client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self.client getPath:@"statuses/home_timeline.json"
              parameters:nil
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSMutableArray * responseDictionary = (NSMutableArray *) responseObject;
                     self.responseFromTwitterClient = responseDictionary;
                     NSLog(@"responseDictionary: %@",responseDictionary[0]);
                     NSLog(@"responseFromTwitter: %@", self.responseFromTwitterClient[0]);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"Error In fetchTimeline: %@", error);
                 }];
    NSLog(@"feeds to be returned: %@", self.responseFromTwitterClient);
    return self.responseFromTwitterClient;
}

@end
