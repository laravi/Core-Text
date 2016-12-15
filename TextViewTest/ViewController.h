//
//  ViewController.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 21/11/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableCoreTextView.h"
#import "TextView.h"

@interface ViewController : UIViewController <EditableCoreTextViewDelegate>

@property (nonatomic, retain) EditableCoreTextView *editableCoreTextView;

@end

