//
//  ArcView.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/27.
//  Copyright © 2017年 Josie. All rights reserved.
//  画雷达上的扇形区

#import "ArcView.h"

@implementation ArcView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    
    static float margin = 15;
    float aWidth = rect.size.width - margin*2;
    
    
    
    // 取到绘图的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // -------------- 画扇形图 --------------
    float centerX = rect.size.width/2.0; // 圆弧的center
    float radiansArc = (M_PI / 180) * HORIZONTAL_DEGREE/2.0;// HORIZONTAL_DEGREE 转成圆弧pi // 圆弧的弧度 的一半.. Y轴的左右各一半  为了等下好计算
    
    // 画圆弧。 0°的位置在x轴
    //             （context，centerX，centerY，半径，起始角度，结束角度，顺时针还是逆时针)
    CGContextAddArc(context, centerX, centerX, aWidth/2.0, -(M_PI_2-radiansArc), -(M_PI_2+radiansArc), 1); // 逆时针, 0顺时针,1逆时针
    // ----- 画扇形的两条直线 ------
    // DegreesToRadians(90)的意思是将90度转换成弧度pi/2，因为求余弦函数cosf的参数是弧度制
    // 半径在X轴上的映射：
    float x1 = sin(radiansArc) * aWidth/2.0;
    // 半径在Y轴上的映射：
    float y1 = cos(radiansArc) * aWidth/2.0;
    //    NSLog(@"%f %f", x1, y1);
    // 第一个点的坐标: ()
    //将画笔移动到第一个点
    CGContextMoveToPoint(context, rect.size.width/2.0 - x1, rect.size.width/2.0 - y1);
    //连线到圆形的中心点
    CGContextAddLineToPoint(context,rect.size.width/2.0, rect.size.width/2.0);
    //连线到第三个点
    CGContextAddLineToPoint(context, rect.size.width/2.0 + x1, rect.size.width/2.0 - y1);
    
    // 设置填充颜色
    CGContextSetRGBFillColor(context, 1, 1, 1, 0.4);
    //填充
    CGContextFillPath(context);

    
}


@end
