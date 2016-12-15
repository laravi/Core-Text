//
//  IndexedRange.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexedRange : UITextRange
{
    NSRange _range;
}
@property (nonatomic) NSRange range;
+ (IndexedRange *)rangeWithNSRange:(NSRange)range;

@end
