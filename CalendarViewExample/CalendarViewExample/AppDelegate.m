//
//  AppDelegate.m
//  CalendarViewExample
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "AppDelegate.h"
#import <CalendarView/TFCalendarView.h>

@interface AppDelegate ()
@property (weak) IBOutlet TFCalendarView *calendarView;
@end

@implementation AppDelegate

@synthesize calendarView = _calendarView;
@synthesize selectedDate = _selectedDate;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.selectedDate = _calendarView.selectedDate;
	[_calendarView addObserver:self forKeyPath:@"selectedDate" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	NSLog(@"Selected Date: %@", _calendarView.selectedDate);
	self.selectedDate = _calendarView.selectedDate;
}

- (IBAction)dateChanged:(id)sender {
	_calendarView.selectedDate = self.selectedDate;
}

@end
