//
//  MachineThread.m
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Machine.h"
#import "HoughImage.h"

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
//                NSLog(@"keine verbindung zu %@", portName);
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
                //NSLog(@"%@", usage)‚;
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
    
    id houghProtocol;
     
    //Verbindung herstellen (ohne Fehlerbehandlung, da der Thread sonst sowieso beendet wird)
    port = (NSSocketPort *) [[[NSSocketPortNameServer sharedInstance] portForName:portName host:@"*"] retain];
    theConnection = [NSConnection connectionWithReceivePort:nil sendPort:port];
    
    [theConnection setRequestTimeout:60];
    [theConnection setReplyTimeout:60];
            
    houghProtocol = [[theConnection rootProxy] retain];                
    [houghProtocol setProtocolForProxy:@protocol(HoughTransformationProtocol)];
    
    
    HoughImage* houghImg = NULL;
    NSMutableArray* circles = [[NSMutableArray alloc] init];

    // Do Work
    while (connected) {
        
        //  Der try Block ist für den Ausfall eines Service Providers nötig. Der aufruf des Distributed Objects wirft eine Exception nach Timeout.
        @try {
            @autoreleasepool {
                houghImg = [dataSource getNextDataset];
                circles = [houghProtocol performHoughTransformationWithNSImage:[self createNSImageFromIplImage:houghImg.img]];
                if ([dataSource showImage:houghImg]) {
                    @synchronized(dataSource) {
                        houghImg.img = [self drawCircles:circles on:houghImg.img];
                        cvShowImage("result", houghImg.img);
                    }
                }
            }
        }
        
        @catch (NSException *exception) {
            if ([[exception name] isEqualToString:NSPortTimeoutException])
            {
                // Falls tatsächlich keine Verbindung zum Provieder mehr besteht, so wird dies im Status-Thread erkannt
                NSLog(@"Datenpaket Nr. ... konnte nicht bearbeitet werden (Timeout).");
            }
            
        }
        @finally {
            
        }
  }
    [pool release];

}

- (IplImage*)drawCircles:(NSMutableArray*) circles on:(IplImage*) img {
    for (Circle* circle in circles) {
        cvCircle(img, cvPoint(circle.x, circle.y), circle.r, CV_RGB(255,0,0), 3, 8, 0);
    }
    return img;
}

- (NSImage*)createNSImageFromIplImage:(IplImage *)image {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    NSSize size;
    size.height = image->height;
    size.width = image->width;
    NSImage *ret = [[NSImage alloc] initWithCGImage:imageRef size:size];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);

    return ret;
}

@end
