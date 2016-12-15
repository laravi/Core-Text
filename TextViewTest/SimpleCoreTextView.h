//
//  SimpleCoreTextView.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@class SimpleCaretView;

@interface SimpleCoreTextView : UIView
{
    NSString           *_text; // Our text content (without attributes)
    UIFont             *_font; // Font used for text content
    BOOL                _editing; // Is view in "editing" mode or not (affects drawn results)
    NSRange             _markedTextRange; // Marked text range (for input method marked text)
    NSRange             _selectedTextRange; // Selected text range
    
    NSDictionary       *_attributes; // Cached string attributes
    CTFramesetterRef    _framesetter; // Cached Core Text framesetter
    CTFrameRef          _frame; // Cached Core Text frame
    SimpleCaretView    *_caretView; // Subview that draws the insertion caret
}

@property (nonatomic, copy)                 NSString *text;
@property (nonatomic, retain)               UIFont *font;
@property (nonatomic, getter=isEditing)     BOOL editing;
@property (nonatomic)                       NSRange markedTextRange;
@property (nonatomic)                       NSRange selectedTextRange;

- (CGRect)caretRectForIndex:(int)index;
- (CGRect)firstRectForNSRange:(NSRange)range;
- (NSInteger)closestIndexToPoint:(CGPoint)point;

@end
