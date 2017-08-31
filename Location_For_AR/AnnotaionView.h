//
//  AnnotaionView.h
//  Location_For_AR
//
//  Created by Josie on 2017/6/29.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointModel.h"
#import "PopView.h"

@interface AnnotaionView : UIView

// 兴趣点的图标
@property (nonatomic, strong) UIImageView   *pointImageView;
@property (nonatomic, strong) UIImageView   *picImageView;  // 图标之上的头像


// 显示距离
@property (nonatomic, strong) UILabel       *distanceLabel;
// 显示name
@property (nonatomic, strong) UILabel       *nameLabel;

@property (nonatomic, strong) UIButton      *clickBtn;

@property (nonatomic, strong) PopView       *popView; // 泡泡

@property (nonatomic, strong) PointModel    *model;

// 触摸收popView
-(void)dismissPopViewWhenTouchsBegan;

@end
