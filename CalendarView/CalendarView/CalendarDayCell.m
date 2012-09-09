//
//  CalendarDayCell.m
//  CalendarView
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "CalendarDayCell.h"

@interface CalendarDayCell ()
@property (strong) NSGradient *gradient;
@property (strong) NSCalendar *currentCalendar;
@property (strong) NSDateFormatter *dayFormatter;
@property (strong) NSString *currentDayLabel;
@end

@implementation CalendarDayCell

@synthesize monthRepresentation;

@synthesize gradient = _gradient;
@synthesize currentCalendar = _currentCalendar;
@synthesize dayFormatter = _dayFormatter;
@synthesize currentDayLabel = _currentDayLabel;

- (id)init {
	if ((self = [super init])) {
		_gradient = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithCalibratedRed:0.000 green:0.463 blue:0.929 alpha:1] endingColor:[NSColor colorWithCalibratedRed:0.188 green:0.298 blue:0.463 alpha:1]];
		_currentCalendar = [NSCalendar currentCalendar];

		_dayFormatter = [[NSDateFormatter alloc] init];
		_dayFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"d" options:0 locale:[NSLocale currentLocale]];

	}

	return self;
}

- (void)setRepresentedObject:(id)anObject {
	[super setRepresentedObject:anObject];

	_currentDayLabel = [_dayFormatter stringFromDate:(NSDate *)anObject];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	cellFrame = NSMakeRect(cellFrame.origin.x + 0.5f, cellFrame.origin.y + 0.5f, cellFrame.size.width, cellFrame.size.height);
	if ((self.state & NSOnState) == NSOnState) {
		if (self.monthRepresentation == TFDayCellCurrentMonth) {
			[_gradient drawInRect:cellFrame relativeCenterPosition:NSMakePoint(0.0f, 0.0f)];
		} else {
			[[NSColor grayColor] set];
			NSRectFill(cellFrame);
		}
	}

	NSColor *fontColor = ((self.state & NSOnState) == NSOnState)?[NSColor whiteColor]:(self.monthRepresentation == TFDayCellCurrentMonth)?[NSColor darkGrayColor]:[NSColor lightGrayColor];

	CGFloat fontSize = cellFrame.size.height / 2.1f;
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:fontSize], NSFontAttributeName, fontColor, NSForegroundColorAttributeName, nil];
	NSSize textSize = [_currentDayLabel sizeWithAttributes:options];
	NSPoint location = NSMakePoint(cellFrame.origin.x + cellFrame.size.width/2.0 - textSize.width / 2.0f, cellFrame.origin.y + cellFrame.size.height/2.0 - textSize.height / 2.0f - 4.0f);

	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:((self.state & NSOnState) == NSOnState)?[NSColor darkGrayColor]:[NSColor whiteColor]];
	[shadow setShadowOffset:NSMakeSize(0, -1)];
	[shadow setShadowBlurRadius:0.0];
	[shadow set];

	[_currentDayLabel drawAtPoint:location withAttributes:options];

	[fontColor set];
	NSRect rect = NSMakeRect(cellFrame.origin.x + cellFrame.size.width/2.0 - 2.0f, cellFrame.origin.y + cellFrame.size.height - 10.0f, 4.0f, 4.0f);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect:rect];
	[circlePath fill];

	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
//	[[NSColor windowBackgroundColor] set];
//	NSRectFill(cellFrame);
	[[NSGraphicsContext currentContext] saveGraphicsState];
//	[[NSGraphicsContext currentContext] setShouldAntialias: NO];
	cellFrame = NSInsetRect(cellFrame, 0.5f, 0.5f);
	[[NSColor windowBackgroundColor] set];
	NSRectFill(cellFrame);

	NSBezierPath *path = [NSBezierPath bezierPath];
	path.lineWidth = 1.0;
	[path moveToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width, cellFrame.origin.y)];
	[path lineToPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y)];
	[path lineToPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y + cellFrame.size.height)];

	[[NSColor scrollBarColor] set];
	[path stroke];

	NSBezierPath *innerHighlight = [NSBezierPath bezierPath];
	innerHighlight.lineWidth = 1.0;
	[innerHighlight moveToPoint:NSMakePoint(cellFrame.origin.x + 1.0, cellFrame.origin.y + 1.0)];
	[innerHighlight lineToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 1.0, cellFrame.origin.y + 1.0)];
	[innerHighlight lineToPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - 1.0, cellFrame.origin.y + cellFrame.size.height - 1.0)];

	[[NSColor whiteColor] set];
	[innerHighlight stroke];
	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[super drawWithFrame:cellFrame inView:controlView];

}

@end
