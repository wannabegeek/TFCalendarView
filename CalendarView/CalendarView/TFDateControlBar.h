//
//  TFDateControlBar.h
//  CalendarView
//
//  Created by Tom Fewster on 10/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TFDateControlBar;

@protocol TFDateControlBarDelegate <NSObject>
- (void)nextMonth:(TFDateControlBar *)dateControlBar;
- (void)previousMonth:(TFDateControlBar *)dateControlBar;
@end

@interface TFDateControlBar : NSView
@property (weak) NSObject<TFDateControlBarDelegate> *delegate;
- (void)setDateForMonth:(NSDate *)date;
@end
