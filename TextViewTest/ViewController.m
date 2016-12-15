//
//  ViewController.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 21/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITextViewDelegate>
{
    TextView *textView;
}

@end

@implementation ViewController
@synthesize editableCoreTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    textView = [TextView new];
    textView.delegate = self;
    
    editableCoreTextView = [[EditableCoreTextView alloc] init];
    editableCoreTextView.editableCoreTextViewDelegate = self;
    
    CGRect frame = self.view.frame;
    frame.origin.y += 20;
    textView.frame = frame;

    [self.view addSubview:textView];
}

- (void)editableCoreTextViewWillEdit:(EditableCoreTextView *)editableCoreTextView;
{
}







-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

-(void)textViewDidChangeSelection:(UITextView *)textView
{
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    
}


@end
