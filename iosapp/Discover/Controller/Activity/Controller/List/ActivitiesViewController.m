//
//  ActivitiesViewController.m
//  iosapp
//
//  Created by chenhaoxiang on 1/25/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import "ActivitiesViewController.h"
#import "OSCActivity.h"
#import "ActivityCell.h"
//#import "OSCActivityTableViewCell.h"//新活动列表cell
#import "ScanViewController.h"
#import "ActivityDetailViewController.h"
#import "OSCEventSignInViewController.h"//test

#import <SDWebImage/UIImageView+WebCache.h>

static NSString * const kActivtyCellID = @"ActivityCell";
//static NSString * const activityReuseIdentifier = @"OSCActivityTableViewCell";

@interface ActivitiesViewController ()

@property NSDateFormatter *formatter;

@end

@implementation ActivitiesViewController


- (instancetype)initWithUID:(int64_t)userID
{
    self = [super init];
    
    if (self) {
        self.generateURL = ^NSString * (NSUInteger page) {
            return [NSString stringWithFormat:@"%@%@?uid=%lld&pageIndex=%lu&%@", OSCAPI_PREFIX, OSCAPI_EVENT_LIST, userID, (unsigned long)page, OSCAPI_SUFFIX];
        };
        
        self.objClass = [OSCActivity class];
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    }
    
    return self;
}


- (NSArray *)parseXML:(ONOXMLDocument *)xml
{
    return [[xml.rootElement firstChildWithTag:@"events"] childrenWithTag:@"event"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"我的活动";
    [self.tableView registerClass:[ActivityCell class] forCellReuseIdentifier:kActivtyCellID];
//    [self.tableView registerNib:[UINib nibWithNibName:@"OSCActivityTableViewCell" bundle:nil] forCellReuseIdentifier:activityReuseIdentifier];
//    self.tableView.estimatedRowHeight = 132;
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_discover_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(scanAction:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    OSCActivityTableViewCell* cell = [OSCActivityTableViewCell returnReuseCellFormTableView:tableView indexPath:indexPath identifier:activityReuseIdentifier];
    
    cell.activity = self.objects[indexPath.row];
    
    cell.contentView.backgroundColor = [UIColor newCellColor];
    cell.backgroundColor = [UIColor themeColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor selectCellSColor];
    
    return cell;
     */
    
    ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:kActivtyCellID forIndexPath:indexPath];
    OSCActivity *activity = self.objects[indexPath.row];
    cell.titleLabel.text       = activity.title;
    cell.titleLabel.textColor = [UIColor titleColor];
    cell.descriptionLabel.text = [NSString stringWithFormat:@"时间：%@\n地点：%@", [self.formatter stringFromDate:activity.startTime], activity.location];
    [cell.posterView sd_setImageWithURL:activity.coverURL placeholderImage:nil];
    
    if ((activity.status == ActivityStatusEnd || activity.status == ActivityStatusHaveInHand || activity.status == ActivityStatusClose) && activity.applyStatus == ApplyStatusAttended) {
        cell.tabImageView.hidden = NO;
        [cell.tabImageView setImage:[UIImage imageNamed:@"icon_event_status_attend"]];
    } else if ((activity.status == ActivityStatusHaveInHand || activity.status == ActivityStatusClose)  && activity.applyStatus == ApplyStatusDetermined) {
        cell.tabImageView.hidden = NO;
        [cell.tabImageView setImage:[UIImage imageNamed:@"icon_event_status_checked"]];
    } else if (activity.status == ActivityStatusEnd && activity.applyStatus == ApplyStatusDetermined) {
        cell.tabImageView.hidden = NO;
        [cell.tabImageView setImage:[UIImage imageNamed:@"icon_event_status_over"]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OSCActivity *activity = self.objects[indexPath.row];
    
    self.label.text = activity.title;
    self.label.font = [UIFont boldSystemFontOfSize:14];
    CGFloat height = [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 84, MAXFLOAT)].height;
    
    self.label.text = [NSString stringWithFormat:@"时间：%@\n地点：%@", [self.formatter stringFromDate:activity.startTime], activity.location];
    self.label.font = [UIFont systemFontOfSize:13];
    height += [self.label sizeThatFits:CGSizeMake(tableView.frame.size.width - 84, MAXFLOAT)].height;
    
    return height + 26;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.objects.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OSCActivity *activity = self.objects[indexPath.row];
    
    //新活动详情页面
    ActivityDetailViewController *activityDetailCtl = [[ActivityDetailViewController alloc] initWithActivityID:activity.activityID];
    activityDetailCtl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityDetailCtl animated:YES];
}

#pragma mark - scanAction

- (void)scanAction:(UIButton *)button
{
    ScanViewController *scanVC = [ScanViewController new];
    UINavigationController *scanNav = [[UINavigationController alloc] initWithRootViewController:scanVC];
    [self.navigationController presentViewController:scanNav animated:NO completion:nil];
    
//    OSCEventSignInViewController *VC = [[OSCEventSignInViewController alloc] initWithActivityModelID:2193617];
//    [self.navigationController pushViewController:VC animated:YES];
}

@end
