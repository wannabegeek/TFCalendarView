//
//  TFDateControlBar.m
//  CalendarView
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFDateControlBar.h"

@interface TFDateControlBar ()
@property (strong) NSGradient *gradient;
@property (strong) NSArray *daysOfTheWeek;
@property (strong) NSDateFormatter *monthYearFormatter;
@property (strong) NSString *currentMonthYearString;

@property (strong) NSButton *previousMonthButton;
@property (strong) NSButton *nextMonthButton;

@end

@implementation TFDateControlBar

@synthesize gradient = _gradient;
@synthesize daysOfTheWeek = _daysOfTheWeek;
@synthesize monthYearFormatter = _monthYearFormatter;
@synthesize currentMonthYearString = _currentMonthYearString;
@synthesize previousMonthButton = _previousMonthButton;
@synthesize nextMonthButton = _nextMonthButton;
@synthesize delegate = _delegate;

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		_gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedWhite:0.84 alpha:1.0] endingColor:[NSColor colorWithCalibratedWhite:0.93 alpha:1.0]];

		// We now need to add the day lables at the top of each column
		_daysOfTheWeek = [NSArray arrayWithObjects:@"Sun", @"Mon", @"Tues", @"Wed", @"Thurs", @"Fri", @"Sat", nil];

		_monthYearFormatter = [[NSDateFormatter alloc] init];
		_monthYearFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"YYYY MMMM" options:0 locale:[NSLocale systemLocale]];

		NSRect buttonRect = NSZeroRect;
		NSRect remainingRect = NSZeroRect;
		NSDivideRect(NSInsetRect([self bounds], 10.0f, 10.0f), &buttonRect, &remainingRect, 20.0f, NSMinXEdge);
		_previousMonthButton = [[NSButton alloc] initWithFrame:buttonRect];
		_previousMonthButton.title = nil;
		[_previousMonthButton setBordered:NO];
		_previousMonthButton.target = self;
		_previousMonthButton.action = @selector(previousMonth:);
		[self addSubview:_previousMonthButton];

		buttonRect = NSZeroRect;
		NSDivideRect(NSInsetRect([self bounds], 10.0f, 10.0f), &buttonRect, &remainingRect, 20.0f, NSMaxXEdge);
		_nextMonthButton = [[NSButton alloc] initWithFrame:buttonRect];
		_nextMonthButton.title = nil;
		[_nextMonthButton setBordered:NO];
		_nextMonthButton.target = self;
		_nextMonthButton.action = @selector(nextMonth:);
		_nextMonthButton.autoresizingMask |=  NSViewMinXMargin;
		[self addSubview:_nextMonthButton];

		NSString *leftArrowPath = nil;
		NSString *rightArrowPath = nil;
		for (NSBundle *bundle in [NSBundle allFrameworks]) {
			if ((leftArrowPath = [bundle pathForImageResource:@"leftarrow"])) {
				[_previousMonthButton setImage:[[NSImage alloc] initWithContentsOfFile:leftArrowPath]];
			}
			if ((rightArrowPath = [bundle pathForImageResource:@"rightarrow"])) {
				[_nextMonthButton setImage:[[NSImage alloc] initWithContentsOfFile:rightArrowPath]];
			}

			if (_nextMonthButton.image && _previousMonthButton.image) {
				break;
			}
		}

	}

	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	[_gradient drawInRect:[self bounds] angle:90.0f];

	NSRect lineRect = [self bounds];
	lineRect.origin.y = lineRect.size.height - 1.0f;
	lineRect.size.height = 1.0f;
	[[NSColor scrollBarColor] set];
	NSRectFill(lineRect);

	NSShadow *textShadow = [[NSShadow alloc] init];
	[textShadow setShadowColor:[NSColor whiteColor]];
	[textShadow setShadowOffset:NSMakeSize(0, -1)];
	[textShadow setShadowBlurRadius:0.0];
	[textShadow set];

//	NSRect *textSpace = NSMakeRect(0.0, 1.0, [self.bounds.size.width / 7.0], 10.f);
	CGFloat spacePerLabel = (self.bounds.size.width / 7.0);
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:9.0f], NSFontAttributeName, [NSColor grayColor], NSForegroundColorAttributeName, nil, nil];

	for (NSUInteger counter = 0; counter < [_daysOfTheWeek count]; counter++) {
		NSString *day = [_daysOfTheWeek objectAtIndex:counter];
		NSSize textSize = [day sizeWithAttributes:options];
		NSPoint location = NSMakePoint((spacePerLabel * counter) + spacePerLabel/2.0 - textSize.width / 2.0f, 1.0f + 5.0 - textSize.height / 2.0f);

		[day drawAtPoint:location withAttributes:options];
	}


	NSRect monthFrame = NSInsetRect([self bounds], 40.0f, 10.0f);
	options = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica Bold" size:17.0f], NSFontAttributeName, [NSColor darkGrayColor], NSForegroundColorAttributeName, nil, nil];
	NSSize textSize = [_currentMonthYearString sizeWithAttributes:options];
	monthFrame.origin.y += 15.0f;
	NSPoint location = NSMakePoint(monthFrame.origin.x + monthFrame.size.width/2.0 - textSize.width / 2.0f, monthFrame.origin.y - textSize.height / 2.0f);
	[_currentMonthYearString drawAtPoint:location withAttributes:options];
}

- (void)setDateForMonth:(NSDate *)date {
	_currentMonthYearString = [_monthYearFormatter stringFromDate:date];
	[self setNeedsDisplay:YES];
}

- (void)previousMonth:(id)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(previousMonth:)]) {
		[_delegate previousMonth:self];
	}
}

- (void)nextMonth:(id)sender {
	if (_delegate && [_delegate respondsToSelector:@selector(nextMonth:)]) {
		[_delegate nextMonth:self];
	}
}

@end
