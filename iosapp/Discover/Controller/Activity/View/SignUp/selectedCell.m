//
//  selectedCell.m
//  iosapp
//
//  Created by 李萍 on 2016/12/8.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "selectedCell.h"
#import "OSCActivityApplyModel.h"
#import "UIColor+Util.h"

#define icon_width_equ_height 20
#define kScreen_W [UIScreen mainScreen].bounds.size.width
#define selectWidth kScreen_W/4
#define selectHeight 40

#pragma mark - cell

@interface selectedCell ()

@property (nonatomic, strong) NSMutableArray *options;
@property (nonatomic, strong) NSMutableArray *optionStatusArray;
@property (nonatomic, strong) OSCActivityApplyModel *applyModel;
@property (nonatomic, strong) NSArray *statusArray;

@property (nonatomic, strong) UILabel *themeL;//主题
@end

@implementation selectedCell

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
      andDictionary:(OSCActivityApplyModel *)model
       locatoinData:(NSArray *)statusArray
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _optionStatusArray = [NSMutableArray new];//存选择的title
        
        self.applyModel = model;
        self.statusArray = statusArray;
        [self dictionaryResolve:model];
        [self setLayOutForSubView:model.formType];
    }
    return self;
}

//data
- (void)dictionaryResolve:(OSCActivityApplyModel *)model
{
    _options = [NSMutableArray new];
    
    if (model.optionStatus == nil) {
        NSArray *array = [selectedCell dicStringToArray:model.option];
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                _optionStatusString = @"0;";
            } else if (idx == array.count - 1) {
                _optionStatusString = [NSString stringWithFormat:@"%@0", _optionStatusString];
            } else {
                _optionStatusString = [NSString stringWithFormat:@"%@0;", _optionStatusString];
            }
            
        }];
        
        model.optionStatus = _optionStatusString;
    } else {
        _optionStatusString = model.optionStatus;
    }
    
    [[selectedCell dicStringToArray:model.option] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SelectOption *option = [SelectOption new];
        option.optionTitle = [selectedCell dicStringToArray:model.option][idx];
        option.optionStatus = [self.statusArray[idx] integerValue];
        
        [_options addObject:option];
    }];
    
}

+ (NSMutableArray *)dicStringToArray:(NSString *)string
{
    if ([string isEqualToString:@""]) {
        NSMutableArray *arr = [NSMutableArray array];
        return arr;
    };
    
    if ([[string substringFromIndex:string.length-1] isEqualToString:@";"]) {
        string = [string substringWithRange:NSMakeRange(0, string.length - 1)];
    } else {
        string = string;
    }
    
    NSMutableArray *array = [string componentsSeparatedByString:@";"].mutableCopy;
    
    return array;
}

// UI
- (void)setLayOutForSubView:(EventApplyPreloadFormType)formType
{
    _boxButtons = [NSMutableArray new];
    _radioButtons = [NSMutableArray new];
    
    self.themeL = [[UILabel alloc] initWithFrame:CGRectMake(16, 5, kScreen_W, 35)];
    self.themeL.text = self.applyModel.label;
    self.themeL.font = [UIFont systemFontOfSize:15.0];
    self.themeL.textColor = [UIColor colorWithHex:0x6A6A6A];
    [self.contentView addSubview:self.themeL];
    
    
    [_options enumerateObjectsUsingBlock:^(SelectOption *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger x = idx%4;
        NSInteger y = idx/4;
        selectedSubView *subView = [[selectedSubView alloc] initWithFrame:(CGRect){{selectWidth*x, selectHeight*y + 40}, {selectWidth, selectHeight}}];
        subView.tag = idx+1;
        [subView addTarget:self action:@selector(changeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *imageName;
        
        if (obj.optionStatus == 1) {//(idx == 0 && obj.optionStatus == 0) {
            imageName = (formType == EventApplyPreloadFormTypeCheckbox) ? @"checkbox_on" : @"radiobox_on";
            [_optionStatusArray addObject:obj.optionTitle];
        } else {
            imageName = (formType == EventApplyPreloadFormTypeCheckbox) ? @"checkbox_off" : @"radiobox_off";
        }

        [subView.iconButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        subView.nameLabel.text = obj.optionTitle;
        
        [self.contentView addSubview:subView];
        
        if (obj.optionStatus == -1) {
            subView.iconButton.enabled = NO;
            subView.nameLabel.enabled = NO;
        } else {
            subView.iconButton.enabled = YES;
            subView.nameLabel.enabled = YES;
            [subView.iconButton addTarget:self action:@selector(changeSelectedAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        subView.iconButton.tag = idx+1;
        
        if (formType == EventApplyPreloadFormTypeCheckbox) {
            [_boxButtons addObject:subView.iconButton];
        } else {
            [_radioButtons addObject:subView.iconButton];
        }
    }];
}

- (void)changeSelectedAction:(UIButton *)button
{
    SelectOption *selectedObj = _options[button.tag - 1];
    __block NSMutableArray *status = self.statusArray.mutableCopy;
    __block NSInteger clickIdx = 0;
    
    if (_radioButtons != nil || _boxButtons != nil) {
        if (_radioButtons.count > 0) {//radio 单选
            
            for (UIButton *btn in _radioButtons) {
                if (button.tag == btn.tag) {
                    //已被选中 不改变
                    [button setImage:[UIImage imageNamed:@"radiobox_on"] forState:UIControlStateNormal];
                    
                    if (_optionStatusArray != nil) {
                        [_optionStatusArray removeAllObjects];
                    }
                    [_optionStatusArray addObject:selectedObj.optionTitle];
                    clickIdx = button.tag - 1;
                } else {
                    [btn setImage:[UIImage imageNamed:@"radiobox_off"]
                             forState:UIControlStateNormal];
                }
            }

            [status enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([status[idx] integerValue] == 1 || [status[idx] integerValue] == 0) {
                    if (idx == clickIdx) {
                        status[idx] = @(1);
                    } else {
                        status[idx] = @(0);
                    }
                } else {
                    
                }
                
            }];
        } else if (_boxButtons.count > 0){//多选
            clickIdx = button.tag - 1;
            
            if ([status[clickIdx] integerValue] == 1) {
                status[clickIdx] = @(0);
                [button setImage:[UIImage imageNamed:@"checkbox_off"] forState:UIControlStateNormal];
            } else if ([status[clickIdx] integerValue] == 0) {
                status[clickIdx] = @(1);
                [button setImage:[UIImage imageNamed:@"checkbox_on"] forState:UIControlStateNormal];
            } else if ([status[clickIdx] integerValue] == -1) {
                
            }
            
            __block BOOL isEquel = NO;
            [_optionStatusArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                if ([obj isEqualToString:selectedObj.optionTitle]) {
                    isEquel = YES;
                }
                
            }];

            if (isEquel) {
                if (_optionStatusArray != nil) {
                    [_optionStatusArray removeObject:selectedObj.optionTitle];
                }
            } else {
                [_optionStatusArray addObject:selectedObj.optionTitle];
            }
            
        }
    } else {
        //不是checkbox,radio类型
    }
    
    if ([_delegate respondsToSelector:@selector(selectedCell:applyModel:locatoinData:forSelectedCell:)]) {
        [_delegate selectedCell:_optionStatusArray applyModel:_applyModel locatoinData:status forSelectedCell:self];
    }
}

@end

#pragma mark - 图标
@implementation selectedSubView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI:frame];
    }
    return self;
}

- (void)setUpUI:(CGRect)frame
{
    CGFloat subViewWidth = CGRectGetWidth(self.frame);
    CGFloat subViewHeight = CGRectGetHeight(self.frame);

    _iconButton = [[UIButton alloc] initWithFrame:(CGRect){{subViewWidth*0.5-25, 10}, {icon_width_equ_height, icon_width_equ_height}}];
    [self addSubview:_iconButton];
    
    _nameLabel = [[UILabel alloc] initWithFrame:(CGRect){{subViewWidth*0.5, 0}, {subViewWidth*0.5, subViewHeight}}];
    _nameLabel.font = [UIFont systemFontOfSize:15];
    
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:_nameLabel];
}

@end
