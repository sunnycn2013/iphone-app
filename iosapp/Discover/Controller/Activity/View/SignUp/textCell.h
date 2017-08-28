//
//  textCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/8.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface textCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *hudTextLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end
