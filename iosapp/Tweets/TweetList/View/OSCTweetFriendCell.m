//
//  OSCTweetFriendCell.m
//  iosapp
//
//  Created by 李萍 on 2016/12/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetFriendCell.h"
#import "OSCListItem.h"
#import "Utils.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define cellHeight 50

@interface OSCTweetFriendCell ()

@property (nonatomic, strong) NSArray *selFriends;

@end

@implementation OSCTweetFriendCell

+ (instancetype)returnReuseTextTweetCellWithTableView:(UITableView* )tableView
                                           identifier:(NSString* )reuseIdentifier
{
    OSCTweetFriendCell *tweetFriendCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!tweetFriendCell) {
        tweetFriendCell = [[OSCTweetFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
        [tweetFriendCell addSubViews];
    }
    return tweetFriendCell;
}

- (void)addSubViews
{
    int arrayCount = (int)self.selFriends.count;
    CGFloat contentSizeW = arrayCount * 50;
    if (contentSizeW > kScreenWidth) {
        contentSizeW = contentSizeW;
    } else {
        contentSizeW = kScreenWidth;
    }
    
    UIScrollView *scrollView = [UIScrollView new];
    scrollView.frame = (CGRect){{5, 0}, {kScreenWidth-10, cellHeight}};
    scrollView.contentSize = CGSizeMake(contentSizeW, cellHeight);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:scrollView];
    
    [self.selFriends enumerateObjectsUsingBlock:^(OSCAuthor *author, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *portraitV = [UIImageView new];
        portraitV.frame = (CGRect){{(10+36)*idx, 7}, {36, 36}};
        portraitV.backgroundColor = [UIColor yellowColor];
        portraitV.contentMode = UIViewContentModeScaleAspectFit;
        portraitV.clipsToBounds = YES;
        portraitV.layer.cornerRadius = 18;
        portraitV.userInteractionEnabled = YES;
        portraitV.tag = idx+1;
        [portraitV loadPortrait:[NSURL URLWithString:author.portrait] userName:author.name];
        
        [portraitV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPortraitAction:)]];
        [scrollView addSubview:portraitV];
    }];
}

- (void)setSelectedFriends:(NSMutableArray *)selectedFriends
{
    self.selFriends = selectedFriends.mutableCopy;
    
    [self addSubViews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - portrait action
- (void)clickPortraitAction:(UITapGestureRecognizer *)tap
{
    NSInteger tagNum = tap.view.tag - 1;
    if ([_delegate respondsToSelector:@selector(clickImageAction:)]) {
        [_delegate clickImageAction:tagNum];
    }
}

@end
