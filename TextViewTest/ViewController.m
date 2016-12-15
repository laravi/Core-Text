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
//    UITextView *textView;
}

@end

@implementation ViewController
@synthesize editableCoreTextView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    textView = [UITextView new];
//    textView.delegate = self;
    
    editableCoreTextView = [[EditableCoreTextView alloc] init];
    editableCoreTextView.editableCoreTextViewDelegate = self;
    
    CGRect frame = self.view.frame;
    frame.origin.y += 20;
    editableCoreTextView.frame = frame;

    [self.view addSubview:editableCoreTextView];
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
