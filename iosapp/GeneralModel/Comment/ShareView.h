//
//  ShareView.h
//  iosapp
//
//  Created by wupei on 2017/4/27.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectBoardView.h"
@interface ShareView : UIView

/**
 显示蒙板
 */
- (void)showView;

-(void)dismissContactView;

@property (nonatomic, strong) SelectBoardView *selV;

@end
