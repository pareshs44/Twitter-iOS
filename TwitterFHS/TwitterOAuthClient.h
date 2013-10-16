//
//  TwitterOAuthClient.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/9/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFNetworking.h"

@class TwitterOAuthToken;

@interface TwitterOAuthClient : AFHTTPClient <NSCoding, NSCopying>

@property (nonatomic, strong) TwitterOAuthToken *accessToken;

+(TwitterOAuthClient *) sharedInstance;
-(void) logInToTwitterWithSuccess:(void (^)(NSMutableArray * results))success;
-(void) fetchHomeTimelineWithSuccess:(void(^)(NSMutableArray * results))success;
-(void) postTweetWithParameters:(NSMutableDictionary *) parameters;

//-(void) fetchMentionsTimelineWithSuccess:(void(^)(NSMutableArray * results))success;



@end

extern NSString * const kAFApplicationLaunchedWithURLNotification;
extern NSString * const kAFApplicationLaunchOptionsURLKey;

@interface TwitterOAuthToken : NSObject <NSCopying, NSCoding>
@property (readonly, nonatomic, copy) NSString * key;
@property (readonly, nonatomic, copy) NSString * secret;
@property (nonatomic, copy) NSString * verifier;
@property (nonatomic, strong) NSDictionary * userInfo;

-(id) initWithQueryString: (NSString *)queryString;
-(id) initWithkey:(NSString *)key secret:(NSString *)secret;
+(TwitterOAuthToken *) retrieveCredentialWithIdentifier:(NSString *)identifier;
+(BOOL) deleteCredentialWithIdentifier:(NSString *) identifier;
+(BOOL) storeCredential: (TwitterOAuthToken *) credential withIdentifier: (NSString *) identifier;


@end
