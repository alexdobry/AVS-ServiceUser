//
//  MachineThread.m
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Machine.h"

@implementation Machine

@synthesize portName;
@synthesize connected;

@synthesize dataSource;

@synthesize statusThread;
@synthesize workerThread;

-(Machine*) initWithName:(NSString*)name dataSource:(DataSource*)source {
    [self setConnected:NO];
    [self setPortName:name];
    [self setDataSource:source];
    
    //Create "Status"-Thread
    statusThread = [[NSThread alloc] initWithTarget:self
                                                 selector:@selector(checkStatus:)
                                             object:nil];
    //start
    [statusThread start];
    
    return self;
}

-(void)checkStatus:(id)arg {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    id infoProtocol;
    
    NSConnection *theConnection = nil;
    NSSocketPort *port = nil;
    
    int currentNumber;
    
    NSString * servicePort = [portName stringByAppendingString:@"_service"];
    
    // Schleife
    while (true) {
        sleep(3);
        // wurde die Verbindung unterbrochen?
        if (!connected) {
            // versuche Verbindung herzustellen
            port = (NSSocketPort *) [[NSSocketPortNameServer sharedInstance] portForName:servicePort host:@"*"];
            if (port == nil) {
                // Verbindung kann nicht hergestellt werden
                NSLog(@"keine verbindung zu %@", portName);
                sleep(5);
                continue;
            }
            theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
            
            //Verbindungsstatus aktualisieren
            [self setConnected:YES];
            
            // Verbindung konfigurieren
            [theConnection setRequestTimeout:10];
            [theConnection setReplyTimeout:10];
            
            infoProtocol = [[theConnection rootProxy] retain];                
            [infoProtocol setProtocolForProxy:@protocol(InformantProtocol)];
            
            //Create "Worker"-Thread
            workerThread = [[NSThread alloc] initWithTarget:self selector:@selector(doWork:) object:nil];
            // Worker-Thread starten
            [workerThread start];
            
        }
        
        
        
        //  Der try Block ist für den Ausfall eines Service Providers nötig. Der aufruf des Distributed Objects wirft eine Exception nach Timeout.
        @try {
            NSMutableArray* coreUsage = [infoProtocol getInfo];
            for (NSNumber* usage in coreUsage) {
                NSLog(@"%@", usage);
            }
        }
        @catch (NSException *exception) {
            // Verbindung zum Provider verloren (Timeout)
            if ([[exception name] isEqualToString:NSPortTimeoutException])
            {
                // Verbindungsstatus aktualisieren
                [self setConnected:NO]; // Beendet indirekt außerdem den Worker-Thread
                
                // Ressourcen freigeben
                NSLog(@"Verbindung verloren: %@ %d", portName, currentNumber);
                [infoProtocol release];
                [[NSSocketPortNameServer sharedInstance] removePortForName:portName];
                [port release];
                [theConnection release];
                infoProtocol = nil;
                theConnection = nil;
                port = nil;
                
                //Vor neuem Verbindungsversuch warten
                sleep(120); //Muss hoch sein weil das Betriebssystem den alten Port ziemlich lange offen hält
            }
            
        }
        @finally {
            
        }
        
    }
    
    
    [pool release];

}

-(void)doWork:(id)arg {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSConnection *theConnection = nil;
    NSSocketPort *port = nil;
    
    id mathProtocol;
     
    
    //Verbindung herstellen (ohne Fehlerbehandlung, da der Thread sonst sowieso beendet wird)
    port = (NSSocketPort *) [[[NSSocketPortNameServer sharedInstance] portForName:portName host:@"*"] retain];
    theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
    
    [theConnection setRequestTimeout:60];
    [theConnection setReplyTimeout:60];
            
    mathProtocol = [[theConnection rootProxy] retain];                
    [mathProtocol setProtocolForProxy:@protocol(MathProtocol)];
    
    
    int currentNumber;
    
    // Do Work
    while (connected) {
        
        //  Der try Block ist für den Ausfall eines Service Providers nötig. Der aufruf des Distributed Objects wirft eine Exception nach Timeout.
        @try {
            @autoreleasepool {
           currentNumber = [dataSource getNextDataset];
            if ([mathProtocol isPrime:currentNumber]) {
                NSLog(@"%@ %d ist eine Primzahl", portName, currentNumber);
                
            }
            else {
                NSLog(@"%@ %d ist keine Primzahl", portName, currentNumber);
            }
            }
        }
        
        @catch (NSException *exception) {
            if ([[exception name] isEqualToString:NSPortTimeoutException])
            {
                // Falls tatsächlich keine Verbindung zum Provieder mehr besteht, so wird dies im Status-Thread erkannt
                NSLog(@"Datenpaket Nr. %d konnte nicht bearbeitet werden (Timeout).", currentNumber);
            }
            
        }
        @finally {
            
        }
    }
    [pool release];

}

@end