//
//  xyzAppDelegate.m
//  DObjectsTest
//
//  Created by Patrick Englert on 22.10.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "xyzAppDelegate.h"

@implementation xyzAppDelegate

@synthesize window = _window;

@protocol BackupServerProtocol
- (int)backup: (int) zahl;
@end;

- (void)dealloc
{
    [super dealloc];
}
	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    //NSConnection *theConnection;
    id backupServer;
    
    NSSocketPort *port = (NSSocketPort *) [[NSSocketPortNameServer sharedInstance] portForName:@"doug" host:@"*"];
    NSConnection *theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
    backupServer = [[theConnection rootProxy] retain];
    [backupServer setProtocolForProxy:@protocol(BackupServerProtocol)];
    
    int i = 2;
    
    while (true) {
        
        NSLog(@"PI ist: %d", [backupServer backup:i]);
        i++;
    }
    
    [pool drain];
}





@end
