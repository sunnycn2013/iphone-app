//
//  UITextView+DisableCopy.m
//  
//
//  Created by wupei on 2017/5/8.
//
//

#import "UITextView+DisableCopy.h"

@implementation UITextView (DisableCopy)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    //一旦双击，里面禁用。这样就不影响点击链接跳转
    [self resignFirstResponder];
    self.userInteractionEnabled = NO;
    
    if ([UIMenuController sharedMenuController])
    {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    
    return NO;
    
}

@end
