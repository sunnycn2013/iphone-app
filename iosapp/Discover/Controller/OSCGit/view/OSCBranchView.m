//
//  OSCBranchView.m
//  iosapp
//
//  Created by Graphic-one on 17/3/22.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBranchView.h"

@interface OSCBranchView () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* dataSource;
@end

@implementation OSCBranchView
- (void)awakeFromNib{
    [super awakeFromNib];
    
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
}

+ (instancetype)BranchViewWithDataSource:(NSArray* )dataSources{
    OSCBranchView* branchView = [[UINib nibWithNibName:@"OSCBranchView" bundle:nil] instantiateWithOwner:nil options:nil].lastObject;
    branchView.dataSource = dataSources;
    return branchView;
}

#pragma mark -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
- (UITableViewCell* )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"OSCBranchsCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OSCBranchsCell"];
    }
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([_delegate respondsToSelector:@selector(branchView:didSelectedIndex:)]) {
        [_delegate branchView:self didSelectedIndex:indexPath.row];
    }
}

@end
