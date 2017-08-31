//
//  BackgroundView.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/30.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "BackgroundView.h"
#import "AnnotaionView.h"




#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height
#define SENCE_HEIGHT        150    // 中间的一条 用来显示view的位置


@implementation BackgroundView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}



-(void)buildAPointViewWithDataModel:(PointModel *)model
{
    
    
    float widthA = 70;  //   annotationView的宽高
    float heightA = 70 + 30;
    float x = (SCREEN_WIDTH * model.degree) / HORIZONTAL_DEGREE;  // x为annotationView center的x
    float offsetY = 150; //  中间的一条 用来显示view的位置 往下移一点吧..
    float beginY = SCREEN_HEIGHT - (SCREEN_HEIGHT - SENCE_HEIGHT) / 2.0 + offsetY; // beginY是从下往上计算的起始位置
    // 映射到BackgroundView 的distance:  比例： SENCE_HEIGHT / 1000
    float distanceY = model.distance * SENCE_HEIGHT / 1000;
    // y坐标： y为center的y
    float y = beginY - distanceY;
    
//    NSLog(@"================================ name = %@ ===========================", model.name);
//    NSLog(@"  degree = %f     distance = %f ", model.degree, model.distance);
//    NSLog(@"  x = %f, y = %f ", x, y);
    
    
    
    
    
    
    
    AnnotaionView *annotationView = [[AnnotaionView alloc] initWithFrame:CGRectMake(x, y, widthA, heightA)];
    annotationView.distanceLabel.text = [NSString stringWithFormat:@"%.f米",model.distance];
    annotationView.nameLabel.text = [NSString stringWithFormat:@"%@", model.name];
//    annotationView.frame = CGRectMake(x, y, widthA, heightA);
    annotationView.center = CGPointMake(x, y);
    annotationView.userInteractionEnabled = YES;
    annotationView.model = model;
    
    
    // ======== 按距离的远近做一个小小的缩放吧 ========
    // 最远的缩放比例scaleD为0.8吧
    float scaleD = (0.8 - 1)/SENCE_HEIGHT * distanceY + 1;
//    NSLog(@" scale = %f" , scaleD);
    annotationView.transform = CGAffineTransformMakeScale(scaleD, scaleD);

    
    
    [self addSubview:annotationView];
    
 
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    NSLog(@"touchesBegan");
    
    // 把popView收起来(通知中心)
    [[NSNotificationCenter defaultCenter] postNotificationName:@"dismissPopView" object:nil];
    
    
}







@end







