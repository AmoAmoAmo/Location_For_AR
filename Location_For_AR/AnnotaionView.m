//
//  AnnotaionView.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/29.
//  Copyright © 2017年 Josie. All rights reserved.
//
//  注释的view，用来显示每一个兴趣点

#import "AnnotaionView.h"



@interface AnnotaionView()

@property (nonatomic, assign) BOOL  isShow;

@end

@implementation AnnotaionView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        NSLog(@"width ===== %f", frame.size.width);
        self.backgroundColor = [UIColor clearColor];
        
        
        [self.pointImageView addSubview:self.picImageView];
        [self addSubview:self.pointImageView];
        
        [self addSubview:self.distanceLabel];
        [self addSubview:self.nameLabel];
        
        [self addSubview:self.clickBtn];
        
        _isShow = NO;
        
        // 添加通知中心
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPopViewWhenTouchsBegan) name:@"dismissPopView" object:nil];
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)click
{
//    NSLog(@"----------- name = %@ ------------",self.model.name);
    
    
    
    // 点击point，出现一个显示细节的view
    float margin = 2;  // 弹性动画的幅度
    float popX = -(POP_WIDTH-ANNOTATION_WIDTH)/2.0;  //popView放大后的位置X
    if (!_isShow) { // 如果这个view没有被显示时就让它显示 , 动画：放大
        [self addSubview:self.popView];
        _isShow = YES;
        
        self.popView.frame = CGRectMake(ANNOTATION_WIDTH/2.0, 0, 0.1, 0.1);// popView做动画前的位置
        
        [UIView animateWithDuration:0.4 animations:^{
            self.popView.frame = CGRectMake(popX-margin, -POP_HEIGHT-margin, POP_WIDTH+2*margin, POP_HEIGHT+margin);

        }completion:^(BOOL finished) {
            // 弹性动画
//            [UIView animateWithDuration:0.2 animations:^{
//                self.popView.frame = CGRectMake(popX, -POP_HEIGHT, POP_WIDTH, POP_HEIGHT);
//            }];
        }];
    }else{
        // 如果已经显示，就让它消失，  动画：缩小
        [UIView animateWithDuration:0.4 animations:^{
            self.popView.frame = CGRectMake(ANNOTATION_WIDTH/2.0, 0, 1, 1);
            
        }completion:^(BOOL finished) {
            [self.popView removeFromSuperview];
            self.popView = nil;
            _isShow = NO;
        }];
  
    }
    
   
    
}

-(void)dismissPopViewWhenTouchsBegan
{
//    NSLog(@"tzzx");
    
    // 收起popView
    if (_isShow) {
        // 如果已经显示，就让它消失，  动画：缩小
        [UIView animateWithDuration:0.4 animations:^{
            self.popView.frame = CGRectMake(ANNOTATION_WIDTH/2.0, 0, 1, 1);
        }completion:^(BOOL finished) {
            [self.popView removeFromSuperview];
            self.popView = nil;
            _isShow = NO;
        }];
    }
  
}







#pragma mark - 懒加载

-(UIImageView *)pointImageView
{
    if (!_pointImageView) {
        _pointImageView = [[UIImageView alloc] init];
        
        _pointImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width);
        _pointImageView.image = [UIImage imageNamed:@"定位"];
        _pointImageView.userInteractionEnabled = YES;
    }
    return _pointImageView;
}

-(UIImageView *)picImageView
{
    if (!_picImageView) {
        _picImageView = [[UIImageView alloc] init];
        float margin = 10;
        _picImageView.frame = CGRectMake(margin, 5, self.frame.size.width - margin * 2, self.frame.size.width - margin * 2);
        _picImageView.image = [UIImage imageNamed:@"123"];
        _picImageView.clipsToBounds = YES;
        _picImageView.layer.cornerRadius = (self.frame.size.width - margin * 2) / 2.0;
        _picImageView.userInteractionEnabled = YES;
    }
    return _picImageView;
}

-(UILabel *)distanceLabel
{
    if (!_distanceLabel) {
        _distanceLabel = [[UILabel alloc] init];
        _distanceLabel.frame = CGRectMake(0, self.frame.size.height - 30, self.frame.size.width, 15);
        _distanceLabel.backgroundColor = [UIColor clearColor];
        _distanceLabel.textColor = [UIColor darkGrayColor];
        _distanceLabel.font = [UIFont systemFontOfSize:14];
        _distanceLabel.textAlignment = NSTextAlignmentCenter;
        _distanceLabel.clipsToBounds = YES;
        _distanceLabel.layer.cornerRadius = 10;
        _distanceLabel.userInteractionEnabled = YES;
    }
    return _distanceLabel;
}

-(UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.frame = CGRectMake(0, _distanceLabel.frame.origin.y + 15, self.frame.size.width, 15);
        _nameLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.clipsToBounds = YES;
        _nameLabel.layer.cornerRadius = 10;
        _nameLabel.userInteractionEnabled = YES;
    }
    return _nameLabel;
}
-(UIButton *)clickBtn
{
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _clickBtn.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _clickBtn.backgroundColor = [UIColor clearColor];
        [_clickBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickBtn;
}

-(PopView *)popView
{
    if (!_popView) {
        _popView = [[PopView alloc] initWithFrame:CGRectMake(-20, -50, POP_WIDTH, POP_HEIGHT)];
        _popView.nameLabel.text = self.model.name;
        _popView.subLabel.text = [NSString stringWithFormat:@"%f",self.model.distance];
//        _popView.backgroundColor = [UIColor blueColor];
    }
    return _popView;
}

@end










