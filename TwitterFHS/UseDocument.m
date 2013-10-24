//
//  UseDocument.m
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/24/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import "UseDocument.h"

@implementation UseDocument

+(void) useDocumentWithSuccess:(void (^)(UIManagedDocument * document))success
{
    NSURL * url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"iOS7MiniTwitterDocument"];
    UIManagedDocument * document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL complete) {
              if(complete) {
                  success(document);
              }
          }];
    }
    
    else if(document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL complete) {
            if(complete) {
                success(document);
            }
        }];
    }
    
    else {
        success(document);
    }
}

@end
