//
//  OSCBranhListCell.m
//  iosapp
//
//  Created by Graphic-one on 17/3/13.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBranhListCell.h"
#import "OSCBranchListModel.h"

#import "UIColor+Util.h"

@interface OSCBranhListCell ()
@property (weak, nonatomic) IBOutlet UIImageView *pojectImgView;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLb;
@end

@implementation OSCBranhListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIView *selectedBackground = [UIView new];
    selectedBackground.backgroundColor = [UIColor themeColor];
    [self setSelectedBackgroundView:selectedBackground];
}

- (void)setModel:(OSCBranchListModel *)model{
    _model = model;
    
    if ([model.type isEqualToString:@"tree"]) {
        _pojectImgView.image = [UIImage imageNamed:@"ic_folder"];
    }else if ([model.type isEqualToString:@"blob"]){
        _pojectImgView.image = [UIImage imageNamed:@"ic_file"];
    }
    
    _fileNameLb.text = model.name ?: @".gitFile";
}

@end
