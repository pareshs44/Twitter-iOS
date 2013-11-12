//
//  UseDocument.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/24/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ManagedObjectManager.h"
#import <CoreData/CoreData.h>

@interface ManagedObjectManager()

@property (strong, nonatomic, readwrite) NSManagedObjectContext *mainContext;
@property (strong, nonatomic, readwrite) NSManagedObjectContext *backgroundContext;

@end

@implementation ManagedObjectManager

+ (ManagedObjectManager *)sharedInstance {
    static ManagedObjectManager *mySharedInstance = nil;
    static dispatch_once_t onceOnly;
    dispatch_once(&onceOnly, ^{
        mySharedInstance = [[ManagedObjectManager alloc] init];
    });
    return mySharedInstance;
}

- (void)createContextsWithSuccess:(void (^)())success {
    NSURL *url = [[[NSFileManager defaultManager]
                    URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]
                   lastObject];
    url = [url URLByAppendingPathComponent:@"iOS7MiniTwitterDocument"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL complete) {
              if(complete) {
                  [self setManagedObjectContextFromDocument:document withSuccess:success];
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL complete) {
            if(complete) {
                [self setManagedObjectContextFromDocument:document withSuccess:success];
            }
        }];
    }
    
    else {
        [self setManagedObjectContextFromDocument:document withSuccess:success];
    }
}

- (void)contextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

- (void)setManagedObjectContextFromDocument:(UIManagedDocument *)document
                                withSuccess:(void(^)())success {
    self.mainContext = document.managedObjectContext;
    self.backgroundContext = [[NSManagedObjectContext alloc]
                              initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.backgroundContext setPersistentStoreCoordinator:[self.mainContext persistentStoreCoordinator]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextDidSave:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:self.backgroundContext];
    success();
}

@end
