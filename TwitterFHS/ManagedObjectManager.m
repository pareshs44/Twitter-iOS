//
//  UseDocument.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/24/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "ManagedObjectManager.h"
#import <CoreData/CoreData.h>

@implementation ManagedObjectManager

+(ManagedObjectManager *) sharedInstance
{
    static ManagedObjectManager * mySharedInstance = nil;
    static dispatch_once_t onceOnly;
    dispatch_once(&onceOnly, ^{
        mySharedInstance = [[ManagedObjectManager alloc] init];
    });
    return mySharedInstance;
}

-(void) createContextsWithSuccess:(void (^)())success
{
    void (^setManagedObjectContext) (UIManagedDocument *, void(^)(void)) = ^(UIManagedDocument * document, void(^success)()){
        self.mainContext = document.managedObjectContext;
        dispatch_queue_t backgroundContextQ = dispatch_queue_create("BackgroundContext", NULL);
        dispatch_async(backgroundContextQ, ^{
            self.backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [self.backgroundContext setPersistentStoreCoordinator:[self.mainContext persistentStoreCoordinator]];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:self.backgroundContext];
            success();
        });
        
    };
    
    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"iOS7MiniTwitterDocument"];
    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL complete) {
              if(complete) {
                  setManagedObjectContext(document, success);
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL complete) {
            if(complete) {
                setManagedObjectContext(document, success);
            }
        }];
    }
    
    else {
        setManagedObjectContext(document, success);
    }
}

-(void) contextDidSave:(NSNotification *) notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    });
}

@end
