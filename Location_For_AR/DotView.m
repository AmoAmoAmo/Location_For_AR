//
//  DotView.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/28.
//  Copyright © 2017年 Josie. All rights reserved.
//
//  用来 显示在雷达图上的兴趣点
//  每个点 就看做是一个画得很小的圆

#import "DotView.h"

@implementation DotView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        // ------------- KVO -------------
//        [self addObserver:self forKeyPath:@"r" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
// 一般情况下 只走一遍
- (void)drawRect:(CGRect)rect {
    
    float centerX = rect.size.width / 2.0;
    
    // 计算兴趣点的xy坐标， 此处讲的坐标系均以dotView中心为原点的坐标系
    float xx = sinf(_radian) * _r;
    float yy = cosf(_radian) * _r;
//    NSLog(@"xx = %f, yy = %f, radian = %f, centerX = %f", xx, yy, _radian, centerX);
    
//    NSLog(@"dot degree = %f", _radian * 180.0 / M_PI);
    
    float xPoint = centerX + xx;
    float yPoint = centerX - yy;  // ?? 要不要考虑 锐角钝角 ??
    
    // 需要的圆点的半径
    float circleR = 2;
    
    
    // 取到绘图的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, CGRectMake(xPoint - circleR, yPoint- circleR, circleR * 2, circleR * 2));
    CGContextSetRGBFillColor(context, 1, 1, 1, 0.8);
    CGContextFillPath(context);
//    // 给圆画边框 ——> 减小误差
//    CGContextAddEllipseInRect(context, CGRectMake(xFrame, yFrame, 0.1, 0.1));// 将大小设为0.1是为了尽量减小误差
//    CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.8);
//    CGContextSetLineWidth(context, 4);
//    CGContextStrokePath(context);
}


@end
