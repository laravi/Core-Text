//
//  IndexedRange.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "IndexedRange.h"
#import "IndexedPosition.h"

@implementation IndexedRange
@synthesize range = _range;

+ (IndexedRange *)rangeWithNSRange:(NSRange)nsrange {
    if (nsrange.location == NSNotFound)
        return nil;
    IndexedRange *range = [[IndexedRange alloc] init];
    range.range = nsrange;
    return range;
}

- (UITextPosition *)start {
    return [IndexedPosition positionWithIndex:self.range.location];
}

- (UITextPosition *)end {
    return [IndexedPosition positionWithIndex:(self.range.location + self.range.length)];
}

-(BOOL)isEmpty {
    return (self.range.length == 0);
}

@end
