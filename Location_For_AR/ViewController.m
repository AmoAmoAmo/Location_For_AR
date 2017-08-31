//
//  ViewController.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/24.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureViewController.h"


@interface ViewController ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setUI];
    
}

#pragma mark - Methods
- (void)setUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.button];
    
}

- (void)pressBtn
{
//    AVCaptureViewController *vc = [[AVCaptureViewController alloc] init];
//    [self presentViewController:vc animated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - 懒加载
-(UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeSystem];
        _button.frame = CGRectMake(100, 100, 100, 30);
        [_button setTitle:@"退出" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        _button.backgroundColor = [UIColor grayColor];

        [_button addTarget:self action:@selector(pressBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}




@end
