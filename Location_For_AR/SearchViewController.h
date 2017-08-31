//
//  SearchViewController.h
//  Location_For_AR
//
//  Created by Josie on 2017/7/3.
//  Copyright © 2017年 Josie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidClickTextFieldBlock)();



@protocol SearchTextDelegate <NSObject>

-(void)getSearchBarText: (NSString *)searchText;

@end



@interface SearchViewController : UIViewController

@property (nonatomic, assign)   id<SearchTextDelegate>  delegate;

@property (nonatomic, strong)   UITableView             *table;
@property (nonatomic, strong)   UISearchController      *searchController;

@property (nonatomic, assign)   CGFloat                 offsetY; // shadowView在第一个视图中的位置  就3个位置：Y1 Y2 Y3;

@property (nonatomic, copy)     DidClickTextFieldBlock  didClickTextFieldBlock;

- (void)didClickTextField: (DidClickTextFieldBlock)block;

@end
