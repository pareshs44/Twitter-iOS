//
//  TweetCell.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/16/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TweetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
