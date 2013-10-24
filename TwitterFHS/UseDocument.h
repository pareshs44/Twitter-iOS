//
//  UseDocument.h
//  TwitterFHS
//
//  Created by Paresh Shukla on 10/24/13.
//  Copyright (c) 2013 Paresh Shukla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UseDocument : NSObject

+(void) useDocumentWithSuccess:(void (^)(UIManagedDocument * document))success;

@end
