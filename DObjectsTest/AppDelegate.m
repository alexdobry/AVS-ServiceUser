//
//  xyzAppDelegate.m
//  DObjectsTest
//
//  Created by Patrick Englert on 22.10.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "Cluster.h"
#import "DataSource.h"
#import "Circle.h"
#import "HoughTransformationProtocol.h"

#include <opencv/cv.h>
#include <opencv/cxcore.h>
#include <opencv/highgui.h>
#include <math.h>

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [super dealloc];
}



//- (double)getFps:(time_t)end i:(int *)i start:(time_t)start
//{
//    time(&end);   
//    return ++(*i) / (difftime (end, start));
//}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    DataSource* source = [[DataSource alloc] init];
    [[Cluster alloc] initWithDataSource:source];
    
//    // prepare fps 
//    time_t start, end;
//    double fps;
//    int i = 0;
//    time(&start);
 
    // start the internal camera and grap each frame
//   
//    while (true) {
//        @autoreleasepool {
//            img = cvQueryFrame(capture);
//            if (!img) {
//                NSLog(@"Failed to retrive frame");
//            }
//            
//            circles = [hough performHoughTransformationWithIplImage:img];
//            img = [self drawCircles:circles on:img];
//            
//            fps = [self getFps:end i:&i start:start];
//            char c=cvWaitKey(33);
//            if(c==27) break;
//            
//            cvPutText(img, [[NSString stringWithFormat:@"%.2lf", fps] UTF8String], cvPoint(30,30), font, cvScalarAll(255));
//            cvShowImage("result", img);
//        }
//    }
    

}

@end
