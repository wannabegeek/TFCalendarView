//
//  NSIndexPath+NSMatrix.h
//  CalendarView
//
//  Created by Tom Fewster on 08/09/2012.
//  Copyright (c) 2012 Tom Fewster. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (NSMatrix)

+ (NSIndexPath *)indexPathForColumn:(NSInteger)column inRow:(NSInteger)row;

@property(nonatomic,readonly) NSInteger column;
@property(nonatomic,readonly) NSInteger row;

@end
