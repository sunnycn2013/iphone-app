//
//  EditingBar.m
//  iosapp
//
//  Created by chenhaoxiang on 11/4/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EditingBar.h"
#import "GrowingTextView.h"
#import "Utils.h"
#import "Config.h"
#import "AppDelegate.h"

#import <Masonry.h>

@interface EditingBar ()

@end

@implementation EditingBar

- (id)initWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
        [self addBorder];
        [self setLayoutWithModeSwitchButton:hasAModeSwitchButton];
    }
    
    return self;
}

- (instancetype)initWithPhotoButton:(BOOL)hasPhotoButton
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
        [self addBorder];
        [self setLayoutWithPhotoButton:hasPhotoButton];
    }
    
    return self;
}


- (void)setLayoutWithModeSwitchButton:(BOOL)hasAModeSwitchButton
{
    _modeSwitchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_modeSwitchButton setImage:[UIImage imageNamed:@"toolbar-barSwitch"] forState:UIControlStateNormal];
    
    _inputViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_normal"] forState:UIControlStateNormal];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_pressed"] forState:UIControlStateHighlighted];
    
    _editView = [[GrowingTextView alloc] initWithPlaceholder:@"说点什么"];
    _editView.returnKeyType = UIReturnKeySend;
    [_editView setCornerRadius:4.0];
    
    self.barTintColor = [UIColor whiteColor];
    [_editView setBorderWidth:0.5f andColor:[UIColor colorWithHex:0xc7c7cc]];
    _modeSwitchButton.backgroundColor = [UIColor clearColor];
    _inputViewButton.backgroundColor = [UIColor clearColor];
    _editView.backgroundColor = [UIColor clearColor];    //0xF5FAFA
    
    _editView.textColor = [UIColor blackColor];
    
    [self addSubview:_editView];
    [self addSubview:_modeSwitchButton];
    [self addSubview:_inputViewButton];
    
    if (hasAModeSwitchButton) {
        [_modeSwitchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(22));
            make.height.equalTo(self);
            make.left.equalTo(self).offset(5);
            make.top.equalTo(self);
        }];
        
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.left.equalTo(_modeSwitchButton.mas_right).offset(5);
            make.right.equalTo(_inputViewButton.mas_left).offset(-8);
        }];
        
        [_inputViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(25));
            make.top.equalTo(self);
            make.height.equalTo(self);
            make.right.equalTo(self).offset(-10);
        }];
    } else {
        [_modeSwitchButton removeFromSuperview];
        
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
            make.left.equalTo(self).offset(5);
            make.right.equalTo(_inputViewButton.mas_left).offset(-8);
        }];
        
        [_inputViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.height.equalTo(self);
            make.right.equalTo(self).offset(-10);
        }];
    }
}

- (void)setLayoutWithPhotoButton:(BOOL)hasPhotoButton
{
    _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_photoButton setImage:[UIImage imageNamed:@"toolbar-image"] forState:UIControlStateNormal];
    
    _inputViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_normal"] forState:UIControlStateNormal];
    [_inputViewButton setImage:[UIImage imageNamed:@"btn_emoji_pressed"] forState:UIControlStateHighlighted];
    
    _editView = [[GrowingTextView alloc] initWithPlaceholder:@"说点什么"];
    _editView.returnKeyType = UIReturnKeySend;
    _editView.layer.borderWidth = 1;
    _editView.layer.borderColor = [UIColor colorWithHex:0xc7c7cc].CGColor;
    [_editView setCornerRadius:4.0];
    
    _editView.textColor = [UIColor blackColor];
    
    [self addSubview:_editView];
    [self addSubview:_photoButton];
    [self addSubview:_inputViewButton];
    
    if (hasPhotoButton) {
        
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.right.equalTo(_photoButton.mas_left).offset(-8);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];
        
        [_photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(20));
            make.top.equalTo(self);
            make.bottom.equalTo(self);
        }];
        
        [_inputViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(25));
            make.left.equalTo(_photoButton.mas_right).offset(8);
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self).offset(-10);
        }];
    } else {
        [_photoButton removeFromSuperview];
        
        [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.right.equalTo(_inputViewButton.mas_left).offset(-8);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];
        
        [_inputViewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(25));
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self).offset(-10);
        }];
    }
}


- (void)addBorder
{
    UIView *upperBorder = [UIView new];
    upperBorder.backgroundColor = [UIColor colorWithHex:0xc7c7cc];
//    [UIColor borderColor];
    upperBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:upperBorder];
    
    UIView *bottomBorder = [UIView new];
    bottomBorder.backgroundColor = [UIColor colorWithHex:0xc7c7cc];
//    [UIColor borderColor];
    bottomBorder.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:bottomBorder];
    
    [upperBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(0.5));
    }];
    
    [bottomBorder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(@(0.5));
    }];
}




@end
