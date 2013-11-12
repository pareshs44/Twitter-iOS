//
//  TweetCell.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/16/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tweet;

@interface TweetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *creatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

- (CGFloat)tweetCellHeightForData:(Tweet *)tweet;

extern CGFloat const FIXED_HEIGHT;
@end
