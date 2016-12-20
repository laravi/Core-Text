//
//  TextView.m
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import "TextView.h"

@implementation TextView

-(id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}


- (void)insertText:(NSString *)text
{
    [super insertText:text];
    
//    self.text = text;
}

- (void)deleteBackward
{
    [super deleteBackward];
}




-(NSString *)textInRange:(UITextRange *)range
{
    return [super textInRange:range];
}
-(void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    [super replaceRange:range withText:text];
}




-(BOOL)shouldChangeTextInRange:(UITextRange *)range replacementText:(NSString *)text
{
    [super shouldChangeTextInRange:range replacementText:text];
    return YES;
}



@end
