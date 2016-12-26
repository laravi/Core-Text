//
//  MultiColumnView.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 20/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "MultiColumnView.h"

@implementation MultiColumnView

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layoutManager = [[NSLayoutManager alloc] init];
        self.layoutManager.delegate = self;
        self.textStorage = [[NSTextStorage alloc] initWithString:@"Products Pricing Docs Communities News Contact Products Pricing Docs Communities News Contact Mastering TextKit Katsumi Kishikawa on Nov 7 2016 Wistia video thumbnail - Preroll Realm 16:38 Wistia video thumbnail - 10 Katsumi Kishikawa Video & transcription provided by Realm. Realm Swift is a totally free, open-source replacement for SQLite & Core Dat"];
        [self createColumns];
    }
    return self;
}

- (void)setTextStorage:(NSTextStorage *)textStorage {
    _textStorage = [[NSTextStorage alloc] initWithAttributedString:textStorage];
    [self.textStorage addLayoutManager:self.layoutManager];
    [self setNeedsDisplay];
}

- (void)createColumns {
    // Remove any existing text containers, since we will recreate them.
    for (NSUInteger i = [self.layoutManager.textContainers count]; i > 0;) {
        [self.layoutManager removeTextContainerAtIndex:--i];
    }
    
    // Capture some frequently-used geometry values in local variables.
    CGRect bounds = self.bounds;
    CGFloat x = bounds.origin.x;
    CGFloat y = bounds.origin.y;
    
    // These are effectively constants. If you want to make this class more
    // extensible, turning these into public properties would be a nice start!
    NSUInteger columnCount = 2;
    CGFloat interColumnMargin = 10;
    
    // Calculate sizes for building a series of text containers.
    CGFloat totalMargin = interColumnMargin * (columnCount - 1);
    CGFloat columnWidth = (bounds.size.width - totalMargin) / columnCount;
    CGSize columnSize = CGSizeMake(columnWidth, bounds.size.height);
    
    NSMutableArray *containers = [NSMutableArray arrayWithCapacity:columnCount];
    NSMutableArray *origins = [NSMutableArray arrayWithCapacity:columnCount];
    
    for (NSUInteger i = 0; i < columnCount; i++) {
        // Create a new container of the appropriate size, and add it to our array.
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:columnSize];
        [containers addObject:container];
        
        // Create a new origin point for the container we just added.
        NSValue *originValue = [NSValue valueWithCGPoint:CGPointMake(x, y)];
        [origins addObject:originValue];
        
        [self.layoutManager addTextContainer:container];
        NSRange actRng;
        NSRange glRng = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(0, 10) actualCharacterRange:&actRng];
        [self.layoutManager setTextContainer:container forGlyphRange:glRng];
        x += columnWidth + interColumnMargin;
    }
    self.textOrigins = origins;
}

- (void)drawRect:(CGRect)rect
{
    for (NSUInteger i = 0; i < [self.layoutManager.textContainers count]; i++) {
        NSTextContainer *container = self.layoutManager.textContainers[i];
        CGPoint origin = [self.textOrigins[i] CGPointValue];
        
        NSRange glyphRange = [self.layoutManager glyphRangeForTextContainer:container];
        NSTextContainer *cont = [self.layoutManager textContainerForGlyphAtIndex:1 effectiveRange:&glyphRange];
//        [self.layoutManager setTextContainer:container forGlyphRange:NSMakeRange(((i+1)*20), 10)];

        
        [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:origin];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self createColumns];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, 1) withString:@"A better mobile database means better apps. Use the Realm Mobile Database to save data in minutes so you can build mobile apps in a fraction of the time. Our object database is a simple alternative to SQLite and Core Data and proudly open source."];
    [self setNeedsLayout];
}


-(void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag
{
    
}

//- (NSUInteger)layoutManager:(NSLayoutManager *)layoutManager shouldGenerateGlyphs:(const CGGlyph *)glyphs properties:(const NSGlyphProperty *)props characterIndexes:(const NSUInteger *)charIndexes font:(UIFont *)aFont forGlyphRange:(NSRange)glyphRange
//{
//    NSRange GLrange;
//    NSRange rng = [self.layoutManager characterRangeForGlyphRange:glyphRange actualGlyphRange:&GLrange];
//    return 0;
//}

@end
