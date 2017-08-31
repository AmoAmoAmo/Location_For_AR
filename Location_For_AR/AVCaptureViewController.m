//
//  AVCaptureViewController.m
//  Location_For_AR
//
//  Created by Josie on 2017/6/26.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "AVCaptureViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "RadarView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "ArcView.h"
#import <CoreMotion/CoreMotion.h>
#import "BigImageView.h"
//#import "AnimatedImageView.h"
#import "AnnotaionView.h"
#import "PointModel.h"
#import "BackgroundView.h"
#import "SearchViewController.h"
#import "DotView.h"
#import "ViewController.h"


#define BTN_WIDTH        25
#define BTN_HEIGHT       25
#define MARGIN           20




//#define RADAR_WIDTH      150    // 雷达图的宽度 （正方形）
#define MAP_DISTANCE     1000   // 检索范围，单位为米
// 比例尺   雷达图(半径)：实际(半径)
#define SCALE           ((150 - 15)/2.0)/ 1200.0
// 比例尺   雷达图(半径)：屏幕(高)
#define SCREEN_SCALE    ((150 - 15)/2.0)/ SCREEN_HEIGHT

@interface AVCaptureViewController ()<AVCaptureMetadataOutputObjectsDelegate,CLLocationManagerDelegate,MKMapViewDelegate, UIGestureRecognizerDelegate, SearchTextDelegate>

@property (nonatomic, strong)   AVCaptureSession    *avSession;
// 返回主界面按钮
@property (nonatomic, strong)   UIButton            *backBtn;

@property (nonatomic, strong)   RadarView           *radarView;

@property (nonatomic, strong)   ArcView             *arcView;
/** 定位管理器 */
@property (nonatomic, strong)   CLLocationManager   *locationManager;

@property (nonatomic, strong)   MKMapView           *mapView;
@property (nonatomic, assign)   CLLocationCoordinate2D myCoordinate;
// 定位后传过来的用户当前方向与真北的夹角
@property (nonatomic, assign)   CLLocationDirection     trueHeading;

@property (nonatomic, assign)   BOOL                isFirst;

@property (nonatomic, strong)   CMMotionManager     *motionManager;

@property (nonatomic, strong)   BigImageView        *bigImageView;

@property (nonatomic, assign)   float               cameraAngle; // 手机的倾斜角度

// 用来装AnimatedImageView，并控制AnimatedImageView移动的view
@property (nonatomic, strong)   BackgroundView      *leftView;
@property (nonatomic, strong)   BackgroundView      *centerView;

@property (nonatomic, strong)   UIView              *bigView;

@property (nonatomic, strong)   NSMutableArray      *dataArray;
// 装SearchViewController.view的视图
@property (nonatomic, strong)   UIView              *shadowView;
@property (nonatomic, strong)   SearchViewController    *searchVC;





@end

@implementation AVCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    [self setUI];
    NSLog(@"====");
    
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [self avSessionStart];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.motionManager stopDeviceMotionUpdates];
    [self.locationManager stopUpdatingHeading];
    
    [self.bigView removeFromSuperview];
}


#pragma mark - Methods
- (void)setUI
{
    // ************ 搜索雷达的动画 ***********
    
    
    self.dataArray = [NSMutableArray array];
    self.isFirst = YES;
    self.view.backgroundColor = [UIColor purpleColor];
    self.view.userInteractionEnabled = YES;
    
    [self.view addSubview:self.mapView];
    
    // 显示采集数据的层   预览图层，来显示照相机拍摄到的画面
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.avSession];
    previewLayer.frame = self.view.frame;
    [self.view.layer insertSublayer:previewLayer above:0];
    

    
    
    

    [self.view addSubview:self.radarView];
    [self.view addSubview:self.arcView];
    
    
    [self startLocation];
    

    
    [NSThread detachNewThreadSelector:@selector(avSessionStart) toTarget:self withObject:nil];
    
    
    
    [self.view addSubview:self.bigView];
    
    [self.view addSubview:self.backBtn]; // 返回按钮
    
    
    [self addSearchViewController];

}

-(void)avSessionStart
{
    [self.avSession startRunning];
    
    [self startMotion];
}

- (void)startLocation
{
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}



- (void)addSearchViewController
{
    [self.shadowView addSubview:self.searchVC.view];
    [self addChildViewController:self.searchVC];
    [self.view addSubview:self.shadowView];
    
    
    
    [self.searchVC didClickTextField:^{
        
        //        NSLog(@"receive-----------");
        [UIView animateWithDuration:0.4 animations:^{
            
            self.shadowView.frame = CGRectMake(0, 50, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
        }completion:^(BOOL finished) {
            // 呼出键盘。  一定要在动画结束后调用，否则会出错
            [self.searchVC.searchController.searchBar becomeFirstResponder];
        }];
        // 更新offsetY
        self.searchVC.offsetY = self.shadowView.frame.origin.y;
        
    }];
    
    
}

// table可滑动时，swipe默认不再响应 所以要打开
- (void)swipe:(UISwipeGestureRecognizer *)swipe
{
    float stopY = 0;     // 停留的位置
    float animateY = 0;  // 做弹性动画的Y
    float margin = 10;   // 动画的幅度
    float offsetY = self.shadowView.frame.origin.y; // 这是上一次Y的位置
//    NSLog(@"==== === %f == =====",self.searchVC.table.contentOffset.y);
//    NSLog(@"----------- swipe ------------");
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionDown) {
        //        NSLog(@"==== down =====");
        
        // 当vc.table滑到头 且是下滑时，让vc.table禁止滑动
        if (self.searchVC.table.contentOffset.y == 0) {
            self.searchVC.table.scrollEnabled = NO;
        }
        
        if (offsetY >= Y1 && offsetY < Y2) {
            // 停在y2的位置
            stopY = Y2;
        }else if (offsetY >= Y2 ){
            // 停在y3的位置
            stopY = Y3;
        }else{
            stopY = Y1;
        }
        animateY = stopY + margin;
    }
    if (swipe.direction == UISwipeGestureRecognizerDirectionUp) {
        //        NSLog(@"==== up =====");
        
        if (offsetY <= Y2) {
            // 停在y1的位置
            stopY = Y1;
            // 当停在Y1位置 且是上划时，让vc.table不再禁止滑动
            self.searchVC.table.scrollEnabled = YES;
        }else if (offsetY > Y2 && offsetY <= Y3 ){
            // 停在y2的位置
            stopY = Y2;
        }else{
            stopY = Y3;
        }
        animateY = stopY - margin;
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        
        self.shadowView.frame = CGRectMake(0, animateY, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 animations:^{
            self.shadowView.frame = CGRectMake(0, stopY, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height);
        }];
    }];
    // 记录shadowView在第一个视图中的位置
    self.searchVC.offsetY = stopY;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//        NSLog(@"-----------  ------------");
    // searchBar收起键盘
    UIButton *cancelBtn = [self.searchVC.searchController.searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    // 代码触发Button的点击事件
    [cancelBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}




// 获取两点经纬度间的距离
- (double)getDistanceFromCoordinates:(CLLocationCoordinate2D)fromPoint toPoint:(CLLocationCoordinate2D)toPoint
{
    /**
     半径为R(EARTH_RADIUS)的球面上两点间的最短距离(大圆弧)
     */
    
    // 赤道半径为6378.140千米
    double EARTH_RADIUS = 6378137.0;
    // DegreesToRadians(90)的意思是将90°转换成弧度pi/2，因为求余弦函数cosf的参数是弧度制
    double radLat1 = [self degreesToRadians:fromPoint.latitude];  // 经度  转换成pi的单位
    double radLat2 = [self degreesToRadians:toPoint.latitude];
    double a = radLat1 - radLat2;
    double b = (fromPoint.longitude - toPoint.longitude) *M_PI / 180.0;
    
    /**
        pow(x,y);   其作用是计算x的y次方
        sqrt        平方根
        公式来源于网络... //google maps里面实现的算法
     */
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));
    
    s = s * EARTH_RADIUS;
    s = round(s * 10000) / 10000;  // round 按照指定的小数位数进行四舍五入运算
//    NSLog(@"s = %f", s);
    

    return s;
}




// 获取两点间的夹角   .与正北方向的夹角，等下画图的时候用;
- (double)getDegreeFronCoordinates:(CLLocationCoordinate2D)fromPoint toPoint:(CLLocationCoordinate2D)toPoint
{
    float latA = [self degreesToRadians:fromPoint.latitude];  // 纬度
    float lonA = [self degreesToRadians:fromPoint.longitude];
    
    float latB = [self degreesToRadians:toPoint.latitude];
    float lonB = [self degreesToRadians:toPoint.longitude];
    
    
    double y = sin(lonB-lonA)*cos(latB);
    double x = cos(latA)*sin(latB)-sin(latA)*cos(latB)*cos(lonB-lonA);
    // atan2(double y,double x) 返回的是原点至点(x,y)的方位角，即与 x 轴的夹角
    float radian = atan2(y, x);
    float degree = [self radiansToDegrees:radian];
    
    if (degree >= 0) {  // 顺时针
        return degree;
    } else {
        return (360+degree);
    }
}





// DegreesToRadians(90)的意思是将90度转换成弧度pi/2，因为求余弦函数cosf的参数是弧度制
- (double)degreesToRadians:(double)degree   //根据角度计算弧度
{
    return degree * M_PI / 180.0;
}
- (double)radiansToDegrees: (double)radian  //根据弧度计算角度
{
    return radian * 180.0 / M_PI;
}





- (void)searchPointWithStr:(NSString *)str
{
    
    
    
    
    
    
    
    
//    NSLog(@"----- my********* = %f,      %f-------", self.myCoordinate.latitude,self.myCoordinate.longitude);
    //创建一个位置信息对象，第一个参数为经纬度，第二个为纬度检索范围，单位为米，第三个为经度检索范围，单位为米
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.myCoordinate, MAP_DISTANCE, MAP_DISTANCE);
    
    //初始化一个检索请求对象
    MKLocalSearchRequest *req = [[MKLocalSearchRequest alloc] init];
    //设置检索参数
    req.region = region;
    //兴趣点关键字
//        req.naturalLanguageQuery = @"酒店";
    req.naturalLanguageQuery = str;
    
    
    //初始化检索
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:req];
    
    //开始检索，结果返回在block中
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        
        // ----------- 清空数据源 ------------
        [self.dataArray removeAllObjects];
        for (UIView *subView in self.leftView.subviews) {
            [subView removeFromSuperview];
        }
        for (UIView *view in self.centerView.subviews) {// 清空Annotation
            [view removeFromSuperview];
        }
        for (UIView *view in self.radarView.subviews) { // 清空雷达图上的点
            if ([view isKindOfClass:[DotView class]]) {
                [view removeFromSuperview];
            }
        }
        
        
        //兴趣点节点数组
        NSArray *arr = [NSArray arrayWithArray:response.mapItems];
        
        for (int i = 0 ; i < arr.count; i++) {
            MKMapItem *item = arr[i];
            MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
            point.title = item.name;
            point.subtitle = item.phoneNumber;
            point.coordinate = item.placemark.coordinate;
            
            
            // distance - 兴趣点与用户的实际距离
            double distance = [self getDistanceFromCoordinates:self.myCoordinate toPoint:point.coordinate];
            // degree - 兴趣点与正北方向的夹角 顺时针
            double degree = [self getDegreeFronCoordinates:self.myCoordinate toPoint:point.coordinate];
//            NSLog(@"**** distance = %f,     degree = %f", distance, degree);
            
            
            // ============== 获取到兴趣点，将它映射到雷达图上 ===============
            float countR = distance * SCALE;   // 通过比例尺换算后的半径
            self.radarView.radian = [self degreesToRadians:degree];
            self.radarView.r = countR;
            
            
            
            
            // ============== 将兴趣点 映射到backgroundView上 ===============
            PointModel *model = [[PointModel alloc] init];
            model.name      = point.title;
            model.coor      = point.coordinate;
            model.distance  = distance;
            model.degree    = degree;
            model.phoneNum = point.subtitle;
            [self.dataArray addObject:model];

            [self.leftView buildAPointViewWithDataModel:model];
            [self.centerView buildAPointViewWithDataModel:model];
            
            // 清0
            item = nil;
            point = nil;
        }
    }];

}



- (void)startMotion
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
//            NSLog(@"x = %f, y = %f, z = %f ", [self radiansToDegrees:gravityX], [self radiansToDegrees:gravityY], [self radiansToDegrees:gravityZ]);
            
            double yaw = motion.attitude.yaw;     // 手机顶部转过的夹角。当手机绕着Z轴旋转时
            double pitch = motion.attitude.pitch; // 手机顶部或尾部翘起的角度. 绕着X轴倾斜时，该角度值发生变化
            double roll = motion.attitude.roll;   // 手机左侧或右侧翘起的角度。当手机绕着Y轴倾斜时
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
                _cameraAngle = zTheta;
            }
//            

            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // 在主队列更新UI
                [self updataPoint];
                
            }];
            
        }];
        
    }
}


- (void)updataPoint
{

    
    
    
    // =============== Y垂直方向 ===================
    float newY = SCREEN_HEIGHT * (_cameraAngle / 70.0 + 0.5);

    
    
    
    
    
    // =============== X水平方向 ===================
    float translationX = 0;
    if (self.trueHeading > 0 && self.trueHeading <= 180) {
        float xx = self.trueHeading - HORIZONTAL_DEGREE/2.0;
        translationX = (SCREEN_WIDTH * xx) / HORIZONTAL_DEGREE;

    }else if(self.trueHeading > 180) // 显示leftView
    {
        float xx = 360 - self.trueHeading + HORIZONTAL_DEGREE/2.0;
        translationX =  - (SCREEN_WIDTH * xx) / HORIZONTAL_DEGREE;
    }
//    NSLog(@"--- translationX = %f ---", translationX);
    
    

    
    
//    [UIView animateWithDuration:0.15 animations:^{
//             // 用animations的话，userInteractionEnabled会失去作用 手势tap会不起作用
//        self.bigView.transform =  CGAffineTransformMakeTranslation(-translationX, newY - SCREEN_HEIGHT/2.0);
//    }];
    self.bigView.transform =  CGAffineTransformMakeTranslation(-translationX, newY - SCREEN_HEIGHT/2.0);
    
    
    
    // =============== Z旋转方向 ===================
    
    
    
}


- (void)pressBtn
{
    [self.avSession stopRunning];
//    [self dismissViewControllerAnimated:NO completion:nil];
    ViewController *vc = [[ViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}





#pragma mark - SearchTextDelegate
-(void)getSearchBarText:(NSString *)searchText
{
    [self searchPointWithStr:searchText];
}





#pragma mark - UIGestureRecognizerDelegate
//                                                                                与手势同步地
/**
 返回值为NO  swipe不响应手势 table响应手势
 返回值为YES swipe、table也会响应手势, 但是把table的scrollEnabled为No就不会响应table了
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
//        NSLog(@"----------- table =  %f ------------",self.searchVC.table.contentOffset.y);
    // 触摸事件，一响应 就把searchBar的键盘收起来
    // searchBar收起键盘
    UIButton *cancelBtn = [self.searchVC.searchController.searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    // 代码触发Button的点击事件
    [cancelBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    // 当table Enabled且offsetY不为0时，让swipe响应
    if (self.searchVC.table.scrollEnabled == YES && self.searchVC.table.contentOffset.y != 0) {
        return NO;
    }
    if (self.searchVC.table.scrollEnabled == YES) {
        return YES;
    }
    return NO;
}



#pragma mark - AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 输出流代理
    NSLog(@"------------ metadataObjects = %ld --------------", metadataObjects.count);
}






#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    // 取到定位成功地点的经纬度  **** 这里定位得到的经纬度并不准确 ，但是必须先给self.myCoordinate赋给初始值，不然下面didUpdateHeading:的方法得到的值是错的
    self.myCoordinate = locations[0].coordinate;
//    NSLog(@"======= %f,    %f =======", self.myCoordinate.latitude, self.myCoordinate.longitude);
  
//    // 停止定位
    [self.locationManager stopUpdatingLocation];
//
}

-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // ======= 让雷达图跟着角度转，指向用户当前方向 ========
    /**
     *  ******** trueHeading ********
     *  表示方向的度数，0度是正北。方向被引用
     *  从设备的顶部，无论设备方向，以及方向的
     *  用户界面。
     *
     *  范围：
     *  0 - 359.9度，0是当前用户指向正北
     */
    
//    NSLog(@"------------- trueHeading = %f", newHeading.trueHeading);
    double userHeading = newHeading.trueHeading;
    self.radarView.trueHeading = userHeading;
    
    self.trueHeading = newHeading.trueHeading;
    
    
    


}











#pragma mark - MKMapViewDelegate
// mapView定位，提高准确度

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D coord = [userLocation coordinate];
    self.myCoordinate = coord;
//    NSLog(@"经度:%f,纬度:%f",coord.latitude,coord.longitude);

    [self.mapView removeFromSuperview];
    self.mapView = nil;
    
    // 给 self.myCoordinate 赋值后，再调用searchPoint
    // 让这个函数值执行一次
    if (self.isFirst) {
        self.isFirst = NO;
        [self searchPointWithStr:@"公交站"];
    }
}








// ===============================================================================================

#pragma mark - 懒加载
-(AVCaptureSession *)avSession
{
    if (!_avSession) {
        
        _avSession = [[AVCaptureSession alloc] init];
        
        // 设备对象(前后摄像头 视频)
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        // 输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        
        if ([_avSession canAddInput:input]) {
            [_avSession addInput:input];
        }
        if ([_avSession canAddOutput:output]) {
            [_avSession addOutput:output];
        }
    
    }
    return _avSession;
}



-(UIButton *)backBtn
{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(SCREEN_WIDTH - MARGIN - BTN_WIDTH, MARGIN+10, BTN_WIDTH, BTN_HEIGHT);
//        [_backBtn setTitle:@"back" forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"设置"] forState:UIControlStateNormal];
//        [_backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(pressBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}


-(RadarView *)radarView
{
    if (!_radarView) {
        _radarView = [[RadarView alloc] init];
        _radarView.frame = CGRectMake(MARGIN-12, MARGIN+10, RADAR_WIDTH, RADAR_WIDTH);
    }
    return _radarView;
}

-(ArcView *)arcView
{
    if (!_arcView) {
        _arcView = [[ArcView alloc] init];
        _arcView.frame = _radarView.frame;
    }
    return _arcView;
}

-(CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];  // CLHeading *heading
        [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

-(MKMapView *)mapView
{
    if (!_mapView) {
        _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
        [_mapView setShowsUserLocation:YES];
        _mapView.delegate = self;
        CLLocationCoordinate2D cl2d = CLLocationCoordinate2DMake(22.540396,113.951832);
        _mapView.centerCoordinate = cl2d;
        MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);// 必须用小数
        MKCoordinateRegion region = MKCoordinateRegionMake(cl2d, span);
//        self.mapView.hidden = YES;
        _mapView.alpha = 0;
        _mapView.region = region;
        _mapView.userInteractionEnabled = YES;
    }
    return _mapView;
}

-(CMMotionManager *)motionManager
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return _motionManager;
}

-(BigImageView *)bigImageView
{
    if (!_bigImageView) {
        _bigImageView = [[BigImageView alloc] init];
        CGFloat width = 100;
        _bigImageView.frame = CGRectMake(200, (SCREEN_HEIGHT-width)/2.0, width, width);
        _bigImageView.clipsToBounds = YES;
        _bigImageView.layer.cornerRadius = width/2.0;
    }
    return _bigImageView;
}



-(BackgroundView *)leftView
{
    if (!_leftView) {
        _leftView = [[BackgroundView alloc] init];
        _leftView.frame = CGRectMake(0, 0, SCREEN_WIDTH * (360/HORIZONTAL_DEGREE), SCREEN_HEIGHT);
        _leftView.backgroundColor = [UIColor clearColor];
        _leftView.userInteractionEnabled = YES;
        
    }
    return _leftView;
}

-(BackgroundView *)centerView
{
    if (!_centerView) {
        _centerView = [[BackgroundView alloc] init];
        _centerView.frame = CGRectMake(SCREEN_WIDTH * (360/HORIZONTAL_DEGREE), 0, SCREEN_WIDTH * (360/HORIZONTAL_DEGREE), SCREEN_HEIGHT);
        _centerView.backgroundColor = [UIColor clearColor];
        _centerView.userInteractionEnabled = YES;
    }
    return _centerView;
}




// 装两个BackgroundView的view
-(UIView *)bigView
{
    if (!_bigView) {
        _bigView = [[UIView alloc] init];
        _bigView.frame = CGRectMake(- SCREEN_WIDTH * (360/HORIZONTAL_DEGREE), 0, SCREEN_WIDTH * (360/HORIZONTAL_DEGREE) * 2, SCREEN_HEIGHT);
        _bigView.backgroundColor = [UIColor clearColor];
        _bigView.userInteractionEnabled = YES;
        [_bigView addSubview:self.leftView];
        [_bigView addSubview:self.centerView];
    }
    return _bigView;
}


// 装SearchViewController.view的视图, 负责：1.显示阴影    2.手势
-(UIView *)shadowView
{
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.frame = CGRectMake(0, Y3, self.view.frame.size.width, self.view.frame.size.height);
        //        _shadowView.backgroundColor = [UIColor clearColor];
        _shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
        _shadowView.layer.shadowRadius = 10;
        _shadowView.layer.shadowOffset = CGSizeMake(5, 5);
        _shadowView.layer.shadowOpacity = 0.8;                       //      不透明度
    }
    return _shadowView;
}

-(SearchViewController *)searchVC
{
    if (!_searchVC) {
        _searchVC = [[SearchViewController alloc] init];
        _searchVC.delegate = self;
        
        // -------------- 添加手势 轻扫手势  -----------
        UISwipeGestureRecognizer *swipe1 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipe1.direction = UISwipeGestureRecognizerDirectionDown ; // 设置手势方向
        //    [self.view addGestureRecognizer:swipe];
        
        swipe1.delegate = self;
        [_searchVC.table addGestureRecognizer:swipe1];
        
        UISwipeGestureRecognizer *swipe2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
        swipe2.direction = UISwipeGestureRecognizerDirectionUp; // 设置手势方向
        swipe2.delegate = self;
        [_searchVC.table addGestureRecognizer:swipe2];
    }
    return _searchVC;
}

@end









