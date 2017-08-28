//
//  NearbyPersonCell.m
//  iosapp
//
//  Created by 李萍 on 2017/1/10.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "NearbyPersonCell.h"
#import "Utils.h"

@interface NearbyPersonCell ()

@property (weak, nonatomic) IBOutlet UIImageView *portrait;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyJobLabel;
@property (weak, nonatomic) IBOutlet UILabel *metersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderIcon;

@property (weak, nonatomic) IBOutlet UILabel *centerNameLb;
@property (weak, nonatomic) IBOutlet UILabel *idendityLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerIdendityLabel;

@end

@implementation NearbyPersonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _nameLabel.hidden = NO;
    
    _idendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _idendityLabel.layer.masksToBounds = YES;
    _idendityLabel.layer.cornerRadius = 2;
    _idendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _idendityLabel.layer.borderWidth = 1;
    
    _centerIdendityLabel.textColor = [UIColor colorWithHex:0x24CF5F];
    _centerIdendityLabel.layer.masksToBounds = YES;
    _centerIdendityLabel.layer.cornerRadius = 2;
    _centerIdendityLabel.layer.borderColor = [UIColor colorWithHex:0x24CF5F].CGColor;
    _centerIdendityLabel.layer.borderWidth = 1;
    
    _companyJobLabel.hidden = NO;
    _centerNameLb.hidden = YES;
    
    _genderIcon.layer.borderWidth = 1.0;
    _genderIcon.clipsToBounds = YES;
    _genderIcon.layer.cornerRadius = 6;
    _genderIcon.layer.borderColor = [UIColor colorWithHex:0xffffff].CGColor;
    
    _portrait.contentMode = UIViewContentModeScaleAspectFit;
    _portrait.clipsToBounds = YES;
    _portrait.layer.cornerRadius = 22.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setModel:(OSCNearByPeopleModel *)model
{
    [_portrait loadPortrait:[NSURL URLWithString:model.portrait] userName:model.name];
    NSString *desc = [NSString stringWithFormat:@"%@", model.more.company];
    
    if (desc && desc.length > 0) {
        _nameLabel.hidden = NO;
        _nameLabel.text = model.name.length ? model.name : @"匿名";
        _companyJobLabel.hidden = NO;
        _companyJobLabel.text = desc.length ? desc : @" ";
        _centerNameLb.hidden = YES;
        if (model.identity.officialMember) {
            _idendityLabel.hidden = NO;
            _centerIdendityLabel.hidden = YES;
        }else{
            _idendityLabel.hidden = YES;
            _centerIdendityLabel.hidden = YES;
        }
    }else{
        _nameLabel.hidden = YES;
        _companyJobLabel.hidden = YES;
        _centerNameLb.hidden = NO;
        _centerNameLb.text = model.name.length ? model.name : @"匿名";
        if (model.identity.officialMember) {
            _idendityLabel.hidden = YES;
            _centerIdendityLabel.hidden = NO;
        }else{
            _idendityLabel.hidden = YES;
            _centerIdendityLabel.hidden = YES;
        }
    }
    
    NSString *distanceStr;
    if (model.meters < 900){
        NSInteger metter = (((NSInteger)model.meters / 100) + 1) * 100;
        distanceStr = [NSString stringWithFormat:@"%ldm 以内",metter];
    }else{
        NSInteger metter = ((NSInteger)model.meters / 1000) + 1;
        distanceStr = [NSString stringWithFormat:@"%ldkm 以内",metter];
    }
    _metersLabel.text = distanceStr;
    
    switch (model.gender) {
        case UserGenderTypeMan:
        {
            _genderIcon.hidden = NO;
            [_genderIcon setImage:[UIImage imageNamed:@"ic_male"]];
            break;
        }
        case UserGenderTypeWoman:
        {
            _genderIcon.hidden = NO;
            [_genderIcon setImage:[UIImage imageNamed:@"ic_female"]];
            break;
        }
        default:
        {
            _genderIcon.hidden = YES;
            break;
        }
            break;
    }
}

@end
