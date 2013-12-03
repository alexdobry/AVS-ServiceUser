//
//  DataSource.m
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "DataSource.h"
#import "HoughImage.h"

@implementation DataSource

@synthesize capture = _capture;
@synthesize counter = _counter;

- (id)init {
    self = [super init];
    if (self) {
        self.counter = 0;
        self.capture = cvCaptureFromCAM(-1);
        if (!self.capture) {
            NSLog(@"Cannot initialize webcam");
        }
        //CvFont* font;
        //cvInitFont(font,CV_FONT_HERSHEY_DUPLEX,1,0.8,0.2,1,8);
    }
    return self;
}

-(HoughImage*)getNextDataset {
    @synchronized(self) {
        //int ret = data;
        //[self setData:data+1];
        //return data++;
        
        HoughImage* houghImg = nil;
        
        @autoreleasepool {
            houghImg = [[HoughImage alloc] initWithIplImage:cvQueryFrame(self.capture) andId:self.counter++];
            if (!houghImg) {
                NSLog(@"Failed to retrive frame");
            }            
        }
        return houghImg;
    }
}

@end
