//
//  SearchViewController.m
//  Location_For_AR
//
//  Created by Josie on 2017/7/3.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import "SearchViewController.h"






@interface SearchViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>


@property (nonatomic, strong) NSMutableArray    *dataArray; // 数据源 存放搜索历史数据

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUI];
    
    
    
}

#pragma mark - Methods
- (void)setUI
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = YES;
    
    self.view.clipsToBounds = YES;
    self.view.layer.cornerRadius = 10;
    
    [self setTableView];
}



#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 删除text时收键盘
    if (searchText.length == 0) {
        UIButton *cancelBtn = [searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
        // 代码触发Button的点击事件
        [cancelBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)didClickTextField:(DidClickTextFieldBlock)block
{
    self.didClickTextFieldBlock = block;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *textStr = searchBar.text;
//    NSLog(@"`````` %@ ```````````", textStr);
    // delegate
    if ([_delegate respondsToSelector:@selector(getSearchBarText:)]) {
        // 通知代理执行协议方法
        [_delegate getSearchBarText:textStr];
    }
    
    
    
    
    
    // 清空textfield
    searchBar.text = @"";
    
    // 插入路径的同时，要同步插入数据
    [self.dataArray insertObject:textStr atIndex:0];
    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.table insertRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationBottom];
}

/**
 每次点击searchBar的textField时，都会走这个方法
 
 *      返回false时， searchBar的textField点击没有反应
 *      默认返回true
 */
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!self.offsetY) {
        self.offsetY = Y3;
    }
    
    // 如果点击时，shadowView的y坐标 在Y2 Y3的位置，
    if (self.offsetY > Y1) {
        //        NSLog(@"----------- y = %f ------------",self.offsetY);
        // ============ 触发block =============
        if (self.didClickTextFieldBlock) {
            self.didClickTextFieldBlock();
        }
        return false;
    }
    
    
    return true;
}



#pragma mark - UITableViewDataSource
- (void)setTableView
{
    [self.view addSubview:self.table];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // 去掉选中效果
    cell.focusStyle = UITableViewCellStyleSubtitle;
    cell.imageView.image = [UIImage imageNamed:@"搜索"];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}




// ************************

// 返回段头高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20+44;
}
// 返回段头
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // UISearchbar默认高度为44，把它放在一个自定义的searchView，通过设置searchView在backgroundView中的位置，（其中3个view的背景色要都设置成一样的）让它看起来好像是searchBar的高度在改变
    // 但是这时会看到searchBar上下的两条黑线出现了，没关系通过给searchBar设置纯色(颜色与背景色一样)的背景图片就可以了
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20+44)];
    backgroundView.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 44)];
    [searchView addSubview:self.searchController.searchBar];
    //    [searchView addSubview:self.searchBar];
    
    [backgroundView addSubview:searchView];
    
    UIImageView *image = [[UIImageView alloc] init];
    image.frame = CGRectMake((SCREEN_WIDTH-40)/2.0, -2, 40, 28);
    image.image = [UIImage imageNamed:@"横线"];
    [backgroundView addSubview:image];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    lineView.alpha = 0.5;
    [backgroundView addSubview:lineView];
    
    return backgroundView;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // searchBar收起键盘
    UIButton *cancelBtn = [self.searchController.searchBar valueForKey:@"cancelButton"]; //首先取出cancelBtn
    // 代码触发Button的点击事件
    [cancelBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    
    // delegate
    if ([_delegate respondsToSelector:@selector(getSearchBarText:)]) {
        // 通知代理执行协议方法
        [_delegate getSearchBarText:[NSString stringWithFormat:@"%@",self.dataArray[indexPath.row]]];
    }
}

//滑动删除事件
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    // 1- 删数据
    [self.dataArray removeObjectAtIndex:indexPath.row];
    // 2- 删界面
    [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
}

//更改删除文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath
                                                                                                    *)indexPath
{
    return @"删除";
}






#pragma mark - 懒加载
- (UITableView *)table
{
    if (!_table) {
        _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50) style:UITableViewStylePlain];
        _table.delegate = self;
        _table.dataSource = self;
        _table.bounces = NO;
        _table.backgroundColor = [UIColor lightGrayColor];
        _table.userInteractionEnabled = YES;
        _table.scrollEnabled = NO; // 让table默认禁止滚动
        _table.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // 去掉table的尾部
        
    }
    return _table;
}

-(UISearchController *)searchController
{
    if (!_searchController) {
        _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        _searchController.searchBar.frame = CGRectMake(0, 0, 0, 50);
        _searchController.searchBar.placeholder = @"搜索";
        _searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        _searchController.searchBar.barTintColor = [UIColor whiteColor];
        // 去掉searchBar上下的两条黑线
        [_searchController.searchBar setBackgroundImage:[UIImage imageNamed:@"11"]];
        //        _searchController.searchBar.translucent = YES;
        [_searchController.searchBar sizeToFit];
        // 设置开始搜索时背景显示与否
        _searchController.dimsBackgroundDuringPresentation = NO; // 就是那一块黑色像蒙版一样的
        
        // ===== 设置取消按钮为中文字 ====
        // 方法1.
        //        [_searchController.searchBar setValue:@"取消" forKey:@"_cancelButtonText"]; // KVC访问私有属性
        // 方法2. 在plist中设置语言Localization native development region 为“China”
        
        
        _searchController.searchBar.delegate = self;
    }
    return _searchController;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"美食", @"公交站", @"hotel", @"atm", @"医院", @"3333", @"abcdd",@"11", @"222", @"3333", @"abcdd", @"222", @"3333", @"abcdd", nil];
    }
    return _dataArray;
}

@end
















