//
//  HJMotion.m
//  Location_For_AR
//
//  Created by Josie on 2017/7/9.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "HJMotion.h"

@implementation HJMotion








-(void)startMotion
{
    //                      加速度传感器是否激活                              加速度传感器是否可用
    if (![self.motionManager isDeviceMotionActive] && [self.motionManager isDeviceMotionAvailable]) {
        //设置CMMotionManager的数据更新频率为0.01秒
        self.motionManager.deviceMotionUpdateInterval = 0.01;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        //push方式开始刷新运动信息
        [self.motionManager startDeviceMotionUpdatesToQueue:queue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            
            double gravityX = motion.gravity.x;  // gravity：该属性返回地球重力对该设备在X、Y、Z轴上施加的重力加速度
            double gravityY = motion.gravity.y;
            double gravityZ = motion.gravity.z;
            //            NSLog(@"x = %f, y = %f, z = %f ", gravityX, gravityY, gravityZ);
            
            //            double yaw = motion.attitude.yaw;     // 手机顶部转过的夹角。当手机绕着Z轴旋转时
            //            double pitch = motion.attitude.pitch; // 手机顶部或尾部翘起的角度. 绕着X轴倾斜时，该角度值发生变化
            //            double roll = motion.attitude.roll;   // 手机左侧或右侧翘起的角度。当手机绕着Y轴倾斜时
            //            NSLog(@"yaw = %f,  pitch = %f,   roll = %f", [self radiansToDegrees:yaw], [self radiansToDegrees:pitch], [self radiansToDegrees:roll]);
            
            if (gravityY<=0 && gravityY>=-1) // 做上下的动画的夹角
            {
                // XYZ轴以设备的外框架为准
                //获取手机的倾斜角度(zTheta是手机与水平面(Y轴)的夹角,向下为负， xyTheta是手机绕自身旋转的角度)：
                double y = gravityZ;  // 此x y 非彼x y，仅为了好理解atan2这个函数
                double x = sqrtf( gravityX*gravityX + gravityY*gravityY ); // sqrtf(float x);
                // atan2(double y,double x) 返回的是原点至点(x,y)的方位角，即与 x 轴的夹角
                double zTheta = atan2(y,x)/M_PI*180.0;
                //                NSLog(@"zTheta == %f",zTheta); // degree
//                _cameraAngle = zTheta;
            }
            //
            //            double xyTheta = atan2(gravityX, gravityY) / M_PI * 180.0;
            //            NSLog(@"手机绕自身旋转的角度为 --- %.4f", xyTheta);
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // 在主队列更新UI
//                [self updataPoint];
                
            }];
            
        }];
        
    }
}










-(void)stopMotion
{
    [self.motionManager stopDeviceMotionUpdates];
}




-(CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}
@end
