//
//  TextView.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 25/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleCoreTextView.h"

@class EditableCoreTextView;

// EditableCoreTextViewDelegate - simple delegate protocol to notify when the EditableCoreTextView
// becomes first responder
@protocol EditableCoreTextViewDelegate
- (void)editableCoreTextViewWillEdit:(EditableCoreTextView *)editableCoreTextView;
@end

// EditableCoreTextView - Main custom text view that handles text input and draws text
// (using contained SimpleCoreTextView)

@interface EditableCoreTextView : UIView <UITextInput>
{
    SimpleCoreTextView                *_textView;
    NSMutableString                   *_text;
    NSDictionary                      *_markedTextStyle;
    __weak id <UITextInputDelegate>           _inputDelegate;
    UITextInputStringTokenizer        *_tokenizer;
    id <EditableCoreTextViewDelegate>  _editableCoreTextViewDelegate;
}

@property (nonatomic, retain) id <EditableCoreTextViewDelegate> editableCoreTextViewDelegate;


@end
