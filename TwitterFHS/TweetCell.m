//
//  TweetCell.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/16/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"
#import "User.h"

@implementation TweetCell

CGFloat const IMAGE_HORIZONTAL_PADDING = 20.0f;
CGFloat const RIGHT_HORIZONTAL_PADDING = 10.0f;
CGFloat const LABEL_HORIZONTAL_PADDING = 8.0f;
CGFloat const IMAGE_WIDTH = 48.0f;
CGFloat const IMAGE_HEIGHT = 48.0f;
CGFloat const IMAGE_TOP_PADDING = 8.0f;
CGFloat const IMAGE_BOTTOM_PADDING = 3.0f;
CGFloat const FIXED_HEIGHT = 60.0f;

- (CGFloat)tweetCellHeightForData:(Tweet *)tweet {
    
    
    self.contentLabel.text = tweet.content;
    self.creatorLabel.text = tweet.createdBy.name;
    self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.superview.bounds.size.width - (IMAGE_WIDTH + IMAGE_HORIZONTAL_PADDING + LABEL_HORIZONTAL_PADDING + RIGHT_HORIZONTAL_PADDING);
    [self.contentView setNeedsLayout];
    CGFloat height = [self.contentView
                      systemLayoutSizeFittingSize:UILayoutFittingExpandedSize].height;
    CGFloat minHeight = IMAGE_HEIGHT + IMAGE_TOP_PADDING + IMAGE_BOTTOM_PADDING;
    return MAX(height, minHeight);
}


@end
