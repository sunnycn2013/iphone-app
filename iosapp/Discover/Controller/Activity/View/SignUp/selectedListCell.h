//
//  selectedListCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/9.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface selectedListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *descTextView;
@property (weak, nonatomic) IBOutlet UILabel *descTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *arrowIcon;

@end
