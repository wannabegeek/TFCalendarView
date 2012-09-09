//
//  GradientBackgroundView.h
//  Shoot
//
//  Created by Tom Fewster on 23/02/2010.
//  Copyright 2010 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define SCOPE_BAR_START_COLOR_GRAY		[NSColor colorWithCalibratedWhite:0.84 alpha:1.0]						// bottom color of gray gradient
#define SCOPE_BAR_END_COLOR_GRAY		[NSColor colorWithCalibratedWhite:0.93 alpha:1.0]						// top color of gray gradient

#define SCOPE_BAR_BORDER_COLOR			[NSColor scrollBarColor]						// bottom line's color
#define SCOPE_BAR_BORDER_WIDTH			1.0																		// bottom line's width

@interface GradientBackgroundView : NSView

@property (assign) BOOL topBorder;

@end
