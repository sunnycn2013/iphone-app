//
//  DiscoverViewController.m
//  iosapp
//
//  Created by AeternChan on 7/16/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "DiscoverViewController.h"
#import "UIColor+Util.h"
#import "ScanViewController.h"
#import "OSCRandomCenterController.h"
#import "NewLoginViewController.h"
#import "OSCSearchViewController.h"
#import "Config.h"
#import "OSCActivityViewController.h"

#import "SwipableViewController.h"
#import "SoftwareCatalogVC.h"
#import "SoftwareListVC.h"
#import "OSCCodeSnippetViewController.h"

#import "OSCNearbyPeopleViewController.h"
#import "OSCGitRecommendController.h"

#define kUsingLocation(id) [NSString stringWithFormat:@"OSCUsingLocationKey_%ld_BOOL",id]

@interface DiscoverViewController ()<OSCNearbyPeopleViewCDelegate>

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, assign) BOOL isCompleteLoc;//临时存放信息

@end

@implementation DiscoverViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _imageView.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _isCompleteLoc = [[[NSUserDefaults standardUserDefaults] valueForKey:kUsingLocation([Config getOwnID])] boolValue];
    
    self.tableView.separatorColor = [UIColor separatorColor];
    
    _imageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIImageView *)findHairlineImageViewUnder:(UIView *)view {
    if ([view isKindOfClass:UIImageView.class] && view.bounds.size.height <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self findHairlineImageViewUnder:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 23;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [UITableViewCell new];
    cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    
    cell.backgroundColor = [UIColor cellsColor];
    cell.textLabel.textColor = [UIColor titleColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (indexPath.section) {
        case 0:
        {
			if (indexPath.row == 0) {
				cell.textLabel.text = @"码云推荐";
				cell.imageView.image = [UIImage imageNamed:@"ic_discover_git"];
            }
//            else if(indexPath.row == 1){
//                cell.textLabel.text = @"代码片段";
//                cell.imageView.image = [UIImage imageNamed:@"ic_discover_gist"];
//            }
            else {
				cell.textLabel.text = @"开源软件";
				cell.imageView.image = [UIImage imageNamed:@"ic_discover_softwares"];
			}
            break;
        }
        case 1:
		{
			if (indexPath.row == 0) {
				cell.textLabel.text = @"扫一扫";
				cell.imageView.image = [UIImage imageNamed:@"ic_discover_scan"];
			} else {
				cell.textLabel.text = @"摇一摇";
				cell.imageView.image = [UIImage imageNamed:@"ic_discover_shake"];
			}
            break;
		}
        case 2:
		{
			if (indexPath.row == 0) {
				cell.textLabel.text = @"附近的程序员";
				cell.imageView.image = [UIImage imageNamed:@"ic_discover_nearby"];
				
				if (_isCompleteLoc) {
					UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 50, CGRectGetMidY(cell.contentView.frame) - 8, 11, 16)];
					imageView.image = [UIImage imageNamed:@"ic_located"];
					[cell.contentView addSubview:imageView];
				}
			} else {
				cell.textLabel.text = @"线下活动";
				cell.imageView.image = [UIImage imageNamed:@"ic_my_event"];
			}
            break;
        }
        default: break;
    }
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
			if (indexPath.row == 0) {
				//码云推荐
				OSCGitRecommendController *gitRecommendVC = [[OSCGitRecommendController alloc] init];
				gitRecommendVC.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController:gitRecommendVC animated:YES];
            }
//            else if(indexPath.row == 1) {
//                //代码片段
//                OSCCodeSnippetViewController *codeVC = [[OSCCodeSnippetViewController alloc] init];
//                codeVC.hidesBottomBarWhenPushed = YES;
//                
//                [self.navigationController pushViewController:codeVC animated:YES];
//            }
            
            else if(indexPath.row == 1) {
				SwipableViewController *softwaresSVC = [[SwipableViewController alloc] initWithTitle:@"开源软件"
																						andSubTitles:@[@"分类", @"推荐", @"最新", @"热门", @"国产"]
																					  andControllers:@[
																									   [[SoftwareCatalogVC alloc] initWithTag:0],
																									   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeRecommended],
																									   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeNewest],
																									   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeHottest],
																									   [[SoftwareListVC alloc] initWithSoftwaresType:SoftwaresTypeCN]                            ]];
				softwaresSVC.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController:softwaresSVC animated:YES];
			}
            break;
        }
        case 1:
        {
			if (indexPath.row == 0) {
				ScanViewController *scanVC = [ScanViewController new];
				UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
				[self.navigationController presentViewController:scanNav animated:NO completion:nil];
				break;
			} else if(indexPath.row == 1) {
				if ([Config getOwnID] == 0) {
					UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
					NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
					[self presentViewController:loginVC animated:YES completion:nil];
				}else{
					[self.navigationController pushViewController:[OSCRandomCenterController new] animated:YES];
				}

			}
            break;
        }
        case 2:
		{
			if (indexPath.row == 0) {
				if ([Config getOwnID] != 0) {
					OSCNearbyPeopleViewController *nearbyPeopleViewController = [[OSCNearbyPeopleViewController alloc] init];
					nearbyPeopleViewController.delegate = self;
					nearbyPeopleViewController.hidesBottomBarWhenPushed = YES;
					[self.navigationController pushViewController:nearbyPeopleViewController animated:YES];
				}else{
					UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"NewLogin" bundle:nil];
					NewLoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"NewLoginViewController"];
					[self presentViewController:loginVC animated:YES completion:nil];
				}

			} else if(indexPath.row == 1) {
				OSCActivityViewController *activityVC = [[OSCActivityViewController alloc] init];
				activityVC.hidesBottomBarWhenPushed = YES;
				[self.navigationController pushViewController:activityVC animated:YES];
			}
		}
        default:
            break;
    }
}

#pragma mark --- OSCNearbyPeopleViewCDelegate
- (void)completeUpdateUserLocationIsUpload:(BOOL)isUpload{
    if (isUpload != _isCompleteLoc) {
        [[NSUserDefaults standardUserDefaults] setBool:isUpload forKey:kUsingLocation([Config getOwnID])];
        [[NSUserDefaults standardUserDefaults] synchronize];
        _isCompleteLoc = isUpload;
        [self.tableView reloadData];
    }
}

#pragma --mark 事件
- (IBAction)searchClick:(id)sender {
    OSCSearchViewController *searchVC = [[OSCSearchViewController alloc] init];
    UINavigationController *searchNav = [[UINavigationController alloc] initWithRootViewController:searchVC];
    [self presentViewController:searchNav animated:YES completion:^{
        
    }];
}


@end
