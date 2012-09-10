//
//  NSDate+Calendar.h
//  CalendarView
//
//  Created by Tom Fewster on 09/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Calendar)

- (BOOL)fallsOnSameDayAsDate:(NSDate*)date;
- (NSDate *)dateWithoutTimeElements;
- (NSDate *)firstDayOfMonth;

@end
