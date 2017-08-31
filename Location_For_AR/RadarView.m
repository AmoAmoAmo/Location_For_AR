//
//  Radar.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/24.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "RadarView.h"
#import <CoreLocation/CoreLocation.h>
#import <math.h>
#import <CoreGraphics/CoreGraphics.h>



@implementation RadarView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        
        // ------------- KVO -------------
        [self addObserver:self forKeyPath:@"trueHeading" options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"r" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    /**
     self 的 rect是整个雷达图的rect
     自定义一个用来显示雷达圆圈位置的rect——> myRect
     */
    static float margin = 15;
    float aWidth = rect.size.width - margin*2;
    CGRect myRect = CGRectMake(margin, margin, aWidth, aWidth);
    _recordRect = rect;
//    NSLog(@"rect.width = %f", rect.size.width);
    
    
    // 取到绘图的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 添加一个椭圆,根据矩形来绘制.如果矩形是正方形,则就是正圆.如果是长方形,则是椭圆
    CGContextAddEllipseInRect(context, myRect);
    // 设置填充颜色
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] set];
    // CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    
    //填充
    CGContextFillPath(context);
 
    
    
    
    
    CGFloat eachWidth = myRect.size.width/3.0;
    
    CGRect rect2 = CGRectMake(eachWidth/2.0 + margin, eachWidth/2.0 + margin, eachWidth*2, eachWidth*2);
    
    CGRect rect3 = CGRectMake(eachWidth + margin, eachWidth + margin, eachWidth, eachWidth);
    
    
    // 画圆线
    CGContextAddEllipseInRect(context, myRect);
    CGContextAddEllipseInRect(context, rect2);
    CGContextAddEllipseInRect(context, rect3);
    // 边框颜色 白
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 0.8);
    CGContextSetLineWidth(context, 1);
    CGContextStrokePath(context);
    
        
    
        
    
    
    // =========== 设置“东南西北”4个label的位置 ==============
    [self setRadarView];
    
    
}


// =========== 设置“东南西北”4个label的位置 ==============
- (void)setRadarView
{
    //label -> N,S,W,E:
    CGFloat labelWidth = 15; // label 是正方形
//    CGFloat labelHeight = 15;
    CGFloat width = RADAR_WIDTH;   // self的大小
    CGFloat height = RADAR_WIDTH;
    
    UILabel *labelN = [[UILabel alloc] init];
    // 假设是正方向时
    labelN.frame = CGRectMake((width-labelWidth)/2.0, 0, labelWidth, labelWidth);
    labelN.text = @"北";
    labelN.font = [UIFont systemFontOfSize:13];
    [self addSubview:labelN];
    
    UILabel *labelE = [[UILabel alloc] init];
    labelE.frame = CGRectMake(width-labelWidth, (height-labelWidth)/2.0, labelWidth, labelWidth);
    labelE.text = @"东";
    labelE.font = [UIFont systemFontOfSize:13];
    labelE.transform = CGAffineTransformMakeRotation(M_PI_2);// 90°
    [self addSubview:labelE];
    
    UILabel *labelS = [[UILabel alloc] init];
    labelS.frame = CGRectMake((width-labelWidth)/2.0, (height-labelWidth), labelWidth, labelWidth);
    labelS.text = @"南";
    labelS.font = [UIFont systemFontOfSize:13];
    labelS.transform = CGAffineTransformMakeRotation(M_PI);// 180°
    [self addSubview:labelS];
    
    UILabel *labelW = [[UILabel alloc] init];
    labelW.frame = CGRectMake(0, (height-labelWidth)/2.0, labelWidth, labelWidth);
    labelW.text = @"西";
    labelW.font = [UIFont systemFontOfSize:13];
    labelW.transform = CGAffineTransformMakeRotation(M_PI + M_PI_2);// 270°
    [self addSubview:labelW];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"trueHeading"];
    [self removeObserver:self forKeyPath:@"r"];
}




#pragma mark - KVO
// ================= 监听self.trueHeading，一有变化 就让雷达图旋转 ====================

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    
    if ([keyPath isEqualToString:@"r"]) {
        
        static float margin = 15;
        float aWidth = _recordRect.size.width - margin*2;
        CGRect myRect = CGRectMake(margin, margin, aWidth, aWidth);
        
        // ============ 添加兴趣点的view ==================
        _dotView = [[DotView alloc] init];
        self.dotView.frame = myRect;
        self.dotView.r = self.r;
        self.dotView.radian = self.radian;
        [self addSubview:self.dotView];
        
    }else if([keyPath isEqualToString:@"trueHeading"])
    {
        
        // ============ 更新雷达的方向 ==================
        float direction = self.trueHeading;
//        NSLog(@"direction = %f", direction);
        float angle = - (direction * M_PI / 180);
        self.transform = CGAffineTransformMakeRotation(angle);
    }
    
    
}



#pragma mark - 懒加载
//-(DotView *)dotView
//{
//    if (!_dotView) {
//        _dotView = [[DotView alloc] init];
////        _dotView.frame = self.frame;
//    }
//    return _dotView;
//}


@end






