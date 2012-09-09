//
//  NSDate+Calendar.m
//  CalendarView
//
//  Created by Tom Fewster on 09/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "NSDate+Calendar.h"

@implementation NSDate (Calendar)

- (NSDate *)dateWithoutTimeElements {
	NSDateComponents *comps = [[NSCalendar currentCalendar ] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self];
	comps.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];
	return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

- (BOOL)fallsOnSameDayAsDate:(NSDate*)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];

    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];

    return comp1.day == comp2.day && comp1.month == comp2.month && comp1.year == comp2.year;
}

- (NSDate *)firstDayOfMonth {
	NSDateComponents *month = [[NSCalendar currentCalendar ] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:self];
	month.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];
	month.day = 1;

	return [[NSCalendar currentCalendar] dateFromComponents:month];
}

@end
