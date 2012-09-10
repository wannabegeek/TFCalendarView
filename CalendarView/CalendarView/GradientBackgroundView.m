//
//  GradientBackgroundView.m
//  Shoot
//
//  Created by Tom Fewster on 23/02/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#import "GradientBackgroundView.h"

@interface GradientBackgroundView ()
@property (strong) NSGradient *gradient;
@end

@implementation GradientBackgroundView

@synthesize topBorder;
@synthesize gradient = _gradient;

- (id)initWithFrame:(NSRect)frameRect {
	if ((self = [super initWithFrame:frameRect])) {
		_gradient = [[NSGradient alloc] initWithStartingColor:SCOPE_BAR_START_COLOR_GRAY endingColor:SCOPE_BAR_END_COLOR_GRAY];
	}

	return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	[super drawRect:dirtyRect];
	[_gradient drawInRect:[self bounds] angle:90.0];

	NSRect lineRect = [self bounds];
	lineRect.origin.y = lineRect.size.height - 1;
	lineRect.size.height = SCOPE_BAR_BORDER_WIDTH;
	[SCOPE_BAR_BORDER_COLOR set];
	NSRectFill(lineRect);

//	if (topBorder) {
//		lineRect = [self bounds];
//		lineRect.origin.y = lineRect.size.height - 1;
//		lineRect.size.height = SCOPE_BAR_BORDER_WIDTH;
//		[SCOPE_BAR_BORDER_COLOR set];
//		NSRectFill(lineRect);
//	}
}

@end
