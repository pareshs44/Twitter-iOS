//
//  TwitterOAuthClient.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/9/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "TwitterOAuthClient.h"
#import "AFHTTPRequestOperation.h"

#import <CommonCrypto/CommonHMAC.h>

NSString * const kTwitterApplicationLaunchedWithURLNotification = @"kAFApplicationLaunchedWithURLNotification";
NSString * const kTwitterApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";


static NSString * AFEncodeBase64WithData(NSData *data) {
    NSUInteger length = [data length];
    NSMutableData *mutableData = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    
    uint8_t *input = (uint8_t *)[data bytes];
    uint8_t *output = (uint8_t *)[mutableData mutableBytes];
    
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        
        static uint8_t const kAFBase64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        
        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = kAFBase64EncodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = kAFBase64EncodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? kAFBase64EncodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? kAFBase64EncodingTable[(value >> 0)  & 0x3F] : '=';
    }
    
    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

static NSString * AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    static NSString * const kAFCharactersToBeEscaped = @":/?&=;+!@#$()',*";
    static NSString * const kAFCharactersToLeaveUnescaped = @"[].";
    
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kAFCharactersToLeaveUnescaped, (__bridge CFStringRef)kAFCharactersToBeEscaped, CFStringConvertNSStringEncodingToEncoding(encoding));
}




static NSDictionary * AFParametersFromQueryString(NSString *queryString) {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (queryString) {
        NSScanner *parameterScanner = [[NSScanner alloc] initWithString:queryString];
        NSString *name = nil;
        NSString *value = nil;
        
        while (![parameterScanner isAtEnd]) {
            name = nil;
            [parameterScanner scanUpToString:@"=" intoString:&name];
            [parameterScanner scanString:@"=" intoString:NULL];
            
            value = nil;
            [parameterScanner scanUpToString:@"&" intoString:&value];
            [parameterScanner scanString:@"&" intoString:NULL];
            
            if (name && value) {
                parameters[[name stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] = [value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            }
        }
    }
    
    return parameters;
}

static inline BOOL AFQueryStringValueIsTrue(NSString *value) {
    return value && [[value lowercaseString] hasPrefix:@"t"];
}

static inline NSString * AFNounce() {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    
    return (NSString *)CFBridgingRelease(string);
}

static inline NSString * AFHMACSHA1Signature(NSURLRequest *request, NSString *consumerSecret, NSString *tokenSecret, NSStringEncoding stringEncoding) {
    NSString *secret = tokenSecret ? tokenSecret : @"";
    NSString *secretString = [NSString stringWithFormat:@"%@&%@", AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(consumerSecret, stringEncoding), AFPercentEscapedQueryStringPairMemberFromStringWithEncoding(secret, stringEncoding)];
    NSData *secretStringData = [secretString dataUsingEncoding:stringEncoding];
    
    NSString *queryString = AFPercentEscapedQueryStringPairMemberFromStringWithEncoding([[[[[request URL] query] componentsSeparatedByString:@"&"] sortedArrayUsingSelector:@selector(compare:)] componentsJoinedByString:@"&"], stringEncoding);
    NSString *requestString = [NSString stringWithFormat:@"%@&%@&%@", [request HTTPMethod], AFPercentEscapedQueryStringPairMemberFromStringWithEncoding([[[request URL] absoluteString] componentsSeparatedByString:@"?"][0], stringEncoding), queryString];
    NSData *requestStringData = [requestString dataUsingEncoding:stringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CCHmacContext cx;
    CCHmacInit(&cx, kCCHmacAlgSHA1, [secretStringData bytes], [secretStringData length]);
    CCHmacUpdate(&cx, [requestStringData bytes], [requestStringData length]);
    CCHmacFinal(&cx, digest);
    
    return AFEncodeBase64WithData([NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH]);
}

NSString * const kTwitterOAuth1CredentialServiceName = @"AFOAuthCredentialService";

static NSDictionary * AFKeyChainQueryDictionaryWithIdentifier(NSString * identifier)
{
    return @{(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
             (__bridge id)kSecAttrAccount: identifier,
             (__bridge id)kSecAttrService: kTwitterOAuth1CredentialServiceName
             };
}




#pragma mark - TwitterOAuthToken

@interface TwitterOAuthToken ()
@property (readwrite, nonatomic, copy) NSString * key;
@property (readwrite, nonatomic, copy) NSString * secret;

@end

@implementation TwitterOAuthToken

-(id) initWithQueryString: (NSString *)queryString
{
    NSDictionary * attributes = AFParametersFromQueryString(queryString);
    
    if([attributes count] == 0) {
        return nil;
    }
    
    NSString * key = attributes[@"oauth_token"];
    NSString * secret = attributes[@"oauth_token_secret"];
    self = [self initWithkey: key secret: secret];
    if(!self) {
        return nil;
    }
    
    NSMutableDictionary * mutableUserInfo = [attributes mutableCopy];
    [mutableUserInfo removeObjectsForKeys:@[@"oauth_token", @"oauth_token_secret"]];
    
    if([mutableUserInfo count] > 0) {
        self.userInfo = [NSDictionary dictionaryWithDictionary:mutableUserInfo];
    }
    return self;
    
    
}

-(id) initWithkey:(NSString *)key secret:(NSString *)secret
{
    self = [super init];
    if(!self) {
        return nil;
    }
    self.key = key;
    self.secret = secret;
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = [decoder decodeObjectForKey:@"key"];
    self.secret = [decoder decodeObjectForKey:@"secret"];
    self.verifier = [decoder decodeObjectForKey:@"verifier"];
    self.userInfo = [decoder decodeObjectForKey:@"userInfo"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.key forKey:@"key"];
    [coder encodeObject:self.secret forKey:@"secret"];
    [coder encodeObject:self.verifier forKey:@"verifier"];
    [coder encodeObject:self.userInfo forKey:@"userInfo"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TwitterOAuthToken *copy = [[[self class] allocWithZone:zone] init];
    copy.key = self.key;
    copy.secret = self.secret;
    copy.verifier = self.verifier;
    copy.userInfo = self.userInfo;
    
    return copy;
}


@end




@interface TwitterOAuthClient()

@property (readwrite, nonatomic, strong) id applicationLaunchNotificationObserver;

- (NSDictionary *)OAuthParameters;
- (NSString *)OAuthSignatureForMethod:(NSString *)method
                                 path:(NSString *)path
                           parameters:(NSDictionary *)parameters
                                token:(TwitterOAuthToken *)token;
- (NSString *)authorizationHeaderForMethod:(NSString*)method
                                      path:(NSString*)path
                                parameters:(NSDictionary *)parameters;
@end



@implementation TwitterOAuthClient

static NSString * const URL_STRING = @"https://api.twitter.com/1.1/";

static NSString * const OAUTH_VERSION = @"1.0";
static NSString * const CLIENT_KEY = @"R9sI6x6sZQdFzHK912tIQw";
static NSString * const CLIENT_SECRET = @"9xFxAYxaTFFmSEJj67lBwDHKAzWakSst0xiJtRcniDs";
static NSString * const CALLBACK_URL_STRING = @"myapp://success";
static NSString * const SIGNATURE_METHOD = @"HMAC-SHA1";
static NSString * const OAUTH_ACCESS_METHOD = @"GET";

static NSString * const REQUEST_TOKEN_PATH = @"/oauth/request_token";
static NSString * const ACCESS_TOKEN_PATH = @"/oauth/access_token";
static NSString * const AUTHORIZATION_PATH = @"/oauth/authorize";



+(TwitterOAuthClient *) sharedInstance
{
    static TwitterOAuthClient * mySharedInstance = nil;
    static dispatch_once_t onceOnly;
    dispatch_once(&onceOnly, ^{
        mySharedInstance = [[TwitterOAuthClient alloc] init];
    });
    return mySharedInstance;
}


- (id)init
{
    self = [super initWithBaseURL:[NSURL URLWithString:URL_STRING]];
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    return self;
}

- (void)dealloc
{
    self.applicationLaunchNotificationObserver = nil;
}

- (void)setApplicationLaunchNotificationObserver:(id)applicationLaunchNotificationObserver
{
    if (_applicationLaunchNotificationObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_applicationLaunchNotificationObserver];
    }
    
    [self willChangeValueForKey:@"applicationLaunchNotificationObserver"];
    _applicationLaunchNotificationObserver = applicationLaunchNotificationObserver;
    [self didChangeValueForKey:@"applicationLaunchNotificationObserver"];
}

-(NSDictionary *) OAuthParameters
{
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"oauth_version"] = OAUTH_VERSION;
    parameters[@"oauth_signature_method"] = SIGNATURE_METHOD;
    parameters[@"oauth_consumer_key"] = CLIENT_KEY;
    parameters[@"oauth_timestamp"] = [@(floor([[NSDate date] timeIntervalSince1970])) stringValue];
    parameters[@"oauth_nonce"] = AFNounce();
    return parameters;
}




-(NSString *) OAuthSignatureForMethod:(NSString *)method
                                 path:(NSString *)path
                           parameters:(NSDictionary *)parameters
                                token:(TwitterOAuthToken *)token
{
    NSMutableURLRequest * request = [super requestWithMethod:@"GET" path:path parameters:parameters];
    [request setHTTPMethod:method];
    
    NSString * tokenSecret = token? token.secret:nil;
    return AFHMACSHA1Signature(request, CLIENT_SECRET, tokenSecret, self.stringEncoding);
}

-(NSString *) authorizationHeaderForMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    static NSString * const kAFOAuth1AuthorizationFormatString = @"OAuth %@";
    NSMutableDictionary * mutableParameters = parameters ? [parameters mutableCopy] : [NSMutableDictionary dictionary];
    NSMutableDictionary * mutableAuthorizationParameters = [NSMutableDictionary dictionary];
    
    [mutableAuthorizationParameters addEntriesFromDictionary:[self OAuthParameters]];
    if(self.accessToken) {
        mutableAuthorizationParameters[@"oauth_token"] = self.accessToken.key;
    }
    
    [mutableParameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && [key hasPrefix:@"oauth_"]) {
            mutableAuthorizationParameters[key] = obj;
        }
    }];

    
    [mutableParameters addEntriesFromDictionary:mutableAuthorizationParameters];
    mutableAuthorizationParameters[@"oauth_signature"] = [self OAuthSignatureForMethod:method path:path parameters:mutableParameters token:self.accessToken];
    NSArray * sortedComponents = [[AFQueryStringFromParametersWithEncoding(mutableAuthorizationParameters, self.stringEncoding) componentsSeparatedByString:@"&"] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSMutableArray * mutableComponents = [NSMutableArray array];
    
    for(NSString * component in sortedComponents) {
        NSArray * subComponents = [component componentsSeparatedByString:@"="];
        if([subComponents count] == 2) {
            [mutableComponents addObject:[NSString stringWithFormat:@"%@=\"%@\"", subComponents[0], subComponents[1]]];
        }
    }
    
    return [NSString stringWithFormat:kAFOAuth1AuthorizationFormatString, [mutableComponents componentsJoinedByString:@", "]];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
    NSMutableDictionary *mutableParameters = [parameters mutableCopy];
    for (NSString *key in parameters) {
        if ([key hasPrefix:@"oauth_"]) {
            [mutableParameters removeObjectForKey:key];
        }
    }
    
    NSMutableURLRequest *request = [super requestWithMethod:method path:path parameters:mutableParameters];
    
    NSDictionary *authorizationParameters = parameters;
    if ([method isEqualToString:@"POST"]) {
        authorizationParameters = ([[request valueForHTTPHeaderField:@"Content-Type"] hasPrefix:@"application/x-www-form-urlencoded"] ? parameters : nil);
    }
    
    [request setValue:[self authorizationHeaderForMethod:method path:path parameters:authorizationParameters] forHTTPHeaderField:@"Authorization"];
    [request setHTTPShouldHandleCookies:NO];
    
    return request;
}

-(void) logInToTwitterWithSuccess:(void (^)(TwitterOAuthToken * accessToken))success
{
    NSMutableDictionary * parameters = [[self OAuthParameters] mutableCopy];
    NSURL * callbackURL = [NSURL URLWithString:CALLBACK_URL_STRING];
    parameters[@"oauth_callback"] = [callbackURL absoluteString];
    
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:REQUEST_TOKEN_PATH parameters:parameters];
    [request setHTTPBody:nil];
    
    AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        __block TwitterOAuthToken *requestToken = [[TwitterOAuthToken alloc] initWithQueryString:operation.responseString];
        
        
        self.applicationLaunchNotificationObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kTwitterApplicationLaunchedWithURLNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            NSURL *url = [[notification userInfo] valueForKey:kTwitterApplicationLaunchOptionsURLKey];
            requestToken.verifier = [AFParametersFromQueryString([url query]) valueForKey:@"oauth_verifier"];
            
            self.accessToken = requestToken;
            NSMutableDictionary * parameters = [[self OAuthParameters] mutableCopy];
            parameters[@"oauth_token"] = requestToken.key;
            parameters[@"oauth_verifier"] = requestToken.verifier;
            
            NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:ACCESS_TOKEN_PATH parameters:parameters];
            
            AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                self.accessToken = [[TwitterOAuthToken alloc] initWithQueryString:operation.responseString];
                if(success) {
                    success(self.accessToken);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
            [self enqueueHTTPRequestOperation:operation];

        }];
        
        NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
        parameters[@"oauth_token"] = requestToken.key;
        NSMutableURLRequest * request = [super requestWithMethod:@"GET" path:AUTHORIZATION_PATH parameters:parameters];
        [request setHTTPShouldHandleCookies:NO];
        [[UIApplication sharedApplication] openURL:[request URL]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [self enqueueHTTPRequestOperation:operation];
}

-(void) verifyUserCredentialsWithSuccess:(void(^)(NSMutableArray * results))success
{
    NSString * accountVerifyURL = @"account/verify_credentials.json";
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:accountVerifyURL parameters:nil];
    AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray * results = (NSMutableArray *)responseObject;
        if(success) {
            success(results);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [self enqueueHTTPRequestOperation:operation];
}


-(void) fetchHomeTimelineHavingParameters:(NSMutableDictionary *)parameters WithSuccess:(void(^)(NSMutableArray * results))success
{
    NSString * homeTimelineURL = @"statuses/home_timeline.json";
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:homeTimelineURL parameters:parameters];
    AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray * results = (NSMutableArray *)responseObject;
        if(success) {
            success(results);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
    }];
    [self enqueueHTTPRequestOperation:operation];
}

-(void) fetchUserTimelineHavingParameters:(NSMutableDictionary *)parameters withSuccess:(void(^)(NSMutableArray * results))success
{
    NSString * userTimelineURL = @"statuses/user_timeline.json";
    NSMutableURLRequest * request = [self requestWithMethod:@"GET" path:userTimelineURL parameters:parameters];
    AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray * results = (NSMutableArray *)responseObject;
        if(success) {
            success(results);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [self enqueueHTTPRequestOperation:operation];
}



-(void) postTweetWithParameters:(NSMutableDictionary *) parameters
{
    NSString * postTweetURL = @"statuses/update.json";
    NSMutableURLRequest * request = [self requestWithMethod:@"POST" path:postTweetURL parameters:parameters];
    AFHTTPRequestOperation * operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Tweet Posted");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [self enqueueHTTPRequestOperation:operation];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    self.accessToken = [decoder decodeObjectForKey:@"accessToken"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.accessToken forKey:@"accessToken"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TwitterOAuthClient *copy = [[[self class] allocWithZone:zone] init];
    copy.accessToken = self.accessToken;    
    return copy;
}

@end


