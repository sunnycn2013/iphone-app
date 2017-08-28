//
//  selectedCell.h
//  iosapp
//
//  Created by 李萍 on 2016/12/8.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "enumList.h"

@class selectedSubView, OSCActivityApplyModel, selectedCell;

@protocol selectedCellDelegate <NSObject>

- (void)selectedCell:(NSArray *)optionStutas
          applyModel:(OSCActivityApplyModel *)model
        locatoinData:(NSArray *)statusArray
     forSelectedCell:(selectedCell *)cell;

@end

@interface selectedCell : UITableViewCell

@property (nonatomic, strong) NSMutableArray *boxButtons; //checkbox
@property (nonatomic, strong) NSMutableArray *radioButtons; //redio
@property (nonatomic, copy) NSString *optionStatusString;
@property (nonatomic, weak) id <selectedCellDelegate> delegate;
//初始化cell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDictionary:(OSCActivityApplyModel *)model locatoinData:(NSArray *)statusArray;
+ (NSMutableArray *)dicStringToArray:(NSString *)string;

@end

// 图标
@interface selectedSubView : UIButton

@property (nonatomic, strong) UIButton *iconButton;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *themeLabel;


@end
