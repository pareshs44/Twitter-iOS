//
//  ResultsTableViewController.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 9/25/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ResultsTableViewController.h"

@interface ResultsTableViewController ()

@end

@implementation ResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"Number of rows: %lu", (unsigned long)[self.results count]);
    return [self.results count];
}


-(NSString *) titleForRow: (NSUInteger) row
{
    return self.results[row][@"text"];
}


-(NSString *) subtitleForRow: (NSUInteger) row
{
    return self.results[row][@"user"][@"name"];
}

-(NSString *) imageURLForRow: (NSUInteger) row
{
    return self.results[row][@"user"][@"profile_image_url"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.spinner startAnimating];
    static NSString *CellIdentifier = @"resultsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
    {
        NSLog(@"ye kaise bey!!");
    }

    cell.textLabel.text = [self titleForRow:indexPath.row];
    //NSLog(@"Title: %@", [self titleForRow:indexPath.row]);
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    //NSLog(@"Subtitle: %@", [self subtitleForRow:indexPath.row]);
    NSURL * imageURL = [[NSURL alloc] initWithString:[self imageURLForRow:indexPath.row]];
    NSData * imageData = [[NSData alloc] initWithContentsOfURL:imageURL];
    UIImage * image = [[UIImage alloc] initWithData:imageData];
    
    cell.imageView.image = image;

    //[self.spinner stopAnimating];
    //cell.
    // Configure the cell...
    
    return cell;
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

@end
