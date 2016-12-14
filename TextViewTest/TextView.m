//
//  TextView.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 25/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "TextView.h"

@implementation TextView
{
    
}

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark UIKeyInput protocol

- (void)insertText:(NSString *)text
{
    
}

- (void)deleteBackward
{
    
}

- (BOOL)hasText
{
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self becomeFirstResponder];
}


#pragma mark uitextinput


/////////////////////////////////////////////////////////////////////////////
// MARK: -
// MARK: UITextInput methods
/////////////////////////////////////////////////////////////////////////////


// MARK: UITextInput - Replacing and Returning Text

//- (NSString *)textInRange:(UITextRange *)range
//{
//    return nil;
//}
//
//- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
//{
//    
//}
//
//// MARK: UITextInput - Working with Marked and Selected Text
//
//- (UITextRange *)selectedTextRange {
//    return nil;
//}
//
//- (void)setSelectedTextRange:(UITextRange *)range {
//}
//
//- (UITextRange *)markedTextRange {
//    return nil;
//}
//
//- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange {
//    
//    
//}
//
//- (void)unmarkText {
//    
//    
//}
//
//// MARK: UITextInput - Computing Text Ranges and Text Positions
//
//- (UITextPosition*)beginningOfDocument {
//    return nil;
//}
//
//- (UITextPosition*)endOfDocument {
//    return nil;
//}
//
//- (UITextRange*)textRangeFromPosition:(UITextPosition *)fromPosition toPosition:(UITextPosition *)toPosition {
//    
//    return nil;
//    
//}
//
//- (UITextPosition*)positionFromPosition:(UITextPosition *)position offset:(NSInteger)offset {
//    
//    return nil;
//}
//
//- (UITextPosition*)positionFromPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction offset:(NSInteger)offset {
//    
//    return nil;
//}
//
//// MARK: UITextInput - Evaluating Text Positions
//
//- (NSComparisonResult)comparePosition:(UITextPosition *)position toPosition:(UITextPosition *)other {
//    return nil;
//}
//
//- (NSInteger)offsetFromPosition:(UITextPosition *)from toPosition:(UITextPosition *)toPosition {
//    return nil;
//}
//
//// MARK: UITextInput - Text Input Delegate and Text Input Tokenizer
//
//- (id <UITextInputTokenizer>)tokenizer {
//    return nil;
//}
//
//
//// MARK: UITextInput - Text Layout, writing direction and position
//
//- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction {
//    
//    return nil;
//}
//
//- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position inDirection:(UITextLayoutDirection)direction {
//    
//    return nil;
//}
//
//- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
//    return UITextWritingDirectionLeftToRight;
//}
//
//- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range {
//    // only ltr supported for now.
//}

// MARK: UITextInput - Geometry

//- (CGRect)firstRectForRange:(UITextRange *)range {
//    
//    return nil;
//}
//
//- (CGRect)caretRectForPosition:(UITextPosition *)position {
//    
//    return nil;
//}
//
//- (UIView *)textInputView {
//    return _textContentView;
//}

// MARK: UITextInput - Hit testing

//- (UITextPosition*)closestPositionToPoint:(CGPoint)point {
//    
//    EGOIndexedPosition *position = [EGOIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
//    return position;
//    
//}
//
//- (UITextPosition*)closestPositionToPoint:(CGPoint)point withinRange:(UITextRange *)range {
//    
//    EGOIndexedPosition *position = [EGOIndexedPosition positionWithIndex:[self closestIndexToPoint:point]];
//    return position;
//    
//}
//
//- (UITextRange*)characterRangeAtPoint:(CGPoint)point {
//    
//    EGOIndexedRange *range = [EGOIndexedRange rangeWithNSRange:[self characterRangeAtPoint_:point]];
//    return range;
//    
//}
//
//// MARK: UITextInput - Styling Information
//
//- (NSDictionary*)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction {
//    
//    EGOIndexedPosition *pos = (EGOIndexedPosition*)position;
//    NSInteger index = MAX(pos.index, 0);
//    index = MIN(index, _attributedString.length-1);
//    
//    NSDictionary *attribs = [self.attributedString attributesAtIndex:index effectiveRange:nil];
//    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:1];
//    
//    CTFontRef ctFont = (CTFontRef)[attribs valueForKey:(NSString*)kCTFontAttributeName];
//    UIFont *font = [UIFont fontWithName:(NSString*)CTFontCopyFamilyName(ctFont) size:CTFontGetSize(ctFont)];
//    
//    [dictionary setObject:font forKey:NSFontAttributeName];
//    
//    return dictionary;
//    
//}





@end
