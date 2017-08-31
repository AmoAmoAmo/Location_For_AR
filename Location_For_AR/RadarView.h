//
//  Radar.h
//  Location_For_AR
//
//  Created by Josie on 2017/6/24.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DotView.h"

@interface RadarView : UIView

// 定位后传过来的北D角度
@property (nonatomic, assign)   CLLocationDirection     trueHeading;

@property (nonatomic, strong)   UIView                  *rotationView;


@property (nonatomic, strong)   DotView                 *dotView;

@property (nonatomic, assign)   float   r; // 半径，兴趣点到圆心的距离

@property (nonatomic, assign)   float   radian;  // 夹角，与x轴？

@property (nonatomic, assign)   CGRect  recordRect;

@end
