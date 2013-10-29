//
//  xyzAppDelegate.m
//  DObjectsTest
//
//  Created by Patrick Englert on 22.10.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "xyzAppDelegate.h"
#import "MathProtocol.h"

@implementation xyzAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

NSLock* myLock;
static unsigned int counter = 2;

- (int) incrementValue
{
    int newNumber;
    [myLock lock];
    newNumber = counter++;
    [myLock unlock];
    return newNumber;
}
	
- (void)spawnThread:(NSString*)portName
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    id mathProtocol;
    NSSocketPort *port = (NSSocketPort *) [[NSSocketPortNameServer sharedInstance] portForName:portName host:@"*"];
    NSConnection *theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
    mathProtocol = [[theConnection rootProxy] retain];
    [mathProtocol setProtocolForProxy:@protocol(MathProtocol)];
    
    int currentNumber = [self incrementValue];
    
    while ( currentNumber < 2100000000 ){
        if ([mathProtocol isPrime:currentNumber]) {
            NSLog(@"%d ist eine Primzahl", currentNumber);
        }
        currentNumber = [self incrementValue];
    }

    
    [pool release];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
    /*
    for (int i = 2000000000; i < 2100000000; i++) {
        if ([mathProtocol isPrime:i]) {
            NSLog(@"%d ist eine Primzahl", i);
        }
    } */
    
    for (int i = 1; i <= 3; i++) {
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(spawnThread:)
                                                       object:[@"worker" stringByAppendingFormat:@"%d", i]];
        [myThread start]; 
    }
   
    [pool drain];
}





@end
