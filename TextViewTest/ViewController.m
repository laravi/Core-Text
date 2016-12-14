//
//  ViewController.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 21/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "ViewController.h"
#import "TextView.h"

@interface ViewController ()<UITextViewDelegate>
{
    TextView *textView;
//    UITextView *textView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
//    textView = [UITextView new];
//    textView.delegate = self;
    
    textView = [[TextView alloc] init];
    
    CGRect frame = self.view.frame;
    frame.origin.y += 20;
    textView.frame = frame;

    [self.view addSubview:textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
