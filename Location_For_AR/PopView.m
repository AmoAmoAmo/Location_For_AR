//
//  PopView.m
//  Location_For_AR
//
//  Created by Josie on 2017/7/7.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "PopView.h"

@implementation PopView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 10;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        //允许子视图自适应
        self.autoresizesSubviews = YES;
        
        // 设置子视图适应方式
        self.nameLabel.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin   |
        UIViewAutoresizingFlexibleWidth        |
        UIViewAutoresizingFlexibleRightMargin  |
        UIViewAutoresizingFlexibleTopMargin    |
        UIViewAutoresizingFlexibleHeight       |
        UIViewAutoresizingFlexibleBottomMargin ;
        
        self.subLabel.autoresizingMask =
        UIViewAutoresizingFlexibleLeftMargin   |
        UIViewAutoresizingFlexibleWidth        |
        UIViewAutoresizingFlexibleRightMargin  |
        UIViewAutoresizingFlexibleTopMargin    |
        UIViewAutoresizingFlexibleHeight       |
        UIViewAutoresizingFlexibleBottomMargin ;
        
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.subLabel];
    }
    return self;
}





-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height / 2.0);
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _nameLabel;
}

-(UILabel *)subLabel
{
    if (!_subLabel) {
        _subLabel = [[UILabel alloc] init];
        _subLabel.frame = CGRectMake(0, CGRectGetMaxY(_nameLabel.frame), self.frame.size.width, self.frame.size.height / 2.0);
        _subLabel.font = [UIFont systemFontOfSize:11];
        _subLabel.textColor = [UIColor whiteColor];
        _subLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _subLabel;
}


@end
