//
//  ComposeTweetViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/15/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ComposeTweetViewController.h"

@interface ComposeTweetViewController ()

@property (weak, nonatomic) IBOutlet UILabel *characters;
@property (weak, nonatomic) IBOutlet UITextView *composeTweetTextView;
@property (strong, nonatomic) TwitterOAuthClient *twitterClient;

@end

@implementation ComposeTweetViewController
static int const MAX_CHARACTERS = 140;

- (TwitterOAuthClient *) twitterClient {
    return [TwitterOAuthClient sharedInstance];
}

- (IBAction)postTweet:(id)sender {
    NSMutableDictionary * parameters = [NSMutableDictionary
                                        dictionaryWithObject:[self.composeTweetTextView text]
                                        forKey:@"status"];
    [self.twitterClient postTweetWithParameters:parameters];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.composeTweetTextView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text {
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    self.characters.text = [NSString stringWithFormat:@"%u", ((newLength >MAX_CHARACTERS)?0:(MAX_CHARACTERS-newLength))];
    return (newLength > MAX_CHARACTERS) ? NO : YES;
}

@end
