//
//  BigImageView.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/27.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "BigImageView.h"

@implementation BigImageView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.image = [UIImage imageNamed:@"abc"];
        self.alpha = 0.6;
    }
    return self;
}





/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
