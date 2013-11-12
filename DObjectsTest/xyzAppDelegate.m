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


- (void)getInfo:(NSString*)portName{

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    NSString * servicePort = [portName stringByAppendingString:@"_service"];
    
       
    int currentNumber = [self incrementValue];

    id mathProtocol;
    NSConnection *theConnection = nil;
    NSSocketPort *port = nil;
    
    while (currentNumber < 2100000000) {
        
    
        if (theConnection == nil) {
            
            port = (NSSocketPort *) [[NSSocketPortNameServer sharedInstance] portForName:servicePort host:@"*"];
            
            if (port == nil) {
                NSLog(@"keine verbindung zu %@", servicePort);
                sleep(5);
                continue;
            } 
            theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
            
            
            [theConnection setRequestTimeout:60];
            [theConnection setReplyTimeout:60];
            
            mathProtocol = [[theConnection rootProxy] retain];                
            [mathProtocol setProtocolForProxy:@protocol(MathProtocol)];
                      
        }
 

        
        
    //  Der try Block ist für den Ausfall eines Service Providers nötig. Der aufruf des Distributed Objects wirft eine Exception nach Timeout.
    @try {
        
        if ([mathProtocol isPrime:currentNumber]) {
            NSLog(@"%@ %d ist eine Primzahl", servicePort, currentNumber);
            
            }
        else {
            NSLog(@"%@ %d ist keine Primzahl", servicePort, currentNumber);

        }
            currentNumber = [self incrementValue];     
        
    }
        
        @catch (NSException *exception) {
            if ([[exception name] isEqualToString:NSPortTimeoutException])
            {
                NSLog(@"Verbindung verloren: %d", currentNumber);
                [mathProtocol release];
                //[[NSSocketPortNameServer sharedInstance] removePortForName:portName];
                /*[port release];
                [theConnection release];
                mathProtocol = nil;
                theConnection = nil;
                port = nil;
                */
                break;//Muss hoch sein weil das Betriebssystem den alten Port ziemlich lange offen hält
            }
        
        }
        @finally {
        
        }
    }
    [pool release];
}

- (void)spawnThread:(NSString*)portName
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    id mathProtocol;

    
    NSConnection *theConnection = nil;
    NSSocketPort *port = nil;
   
    
    

    
    int currentNumber = [self incrementValue];
        while ( currentNumber < 2100000000 ){

            if (theConnection == nil) {
                
                port = (NSSocketPort *) [[NSSocketPortNameServer sharedInstance] portForName:portName host:@"*"];
               
                if (port == nil) {
                    NSLog(@"keine verbindung zu %@", portName);
                    sleep(5);
                    continue;
                } 
                theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
                

                [theConnection setRequestTimeout:60];
                [theConnection setReplyTimeout:60];
                
                mathProtocol = [[theConnection rootProxy] retain];                
                [mathProtocol setProtocolForProxy:@protocol(MathProtocol)];
                
                NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                             selector:@selector(getInfo:)
                                                               object:portName];
                [myThread start];
                
            }
            
            //  Der try Block ist für den Ausfall eines Service Providers nötig. Der aufruf des Distributed Objects wirft eine Exception nach Timeout.
            @try {
                
                if ([mathProtocol isPrime:currentNumber]) {
                    NSLog(@"%@ %d ist eine Primzahl", portName, currentNumber);
                    
                }
                else {
                    NSLog(@"%@ %d ist keine Primzahl", portName, currentNumber);
                    
                }
                currentNumber = [self incrementValue];            
            }
            @catch (NSException *exception) {
                if ([[exception name] isEqualToString:NSPortTimeoutException])
                {
                    NSLog(@"Verbindung verloren: %@ %d", portName, currentNumber);
                    [mathProtocol release];
                    [[NSSocketPortNameServer sharedInstance] removePortForName:portName];
                    [port release];
                    [theConnection release];
                    mathProtocol = nil;
                    theConnection = nil;
                    port = nil;
                     
                    sleep(120); //Muss hoch sein weil das Betriebssystem den alten Port ziemlich lange offen hält
                }
                
            }
            @finally {
                
            }

        }

    
    [pool release];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        
    NSArray * providerNames;
    
    providerNames = [NSArray arrayWithObjects:@"pip01",@"pip02",@"pip03",@"pip04",@"pip05",@"pip06",@"pip07",@"pip08",@"pip09",@"pip10", nil];
    
    for (id portName in providerNames) {
    
        
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(spawnThread:)
                                                       object:portName];
        [myThread start]; 
    }
   
    [pool drain];
}





@end
