//
//  GAMenuView.h
//  iosapp
//
//  Created by Graphic-one on 17/2/24.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GAMenuView : UIView

+ (void)MenuViewWithTitle:(NSString* )title
                    block:(void(^)())block
                   inView:(UIView* )view;

+ (void)MenuViewWithTitle:(NSString* )title
                    block:(void(^)())block
              cancelBlock:(void(^)())cancelBlock
                   inView:(UIView* )view;

@end
