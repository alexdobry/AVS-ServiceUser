//
//  DataSource.h
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSource : NSObject

@property int data;

-(int)getNextDataset;

@end
