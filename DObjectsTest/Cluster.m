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
    MACHINE_NAMES = [NSArray arrayWithObjects:@"pip01",@"pip02",@"pip03",@"pip04",@"pip05",@"pip06",@"pip07hallo",@"pip08hallo",@"pip09",@"pip10", nil];
    
    [self setDataSource:source];
    
    for (NSString* portName in MACHINE_NAMES) {
        [[Machine alloc] initWithName:portName dataSource:dataSource];
    }
    return self;
}

@end
