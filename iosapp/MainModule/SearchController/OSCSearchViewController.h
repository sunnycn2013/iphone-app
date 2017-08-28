//
//  OSCSearchViewController.h
//  iosapp
//
//  Created by 王恒 on 16/10/18.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSCSearchViewController : UIViewController

@end




@interface  SearchTitleBar : UIView

@property(nonatomic,copy)void(^btnClick)(NSInteger index);

-(instancetype)initWithFrame:(CGRect)frame WithTitles:(NSArray *)titles;

-(void)selectBtn:(UIButton *)btn;

@end


@protocol KeyWordDelegate <NSObject>

- (void)didSelectRowWithKeyWord:(NSString *)keyWord;

- (void)tableViewDidScroll;

@end

@interface KeyWordView : UITableView

@property (nonatomic,assign) id<KeyWordDelegate> keyWordDelegate;

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

- (void)reloadArray;

@end
