//
//  AppDelegate.h
//  CalendarViewExample
//
//  Created by Tom Fewster on 06/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSDate *selectedDate;

@end
