//
//  MultiColumnView.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 20/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiColumnView : UIView

@property (copy, nonatomic) NSTextStorage *textStorage;
@property (strong, nonatomic) NSArray *textOrigins;
@property (strong, nonatomic) NSLayoutManager *layoutManager;

@end
