//
//  TextView.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 25/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "EditableCoreTextView.h"
#import <CoreText/CoreText.h>
#import "IndexedPosition.h"
#import "IndexedRange.h"

@interface EditableCoreTextView () <UIGestureRecognizerDelegate>

- (void)tap:(UITapGestureRecognizer *)tap;

@end

@implementation EditableCoreTextView

@synthesize markedTextStyle = _markedTextStyle;
@synthesize inputDelegate = _inputDelegate;
@synthesize editableCoreTextViewDelegate = _editableCoreTextViewDelegate;

- (id)init {
    if ((self = [super init])) {
        // Add tap gesture recognizer to let the user enter editing mode
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tap];
        tap.delegate = self;
        
        // Create our tokenizer and text storage
        _tokenizer = [[UITextInputStringTokenizer alloc] initWithTextInput:self];
        _text = [[NSMutableString alloc] init];
        
        // Create and set up our SimpleCoreTextView that will do the drawing
        _textView = [[SimpleCoreTextView alloc] initWithFrame:self.frame];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.userInteractionEnabled = YES;
        self.autoresizesSubviews = YES;
        [self addSubview:_textView];
        _textView.text = @"";
        _textView.userInteractionEnabled = NO;
    }
    return self;
}

- (void)dealloc {
    self.markedTextStyle = nil;
    _tokenizer = nil;
    _text = nil;
    _textView = nil;
}

#pragma mark Custom user interaction

// UIResponder protocol override - our view can become first responder to
// receive user text input
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

// UIResponder protocol override - called when our view is being asked to resign
// first responder state (in this sample by using the "Done" button)
- (BOOL)resignFirstResponder
{
    // Flag that underlying SimpleCoreTextView is no longer in edit mode
    _textView.editing = NO;
    return [super resignFirstResponder];
}

// UIGestureRecognizerDelegate method - called to determine if we want to handle
// a given gesture
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gesture shouldReceiveTouch:(UITouch *)touch
{
    // If gesture touch occurs in our view, we want to handle it
    return (touch.view == self);
}

// Our tap gesture recognizer selector that enters editing mode, or if already
// in editing mode, updates the text insertion point
- (void)tap:(UITapGestureRecognizer *)tap
{
    if (![self isFirstResponder]) {
        // Inform controller that we're about to enter editing mode
        [self.editableCoreTextViewDelegate editableCoreTextViewWillEdit:self];
        // Flag that underlying SimpleCoreTextView is now in edit mode
        _textView.editing = YES;
        // Become first responder state (which shows software keyboard, if applicable)
        [self becomeFirstResponder];
    } else {
        // Already in editing mode, set insertion point (via selectedTextRange)
        [self.inputDelegate selectionWillChange:self];
        
        // Find and update insertion point in underlying SimpleCoreTextView
        NSInteger index = [_textView closestIndexToPoint:[tap locationInView:_textView]];
        _textView.markedTextRange = NSMakeRange(NSNotFound, 0);
        _textView.selectedTextRange = NSMakeRange(index, 0);
        
        // Let inputDelegate know selection has changed
        [self.inputDelegate selectionDidChange:self];
    }
}

#if 0
// Helper method to use whenever selection state changes
- (void)selectionChanged
{
    // Not implemented in this sample -- a user selection mechanism is beyond
    // the scope of this simple sample, but if a mechanism and UI existed to
    // support user selection of text, this method would update selection information,
    // and inform the underlying SimpleCoreTextView.
}
// Helper method to use whenever text storage changes
- (void)textChanged
{
    _textView.text = _text;
}
#endif


#pragma mark UITextInput methods

#pragma mark UITextInput - Replacing and Returning Text

// UITextInput required method - called by text system to get the string for
// a given range in the text storage
- (NSString *)textInRange:(UITextRange *)range
{
    IndexedRange *r = (IndexedRange *)range;
    return ([_text substringWithRange:r.range]);
}

// UITextInput required method - called by text system to replace the given
// text storage range with new text
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    IndexedRange *r = (IndexedRange *)range;
    // Determine if replaced range intersects current selection range
    // and update selection range if so.
    NSRange selectedNSRange = _textView.selectedTextRange;
    if ((r.range.location + r.range.length) <= selectedNSRange.location) {
        // This is the easy case.
        selectedNSRange.location -= (r.range.length - text.length);
    } else {
        // Need to also deal with overlapping ranges.  Not addressed
        // in this simplified sample.
    }
    
    // Now replace characters in text storage
    [_text replaceCharactersInRange:r.range withString:text];
    
    // Update underlying SimpleCoreTextView
    _textView.text = _text;
    _textView.selectedTextRange = selectedNSRange;
    
}

#pragma mark UITextInput - Working with Marked and Selected Text

// UITextInput selectedTextRange property accessor overrides
// (access/update underlaying SimpleCoreTextView)

- (UITextRange *)selectedTextRange
{
    return [IndexedRange rangeWithNSRange:_textView.selectedTextRange];
}

- (void)setSelectedTextRange:(UITextRange *)range
{
    IndexedRange *r = (IndexedRange *)range;
    _textView.selectedTextRange = r.range;
}

// UITextInput markedTextRange property accessor overrides
// (access/update underlaying SimpleCoreTextView)

- (UITextRange *)markedTextRange
{
    return [IndexedRange rangeWithNSRange:_textView.markedTextRange];
}

// UITextInput required method - Insert the provided text and marks it to indicate
// that it is part of an active input session.
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    NSRange selectedNSRange = _textView.selectedTextRange;
    NSRange markedTextRange = _textView.markedTextRange;
    
    if (markedTextRange.location != NSNotFound) {
        if (!markedText)
            markedText = @"";
        // Replace characters in text storage and update markedText range length
        [_text replaceCharactersInRange:markedTextRange withString:markedText];
        markedTextRange.length = markedText.length;
    } else if (selectedNSRange.length > 0) {
        // There currently isn't a marked text range, but there is a selected range,
        // so replace text storage at selected range and update markedTextRange.
        [_text replaceCharactersInRange:selectedNSRange withString:markedText];
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
    } else {
        // There currently isn't marked or selected text ranges, so just insert
        // given text into storage and update markedTextRange.
        [_text insertString:markedText atIndex:selectedNSRange.location];
        markedTextRange.location = selectedNSRange.location;
        markedTextRange.length = markedText.length;
    }
    
    // Updated selected text range and underlying SimpleCoreTextView
    
    selectedNSRange = NSMakeRange(selectedRange.location + markedTextRange.location, selectedRange.length);
    
    _textView.text = _text;
    _textView.markedTextRange = markedTextRange;
    _textView.selectedTextRange = selectedNSRange;
    
}

// UITextInput required method - Unmark the currently marked text.
- (void)unmarkText
{
    NSRange markedTextRange = _textView.markedTextRange;
    
    if (markedTextRange.location == NSNotFound)
        return;
    
    // unmark the underlying SimpleCoreTextView.markedTextRange
    markedTextRange.location = NSNotFound;
    _textView.markedTextRange = markedTextRange;
}

#pragma mark UITextInput - Computing Text Ranges and Text Positions

// UITextInput beginningOfDocument property accessor override
- (UITextPosition *)beginningOfDocument
{
    // For this sample, the document always starts at index 0 and is the full
    // length of the text storage
    return [IndexedPosition positionWithIndex:0];
}

// UITextInput endOfDocument property accessor override
- (UITextPosition *)endOfDocument
{
    // For this sample, the document always starts at index 0 and is the full
    // length of the text storage
    return [IndexedPosition positionWithIndex:_text.length];
}

// UITextInput protocol required method - Return the range between two text positions
// using our implementation of UITextRange
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition
{
    // Generate IndexedPosition instances that wrap the to and from ranges
    IndexedPosition *from = (IndexedPosition *)fromPosition;
    IndexedPosition *to = (IndexedPosition *)toPosition;
    NSRange range = NSMakeRange(MIN(from.index, to.index), ABS(to.index - from.index));
    return [IndexedRange rangeWithNSRange:range];
    
}

// UITextInput protocol required method - Returns the text position at a given offset
// from another text position using our implementation of UITextPosition
- (UITextPosition *)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset
{
    // Generate IndexedPosition instance, and increment index by offset
    IndexedPosition *pos = (IndexedPosition *)position;
    NSInteger end = pos.index + offset;
    // Verify position is valid in document
    if (end > _text.length || end < 0)
        return nil;
    
    return [IndexedPosition positionWithIndex:end];
}

// UITextInput protocol required method - Returns the text position at a given offset
// in a specified direction from another text position using our implementation of
// UITextPosition.
- (UITextPosition *)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset
{
    // Note that this sample assumes LTR text direction
    IndexedPosition *pos = (IndexedPosition *)position;
    NSInteger newPos = pos.index;
    
    switch (direction) {
        case UITextLayoutDirectionRight:
            newPos += offset;
            break;
        case UITextLayoutDirectionLeft:
            newPos -= offset;
            break;
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionDown:
            // This sample does not support vertical text directions
            break;
    }
    
    // Verify new position valid in document
    
    if (newPos < 0)
        newPos = 0;
    
    if (newPos > _text.length)
        newPos = _text.length;
    
    return [IndexedPosition positionWithIndex:newPos];
}

#pragma mark UITextInput - Evaluating Text Positions

// UITextInput protocol required method - Return how one text position compares to another
// text position.
- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other
{
    IndexedPosition *pos = (IndexedPosition *)position;
    IndexedPosition *o = (IndexedPosition *)other;
    
    // For this sample, we simply compare position index values
    if (pos.index == o.index) {
        return NSOrderedSame;
    } if (pos.index < o.index) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

// UITextInput protocol required method - Return the number of visible characters
// between one text position and another text position.
- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition
{
    IndexedPosition *f = (IndexedPosition *)from;
    IndexedPosition *t = (IndexedPosition *)toPosition;
    return (t.index - f.index);
}

#pragma mark UITextInput - Text Input Delegate and Text Input Tokenizer

// UITextInput tokenizer property accessor override
//
// An input tokenizer is an object that provides information about the granularity
// of text units by implementing the UITextInputTokenizer protocol.  Standard units
// of granularity include characters, words, lines, and paragraphs. In most cases,
// you may lazily create and assign an instance of a subclass of
// UITextInputStringTokenizer for this purpose, as this sample does. If you require
// different behavior than this system-provided tokenizer, you can create a custom
// tokenizer that adopts the UITextInputTokenizer protocol.
- (id <UITextInputTokenizer>)tokenizer
{
    return _tokenizer;
}

#pragma mark UITextInput - Text Layout, writing direction and position related methods

// UITextInput protocol method - Return the text position that is at the farthest
// extent in a given layout direction within a range of text.
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    // Note that this sample assumes LTR text direction
    IndexedRange *r = (IndexedRange *)range;
    NSInteger pos = r.range.location;
    
    // For this sample, we just return the extent of the given range if the
    // given direction is "forward" in a LTR context (UITextLayoutDirectionRight
    // or UITextLayoutDirectionDown), otherwise we return just the range position
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            pos = r.range.location;
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            pos = r.range.location + r.range.length;
            break;
    }
    
    // Return text position using our UITextPosition implementation.
    // Note that position is not currently checked against document range.
    return [IndexedPosition positionWithIndex:pos];
}

// UITextInput protocol required method - Return a text range from a given text position
// to its farthest extent in a certain direction of layout.
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction
{
    // Note that this sample assumes LTR text direction
    IndexedPosition *pos = (IndexedPosition *)position;
    NSRange result = NSMakeRange(pos.index, 1);
    
    switch (direction) {
        case UITextLayoutDirectionUp:
        case UITextLayoutDirectionLeft:
            result = NSMakeRange(pos.index - 1, 1);
            break;
        case UITextLayoutDirectionRight:
        case UITextLayoutDirectionDown:
            result = NSMakeRange(pos.index, 1);
            break;
    }
    
    // Return range using our UITextRange implementation
    // Note that range is not currently checked against document range.
    return [IndexedRange rangeWithNSRange:result];
}

// UITextInput protocol required method - Return the base writing direction for
// a position in the text going in a specified text direction.
- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    // This sample assumes LTR text direction and does not currently support BiDi or RTL.
    return UITextWritingDirectionLeftToRight;
}

// UITextInput protocol required method - Set the base writing direction for a
// given range of text in a document.
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    // This sample assumes LTR text direction and does not currently support BiDi or RTL.
}

#pragma mark UITextInput - Geometry methods

// UITextInput protocol required method - Return the first rectangle that encloses
// a range of text in a document.
- (CGRect)firstRectForRange:(UITextRange *)range
{
    IndexedRange *r = (IndexedRange *)range;
    // Use underlying SimpleCoreTextView to get rect for range
    CGRect rect = [_textView firstRectForNSRange:r.range];
    // Convert rect to our view coordinates
    return [self convertRect:rect fromView:_textView];
}

// UITextInput protocol required method - Return a rectangle used to draw the caret
// at a given insertion point.
- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    IndexedPosition *pos = (IndexedPosition *)position;
    
    // Get caret rect from underlying SimpleCoreTextView
    CGRect rect =  [_textView caretRectForIndex:pos.index];
    // Convert rect to our view coordinates
    return [self convertRect:rect fromView:_textView];
}

#pragma mark UITextInput - Hit testing

// Note that for this sample hit testing methods are not implemented, as there
// is no implemented mechanic for letting user select text via touches.  There
// is a wide variety of approaches for this (gestures, drag rects, etc) and
// any approach chosen will depend greatly on the design of the application.

// UITextInput protocol required method - Return the position in a document that
// is closest to a specified point.
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    // Not implemented in this sample.  Could utilize underlying
    // SimpleCoreTextView:closestIndexToPoint:point
    return nil;
}

// UITextInput protocol required method - Return the position in a document that
// is closest to a specified point in a given range.
- (UITextPosition *)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range
{
    // Not implemented in this sample.  Could utilize underlying
    // SimpleCoreTextView:closestIndexToPoint:point
    return nil;
}

// UITextInput protocol required method - Return the character or range of
// characters that is at a given point in a document.
- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    // Not implemented in this sample.  Could utilize underlying
    // SimpleCoreTextView:closestIndexToPoint:point
    return nil;
}

#pragma mark UITextInput - Returning Text Styling Information

// UITextInput protocol method - Return a dictionary with properties that specify
// how text is to be style at a certain location in a document.
- (NSDictionary *)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    // This sample assumes all text is single-styled, so this is easy.
    return [NSDictionary dictionaryWithObject:_textView.font forKey:UITextInputTextFontKey];
}

#pragma mark UIKeyInput methods

// UIKeyInput required method - A Boolean value that indicates whether the text-entry
// objects have any text.
- (BOOL)hasText
{
    return (_text.length != 0);
}

// UIKeyInput required method - Insert a character into the displayed text.
// Called by the text system when the user has entered simple text
- (void)insertText:(NSString *)text
{
    NSRange selectedNSRange = _textView.selectedTextRange;
    NSRange markedTextRange = _textView.markedTextRange;
    
    // Note: While this sample does not provide a way for the user to
    // create marked or selected text, the following code still checks for
    // these ranges and acts accordingly.
    if (markedTextRange.location != NSNotFound) {
        // There is marked text -- replace marked text with user-entered text
        [_text replaceCharactersInRange:markedTextRange withString:text];
        selectedNSRange.location = markedTextRange.location + text.length;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
    } else if (selectedNSRange.length > 0) {
        // Replace selected text with user-entered text
        [_text replaceCharactersInRange:selectedNSRange withString:text];
        selectedNSRange.length = 0;
        selectedNSRange.location += text.length;
    } else {
        // Insert user-entered text at current insertion point
        [_text insertString:text atIndex:selectedNSRange.location];
        selectedNSRange.location += text.length;
    }
    
    // Update underlying SimpleCoreTextView
    _textView.text = _text;
    _textView.markedTextRange = markedTextRange;
    _textView.selectedTextRange = selectedNSRange;
}

// UIKeyInput required method - Delete a character from the displayed text.
// Called by the text system when the user is invoking a delete (e.g. pressing
// the delete software keyboard key)
- (void)deleteBackward
{
    NSRange selectedNSRange = _textView.selectedTextRange;
    NSRange markedTextRange = _textView.markedTextRange;
    
    // Note: While this sample does not provide a way for the user to
    // create marked or selected text, the following code still checks for
    // these ranges and acts accordingly.
    if (markedTextRange.location != NSNotFound) {
        // There is marked text, so delete it
        [_text deleteCharactersInRange:markedTextRange];
        selectedNSRange.location = markedTextRange.location;
        selectedNSRange.length = 0;
        markedTextRange = NSMakeRange(NSNotFound, 0);
    } else if (selectedNSRange.length > 0) {
        // Delete the selected text
        [_text deleteCharactersInRange:selectedNSRange];
        selectedNSRange.length = 0;
    } else if (selectedNSRange.location > 0) {
        // Delete one char of text at the current insertion point
        selectedNSRange.location--;
        selectedNSRange.length = 1;
        [_text deleteCharactersInRange:selectedNSRange];
        selectedNSRange.length = 0;
    }
    
    // Update underlying SimpleCoreTextView
    _textView.text = _text;
    _textView.markedTextRange = markedTextRange;
    _textView.selectedTextRange = selectedNSRange;
}

@end
