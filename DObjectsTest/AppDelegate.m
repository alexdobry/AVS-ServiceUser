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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{    
    DataSource* source = [[DataSource alloc] init];
    [[Cluster alloc] initWithDataSource:source];
}

@end
