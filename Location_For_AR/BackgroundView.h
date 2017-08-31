//
//  BackgroundView.h
//  Location_For_AR
//
//  Created by Josie on 2017/6/30.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointModel.h"
#import <CoreLocation/CoreLocation.h>

@interface BackgroundView : UIView

// 定位后传过来的北D角度
@property (nonatomic, assign)   CLLocationDirection     trueHeading;

- (void)buildAPointViewWithDataModel: (PointModel*)model;

@end
