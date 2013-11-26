//
//  xyzAppDelegate.m
//  DObjectsTest
//
//  Created by Patrick Englert on 22.10.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "xyzAppDelegate.h"
#import "Cluster.h"
#import "DataSource.h"
#import "Circle.h"
#import "HoughTransformationProtocol.h"

#include <opencv/cv.h>
#include <opencv/highgui.h>
#include <math.h>

@implementation xyzAppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}

- (IplImage*)drawCircles:(NSMutableArray*) circles on:(IplImage*) img {
    for (Circle* circle in circles) {
        cvCircle(img, cvPoint(circle.x, circle.y), circle.r, CV_RGB(255,0,0), 3, 8, 0);
    }
    return img;
}

- (double)getFps:(time_t)end i:(int *)i start:(time_t)start
{
    time(&end);   
    return ++(*i) / (difftime (end, start));
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
//    NSMutableArray* circles = [[NSMutableArray alloc] init];
//    DataSource* source = [[DataSource alloc] init];

    IplImage* img = NULL;
    CvCapture *capture = 0;
    capture = cvCaptureFromCAM(-1);
    if (!capture) {
        NSLog(@"Cannot initialize webcam");
    }
    CvFont* font;
    cvInitFont(font,CV_FONT_HERSHEY_DUPLEX,1,0.8,0.2,1,8);
    
    cvNamedWindow("result", CV_WINDOW_AUTOSIZE);
    
    time_t start, end;
    double fps;
    int i = 0;
    
    time(&start);
 
    while (true) {
        @autoreleasepool {
            img = cvQueryFrame(capture);
            if (!img) {
                NSLog(@"Failed to retrive frame");
            }
            //            if (i % 2 == 0) {
            //                circles = [hough performHoughTransformationWithIplImage:img];
            //                img = [self drawCircles:circles on:img];
            //            }
            
            fps = [self getFps:end i:&i start:start];
            char c=cvWaitKey(33);
            if(c==27) break;
            
            cvPutText(img, [[NSString stringWithFormat:@"%.2lf", fps] UTF8String], cvPoint(30,30), font, cvScalarAll(255));
            cvShowImage("result", img);
        }

        
    }
    
//    [[Cluster alloc] initWithDataSource:source];

}

@end
