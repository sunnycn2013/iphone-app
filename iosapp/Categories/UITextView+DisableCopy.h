//
//  UITextView+DisableCopy.h
//  
//
//  Created by wupei on 2017/5/8.
//
//

#import <UIKit/UIKit.h>

@interface UITextView (DisableCopy)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender;
@end
