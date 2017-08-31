//
//  PointModel.h
//  Location_For_AR
//
//  Created by Josie on 2017/6/30.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface PointModel : NSObject

@property (nonatomic, copy)     NSString                    *name;
@property (nonatomic, copy)     NSString                    *phoneNum;

@property (nonatomic, assign)   CLLocationCoordinate2D      coor;
@property (nonatomic, assign)   double                      distance;  // - 兴趣点与用户的实际距离
@property (nonatomic, assign)   double                      degree;    // - 兴趣点与正北方向的夹角


@end
