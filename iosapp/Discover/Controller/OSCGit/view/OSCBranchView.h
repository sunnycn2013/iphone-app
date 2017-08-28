//
//  OSCBranchView.h
//  iosapp
//
//  Created by Graphic-one on 17/3/22.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCBranchView;

@protocol OSCBranchViewDelegate <NSObject>
@optional
- (void)branchView:(OSCBranchView* )OSCBranchView didSelectedIndex:(NSUInteger)index;
@end

@interface OSCBranchView : UIView

+ (instancetype)BranchViewWithDataSource:(NSArray* )dataSources;

@property (nonatomic,weak) id<OSCBranchViewDelegate> delegate;

@end
