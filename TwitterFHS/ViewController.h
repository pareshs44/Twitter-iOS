//
//  ViewController.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/20/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSTwitterEngine.h"

@interface ViewController : UIViewController <FHSTwitterEngineAccessTokenDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (nonatomic) NSMutableDictionary * dict;

@end
