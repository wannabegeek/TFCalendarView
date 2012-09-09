//
//  ContigiousSelectionMatrix.h
//  CalendarView
//
//  Created by Tom Fewster on 07/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CalendarMatrix : NSMatrix

@property (strong) NSIndexPath *monthStartIndexPath;
@property (strong) NSIndexPath *monthEndIndexPath;

@end
