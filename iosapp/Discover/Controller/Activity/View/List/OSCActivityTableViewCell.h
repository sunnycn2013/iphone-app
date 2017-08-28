//
//  OSCActivityTableViewCell.h
//  iosapp
//
//  Created by Graphic-one on 16/5/24.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UsualTableViewCell.h"

extern NSString* OSCActivityTableViewCell_IdentifierString;

@class OSCActivities, OSCListItem;
@interface OSCActivityTableViewCell : UsualTableViewCell

+(instancetype)returnReuseCellFormTableView:(UITableView* )tableView
                                  indexPath:(NSIndexPath *)indexPath
                                 identifier:(NSString *)identifierString;

@property (nonatomic, strong) OSCActivities* viewModel; //线下活动model

@property (nonatomic,strong) OSCListItem* listItem;

@end
