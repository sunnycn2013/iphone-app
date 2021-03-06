//
//  NewBlogDetailController.h
//  iosapp
//
//  Created by 李萍 on 2016/11/7.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTextView.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSObjcDelegate <JSExport>


@end

@interface NewBlogDetailController : UIViewController <JSObjcDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewConstraint;
@property (weak, nonatomic) IBOutlet CommentTextView *commentTextView;

@property (weak, nonatomic) IBOutlet UIButton *favButton;

- (instancetype)initWithDetailId:(NSInteger)blogID;

@end
