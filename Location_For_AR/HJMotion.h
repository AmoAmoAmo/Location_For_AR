//
//  HJMotion.h
//  Location_For_AR
//
//  Created by Josie on 2017/7/9.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface HJMotion : NSObject

@property (nonatomic, strong)   CMMotionManager     *motionManager;

- (void)startMotion;
- (void)stopMotion;


@end
