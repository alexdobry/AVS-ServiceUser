//
//  Server.m
//  DObjectsTest
//
//  Created by Patrick Englert on 22.10.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Server.h"

@interface BackupServer : NSObject   { }
@end

@implementation BackupServer
- (void) backup {
    NSLog(@"backuping : ");
    for(int i = 0; i < 5; i++) {
        NSLog(@".");
        [NSThread sleepForTimeInterval:1.0];
    }
}
@end