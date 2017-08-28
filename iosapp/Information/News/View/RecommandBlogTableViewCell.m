//
//  RecommandBlogTableViewCell.m
//  iosapp
//
//  Created by 巴拉提 on 16/5/30.
//  Copyright © 2016年 oschina. All rights reserved.
//

#import "RecommandBlogTableViewCell.h"
#import "OSCAbout.h"

@implementation RecommandBlogTableViewCell{
    __weak IBOutlet UIView *_colorLine;
}

-(void)setHiddenLine:(BOOL)hiddenLine{
    _hiddenLine = hiddenLine;
    _colorLine.hidden = hiddenLine;
}

- (void)setAbouts:(OSCAbout *)abouts
{
    _titleLabel.text = abouts.title;
    _commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)abouts.statistics.comment];
}

- (void)setNewsRelatedSoftWareStr:(NSString *)newsRelatedSoftWareStr {
    _titleLabel.text = newsRelatedSoftWareStr;
}
@end
