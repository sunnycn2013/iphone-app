//
//  EmojiPanelVC.m
//  iosapp
//
//  Created by ChanAetern on 12/21/14.
//  Copyright (c) 2014 oschina. All rights reserved.
//

#import "EmojiPanelVC.h"
#import "Utils.h"

#import <objc/runtime.h>
#import <Masonry.h>

@interface EmojiPanelVC () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *emojiCollectionView;

@end

@implementation EmojiPanelVC

- (instancetype)initWithPageIndex:(int)pageIndex
{
    if (self = [super init]) {
        _pageIndex = pageIndex;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor]; //[UIColor themeColor]
    
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    flowLayout.minimumInteritemSpacing = (screenWidth - 40 - 30 * 7) / 7;
    flowLayout.minimumLineSpacing = 25;
    flowLayout.sectionInset = UIEdgeInsetsMake(15, 0, 5, 0);
    
    _emojiCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [_emojiCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"EmojiCell"];
    _emojiCollectionView.backgroundColor = [UIColor whiteColor]; //[UIColor themeColor]
    _emojiCollectionView.scrollEnabled = NO;
    _emojiCollectionView.dataSource = self;
    _emojiCollectionView.delegate = self;
    _emojiCollectionView.bounces = NO;
    [self.view addSubview:_emojiCollectionView];
    
    [_emojiCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(8);
        make.bottom.equalTo(self.view);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger left = 123 - _pageIndex * 20;
    return left >= 20 ? 3 : (left + 7) / 7;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger left = 123 - _pageIndex * 20 - section * 7;
    return left >= 7? 7 : left + 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(30, 30);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EmojiCell" forIndexPath:indexPath];
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;
    
    if (section == [self numberOfSectionsInCollectionView:collectionView] - 1 &&
            row == [self collectionView:collectionView numberOfItemsInSection:section] - 1) {
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"delete"]]];
    } else {
        NSInteger emojiNum = _pageIndex * 20 + section * 7 + row + 1;
        NSString *emojiImageName;
        if (emojiNum >= 106) {
            emojiImageName = [Utils.emojiDict[@(emojiNum).stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        } else {
            emojiImageName = [NSString stringWithFormat:@"%03ld", (long)emojiNum];
        }
        [cell setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:emojiImageName]]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;
    
    if (section == [self numberOfSectionsInCollectionView:collectionView] - 1 &&
        row == [self collectionView:collectionView numberOfItemsInSection:section] - 1) {
        _deleteEmoji();
    } else {
        NSInteger emojiNum = _pageIndex * 20 + section * 7 + row + 1;
        NSString *emojiImageName, *emojiStr;
        if (emojiNum >= 106) {
            emojiStr = Utils.emojiDict[@(emojiNum).stringValue];
            emojiImageName = [emojiStr stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        } else {
            emojiStr = [NSString stringWithFormat:@"[%ld]", emojiNum - 1];
            emojiImageName = [NSString stringWithFormat:@"%03ld", emojiNum];
        }
        
        NSTextAttachment *textAttachment = [NSTextAttachment new];
        textAttachment.image = [UIImage imageNamed:emojiImageName];
        [textAttachment adjustY:-3];
        
        objc_setAssociatedObject(textAttachment, @"emoji", emojiStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        _didSelectEmoji(textAttachment);
    }
}



@end