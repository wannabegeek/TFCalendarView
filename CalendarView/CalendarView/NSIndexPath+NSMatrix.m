//
//  NSIndexPath+NSMatrix.m
//  CalendarView
//
//  Created by Tom Fewster on 08/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import "NSIndexPath+NSMatrix.h"

@implementation NSIndexPath (NSMatrix)

+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inRow:(NSInteger)row {
	NSUInteger indexes[2];
	indexes[0] = column;
	indexes[1] = row;
	return [NSIndexPath indexPathWithIndexes:indexes length:2];
}

- (NSInteger)column {
	return [self indexAtPosition:0];
}

- (NSInteger)row {
	return [self indexAtPosition:1];
}


@end
