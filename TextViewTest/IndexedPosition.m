//
//  IndexedPosition.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "IndexedPosition.h"

@implementation IndexedPosition

@synthesize index = _index;

+ (IndexedPosition *)positionWithIndex:(NSUInteger)index {
    IndexedPosition *pos = [[IndexedPosition alloc] init];
    pos.index = index;
    return pos;
}

@end
