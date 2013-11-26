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

-(int)getNextDataset {
    @synchronized(self) {
        //int ret = data;
        //[self setData:data+1];
        return data++;
    }
}

@end
