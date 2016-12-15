//
//  IndexedPosition.h
//  TextViewTest
//
//  Created by Vignesh Ramesh on 15/12/16.
//  Copyright © 2016 Vignesh Ramesh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexedPosition : UITextPosition
{
    NSUInteger _index;
    id <UITextInputDelegate> _inputDelegate;
}
@property (nonatomic) NSUInteger index;
+ (IndexedPosition *)positionWithIndex:(NSUInteger)index;

@end
