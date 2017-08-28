//
//  OSCEventSignInCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/2.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCActivities.h"

@interface OSCEventSignInCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *phoneInfoView;
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTF;
@property (weak, nonatomic) IBOutlet UILabel *costMessageLabel;

@end
