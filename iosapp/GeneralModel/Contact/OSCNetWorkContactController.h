//
//  OSCNetWorkContactController.h
//  iosapp
//
//  Created by Graphic-one on 16/12/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OSCNetWorkContactController,OSCAuthor;
@protocol OSCNetWorkContactControllerDelegate <NSObject>

- (void)netWorkContactController:(OSCNetWorkContactController* )netWorkContactController
                    selectedUser:(OSCAuthor* )selectedAuthor;

@end


@interface OSCNetWorkContactController : UITableViewController

- (instancetype)initWithSearchKey:(nonnull NSString* )key;

@property (nonatomic,weak) id<OSCNetWorkContactControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
