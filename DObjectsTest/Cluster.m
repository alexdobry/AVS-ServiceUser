//
//  ClusterManager.m
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Cluster.h"

@implementation Cluster
NSArray* MACHINE_NAMES;

@synthesize machineThreads;
@synthesize dataSource;

-(Cluster*) initWithDataSource:(DataSource*)source {
    MACHINE_NAMES = [NSArray arrayWithObjects:@"pip01hallo",@"pip02hallo",@"pip03hallo",@"pip04hallo",@"pip05hallo",@"pip06hallo",@"pip07hallo",@"pip08hallo",@"pip09hallo",@"pip10hallo", nil];
    
    [self setDataSource:source];
    
    for (NSString* portName in MACHINE_NAMES) {
        [[Machine alloc] initWithName:portName dataSource:dataSource];
    }
    return self;
}

@end
