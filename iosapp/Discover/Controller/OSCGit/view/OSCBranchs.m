//
//  OSCBranchs.m
//  iosapp
//
//  Created by Graphic-one on 17/3/21.
//  Copyright © 2017年 oschina. All rights reserved.
//

#import "OSCBranchs.h"

@interface OSCBranchs () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* dataSource;
@end

@implementation OSCBranchs

- (void)awakeFromNib{
    [super awakeFromNib];
    
    _tableView.tableFooterView = [UIView new];
    _tableView.dataSource = self;
    _tableView.delegate = self;
}

+ (instancetype)BranchsWithDataSource:(NSArray* )dataSources{
    OSCBranchs* branchView = [[[NSBundle mainBundle] loadNibNamed:@"OSCBranchs" owner:nil options:nil] lastObject];
//    OSCBranchs* branchView = [[UINib nibWithNibName:@"OSCBranchs" bundle:nil] instantiateWithOwner:nil options:nil].lastObject;
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
    if ([_delegate respondsToSelector:@selector(branchs:didSelectedIndexPath:)]) {
        [_delegate branchs:self didSelectedIndexPath:indexPath];
    }
}

@end
