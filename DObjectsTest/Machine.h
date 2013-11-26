//
//  MachineThread.h
//  DObjectsTest
//
//  Created by Markus Müller on 19.11.13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HoughTransformationProtocol.h"
#import "InformantProtocol.h"
#import "DataSource.h"

@interface Machine : NSObject

@property(retain) NSString* portName;
@property BOOL connected;

@property(retain) DataSource* dataSource;

@property(retain) NSThread* statusThread;
@property(retain) NSThread* workerThread;

-(Machine*) initWithName:(NSString*)name dataSource:(DataSource*)source;

@end
