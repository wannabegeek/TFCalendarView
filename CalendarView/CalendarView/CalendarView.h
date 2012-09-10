//
//  CalendarView.h
//  CalendarView
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CalendarView : NSView

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSDate *selectedDate;

- (void)setDepressedStateFromDate:(NSDate *)startDate to:(NSDate *)endDate;
@end
