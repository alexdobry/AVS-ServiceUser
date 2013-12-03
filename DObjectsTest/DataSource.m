//
//  DataSource.m
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DataSource.h"

@implementation DataSource

@synthesize data;

CvCapture *capture;

- (id)init {
    self = [super init];
    if (self) {
        // setup opencv stuff
        capture = cvCaptureFromCAM(-1);
        if (!capture) {
            NSLog(@"Cannot initialize webcam");
        }
        //CvFont* font;
        //cvInitFont(font,CV_FONT_HERSHEY_DUPLEX,1,0.8,0.2,1,8);
    }
    return self;
}

-(IplImage*)getNextDataset {
    @synchronized(self) {
        //int ret = data;
        //[self setData:data+1];
        //return data++;
        
        
        IplImage* img = NULL;
        
        @autoreleasepool {
            img = cvQueryFrame(capture);
            if (!img) {
                NSLog(@"Failed to retrive frame");
            }
        }
        return img;
    }
}

@end
