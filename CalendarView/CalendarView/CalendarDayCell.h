//
//  CalendarDayCell.h
//  CalendarView
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	TFDayCellCurrentMonth,
	TFDayCellPreviousMonth,
	TFDayCellNextMonth
} CellMonthRepresentation;

@interface CalendarDayCell : NSCell

@property (assign) CellMonthRepresentation monthRepresentation;
@property (assign) BOOL depressed;
@end
