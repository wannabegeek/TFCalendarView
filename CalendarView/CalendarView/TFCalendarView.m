//
//  CalendarView.m
//  CalendarView
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "TFCalendarView.h"
#import "TFDateControlBar.h"
#import "TFCalendarDayCell.h"
#import "TFCalendarMatrix.h"
#import "NSIndexPath+NSMatrix.h"
#import "NSDate+Calendar.h"

#define DATE_BAR_HEIGHT 40.0f
#define GRID_ROWS 6
#define GRID_COLUMNS 7

#define SCROLL_SPEED 0.25f

@interface TFCalendarView ()
@property (strong) TFCalendarMatrix *matrix;
@property (strong) TFCalendarMatrix *bufferedMatrix;
@property (strong) TFDateControlBar *dateBar;
@property (assign) NSInteger currentOffset;
@property (strong) NSTextField *dateLabel;

@property (assign) BOOL animationInProgress;

@property (strong) NSDate *depressedRangeStart;
@property (strong) NSDate *depressedRangeEnd;

- (void)populateMatrix:(TFCalendarMatrix *)matrix offsetFromCurrentMonth:(NSInteger)offset;
@end

@implementation TFCalendarView

@synthesize matrix = _matrix;
@synthesize bufferedMatrix = _bufferedMatrix;
@synthesize dateBar = _dateBar;
@synthesize currentOffset = _currentOffset;
@synthesize dateLabel = _dateLabel;
@synthesize selectedDate = _selectedDate;
@synthesize animationInProgress = _animationInProgress;
@synthesize enabled = _enabled;
@synthesize depressedRangeStart = _depressedRangeStart;
@synthesize depressedRangeEnd = _depressedRangeEnd;

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {

		_selectedDate = [[NSDate date] dateWithoutTimeElements];
		_depressedRangeStart = [NSDate date];
		_depressedRangeEnd = [NSDate date];

		NSRect matrixFrame = frameRect;
		matrixFrame.size.height -= DATE_BAR_HEIGHT;

		// Create a view to contain the matrix created below. This seemed like the most convenient way to apply
		// a clipping mask to any animations that go on on the matrix.
		CGFloat cellSize = MIN(matrixFrame.size.width/(CGFloat)GRID_COLUMNS, matrixFrame.size.height/(CGFloat)GRID_ROWS);
		NSView *containerView = [[NSView alloc] initWithFrame:NSMakeRect(0.0f, 0.0f, cellSize * (CGFloat)GRID_COLUMNS, cellSize * (CGFloat)GRID_ROWS)];
		[containerView setWantsLayer:YES];
		containerView.layer.masksToBounds = YES;
		[self addSubview:containerView];

		// create the matrix which is going to hold our day cells
		_matrix = [[TFCalendarMatrix alloc] initWithFrame:containerView.frame mode:NSRadioModeMatrix cellClass:[TFCalendarDayCell class] numberOfRows:GRID_ROWS numberOfColumns:GRID_COLUMNS];
		_matrix.allowsEmptySelection = NO;
		_matrix.cellSize = NSMakeSize(cellSize, cellSize);
		_matrix.intercellSpacing = NSMakeSize(0.0f, 0.0f);
		_matrix.target = self;
		_matrix.action = @selector(matrixClicked:);

		// this is a temporary buffer, which is switched back and fourth between _matrix during animations
		// this is generally created offscreen and animated into place.
		_bufferedMatrix = [[TFCalendarMatrix alloc] initWithFrame:NSZeroRect mode:NSRadioModeMatrix cellClass:[TFCalendarDayCell class] numberOfRows:GRID_ROWS numberOfColumns:GRID_COLUMNS];
		_bufferedMatrix.allowsEmptySelection = NO;
		_bufferedMatrix.cellSize = NSMakeSize(cellSize, cellSize);
		_bufferedMatrix.intercellSpacing = NSMakeSize(0.0f, 0.0f);
		_bufferedMatrix.target = self;
		_bufferedMatrix.action = @selector(matrixClicked:);

		_currentOffset = 0;
		[containerView addSubview:_matrix];

		// Create the date bar, which should show the current month & year, and also direction arrows for
		// navigating the months
		NSRect dateBarFrame = [self bounds];
		dateBarFrame.size.height = DATE_BAR_HEIGHT;
		dateBarFrame.origin.y = _matrix.frame.size.height - 1.0f;// + 1.0f;

		_dateBar = [[TFDateControlBar alloc] initWithFrame:dateBarFrame];
		_dateBar.delegate = self;
		[self addSubview:_dateBar];

		// populate teh matrix witht eh current offset
		[self populateMatrix:_matrix offsetFromCurrentMonth:_currentOffset];

		[_matrix deselectAllCells];
	}

	return self;
}

- (void)setFrame:(NSRect)frameRect {
	[super setFrame:frameRect];

	NSRect matrixFrame = frameRect;
	matrixFrame.size.height -= DATE_BAR_HEIGHT;

	CGFloat cellSize = MIN(matrixFrame.size.width/(CGFloat)GRID_COLUMNS, matrixFrame.size.height/(CGFloat)GRID_ROWS);
	_matrix.frame = NSMakeRect(0.0f, 0.0f, cellSize * (CGFloat)GRID_COLUMNS, cellSize * (CGFloat)GRID_ROWS);
	_matrix.cellSize = NSMakeSize(cellSize, cellSize);

	NSRect dateBarFrame = [self bounds];
	dateBarFrame.size.height = DATE_BAR_HEIGHT;
	dateBarFrame.origin.y = _matrix.frame.size.height;
	_dateBar.frame = dateBarFrame;
}

- (void)drawRect:(NSRect)dirtyRect {
	// Just adds a border around the edge of the view
	NSBezierPath *border = [NSBezierPath bezierPath];
	border.lineWidth = 1.0;
	[border moveToPoint:NSMakePoint(_matrix.frame.origin.x + 0.5f, _matrix.frame.origin.y + 0.5f)];
	[border lineToPoint:NSMakePoint(_matrix.frame.origin.x + _matrix.frame.size.width - 0.5f, _matrix.frame.origin.y + 0.5f)];
	[border lineToPoint:NSMakePoint(_matrix.frame.origin.x + _matrix.frame.size.width - 0.5f, _matrix.frame.origin.y + _matrix.frame.size.height)];

	[[NSColor scrollBarColor] set];
	[border stroke];

}

- (void)populateMatrix:(TFCalendarMatrix *)matrix offsetFromCurrentMonth:(NSInteger)offset {
	// This will lay-out the cells into 'matrix', the displayed month should be relative to the current
	// month (i.e. [NSDate date]) adjusted by offset

	matrix.monthStartIndexPath = nil;
	matrix.monthEndIndexPath = nil;

	// Calculate the first day of the current month
	NSDate *firstDayOfCurrentMonth = [[NSDate date] firstDayOfMonth];

	// Create a date component to shift the current month by
	NSDateComponents *offsetFromCurrentMonth = [[NSDateComponents alloc] init];
	offsetFromCurrentMonth.month = offset;

	// Calculate teh first day of the date we wish to display
	NSDate *firstDayOfMonth = [[NSCalendar currentCalendar] dateByAddingComponents:offsetFromCurrentMonth toDate:firstDayOfCurrentMonth options:0];

	NSDateComponents *currentMonthComponents = [[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:firstDayOfMonth];
	currentMonthComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];

	// Which day should we be displaying as the start of the week?
	// Normally Saturday = 0..., so a weekStartOffset would start on Monday
	NSUInteger weekStartOffset = [[NSCalendar currentCalendar] firstWeekday];

	///////////////////

	// The start dat within out matrix, may not be the 1st day of the month (i.e. the 1st isn't always a monday etc.).
	// So, we need to work backwards and display a few days from the previous month.
	// This is also true for the end of the month, butt that is handled by adding on a day to the start date until the grid is full
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];

	[offsetComponents setDay:(currentMonthComponents.weekday > weekStartOffset)?-(currentMonthComponents.weekday - weekStartOffset):(-7 + weekStartOffset) - currentMonthComponents.weekday];
	NSDate *startDate = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:firstDayOfMonth options:0];


	// create an offset with will add 1 day on to the date it is applied to
	offsetComponents = [[NSDateComponents alloc] init];
	offsetComponents.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];
	[offsetComponents setDay:1];

	// populate our matix...
	NSDate *currentDay = startDate;
	for (NSUInteger row = 0; row < GRID_ROWS; row++) {
		for (NSUInteger col = 0; col < GRID_COLUMNS; col++) {
			TFCalendarDayCell *cell = [matrix cellAtRow:row column:col];
			cell.representedObject = currentDay;
			// Calculate whether the cell we are putting here is for the month we are trying to display
			// if not, we will still display it, but it will be greyed out
			NSDateComponents *currentCellComponents = [[NSCalendar currentCalendar] components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:currentDay];
			if (currentCellComponents.month == currentMonthComponents.month && currentCellComponents.year == currentMonthComponents.year) {
				cell.monthRepresentation = TFDayCellCurrentMonth;
				if (matrix.monthStartIndexPath == nil) {
					matrix.monthStartIndexPath = [NSIndexPath indexPathForColumn:col inRow:row];
				}
				matrix.monthEndIndexPath = [NSIndexPath indexPathForColumn:col inRow:row];
			} else if (currentCellComponents.year < currentMonthComponents.year || (currentCellComponents.year == currentMonthComponents.year && currentCellComponents.month < currentMonthComponents.month)) {
				cell.monthRepresentation = TFDayCellPreviousMonth;
			} else {
				cell.monthRepresentation = TFDayCellNextMonth;
			}

			// if the cell is for the currently selected date, we will highlight it.
			if ([currentDay fallsOnSameDayAsDate:_selectedDate]) {
				[matrix selectCell:cell];
			}

			if (_depressedRangeStart && _depressedRangeEnd && ([currentDay fallsOnSameDayAsDate:_depressedRangeStart] || [currentDay fallsOnSameDayAsDate:_depressedRangeEnd] || ([currentDay laterDate:_depressedRangeStart] == currentDay && [currentDay earlierDate:_depressedRangeEnd] == currentDay))) {
				cell.depressed = YES;
			} else {
				cell.depressed = NO;
			}

			// add on 1 day to our current date, this will continue until our matrix is full
			currentDay = [[NSCalendar currentCalendar] dateByAddingComponents:offsetComponents toDate:currentDay options:0];
		}
	}

	[matrix setNeedsDisplay];

	// Update the displayed month & year above the date matrix
	[_dateBar setDateForMonth:firstDayOfMonth];
}

- (IBAction)matrixClicked:(id)sender {
	// a new date has been selected
	TFCalendarDayCell *cell = _matrix.selectedCell;
	if (![_selectedDate isEqualToDate:cell.representedObject]) {
		[self willChangeValueForKey:@"selectedDate"];
		_selectedDate = cell.representedObject;
		[self didChangeValueForKey:@"selectedDate"];
	}

	// if the new date from fromt he previous or next month, we need to scroll to that month
	if (cell.monthRepresentation == TFDayCellPreviousMonth) {
		[self previousMonth:nil];
	} else if (cell.monthRepresentation == TFDayCellNextMonth) {
		[self nextMonth:nil];
	}
}

- (void)setSelectedDate:(NSDate *)selectedDate {

	[self willChangeValueForKey:@"selectedDate"];
	_selectedDate = [selectedDate dateWithoutTimeElements];
	[self didChangeValueForKey:@"selectedDate"];

	NSDateComponents *selectedMonth = [[NSCalendar currentCalendar ] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:selectedDate];
	selectedMonth.day = 1;
	selectedMonth.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];

	NSDateComponents *thisMonth = [[NSCalendar currentCalendar ] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:[NSDate date]];
	thisMonth.day = 1;
	thisMonth.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0.0f];

	NSInteger monthOffset = (selectedMonth.year - thisMonth.year) * 12u + (selectedMonth.month - thisMonth.month);

	if (_currentOffset == monthOffset) {
		[self populateMatrix:_animationInProgress?_bufferedMatrix:_matrix offsetFromCurrentMonth:_currentOffset];
	} else {
		_currentOffset = monthOffset;

		[self populateMatrix:_bufferedMatrix offsetFromCurrentMonth:_currentOffset];
		if (!_animationInProgress) {
			[_bufferedMatrix setAlphaValue:0.0f];
			_bufferedMatrix.frame = _matrix.frame;
			[_matrix.superview addSubview:_bufferedMatrix];

			[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
				_animationInProgress = YES;

				[context setDuration:SCROLL_SPEED];
				[[_bufferedMatrix animator] setAlphaValue:1.0f];
				[[_matrix animator] setAlphaValue:0.0f];
			} completionHandler:^{
				[_matrix removeFromSuperview];
				[_matrix setAlphaValue:1.0f];
				TFCalendarMatrix *temp = _matrix;
				_matrix = _bufferedMatrix;
				_bufferedMatrix = temp;

				_animationInProgress = NO;
			}];
		}
	}
}

- (void)setEnabled:(BOOL)enabled {
	_enabled = enabled;
	[_matrix setEnabled:_enabled];
}

- (void)setDepressedStateFromDate:(NSDate *)startDate to:(NSDate *)endDate {
	_depressedRangeStart = startDate;
	_depressedRangeEnd = endDate;
	[self populateMatrix:_matrix offsetFromCurrentMonth:_currentOffset];
}

#pragma mark - TFDateControlBarDelegate

- (void)nextMonth:(TFDateControlBar *)dateControlBar {
	_currentOffset--;
	[_matrix deselectAllCells];

	[self populateMatrix:_bufferedMatrix offsetFromCurrentMonth:_currentOffset];

	NSRect matrixFrame = [self frame];
	matrixFrame.size.height -= DATE_BAR_HEIGHT;

	CGFloat cellSize = MIN(matrixFrame.size.width/(CGFloat)GRID_COLUMNS, matrixFrame.size.height/(CGFloat)GRID_ROWS);
	_bufferedMatrix.cellSize = NSMakeSize(cellSize, cellSize);

	// calculate the number of rows we need to over-lap at the top
	NSInteger rowOffset = _matrix.monthStartIndexPath.row + (GRID_ROWS - _bufferedMatrix.monthEndIndexPath.row);

	// If the animation is already in progress, we don't need to do any of this. The populateMatrix:offsetFromCurrentMonth: call
	// will update the _bufferedMatrix which is currenly being animated into place.
	// The worst taht can happen is the user lands up at the month they wanted, but the animation missed out displaying a few months.
	// Since this occoures quite quickly, no-one wil notice.
	if (!_animationInProgress) {
		NSRect frame = _matrix.frame;
		frame.origin.y += frame.size.height - (cellSize * rowOffset);
		_bufferedMatrix.frame = frame;
		[_matrix.superview addSubview:_bufferedMatrix];
	}

	// Update the selectedDate, if we have moved months, we don't want a date from the next month selected. So in this case
	// select the last day of the new month
	if ([(TFCalendarDayCell *)_matrix.selectedCell monthRepresentation] != TFDayCellPreviousMonth) {
		TFCalendarDayCell *cell = [_bufferedMatrix cellAtRow:_bufferedMatrix.monthEndIndexPath.row column:_bufferedMatrix.monthEndIndexPath.column];
		[self willChangeValueForKey:@"selectedDate"];
		_selectedDate = cell.representedObject;
		[self didChangeValueForKey:@"selectedDate"];
		[_bufferedMatrix selectCell:cell];
	}

	// Animate the new matrix into view, by sliding it in from the bottom
	if (!_animationInProgress) {
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			_animationInProgress = YES;

			[context setDuration:SCROLL_SPEED];
			// move the new matrix in
			[[_bufferedMatrix animator] setFrame:_matrix.frame];
			// ...and the old one out
			NSRect moveOutFrame = _matrix.frame;
			moveOutFrame.origin.y -= moveOutFrame.size.height - (cellSize * rowOffset);
			[[_matrix animator] setFrame:moveOutFrame];
		} completionHandler:^{
			[_matrix removeFromSuperview];
			// swap the buffers so tehy can be reused
			TFCalendarMatrix *temp = _matrix;
			_matrix = _bufferedMatrix;
			_bufferedMatrix = temp;

			_animationInProgress = NO;
		}];
	}
}

- (void)previousMonth:(TFDateControlBar *)dateControlBar {
	_currentOffset++;
	[_matrix deselectAllCells];

	[self populateMatrix:_bufferedMatrix offsetFromCurrentMonth:_currentOffset];

	NSRect matrixFrame = [self frame];
	matrixFrame.size.height -= DATE_BAR_HEIGHT;

	CGFloat cellSize = MIN(matrixFrame.size.width/(CGFloat)GRID_COLUMNS, matrixFrame.size.height/(CGFloat)GRID_ROWS);
	_bufferedMatrix.cellSize = NSMakeSize(cellSize, cellSize);

	// calculate the number of rows we need to over-lap at the top
	NSInteger rowOffset = GRID_ROWS - _matrix.monthEndIndexPath.row;

	// If the animation is already in progress, we don't need to do any of this. The populateMatrix:offsetFromCurrentMonth: call
	// will update the _bufferedMatrix which is currenly being animated into place.
	// The worst taht can happen is the user lands up at the month they wanted, but the animation missed out displaying a few months.
	// Since this occoures quite quickly, no-one wil notice.
	if (!_animationInProgress) {
		NSRect frame = _matrix.frame;
		frame.origin.y -= frame.size.height - (cellSize * rowOffset);
		_bufferedMatrix.frame = frame;
		[_matrix.superview addSubview:_bufferedMatrix];
	}

	// Update the selectedDate, if we have moved months, we don't want a date from the previous month selected. So in this case
	// select the first day of the new month
	if ([(TFCalendarDayCell *)_matrix.selectedCell monthRepresentation] != TFDayCellNextMonth) {
		TFCalendarDayCell *cell = [_bufferedMatrix cellAtRow:_bufferedMatrix.monthStartIndexPath.row column:_bufferedMatrix.monthStartIndexPath.column];
		[self willChangeValueForKey:@"selectedDate"];
		_selectedDate = cell.representedObject;
		[self didChangeValueForKey:@"selectedDate"];
		[_bufferedMatrix selectCell:cell];
	}

	// Animate the new matrix into view, by sliding it in from the top
	if (!_animationInProgress) {
		[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
			_animationInProgress = YES;

			[context setDuration:SCROLL_SPEED];
			// move the new matrix in
			[[_bufferedMatrix animator] setFrame:_matrix.frame];
			// ...and the old one out
			NSRect moveOutFrame = _matrix.frame;
			moveOutFrame.origin.y += moveOutFrame.size.height - (cellSize * rowOffset);
			[[_matrix animator] setFrame:moveOutFrame];
		} completionHandler:^{
			[_matrix removeFromSuperview];
			// swap the buffers so tehy can be reused
			TFCalendarMatrix *temp = _matrix;
			_matrix = _bufferedMatrix;
			_bufferedMatrix = temp;

			_animationInProgress = NO;
		}];
	}
}

@end
