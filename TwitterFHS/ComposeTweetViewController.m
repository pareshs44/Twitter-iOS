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

@end

@implementation ComposeTweetViewController

- (IBAction)postTweet:(id)sender
{
    self.twitterOAuthClient = [TwitterOAuthClient sharedInstance];
    NSMutableDictionary * parameters = [NSMutableDictionary dictionary];
    parameters[@"status"] = [self.composeTweettTextView text];
    [self.twitterOAuthClient postTweetWithParameters:parameters];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.composeTweettTextView becomeFirstResponder];
}

-(BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    self.characters.text = [NSString stringWithFormat:@"%u", ((newLength >140)?0:(140-newLength))];
    return (newLength > 140) ? NO : YES;
}

@end
