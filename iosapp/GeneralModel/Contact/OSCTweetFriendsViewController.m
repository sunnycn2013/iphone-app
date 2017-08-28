//
//  OSCTweetFriendsViewController.m
//  iosapp
//
//  Created by 李萍 on 2016/12/29.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "OSCTweetFriendsViewController.h"
#import "OSCTweetFriendCell.h"
#import "TweetFriendCell.h"
#import "OSCNetWorkSearchCell.h"
#import "OSCNetWorkContactController.h"

#import "OSCListItem.h"
#import "Utils.h"
#import "NSString+Comment.h"
#import "NSObject+Comment.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width

static NSString *kTweetFriendCellID = @"TweetFriendCell";
static NSString *kTweetSelFriendCellID = @"OSCTweetFriendCell";

@interface OSCTweetFriendsViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, OSCTweetFriendIDelegate,TweetFriendCellDelegate,OSCNetWorkContactControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL searchCanlceBool;
@property (nonatomic, copy) NSString *searcchString;
@property (nonatomic, strong) NSMutableArray<OSCAuthor* > *searchAttents; //搜索数组

@property (nonatomic, strong) NSMutableArray<OSCAuthor* > *selectedFriends; //选择@的好友，不能超过10
@property (nonatomic, strong) NSMutableArray<OSCAuthor* > *newsContacts; //最近联系人
@property (nonatomic, strong) NSMutableArray<OSCAuthor* > *noSectionAttentions; //关注人数组未分组前
@property (nonatomic, strong) NSMutableArray *attentions; //关注人数组
@property (nonatomic, strong) NSMutableArray<NSString* > *attentionTitles; //关注人区域标题字母

@end

@implementation OSCTweetFriendsViewController


- (instancetype)init
{
    self = [super init];
    if (self) {
        _searcchString = @"";
        _searchAttents = [NSMutableArray array];
        _noSectionAttentions = [NSMutableArray array];
        _selectedFriends = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择好友";
    [self LayoutUI];
    if ([NSObject recentlyContacter]) {
        _newsContacts = [NSObject recentlyContacter].mutableCopy;
    }
    [self manageArrays]; //获取关注人列表数据
    [self refresh_done];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    NSLog(@"dealloc");
}

- (void)LayoutUI
{
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[OSCTweetFriendCell class] forCellReuseIdentifier:kTweetSelFriendCellID];
    [self.tableView registerClass:[TweetFriendCell class] forCellReuseIdentifier:kTweetFriendCellID];
    [self.tableView registerNib:[UINib nibWithNibName:@"OSCNetWorkSearchCell" bundle:nil] forCellReuseIdentifier:OSCNetWorkSearchCellReuseIdentifier];
    
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    _searchController.obscuresBackgroundDuringPresentation = NO;
    
    
    UIView *customTableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 44.0)];
    UINavigationBar *dummyNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0.0, 0.0, kScreenWidth, 44.0)];
    [customTableHeaderView addSubview:dummyNavigationBar];
    [customTableHeaderView addSubview:_searchController.searchBar];
    
    _searchController.searchBar.delegate = self;
    [_searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = customTableHeaderView;
    
    _searchController.searchBar.backgroundImage = [UIImage new];
    _searchController.searchBar.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    _searchController.searchBar.barTintColor = [UIColor colorWithHex:0xf6f6f6];
    
    UITextField *searchField = [_searchController.searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.backgroundColor = [UIColor whiteColor];
        searchField.layer.cornerRadius = 2;
        searchField.layer.borderWidth = 1;
        searchField.layer.borderColor = [UIColor colorWithHex:0xE1E1E1].CGColor;
    }
}

#pragma mark - 关注人列表
- (void)manageArrays
{
    if ([NSObject attentionContacter]) {
        self.noSectionAttentions = [NSObject attentionContacter].mutableCopy;
    } else {
        return;
    }
    
    UILocalizedIndexedCollation * indexCollation = [UILocalizedIndexedCollation currentCollation];
    
    self.attentionTitles = indexCollation.sectionTitles.mutableCopy;
    self.attentions = @[].mutableCopy;
    [indexCollation.sectionTitles enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [self.attentions addObject:@[].mutableCopy];
        
    }];
    [self.noSectionAttentions enumerateObjectsUsingBlock:^(OSCAuthor *object, NSUInteger idx, BOOL *stop) {
        NSString *pinyin = [object.name pinyin];
        NSArray *pinyinArray = [pinyin componentsSeparatedByString:@" "]; //取首字母
        NSMutableString *pinyinStr = @"".mutableCopy;
        for (NSString *obj in pinyinArray) {
            [pinyinStr appendString:[obj substringToIndex:1]];
        }
        NSInteger section = [indexCollation sectionForObject:[pinyin stringByReplacingOccurrencesOfString:@" " withString:@""]
                                     collationStringSelector:@selector(uppercaseString)];
        NSMutableArray *sectionArray = [self.attentions objectAtIndex:section];
        [sectionArray addObject:object];
    }];
    
    for (NSInteger i = 0; i < [self.attentions count]; i++) {
        if ([self.attentions[i] count] == 0) {
            [self.attentions removeObjectAtIndex:i];
            [self.attentionTitles removeObjectAtIndex:i];
            i --;
        }
    }
}

- (void)refresh_done {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"确定(%ld/10)",(unsigned long)[self.selectedFriends count]]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(click_done)];
}

- (void)click_done {
    if ([self.selectedFriends count]) {
        NSMutableString *result = @"".mutableCopy;
        [self.selectedFriends enumerateObjectsUsingBlock:^(OSCAuthor *obj, NSUInteger idx, BOOL *stop) {
            [result appendFormat:@"@%@ ",obj.name];
            [NSObject updateToRecentlyContacterList:obj];
        }];
        self.selectDone(result.copy);
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger sectionNum = 1;
    if (self.searchController.active) { //搜索
        if (self.searcchString.length) {
            sectionNum += 1;
        }
        if (self.searchAttents.count) {
            sectionNum += 1;
        }
    } else { //正常
        if (self.newsContacts.count) {
            sectionNum += 1;
        }
        if (self.attentions.count) {
            sectionNum += self.attentions.count;
        }
    }
    
    return sectionNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        switch (section) {
            case 0:
            {
                return self.searcchString.length ? 1 : 0;;
                break;
            }
            case 1:
            {
                if (self.searchAttents.count) {
                    return self.searchAttents.count;
                } else {
                    return 1;
                }
                break;
            }
            default:
            {
                return 1;
                break;
            }
        }
    } else {
        switch (section) {
            case 0:
            {
                return 1;
                break;
            }
            case 1:
            {
                if (self.newsContacts.count) {
                    return self.newsContacts.count;
                }else {
                    return [self.attentions[section-1] count] ? [self.attentions[section-1] count] : 0;
                }
                break;
            }
            default:
                if (self.newsContacts.count) {
                    
                    return [self.attentions[section-2] count] ? [self.attentions[section-2] count] : 0;
                } else {
                    return [self.attentions[section-1] count] ? [self.attentions[section-1] count] : 0;
                }
                
                break;
        }

    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        if (indexPath.section == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sideCell"];
            }
            
            cell.textLabel.text = [NSString stringWithFormat:@"@%@", self.searcchString];
            
            return cell;
        } else if (indexPath.section == 1){
            if (self.searchAttents.count > 0) {
                OSCNetWorkSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:OSCNetWorkSearchCellReuseIdentifier forIndexPath:indexPath];
                cell.backgroundColor = [UIColor cellsColor];
                
                OSCAuthor *author = self.searchAttents[indexPath.row];
                cell.author = author;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return cell;
            } else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideCell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sideCell"];
                }
                
                cell.textLabel.text = @"网络搜索结果>>>";
                
                return cell;
            }
            
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideCell"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sideCell"];
            }
            
            cell.textLabel.text = @"网络搜索结果>>>";
            
            
            return cell;
        }
    } else {
        if (indexPath.section == 0) {
            if (self.selectedFriends.count) {
                OSCTweetFriendCell *selFriendCell = [OSCTweetFriendCell returnReuseTextTweetCellWithTableView:tableView identifier:kTweetSelFriendCellID];
                
                selFriendCell.selectedFriends = self.selectedFriends;
                selFriendCell.delegate = self;
                selFriendCell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                return selFriendCell;
            } else {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sideCell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"sideCell"];
                }
                
                cell.textLabel.text = @" ";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.textLabel.textAlignment = NSTextAlignmentLeft;
                cell.textLabel.font = [UIFont systemFontOfSize:15];
                cell.textLabel.textColor = [UIColor newSecondTextColor];
                
                return cell;
            }
            
        } else {
            OSCAuthor *author = nil;
            switch (indexPath.section) {
                case 0:
                {
                    break;
                }
                case 1:
                {
                    if (_newsContacts.count) {
                        author = _newsContacts[indexPath.row];
                    } else {
                        author = self.attentions[indexPath.section-1][indexPath.row];
                    }
                    
                    break;
                }
                default:
                {
                    if (_newsContacts.count) {
                        author = self.attentions[indexPath.section-2][indexPath.row];
                    } else {
                        author = self.attentions[indexPath.section-1][indexPath.row];
                    }
                }
                    
                    break;
            }
            
            TweetFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:kTweetFriendCellID forIndexPath:indexPath];
            cell.backgroundColor = [UIColor cellsColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            author.selected = NO;
            for (OSCAuthor* selectedAuthor in _selectedFriends) {
                if (selectedAuthor.id == author.id) {
                    author.selected = YES;
                    break;
                }
            }
            cell.author = author;
            cell.delegate = self;
            cell.selectedButton.tag = indexPath.row;
            
            return cell;
        }
        
        return [UITableViewCell new];
    }
    
    return [UITableViewCell new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.searchController.active ? 40 : 50;
    }
    return 52;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 24;
}

- (NSString *)tableViewTitleForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    
    if (self.searchController.active) {
        switch (section) {
            case 0:
            {
                title = @"";
                break;
            }
            case 1:
            {
                if (self.searchAttents.count) {
                    title = @"本地搜索结果";
                } else {
                    title = @"网络搜索结果";
                }
                break;
            }
            default:
            {
                title = @"网络搜索结果";
                break;
            }
        }
    } else {
        switch (section) {
            case 0:
                title = @"";
                break;
            case 1:
            {
                if (self.newsContacts.count) {
                    title = @"最近联系人";
                } else {
                    title = self.attentionTitles[section-1];
                }
                
                break;
            }
            default:
            {
                if (self.newsContacts.count) {
                    title = self.attentionTitles[section-2];
                } else {
                    title = self.attentionTitles[section-1];
                }
                
                break;
            }
        }
    }
    
    return title;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){{0, 0}, {kScreenWidth, 24}}];
    headerView.backgroundColor = [UIColor colorWithHex:0xf6f6f6];
    
    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){{16, 4}, {kScreenWidth, 16}}];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithHex:0x6a6a6a];
    label.text = [self tableViewTitleForHeaderInSection:section];
    [headerView addSubview:label];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.searchController.active) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
        } else {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 20, 0, 0)];
        }
    } else {
        if (self.searchController.active) {
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
            if (indexPath.section == 1) {
                if (self.searchAttents.count) {} else {
                    [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 0)];
                }
                
            } else {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 16, 0, 0)];
            }
        } else {
            if (indexPath.section != 0) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 100, 0, 0)];
            }
        }
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (self.searchController.active) {
        return nil;
    }
    return self.attentionTitles;
}
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger indexSectionNum = 0;
    if (self.newsContacts.count) {
        indexSectionNum  = index + 2;
    } else {
        indexSectionNum  = index + 1;
    }
    // 获取所点目录对应的indexPath值
    NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexSectionNum];
    // 让table滚动到对应的indexPath位置
    [tableView scrollToRowAtIndexPath:selectIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
    return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.searchController.active) {
        if (self.searchController.isActive) { self.searchController.active = NO; }
        NSString* searchStr = self.searcchString;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section == 0) {
            NSLog(@"输入文字 %@", [NSString stringWithFormat:@"@%@", self.searcchString]);
            OSCAuthor* author = [OSCAuthor new];
            author.name = self.searcchString;
            author.id = self.searcchString.hash;
            author.portrait = [[NSBundle mainBundle] pathForResource:@"default-portrait" ofType:nil];
            [self effectivelyAddSelectedFriend:author];
            [self.tableView reloadData];
            
        } else if (indexPath.section == 1){
            if (self.searchAttents.count > 0) {
                OSCAuthor *author = self.searchAttents[indexPath.row];
                
                NSLog(@"选中的好友名 %@", author.name);
                
                if ([self.selectedFriends containsObject:author]) {
                    [self.selectedFriends removeObject:author];
                } else {
                    [self effectivelyAddSelectedFriend:author];
                }
                [self.tableView reloadData];
            } else {
                OSCNetWorkContactController *vc = [[OSCNetWorkContactController alloc] initWithSearchKey:searchStr];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
            }
        } else {
            OSCNetWorkContactController *vc = [[OSCNetWorkContactController alloc] initWithSearchKey:searchStr];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    [self refresh_done];
}



#pragma mark - UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *filterString = searchController.searchBar.text;
    if (filterString.length != 0) {
        _searcchString = filterString;
        if (self.searchAttents!= nil) {
            [self.searchAttents removeAllObjects];
        }
        
        if (filterString.length) {
            //筛选最近联系人 筛选关注人列表
            [self filterdeAttentsForLocAttent:filterString]; //
        }
    }
    
    //搜索数组列表
    [self.tableView reloadData];
}

- (void)filterdeAttentsForLocAttent:(NSString *)filterStr
{
    if (self.newsContacts.count) {
        [self.newsContacts enumerateObjectsUsingBlock:^(OSCAuthor *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name rangeOfString:filterStr].location != NSNotFound) {
                [self.searchAttents addObject:obj];
            }
        }];
    }
    
    NSMutableArray *mutableArrayID = [NSMutableArray new];
    [self.searchAttents enumerateObjectsUsingBlock:^(OSCAuthor *author, NSUInteger idx, BOOL * _Nonnull stop) {
        [mutableArrayID addObject:@(author.id)];
    }];
    
    
    if (self.noSectionAttentions.count) {
        [self.noSectionAttentions enumerateObjectsUsingBlock:^(OSCAuthor *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj.name rangeOfString:filterStr].location != NSNotFound) {//遍历判断当前obj是否存在搜索的字符
                if (![mutableArrayID containsObject:@(obj.id)]) {//遍历判断搜索数组是否存在当前obj
                    [self.searchAttents addObject:obj];
                }
            }
        }];
    }
    //搜索数组列表
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchCanlceBool = NO;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [UIApplication sharedApplication].statusBarStyle = self.searchCanlceBool ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchCanlceBool = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

#pragma mark - OSCTweetFriendIDelegate
- (void)clickImageAction:(NSInteger)imageRow
{
    [self.selectedFriends removeObjectAtIndex:imageRow];
    
    if (_selectedFriends.count) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
        [self refresh_done];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
    } else {
        [self refresh_done];
    }
    [self.tableView reloadData];
}

#pragma mark - OSCNetWorkContactControllerDelegate
- (void)netWorkContactController:(OSCNetWorkContactController *)netWorkContactController
                    selectedUser:(nonnull OSCAuthor *)selectedAuthor
{
    [self.navigationController popViewControllerAnimated:YES];
    [self effectivelyAddSelectedFriend:selectedAuthor];
    [self refresh_done];
    [self.tableView reloadData];
}

#pragma mark - TweetFriendCellDelegate
- (void)clickedToSelectedAuthor:(TweetFriendCell *)cell authorInfo:(OSCAuthor *)author
{
    if (self.selectedFriends.count - [self.selectedFriends containsObject:author] >= 10) {
        [self showTheTipWindow];
        return;
    }
    
    BOOL isSelected = NO;
    for (OSCAuthor* selectedAuthor in self.selectedFriends) {
        if ([selectedAuthor isEqual:author]) {
            isSelected = YES;
            author = selectedAuthor;
            break;
        }
    }
    
    if (isSelected) {
        [self.selectedFriends removeObject:author];
    }else{
        [self.selectedFriends addObject:author];
    }

    [self refresh_done];
 
    [self.tableView reloadData];
}

- (void)effectivelyAddSelectedFriend:(OSCAuthor* )author{
    if (self.selectedFriends.count >= 10) {
        [self showTheTipWindow];
    }else{
        [self.selectedFriends addObject:author];
    }
}

- (void)showTheTipWindow{
    UIAlertController *alertCtl = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您最多可以一次选择10个好友" preferredStyle:UIAlertControllerStyleAlert];
    [alertCtl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        return ;
    }]];
    
    [self presentViewController:alertCtl animated:YES completion:nil];
}


@end
