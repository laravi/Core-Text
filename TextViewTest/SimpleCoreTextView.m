//
//  SimpleCoreTextView.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "SimpleCoreTextView.h"
#import <QuartzCore/CALayer.h>

#pragma mark SimpleCoreTextView class extension

@interface SimpleCoreTextView ()

@property (nonatomic, retain) NSDictionary *attributes;

- (void)clearPreviousLayoutInformation;
- (void)textChanged;

// Note that for this sample for simplicity, the selection color and
// insertion point "caret" color are fixed and cannot be changed.
+ (UIColor *)selectionColor;
+ (UIColor *)caretColor;

@end

#pragma mark SimpleCaretView definition

// SimpleCaretView draws a basic text "caret", used as an insertion point
// cursor in SimpleCoreTextView
@interface SimpleCaretView : UIView {
    NSTimer *_blinkTimer;
}

- (void)delayBlink;

@end

#pragma mark SimpleCoreTextView implementation

@implementation SimpleCoreTextView

@synthesize text = _text;
@synthesize font = _font;
@synthesize editing = _editing;
@synthesize markedTextRange = _markedTextRange;
@synthesize selectedTextRange = _selectedTextRange;
@synthesize attributes = _attributes;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.geometryFlipped = YES;  // For ease of interaction with the CoreText coordinate system.
        self.text = @"";
        self.font = [UIFont systemFontOfSize:18];
        self.backgroundColor = [UIColor clearColor];
        _caretView = [[SimpleCaretView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

- (void)dealloc
{
    self.text = nil;
    self.font = nil;
    self.attributes = nil;
}

// Helper method to release our cached Core Text framesetter and frame
- (void)clearPreviousLayoutInformation
{
    if (_framesetter != NULL) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    
    if (_frame != NULL) {
        CFRelease(_frame);
        _frame = NULL;
    }
}

// font property setter override - we need to additionally create and set the Core Text
// font object that corresponds to the UIFont being set.
- (void)setFont:(UIFont *)font
{
    _font = font;
    
    // Find matching CTFont via name and size
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef) self.font.fontName, self.font.pointSize, NULL);
    
    // Set CTFont instance in our attributes dictionary, to be set on our attributed string
    self.attributes = [NSDictionary dictionaryWithObject:(__bridge id)ctFont forKey:(NSString *)kCTFontAttributeName];
    
    CFRelease(ctFont);
    
    [self textChanged];
}

// Helper method to update our text storage when the text content has changed
- (void)textChanged
{
    [self setNeedsDisplay];
    [self clearPreviousLayoutInformation];
    
    // Build the attributed string from our text data and string attribute data
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:self.attributes];
    
    // Create the Core Text framesetter using the attributed string
    _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributedString);
    
    // Create the Core Text frame using our current view rect bounds
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    _frame =  CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), [path CGPath], NULL);
    NSArray *lines = CTFrameGetLines(_frame);
}

// text property accessor overrides

- (NSString *)text {
    return _text;
}

- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    // We need to call textChanged after setting the new property text to update layout
    [self textChanged];
}

// Helper method for obtaining the intersection of two ranges (for handling
// selection range across multiple line ranges in drawRangeAsSelection below)
- (NSRange)RangeIntersection:(NSRange)first withSecond:(NSRange)second
{
    NSRange result = NSMakeRange(NSNotFound, 0);
    
    // Ensure first range does not start after second range
    if (first.location > second.location) {
        NSRange tmp = first;
        first = second;
        second = tmp;
    }
    
    // Find the overlap intersection range between first and second
    if (second.location < first.location + first.length) {
        result.location = second.location;
        NSUInteger end = MIN(first.location + first.length, second.location + second.length);
        result.length = end - result.location;
    }
    
    return result;
}

// Helper method for drawing the current selection range (as a simple filled rect)
- (void)drawRangeAsSelection:(NSRange)selectionRange
{
    // If not in editing mode, we do not draw selection rects
    if (!self.editing)
        return;
    
    // If selection range empty, do not draw
    if (selectionRange.length == 0 || selectionRange.location == NSNotFound)
        return;
    
    // set the fill color to the selection color
    [[SimpleCoreTextView selectionColor] setFill];
    
    // Iterate over the lines in our CTFrame, looking for lines that intersect
    // with the given selection range, and draw a selection rect for each intersection
    NSArray *lines = (NSArray *) CTFrameGetLines(_frame);
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSRange intersection = [self RangeIntersection:range withSecond:selectionRange];
        if (intersection.location != NSNotFound && intersection.length > 0) {
            // The text range for this line intersects our selection range
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, intersection.location, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, intersection.location + intersection.length, NULL);
            CGPoint origin;
            // Get coordinate and bounds information for the intersection text range
            CTFrameGetLineOrigins(_frame, CFRangeMake(i, 0), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            // Create a rect for the intersection and draw it with selection color
            CGRect selectionRect = CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
            UIRectFill(selectionRect);
        }
    }
}

// Standard UIView drawRect override that uses Core Text to draw our text contents
- (void)drawRect:(CGRect)rect
{
    // First draw selection / marked text, then draw text
    [self drawRangeAsSelection:_selectedTextRange];
    [self drawRangeAsSelection:_markedTextRange];
    
    CTFrameDraw(_frame, UIGraphicsGetCurrentContext());
}

// Public method to find the text range index for a given CGPoint
- (NSInteger)closestIndexToPoint:(CGPoint)point
{
    // Use Core Text to find the text index for a given CGPoint by
    // iterating over the y-origin points for each line, finding the closest
    // line, and finding the closest index within that line.
    NSArray *lines = (NSArray *) CTFrameGetLines(_frame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, lines.count), origins);
    
    for (int i = 0; i < lines.count; i++) {
        if (point.y > origins[i].y) {
            // This line origin is closest to the y-coordinate of our point,
            // now look for the closest string index in this line.
            CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
            return CTLineGetStringIndexForPosition(line, point);
            
        }
    }
    
    return  _text.length;
    
}

// Public method to determine the CGRect for the insertion point or selection, used
// when creating or updating our SimpleCaretView instance
- (CGRect)caretRectForIndex:(int)index
{
    NSArray *lines = (NSArray *) CTFrameGetLines(_frame);
    
    // Special case, no text
    if (_text.length == 0) {
        CGPoint origin = CGPointMake(CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds) - self.font.leading);
        // Note: using fabs() for typically negative descender from fonts
        return CGRectMake(origin.x, origin.y - fabs(self.font.descender), 3, self.font.ascender + fabs(self.font.descender));
    }
    
    // Special case, insertion point at final position in text after newline
    if (index == _text.length && [_text characterAtIndex:(index - 1)] == '\n') {
        CTLineRef line = (__bridge CTLineRef) [lines lastObject];
        CFRange range = CTLineGetStringRange(line);
        CGFloat xPos = CTLineGetOffsetForStringIndex(line, range.location, NULL);
        CGPoint origin;
        CGFloat ascent, descent;
        CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
        CTFrameGetLineOrigins(_frame, CFRangeMake(lines.count - 1, 0), &origin);
        // Place point after last line, including any font leading spacing if applicable
        origin.y -= self.font.leading;
        return CGRectMake(xPos, origin.y - descent, 3, ascent + descent);
    }
    
    // Regular case, caret somewhere within our text content range
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange range = CTLineGetStringRange(line);
        NSInteger localIndex = index - range.location;
        if (localIndex >= 0 && localIndex <= range.length) {
            // index is in the range for this line
            CGFloat xPos = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGPoint origin;
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            CTFrameGetLineOrigins(_frame, CFRangeMake(i, 0), &origin);
            // Make a small "caret" rect at the index position
            return CGRectMake(xPos, origin.y - descent, 3, ascent + descent);
        }
    }
    
    return CGRectNull;
}

// Public method to create a rect for a given range in the text contents
// Called by our EditableTextRange to implement the required
// UITextInput:firstRectForRange method
- (CGRect)firstRectForNSRange:(NSRange)range;
{
    NSInteger index = range.location;
    
    // Iterate over our CTLines, looking for the line that encompasses the given range
    NSArray *lines = (NSArray *) CTFrameGetLines(_frame);
    for (int i = 0; i < [lines count]; i++) {
        CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
        CFRange lineRange = CTLineGetStringRange(line);
        NSInteger localIndex = index - lineRange.location;
        if (localIndex >= 0 && localIndex < lineRange.length) {
            // For this sample, we use just the first line that intersects range
            NSInteger finalIndex = MIN(lineRange.location + lineRange.length, range.location + range.length);
            // Create a rect for the given range within this line
            CGFloat xStart = CTLineGetOffsetForStringIndex(line, index, NULL);
            CGFloat xEnd = CTLineGetOffsetForStringIndex(line, finalIndex, NULL);
            CGPoint origin;
            CTFrameGetLineOrigins(_frame, CFRangeMake(i, 0), &origin);
            CGFloat ascent, descent;
            CTLineGetTypographicBounds(line, &ascent, &descent, NULL);
            
            return CGRectMake(xStart, origin.y - descent, xEnd - xStart, ascent + descent);
        }
    }
    
    return CGRectNull;
}

// Helper method to update caretView when insertion point/selection changes
- (void)selectionChanged
{
    // If not in editing mode, we don't show the caret
    if (!self.editing) {
        [_caretView removeFromSuperview];
        return;
    }
    
    // If there is no selection range (always true for this sample), find the
    // insert point rect and create a caretView to draw the caret at this position
    if (self.selectedTextRange.length == 0) {
        _caretView.frame = [self caretRectForIndex:self.selectedTextRange.location];
        if (!_caretView.superview) {
            [self addSubview:_caretView];
            [self setNeedsDisplay];
        }
        // Set up a timer to "blink" the caret
        [_caretView delayBlink];
    } else {
        // If there is an actual selection, don't draw the insertion caret too
        [_caretView removeFromSuperview];
        [self setNeedsDisplay];
    }
    
    if (self.markedTextRange.location != NSNotFound) {
        [self setNeedsDisplay];
    }
}

// markedTextRange property accessor overrides

- (NSRange)markedTextRange
{
    return _markedTextRange;
}

- (void)setMarkedTextRange:(NSRange)range
{
    _markedTextRange = range;
    // Call selectionChanged to update view if necessary
    [self selectionChanged];
}

// selectedTextRange property accessor overrides

- (NSRange)selectedTextRange
{
    return _selectedTextRange;
}

- (void)setSelectedTextRange:(NSRange)range
{
    _selectedTextRange = range;
    // Call selectionChanged to update view if necessary
    [self selectionChanged];
}

// editing property accessor overrides

- (BOOL)isEditing
{
    return _editing;
}

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    // Call selectionChanged to update view if necessary
    [self selectionChanged];
}

// Class method that returns current selection color (note that in this sample,
// the color cannot be changed)
+ (UIColor *)selectionColor
{
    static UIColor *color = nil;
    if (color == nil) {
        color = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:0.50];
    }
    return color;
}

// Class method that returns current caret color (note that in this sample,
// the color cannot be changed)
+ (UIColor *)caretColor
{
    static UIColor *color = nil;
    if (color == nil) {
        color = [[UIColor alloc] initWithRed:0.25 green:0.50 blue:1.0 alpha:1.0];
    }
    return color;
}

@end

#pragma mark SimpleCaretView implementation

@implementation SimpleCaretView

static const NSTimeInterval InitialBlinkDelay = 0.7;
static const NSTimeInterval BlinkRate = 0.5;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [SimpleCoreTextView caretColor];
    }
    return self;
}

// Helper method to toggle hidden state of caret view
- (void)blink
{
    self.hidden = !self.hidden;
}

// UIView didMoveToSuperview override to set up blink timers after caret view created in superview
- (void)didMoveToSuperview
{
    self.hidden = NO;
    
    if (self.superview) {
        _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:BlinkRate target:self selector:@selector(blink) userInfo:nil repeats:YES];
        [self delayBlink];
    } else {
        [_blinkTimer invalidate];
        _blinkTimer = nil;
    }
}

- (void)dealloc
{
    [_blinkTimer invalidate];
}

// Helper method to set an initial blink delay
- (void)delayBlink
{
    self.hidden = NO;
    
    [_blinkTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:InitialBlinkDelay]];
}

@end
