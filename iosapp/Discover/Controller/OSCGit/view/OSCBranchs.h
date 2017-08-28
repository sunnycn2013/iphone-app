//
//  OSCBranchs.h
//  iosapp
//
//  Created by Graphic-one on 17/3/21.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCBranchs;

@protocol OSCBranchsDelegate <NSObject>
@optional
- (void)branchs:(OSCBranchs* )OSCBranchsView didSelectedIndexPath:(NSIndexPath* )indexPath;
@end

@interface OSCBranchs : UIView

+ (instancetype)BranchsWithDataSource:(NSArray* )dataSources;

@property (nonatomic,weak) id<OSCBranchsDelegate> delegate;

@end
