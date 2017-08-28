//
//  SoftWareDetailBodyCell.h
//  iosapp
//
//  Created by Graphic-one on 16/6/28.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSCListItem;
@interface SoftWareDetailBodyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIWebView *webView;

-(void)configurationRelatedInfo:(OSCListItem* )softWareModel;

-(void)configurationRelatedInfo:(OSCListItem* )softWareModel tapGesture:(UITapGestureRecognizer *)tap;

@end
