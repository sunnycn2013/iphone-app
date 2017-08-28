//
//  NearbyPersonCell.h
//  iosapp
//
//  Created by 李萍 on 2017/1/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSCNearByPeopleModel.h"

#define kNearbyPersonCellID @"nearbyPersonCellID"

@interface NearbyPersonCell : UITableViewCell

@property (nonatomic, strong) OSCNearByPeopleModel *model;

@end
