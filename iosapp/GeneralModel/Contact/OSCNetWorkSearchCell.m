//
//  OSCNetWorkSearchCell.m
//  iosapp
//
//  Created by Graphic-one on 16/12/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCNetWorkSearchCell.h"
#import "OSCListItem.h"

#import "UIImageView+Comment.h"

@interface OSCNetWorkSearchCell ()

@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation OSCNetWorkSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];

    [_portraitImageView handleCornerRadiusWithRadius:18];
}

- (void)setAuthor:(OSCAuthor *)author{
    _author = author;
    
    [_portraitImageView loadPortrait:[NSURL URLWithString:author.portrait] userName:author.name];
    _nameLabel.text = author.name;
}

@end
